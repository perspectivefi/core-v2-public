// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "src/proxy/AMBeacon.sol";
import "../src/interfaces/IRegistry.sol";
import "roles/Roles.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the PrincipalToken Beacon
contract PrincipalTokenBeaconScript is Script, SpectraConfigReader, SpectraConfigWriter {
    bytes4[] private selectors_beacon = new bytes4[](1);
    address private testRes;
    address private ptInstance;
    address private initialAuthority;
    address private registry;
    bool private forTest;
    string private configFilePath = "script/constants/04_deployPrincipalTokenBeacon";
    string private configFilePrefix = "04_deployPrincipalTokenBeacon";
    string private outputFilePath = "script/output/04_deployPrincipalTokenBeacon";
    string private outputFilePrefix = "04_deployPrincipalTokenBeacon";

    function run() public {
        vm.startBroadcast();
        selectors_beacon[0] = AMBeacon(address(0)).upgradeTo.selector;
        if (forTest) {
            address ptBeacon = address(new AMBeacon(ptInstance, initialAuthority));
            console.log("PrincipalTokenBeaconUpgradeable deployed at", ptBeacon);
            IAccessManager(initialAuthority).setTargetFunctionRole(ptBeacon, selectors_beacon, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            IRegistry(registry).setPTBeacon(ptBeacon);
            testRes = ptBeacon;
        } else {
            registry = getAddressFromFile(configFilePath, configFilePrefix, ".registry");
            initialAuthority = getAddressFromFile(configFilePath, configFilePrefix, ".accessManager");
            ptInstance = getAddressFromFile(configFilePath, configFilePrefix, ".ptInstance");

            address ptBeacon = address(new AMBeacon(ptInstance, initialAuthority));
            logAddress("ptBeacon", ptBeacon);
            console.log("Principal Token Beacon Upgradeable deployed at", ptBeacon);
            IAccessManager(initialAuthority).setTargetFunctionRole(ptBeacon, selectors_beacon, Roles.UPGRADE_ROLE);
            IRegistry(registry).setPTBeacon(ptBeacon);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _ptInstance, address _registry, address _initialAuthority)
        public
        returns (address _testRes)
    {
        forTest = true;
        ptInstance = _ptInstance;
        registry = _registry;
        initialAuthority = _initialAuthority;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        ptInstance = address(0);
        registry = address(0);
        initialAuthority = address(0);
    }
}
