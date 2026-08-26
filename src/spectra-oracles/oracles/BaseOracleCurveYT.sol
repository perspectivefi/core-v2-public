// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {BaseOracle} from "src/spectra-oracles/oracles/BaseOracle.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title BaseOracleCurveYT contract
 * @author Spectra Finance
 * @notice A base oracle implementation for the YT
 */
abstract contract BaseOracleCurveYT is BaseOracle {
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the oracle
     * @param _pt The principal token address
     * @param _pool The pool address
     */
    function __BaseOracleCurveYT_init(address _pt, address _pool) internal onlyInitializing {
        super.__BaseOracle_init(_pt, _pool);
    }
    /* INTERNAL
     *****************************************************************************************************************/

    function _getQuoteAmount() internal view override returns (uint256) {
        return _YTPrice();
    }

    function _YTPrice() internal view virtual returns (uint256);
}
