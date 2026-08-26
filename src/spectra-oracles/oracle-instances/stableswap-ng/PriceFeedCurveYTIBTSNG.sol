// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "src/interfaces/AggregatorV3Interface.sol";
import {BaseFeedCurveYTIBTSNG} from "src/spectra-oracles/chainlinkFeeds/stableswap-ng/BaseFeedCurveYTIBT.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title PriceFeedCurveYTIBTSNG
 * @notice Curve YT price feed that gives the YT price in a provided IBT/PT Curve Pool in IBT
 * @notice Designed to be used with stableswap-ng pools
 */
contract PriceFeedCurveYTIBTSNG is BaseFeedCurveYTIBTSNG, OwnableUpgradeable {
    string public constant description = "IBT/PT Curve Pool Oracle: YT price in IBT";

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the oracle
     * @param _pt The principal token address
     * @param _pool The pool address
     */
    function initialize(address _pt, address _pool) external initializer {
        __BaseFeedCurveYTIBTSNG_init(_pt, _pool);
    }
}
