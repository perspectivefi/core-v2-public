// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "src/interfaces/AggregatorV3Interface.sol";
import {BaseFeedCurveLPTIBTSNG} from "src/spectra-oracles/chainlinkFeeds/stableswap-ng/BaseFeedCurveLPTIBT.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title PriceFeedCurveLPTIBTSNG
 * @notice Curve PT price feed that gives the LPT price in a provided IBT/PT Curve Pool in IBT
 * @notice Designed to be used with stableswap-ng pools
 */
contract PriceFeedCurveLPTIBTSNG is BaseFeedCurveLPTIBTSNG, OwnableUpgradeable {
    string public constant description = "IBT/PT Curve Pool Oracle: LPT price in IBT";

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the oracle
     * @param _pt The principal token address
     * @param _pool The pool address
     */
    function initialize(address _pt, address _pool) external initializer {
        __BaseFeedCurveLPTIBTSNG_init(_pt, _pool);
    }
}
