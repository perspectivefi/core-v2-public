// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import {BaseOracle} from "src/spectra-oracles/oracles/BaseOracle.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title BaseOracleCurveLPT contract
 * @author Spectra Finance
 * @notice A base oracle implementation for Curve LP Token
 */
abstract contract BaseOracleCurveLPT is BaseOracle {
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the oracle
     * @param _pt The principal token address
     * @param _pool The pool address
     */
    function __BaseOracleCurveLPT_init(address _pt, address _pool) internal onlyInitializing {
        super.__BaseOracle_init(_pt, _pool);
    }

    /* INTERNAL
     *****************************************************************************************************************/

    /**
     * @dev Returns the LPT Price of the pool in asset or IBT
     */
    function _getQuoteAmount() internal view override returns (uint256) {
        return _LPTPrice();
    }

    function _LPTPrice() internal view virtual returns (uint256);
}
