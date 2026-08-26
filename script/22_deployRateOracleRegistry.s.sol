// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/RateOracleRegistry.sol";
import "src/proxy/AMTransparentUpgradeableProxy.sol";
import "src/proxy/AMProxyAdmin.sol";
import "roles/Roles.sol";
import "openzeppelin-contracts/access/manager/IAccessManager.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

contract RateOracleRegistryScript is Script, SpectraConfigReader, SpectraConfigWriter {
    string private outputFilePath = "script/output/22_deployRateOracleRegistry";
    string private outputFilePrefix = "22_deployRateOracleRegistry";

    // Selectors
    bytes4[] private selectors_proxy_admin = new bytes4[](1);
    bytes4[] private registry_methods_selectors = new bytes4[](3);

    // Addresses
    address private testRes;
    address private initialAuthority;

    // True if test deployment
    bool private forTest;
    string private configFilePath = "script/constants/22_deployRateOracleRegistry";
    string private configFilePrefix = "22_deployRateOracleRegistry";

    function run() public {
        vm.startBroadcast();

        // proxy admin selectors
        selectors_proxy_admin[0] = AMProxyAdmin(address(0)).upgradeAndCall.selector;

        // registry methods selectors
        registry_methods_selectors[0] = IRateOracleRegistry(address(0)).setRateOracleBeacon.selector;
        registry_methods_selectors[1] = IRateOracleRegistry(address(0)).addRateOracle.selector;
        registry_methods_selectors[2] = IRateOracleRegistry(address(0)).removeRateOracle.selector;

        if (forTest) {
            RateOracleRegistry rateOracleRegistryInstance = new RateOracleRegistry();
            console.log("Rate oracle registry instance deployed at", address(rateOracleRegistryInstance));
            address rateOracleRegistryProxy = address(
                new AMTransparentUpgradeableProxy(
                    address(rateOracleRegistryInstance),
                    initialAuthority,
                    abi.encodeWithSelector(RateOracleRegistry(address(0)).initialize.selector, initialAuthority)
                )
            );
            console.log("Rate Oracle registry proxy deployed at", rateOracleRegistryProxy);

            // Set the roles
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(rateOracleRegistryProxy, registry_methods_selectors, Roles.REGISTRY_ROLE);

            bytes32 adminSlot = vm.load(address(rateOracleRegistryProxy), ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(proxyAdmin, selectors_proxy_admin, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            testRes = rateOracleRegistryProxy;
        } else {
            initialAuthority = getAddressFromFile(configFilePath, configFilePrefix, ".accessManager");

            address rateOracleRegistryInstance = address(new RateOracleRegistry());
            logAddress("rateOracleRegistryImplementation", rateOracleRegistryInstance);
            console.log("Registry instance deployed at", rateOracleRegistryInstance);
            address rateOracleRegistryProxy = address(
                new AMTransparentUpgradeableProxy(
                    rateOracleRegistryInstance,
                    initialAuthority,
                    abi.encodeWithSelector(RateOracleRegistry(address(0)).initialize.selector, initialAuthority)
                )
            );
            logAddress("rateOracleRegistryProxy", rateOracleRegistryProxy);
            console.log("Rate Oracle Registry proxy deployed at", rateOracleRegistryProxy);

            // set roles
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(rateOracleRegistryProxy, registry_methods_selectors, Roles.REGISTRY_ROLE);

            bytes32 adminSlot = vm.load(address(rateOracleRegistryProxy), ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));
            logAddress("rateOracleRegistryProxyAdmin", proxyAdmin);
            console.log("Rate Oracle Registry Proxy Admin Address:", proxyAdmin);

            IAccessManager(initialAuthority)
                .setTargetFunctionRole(proxyAdmin, selectors_proxy_admin, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
        }

        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _initialAuthority) public returns (address _testRes) {
        forTest = true;
        initialAuthority = _initialAuthority;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        initialAuthority = address(0);
    }
}
