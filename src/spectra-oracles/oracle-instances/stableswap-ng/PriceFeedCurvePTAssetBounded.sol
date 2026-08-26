// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {
    BaseFeedCurvePTAssetBounded
} from "src/spectra-oracles/chainlinkFeeds/stableswap-ng/BaseFeedCurvePTAssetBounded.sol";

/**
 * @title PriceFeedCurvePTAssetBounded contract
 * @author Spectra Finance
 * @notice Price feed for the PT in asset upper bounded by the redemption value and lower bounded by the ZCB model
 *
 */

contract PriceFeedCurvePTAssetBounded is BaseFeedCurvePTAssetBounded {
    string public constant description =
        "IBT/PT Curve Pool Oracle: TWAP PT price in asset. Lower bounded by the ZCB model according to _impliedRateand upper bounded by the redemption value";

    constructor() BaseFeedCurvePTAssetBounded() {}

    function initialize(address _pt, address _pool, uint256 _impliedRate) external initializer {
        super.__BaseFeedCurvePTAssetBounded_init(_pt, _pool, _impliedRate);
    }
}
