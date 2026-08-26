// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "src/proxy/AMBeacon.sol";
import "../src/interfaces/IRateOracleRegistry.sol";
import "roles/Roles.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the PrincipalToken Beacon
contract RateAdjustmentOracleBeaconScript is Script, SpectraConfigReader, SpectraConfigWriter {
    string private outputFilePath = "script/output/25_deployRateAdjustmentOracleBeacon";
    string private outputFilePrefix = "25_deployRateAdjustmentOracleBeacon";

    bytes4[] private selectors_beacon = new bytes4[](1);
    address private testRes;
    address private rateAdjustmentOracleInstance;
    address private initialAuthority;
    address private rateOracleRegistry;
    bool private forTest;
    string private configFilePath = "script/constants/25_deployRateAdjustmentOracleBeacon";
    string private configFilePrefix = "25_deployRateAdjustmentOracleBeacon";

    function run() public {
        vm.startBroadcast();
        selectors_beacon[0] = AMBeacon(address(0)).upgradeTo.selector;
        if (forTest) {
            address rateAdjustmentOracleBeacon = address(new AMBeacon(rateAdjustmentOracleInstance, initialAuthority));
            console.log("RateAdjusmtentOracle1BeaconUpgradeable deployed at", rateAdjustmentOracleBeacon);
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(rateAdjustmentOracleBeacon, selectors_beacon, Roles.UPGRADE_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            IRateOracleRegistry(rateOracleRegistry).setRateOracleBeacon(rateAdjustmentOracleBeacon);
            testRes = rateAdjustmentOracleBeacon;
        } else {
            rateOracleRegistry = getAddressFromFile(configFilePath, configFilePrefix, ".rateOracleRegistry");
            initialAuthority = getAddressFromFile(configFilePath, configFilePrefix, ".accessManager");
            rateAdjustmentOracleInstance = getAddressFromFile(configFilePath, ".rateAdjustmentOracleInstance");

            address rateAdjustmentOracleBeacon = address(new AMBeacon(rateAdjustmentOracleInstance, initialAuthority));
            logAddress("rateAdjustmentOracleBeacon", rateAdjustmentOracleBeacon);
            console.log("Rate Adjustment Oracle Beacon Upgradeable deployed at", rateAdjustmentOracleInstance);
            IAccessManager(initialAuthority)
                .setTargetFunctionRole(rateAdjustmentOracleBeacon, selectors_beacon, Roles.UPGRADE_ROLE);
            IRateOracleRegistry(rateOracleRegistry).setRateOracleBeacon(rateAdjustmentOracleBeacon);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _rateOracleInstance, address _registry, address _initialAuthority)
        public
        returns (address _testRes)
    {
        forTest = true;
        rateAdjustmentOracleInstance = _rateOracleInstance;
        rateOracleRegistry = _registry;
        initialAuthority = _initialAuthority;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        rateAdjustmentOracleInstance = address(0);
        rateOracleRegistry = address(0);
        initialAuthority = address(0);
    }
}
