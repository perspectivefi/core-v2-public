// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "src/interfaces/AggregatorV3Interface.sol";
import {BaseFeedCurvePTAssetSNG} from "src/spectra-oracles/chainlinkFeeds/stableswap-ng/BaseFeedCurvePTAsset.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title PriceFeedCurvePTAssetSNG
 * @notice Curve PT price feed that gives the PT price in a provided IBT/PT Curve Pool in asset
 * @notice Designed to be used with stableswap-ng pools
 */
contract PriceFeedCurvePTAssetSNG is BaseFeedCurvePTAssetSNG, OwnableUpgradeable {
    string public constant description = "IBT/PT Curve Pool Oracle: PT price in asset";

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the oracle
     * @param _pt The principal token address
     * @param _pool The pool address
     */
    function initialize(address _pt, address _pool) external initializer {
        __BaseFeedCurvePTAssetSNG_init(_pt, _pool);
    }
}
