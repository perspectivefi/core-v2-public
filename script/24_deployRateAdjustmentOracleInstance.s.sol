// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/amm/RateAdjustmentOracle.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the Rate Adjustment Oracle  Instance
contract RateAdjustmentOracleInstanceScript is Script, SpectraConfigWriter {
    string private outputFilePath = "script/output/24_deployRateAdjustmentOracleInstance";
    string private outputFilePrefix = "24_deployRateAdjustmentOracleInstance";

    address private testRes;
    address private rateAdjustmentOracleInstance;
    bool private forTest;

    function run() public {
        vm.startBroadcast();
        if (forTest) {
            rateAdjustmentOracleInstance = address(new RateAdjustmentOracle());
            testRes = rateAdjustmentOracleInstance;
        } else {
            rateAdjustmentOracleInstance = address(new RateAdjustmentOracle());
        }
        logAddress("rateAdjustmentOracleImplementation", rateAdjustmentOracleInstance);
        console.log("Rate adjustment oracle instance deployed at", rateAdjustmentOracleInstance);
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest() public returns (address _testRes) {
        forTest = true;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
    }
}
