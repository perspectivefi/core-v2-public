// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {CurveOracleLib} from "src/libraries/CurveOracleLib.sol";
import {BaseOracleCurvePT} from "src/spectra-oracles/oracles/BaseOracleCurvePT.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title BaseFeedCurvePTAssetBounded contract
 * @author Spectra Finance
 * @notice Base contract to implement the AggregatorV3Interface feed for the PT in asset upper bounded by the redemption value and lower bounded by the ZCB model
 */
abstract contract BaseFeedCurvePTAssetBounded is BaseOracleCurvePT {
    uint256 private impliedRate;

    constructor() {
        _disableInitializers();
    }

    /* INITIALIZERS
     *****************************************************************************************************************/

    /**
     * @notice Initializes the oracle
     * @param _pt The principal token address
     * @param _pool The pool address
     * @param _impliedRate The implied rate used for the linear discount model
     */
    function __BaseFeedCurvePTAssetBounded_init(address _pt, address _pool, uint256 _impliedRate)
        internal
        onlyInitializing
    {
        super.__BaseOracleCurvePT_init(_pt, _pool);
        impliedRate = _impliedRate;
    }

    /* INTERNAL
     *****************************************************************************************************************/

    function _PTPrice() internal view override returns (uint256) {
        return CurveOracleLib.getBoundedPTPrice(pool, impliedRate);
    }

    function decimals() external view override returns (uint8) {
        return IERC20Metadata(asset).decimals();
    }

    /* PUBLIC FUNCTIONS
     *****************************************************************************************************************/

    /**
     * @notice Get the implied rate
     * @return The implied rate
     */
    function getImpliedRate() external view returns (uint256) {
        return impliedRate;
    }
}
