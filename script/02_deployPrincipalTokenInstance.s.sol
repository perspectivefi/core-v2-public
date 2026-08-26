// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "src/tokens/PrincipalToken.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the PrincipalToken Instance
contract PrincipalTokenInstanceScript is Script, SpectraConfigReader, SpectraConfigWriter {
    address private testRes;
    address private ptInstance;
    address private registry;
    bool private forTest;
    string private configFilePath = "script/constants/02_deployPrincipalTokenInstance";
    string private configFilePrefix = "02_deployPrincipalTokenInstance";
    string private outputFilePath = "script/output/02_deployPrincipalTokenInstance";
    string private outputFilePrefix = "02_deployPrincipalTokenInstance";

    function run() public {
        vm.startBroadcast();
        if (forTest) {
            ptInstance = address(new PrincipalToken(registry));
            testRes = ptInstance;
        } else {
            registry = getAddressFromFile(configFilePath, configFilePrefix, ".registry");
            ptInstance = address(new PrincipalToken(registry));
            logAddress("ptImplementation", ptInstance);
        }
        console.log("PrincipalToken instance deployed at", ptInstance);
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _registry) public returns (address _testRes) {
        forTest = true;
        registry = _registry;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        registry = address(0);
    }
}
