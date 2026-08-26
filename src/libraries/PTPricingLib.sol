// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {LogExpMath} from "./LogExpMath.sol";

/**
 * @title PTPricingLib library
 * @author Spectra Finance
 * @notice Provides miscellaneous utils for computations related to Principal Token pricing.
 */
library PTPricingLib {
    uint256 public constant UNIT = 10 ** 18;
    uint256 public constant YEAR = 365 days;

    /**
     * @notice Computes the price of the Principal Token in the ZCB model
     * @param futurePTValue The redemption value of the Principal Token
     * @param impliedRate The implied rate expressed in 18 decimals. For example 30% is expressed as 3e17
     * @param currentTimestamp The current timestamp
     * @param maturity The maturity timestamp
     */
    function getPTPriceZCBModel(uint256 futurePTValue, uint256 impliedRate, uint256 currentTimestamp, uint256 maturity)
        internal
        view
        returns (uint256)
    {
        if (currentTimestamp >= maturity) {
            return futurePTValue;
        }
        uint256 timeLeft = maturity - currentTimestamp;
        int256 t = int256((timeLeft * UNIT) / YEAR);
        int256 unitInt = int256(UNIT);
        int256 base = unitInt + int256(impliedRate);
        int256 ratePerSecond = LogExpMath.ln(base);
        int256 denominator = LogExpMath.exp((ratePerSecond * t) / unitInt);
        int256 presentValue = (int256(futurePTValue) * unitInt) / denominator;
        return uint256(presentValue);
    }
}
