// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import "../interfaces/IRateAdjustmentOracle.sol";
import "../interfaces/IPrincipalToken.sol";
import "../interfaces/IStableSwapNG.sol";
import "../libraries/RateAdjustmentMath.sol";
import "../libraries/RayMath.sol";
import "openzeppelin-contracts/utils/math/Math.sol";
import "openzeppelin-contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC4626} from "openzeppelin-contracts/interfaces/IERC4626.sol";

contract RateAdjustmentOracle is AccessManagedUpgradeable, IRateAdjustmentOracle {
    using Math for uint256;
    using RayMath for uint256;

    // state
    address private curvePoolAddress;
    uint256 private startTime;
    uint256 private expiry;
    uint256 private initialPrice;

    // constants
    uint64 private constant POST_INIT_ID = 2;
    uint256 private constant ORACLE_DECIMALS = 18;

    /* EVENTS
     *****************************************************************************************************************/

    event InitialPriceChanged(uint256 indexed _previousInitialPrice, uint256 indexed _newInitialPrice);

    /* CONSTRUCTOR
     *****************************************************************************************************************/
    constructor() {
        _disableInitializers();
    }

    /* INITIALIZERS
     *****************************************************************************************************************/

    /**
     * @dev See {IRateAdjustmentOracle-initialize}.
     */
    function initialize(address _initialAuthority) external initializer {
        if (_initialAuthority == address(0)) {
            revert AddressError();
        }
        __AccessManaged_init(_initialAuthority);
    }

    /**
     * @dev See {IRateAdjustmentOracle-post_initialize}.
     */
    function post_initialize(
        uint256 _initialTimestamp,
        uint256 _expiry,
        uint256 _initialPrice,
        address _curvePoolAddress
    ) external override restricted reinitializer(POST_INIT_ID) {
        if (_curvePoolAddress == address(0)) {
            revert AddressError();
        }

        curvePoolAddress = _curvePoolAddress;
        startTime = _initialTimestamp;
        expiry = _expiry;
        initialPrice = _initialPrice;
    }

    /* FUNCTIONS
     *****************************************************************************************************************/

    /**
     * @dev See {IRateAdjustmentOracle-value}.
     */
    function value() external view returns (uint256 rate) {
        if (curvePoolAddress == address(0)) {
            revert AddressesNotSet();
        }
        // Get the future PT value in 18 decimals
        address ptAddress = IStableSwapNG(curvePoolAddress).coins(1);
        address ibtAddress = IStableSwapNG(curvePoolAddress).coins(0);
        address underlyingAddress = IERC4626(ibtAddress).asset();

        uint8 ibtDecimals = IERC20Metadata(ibtAddress).decimals();
        uint8 underlyingDecimals = IERC20Metadata(underlyingAddress).decimals();

        uint256 ibtUnit = 10 ** ibtDecimals;
        uint256 futurePTValue =
            IPrincipalToken(ptAddress).convertToUnderlying(ibtUnit) * 10 ** (ORACLE_DECIMALS - underlyingDecimals);

        // @dev: Curve IERC4626 oracle uses convertToAssets, which is imprecise, hence we correct it here with previewRedeem
        uint256 adjustedFuturePTValue = (futurePTValue * IERC4626(ibtAddress).convertToAssets(ibtUnit))
            / IERC4626(ibtAddress).previewRedeem(ibtUnit);

        // Get the adjustment factor
        rate = RateAdjustmentMath.getAdjustmentFactor(
            startTime, block.timestamp, expiry, initialPrice, adjustedFuturePTValue
        );
    }

    /**
     * @dev See {IRateAdjustmentOracle-setInitialPrice}.
     */
    function setInitialPrice(uint256 _newInitialPrice) external override restricted {
        emit InitialPriceChanged(initialPrice, _newInitialPrice);
        initialPrice = _newInitialPrice;
    }

    /**
     * @dev See {IRateAdjustmentOracle-getInitialPrice}.
     */
    function getInitialPrice() external view returns (uint256) {
        return initialPrice;
    }

    /**
     * @dev See {IRateAdjustmentOracle-getCurvePoolAddress}.
     */
    function getCurvePoolAddress() external view returns (address) {
        return curvePoolAddress;
    }

    /**
     * @dev See {IRateAdjustmentOracle-getStartTime}.
     */
    function getStartTime() external view returns (uint256) {
        return startTime;
    }

    /**
     * @dev See {IRateAdjustmentOracle-getExpiry}.
     */
    function getExpiry() external view returns (uint256) {
        return expiry;
    }
}
