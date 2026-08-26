// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/Registry.sol";
import "src/proxy/AMTransparentUpgradeableProxy.sol";
import {AMProxyAdmin} from "src/proxy/AMProxyAdmin.sol";
import "roles/Roles.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the Registry Instance and Proxy
contract RegistryScript is Script, SpectraConfigReader, SpectraConfigWriter {
    bytes4[] private selectors_proxy_admin = new bytes4[](1);
    bytes4[] private fee_methods_selectors = new bytes4[](5);
    bytes4[] private registry_methods_selectors = new bytes4[](7);
    address private testRes;
    uint256 private tokenizationFee;
    uint256 private yieldFee;
    uint256 private ptFlashLoanFee;
    address private feeCollector;
    address private initialAuthority;
    bool private forTest;
    string private configFilePath = "script/constants/01_deployRegistry";
    string private configFilePrefix = "01_deployRegistry";
    string private outputFilePath = "script/output/01_deployRegistry";
    string private outputFilePrefix = "01_deployRegistry";

    function run() public {
        vm.startBroadcast();
        selectors_proxy_admin[0] = AMProxyAdmin(address(0)).upgradeAndCall.selector;
        fee_methods_selectors[0] = IRegistry(address(0)).setTokenizationFee.selector;
        fee_methods_selectors[1] = IRegistry(address(0)).setYieldFee.selector;
        fee_methods_selectors[2] = IRegistry(address(0)).setPTFlashLoanFee.selector;
        fee_methods_selectors[3] = IRegistry(address(0)).setFeeCollector.selector;
        fee_methods_selectors[4] = IRegistry(address(0)).reduceFee.selector;

        registry_methods_selectors[0] = IRegistry(address(0)).setFactory.selector;
        registry_methods_selectors[1] = IRegistry(address(0)).setPTBeacon.selector;
        registry_methods_selectors[2] = IRegistry(address(0)).setYTBeacon.selector;
        registry_methods_selectors[3] = IRegistry(address(0)).removePT.selector;
        registry_methods_selectors[4] = IRegistry(address(0)).addPT.selector;
        registry_methods_selectors[5] = IRegistry(address(0)).setRouter.selector;
        registry_methods_selectors[6] = IRegistry(address(0)).setRouterUtil.selector;
        if (forTest) {
            Registry registryInstance = new Registry();
            console.log("Registry instance deployed at", address(registryInstance));
            address registryProxy = address(
                new AMTransparentUpgradeableProxy(
                    address(registryInstance),
                    initialAuthority,
                    abi.encodeWithSelector(Registry(address(0)).initialize.selector, initialAuthority)
                )
            );

            console.log("Registry proxy deployed at", registryProxy);
            IRegistry(registryProxy).setTokenizationFee(tokenizationFee);
            IRegistry(registryProxy).setYieldFee(yieldFee);
            IRegistry(registryProxy).setPTFlashLoanFee(ptFlashLoanFee);
            IRegistry(registryProxy).setFeeCollector(feeCollector);

            IAccessManager(initialAuthority)
                .setTargetFunctionRole(registryProxy, fee_methods_selectors, Roles.FEE_SETTER_ROLE);

            IAccessManager(initialAuthority)
                .setTargetFunctionRole(registryProxy, registry_methods_selectors, Roles.REGISTRY_ROLE);

            bytes32 adminSlot = vm.load(address(registryProxy), ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(proxyAdmin, selectors_proxy_admin, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            testRes = registryProxy;
        } else {
            initialAuthority = getAddressFromFile(configFilePath, configFilePrefix, ".accessManager");
            tokenizationFee = getUint256FromFile(configFilePath, configFilePrefix, ".tokenizationFee");
            yieldFee = getUint256FromFile(configFilePath, configFilePrefix, ".yieldFee");
            ptFlashLoanFee = getUint256FromFile(configFilePath, configFilePrefix, ".ptFlashLoanFee");
            feeCollector = getAddressFromFile(configFilePath, configFilePrefix, ".feeCollector");

            address registryInstance = address(new Registry());
            logAddress("registryImplementation", registryInstance);
            console.log("Registry instance deployed at", registryInstance);
            address registryProxy = address(
                new AMTransparentUpgradeableProxy(
                    registryInstance,
                    initialAuthority,
                    abi.encodeWithSelector(Registry(address(0)).initialize.selector, initialAuthority)
                )
            );
            logAddress("registryProxy", registryProxy);
            console.log("Registry proxy deployed at", registryProxy);
            IRegistry(registryProxy).setTokenizationFee(tokenizationFee);
            IRegistry(registryProxy).setYieldFee(yieldFee);
            IRegistry(registryProxy).setPTFlashLoanFee(ptFlashLoanFee);
            IRegistry(registryProxy).setFeeCollector(feeCollector);

            IAccessManager(initialAuthority)
                .setTargetFunctionRole(registryProxy, fee_methods_selectors, Roles.FEE_SETTER_ROLE);

            IAccessManager(initialAuthority)
                .setTargetFunctionRole(registryProxy, registry_methods_selectors, Roles.REGISTRY_ROLE);

            bytes32 adminSlot = vm.load(address(registryProxy), ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));
            logAddress("registryProxyAdmin", proxyAdmin);
            console.log("Registry Proxy Admin Address:", address(proxyAdmin));
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(proxyAdmin, selectors_proxy_admin, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(
        uint256 _tokenizationFee,
        uint256 _yieldFee,
        uint256 _ptFlashLoanFee,
        address _feeCollector,
        address _initialAuthority
    ) public returns (address _testRes) {
        forTest = true;
        tokenizationFee = _tokenizationFee;
        yieldFee = _yieldFee;
        ptFlashLoanFee = _ptFlashLoanFee;
        feeCollector = _feeCollector;
        initialAuthority = _initialAuthority;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        tokenizationFee = 0;
        yieldFee = 0;
        ptFlashLoanFee = 0;
        feeCollector = address(0);
        initialAuthority = address(0);
    }
}
