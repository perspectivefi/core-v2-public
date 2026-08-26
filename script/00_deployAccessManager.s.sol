// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/access/manager/AccessManager.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the Factory Instance and Proxy
contract AccessManagerDeploymentScript is Script, SpectraConfigReader, SpectraConfigWriter {
    address private testRes;
    address private initialSuperAdmin;
    bool private forTest;
    string private outputFilePath = "script/output/00_deployAccessManager";
    string private outputFilePrefix = "00_deployAccessManager";

    function run() public {
        vm.startBroadcast();
        if (forTest) {
            address accessManagerInstance = address(new AccessManager(initialSuperAdmin));
            console.log(
                "AccessManager instance deployed at", accessManagerInstance, "with super admin", initialSuperAdmin
            );
            testRes = accessManagerInstance;
        } else {
            initialSuperAdmin = getSpectraDAO();

            address accessManagerInstance = address(new AccessManager(initialSuperAdmin));
            logAddress("accessManager", accessManagerInstance);
            console.log(
                "AccessManager instance deployed at", accessManagerInstance, "with super admin", initialSuperAdmin
            );
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _initialSuperAdmin) public returns (address _testRes) {
        forTest = true;
        initialSuperAdmin = _initialSuperAdmin;
        run();
        _testRes = testRes;
        forTest = false;
        testRes = address(0);
        initialSuperAdmin = address(0);
    }
}
