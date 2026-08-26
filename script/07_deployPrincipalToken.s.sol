// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/tokens/PrincipalToken.sol";
import "../src/factory/Factory.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the PrincipalToken Proxy
contract PrincipalTokenScript is Script, SpectraConfigReader, SpectraConfigWriter {
    address private testRes;
    address private factory;
    address private ibt;
    uint256 private duration;
    bool private forTest;
    string private configFilePath = "script/constants/07_deployPrincipalToken";
    string private configFilePrefix = "07_deployPrincipalToken";
    string private outputFilePath = "script/output/07_deployPrincipalToken";
    string private outputFilePrefix = "07_deployPrincipalToken";

    function run() public {
        vm.startBroadcast();

        if (forTest) {
            // deploy principalToken
            address principalToken = IFactory(factory).deployPT(ibt, duration);
            console.log("PrincipalToken Beacon Proxy deployed at", address(principalToken));
            console.log("YT Beacon Proxy deployed at ", IPrincipalToken(principalToken).getYT());
            testRes = address(principalToken);
        } else {
            ibt = getAddressFromFile(configFilePath, configFilePrefix, ".ibt");
            duration = getUint256FromFile(configFilePath, configFilePrefix, ".duration");
            factory = getAddressFromFile(configFilePath, configFilePrefix, ".factory");

            // deploy principalToken
            address principalToken = IFactory(factory).deployPT(ibt, duration);
            logAddress("principalToken", principalToken);
            console.log("PrincipalToken Beacon Proxy deployed at", principalToken);
            console.log("YT Beacon Proxy deployed at ", IPrincipalToken(principalToken).getYT());
            saveOutput(outputFilePath, outputFilePrefix);
        }
        vm.stopBroadcast();
    }

    function deployForTest(address _factoryAddr, address _ibt, uint256 _duration) public returns (address _testRes) {
        forTest = true;
        factory = _factoryAddr;
        ibt = _ibt;
        duration = _duration;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        factory = address(0);
        ibt = address(0);
        duration = 0;
    }
}
