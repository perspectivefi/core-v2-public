// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/interfaces/IRegistry.sol";
import "src/proxy/AMBeacon.sol";
import "roles/Roles.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the YT Beacon
contract YTBeaconScript is Script, SpectraConfigReader, SpectraConfigWriter {
    bytes4[] private selectors_beacon = new bytes4[](1);
    address private testRes;
    address private ytInstance;
    address private initialAuthority;
    address private registry;
    bool private forTest;
    string private configFilePath = "script/constants/05_deployYTBeacon";
    string private configFilePrefix = "05_deployYTBeacon";
    string private outputFilePath = "script/output/05_deployYTBeacon";
    string private outputFilePrefix = "05_deployYTBeacon";

    function run() public {
        vm.startBroadcast();
        selectors_beacon[0] = AMBeacon(address(0)).upgradeTo.selector;
        if (forTest) {
            address ytBeacon = address(new AMBeacon(ytInstance, initialAuthority));
            console.log("YTBeaconUpgradeable deployed at", ytBeacon);
            IAccessManager(initialAuthority).setTargetFunctionRole(ytBeacon, selectors_beacon, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            IRegistry(registry).setYTBeacon(ytBeacon);
            testRes = ytBeacon;
        } else {
            initialAuthority = getAddressFromFile(configFilePath, configFilePrefix, ".accessManager");
            ytInstance = getAddressFromFile(configFilePath, configFilePrefix, ".ytInstance");
            registry = getAddressFromFile(configFilePath, configFilePrefix, ".registry");

            address ytBeacon = address(new AMBeacon(ytInstance, initialAuthority));
            logAddress("ytBeacon", ytBeacon);
            console.log("YTBeaconUpgradeable deployed at", ytBeacon);
            IAccessManager(initialAuthority).setTargetFunctionRole(ytBeacon, selectors_beacon, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            IRegistry(registry).setYTBeacon(ytBeacon);
            testRes = ytBeacon;
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _ytInstance, address _registry, address _initialAuthority)
        public
        returns (address _testRes)
    {
        forTest = true;
        ytInstance = _ytInstance;
        registry = _registry;
        initialAuthority = _initialAuthority;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        ytInstance = address(0);
        registry = address(0);
        initialAuthority = address(0);
    }
}
