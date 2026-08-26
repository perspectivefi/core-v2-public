// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/factory/Factory.sol";

import "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy a Curve Pool
contract CurvePoolScript is Script, SpectraConfigReader, SpectraConfigWriter {
    address private testRes;
    address private factory;
    address private pt;
    address private ibt;
    IFactory.CurvePoolParams private curvePoolParams;
    uint256 private initialLiquidityInIBT;
    uint256 private minPTShares;
    bool private forTest;
    string private configFilePath = "script/constants/08_deployCurvePool";
    string private configFilePrefix = "08_deployCurvePool";
    string private outputFilePath = "script/output/08_deployCurvePool";
    string private outputFilePrefix = "08_deployCurvePool";

    function run() public {
        vm.startBroadcast();
        if (forTest) {
            IERC20(ibt).approve(factory, initialLiquidityInIBT);
            address curvePool =
                IFactory(factory).deployCurvePool(pt, curvePoolParams, initialLiquidityInIBT, minPTShares);

            console.log("Curve pool deployed deployed at", curvePool);
            testRes = curvePool;
        } else {
            IFactory.CurvePoolParams memory data;

            factory = getAddressFromFile(configFilePath, configFilePrefix, ".factory");
            ibt = getAddressFromFile(configFilePath, configFilePrefix, ".ibt");
            pt = getAddressFromFile(configFilePath, configFilePrefix, ".ptBeaconProxy");
            data.A = getUint256FromFile(configFilePath, configFilePrefix, ".curvePoolParams.A");
            if (data.A == 0) {
                revert("Curve Pool A cannot be 0");
            }

            data.gamma = getUint256FromFile(configFilePath, ".curvePoolParams.gamma");
            if (data.gamma == 0) {
                revert("Curve Pool gamma cannot be 0");
            }

            data.mid_fee = getUint256FromFile(configFilePath, ".curvePoolParams.mid_fee");
            if (data.mid_fee == 0) {
                revert("Curve Pool mid_fee cannot be 0");
            }

            data.out_fee = getUint256FromFile(configFilePath, ".curvePoolParams.out_fee");
            if (data.out_fee == 0) {
                revert("Curve Pool out_fee cannot be 0");
            }

            data.fee_gamma = getUint256FromFile(configFilePath, ".curvePoolParams.fee_gamma");
            if (data.fee_gamma == 0) {
                revert("Curve Pool fee_gamma cannot be 0");
            }

            data.allowed_extra_profit = getUint256FromFile(configFilePath, ".curvePoolParams.allowed_extra_profit");
            if (data.allowed_extra_profit == 0) {
                revert("Curve Pool allowed_extra_profit cannot be 0");
            }

            data.adjustment_step = getUint256FromFile(configFilePath, ".curvePoolParams.adjustment_step");
            if (data.adjustment_step == 0) {
                revert("Curve Pool adjustment_step cannot be 0");
            }

            data.ma_exp_time = getUint256FromFile(configFilePath, ".curvePoolParams.ma_exp_time");
            if (data.ma_exp_time == 0) {
                revert("Curve Pool ma_exp_time cannot be 0");
            }

            data.initial_price = getUint256FromFile(configFilePath, ".curvePoolParams.initial_price");
            if (data.initial_price == 0) {
                revert("Curve Pool initial_price cannot be 0");
            }

            initialLiquidityInIBT = getUint256FromFile(configFilePath, ".initialLiquidityInIBT");

            minPTShares = getUint256FromFile(configFilePath, ".minPTShares");

            IERC20(ibt).approve(factory, initialLiquidityInIBT);
            address curvePool = IFactory(factory).deployCurvePool(pt, data, initialLiquidityInIBT, minPTShares);
            logAddress("curvePool", curvePool);
            console.log("Curve pool deployed deployed at", curvePool);
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(
        address _factory,
        address _ibt,
        address _pt,
        IFactory.CurvePoolParams memory _curvePoolData,
        uint256 _initialLiquidityInIBT,
        uint256 _minPTShares
    ) public returns (address _testRes) {
        forTest = true;
        factory = _factory;
        ibt = _ibt;
        pt = _pt;
        curvePoolParams = _curvePoolData;
        initialLiquidityInIBT = _initialLiquidityInIBT;
        minPTShares = _minPTShares;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        factory = address(0);
        ibt = address(0);
        pt = address(0);
        curvePoolParams = IFactory.CurvePoolParams(0, 0, 0, 0, 0, 0, 0, 0, 0);
        initialLiquidityInIBT = 0;
        minPTShares = 0;
    }
}
