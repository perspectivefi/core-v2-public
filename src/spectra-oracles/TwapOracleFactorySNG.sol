// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "openzeppelin-contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import "openzeppelin-contracts/proxy/beacon/BeaconProxy.sol";
import "src/interfaces/ITwapOracleFactory.sol";

import {
    PriceFeedCurvePTAssetSNG
} from "src/spectra-oracles/oracle-instances/stableswap-ng/PriceFeedCurvePTAssetSNG.sol";
import {
    PriceFeedCurvePTAssetBounded
} from "src/spectra-oracles/oracle-instances/stableswap-ng/PriceFeedCurvePTAssetBounded.sol";

/**
 * @title Twap Oracle Factory for stableswap-ng pools
 * @author Spectra Finance
 * @notice Deploys twap oracles for PT/IBT/LP tokens quoted either in IBT or underlying asset
 */
contract TwapOracleFactorySNG is AccessManagedUpgradeable, ITwapOracleFactory {
    uint256 public constant ORACLE_TYPE_COUNT = 7;
    mapping(OracleType => address) private oracleBeaconAddresses;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialAuthority, address[ORACLE_TYPE_COUNT] memory _oracleBeaconAddresses)
        external
        initializer
    {
        if (_initialAuthority == address(0)) {
            revert AddressError();
        }
        __AccessManaged_init(_initialAuthority);

        for (uint256 i = 0; i < ORACLE_TYPE_COUNT; i++) {
            if (_oracleBeaconAddresses[i] == address(0)) {
                revert BeaconAddressNotSet(OracleType(i));
            }
            oracleBeaconAddresses[OracleType(i)] = _oracleBeaconAddresses[i];
        }
    }

    function setOracleBeaconAddress(OracleType _oracleType, address _beaconAddress) external restricted {
        if (_beaconAddress == address(0)) {
            revert AddressError();
        }
        emit OracleBeaconChanged(_oracleType, oracleBeaconAddresses[_oracleType], _beaconAddress);
        oracleBeaconAddresses[_oracleType] = _beaconAddress;
    }

    function deployOracle(address _pt, address _pool, uint256 _impliedRate, OracleType _oracleType)
        external
        returns (address oracleAddress)
    {
        if (_pt == address(0)) {
            revert AddressError();
        }
        if (_pool == address(0)) {
            revert AddressError();
        }

        address beaconAddress = oracleBeaconAddresses[_oracleType];
        if (beaconAddress == address(0)) {
            revert BeaconAddressNotSet(_oracleType);
        }

        bytes memory initData = (OracleType.PTUNDHYBRID == _oracleType)
            ? abi.encodeWithSelector(
                PriceFeedCurvePTAssetBounded(address(0)).initialize.selector, _pt, _pool, _impliedRate
            )
            : abi.encodeWithSelector(_getInitializeSelector(), _pt, _pool);

        oracleAddress = address(new BeaconProxy(beaconAddress, initData));
        emit OracleDeployed(oracleAddress);
    }

    /**
     * @notice Returns the initialize selector for an oracle type. The selector is the same for all oracle types.
     * @return The initialize selector
     */
    function _getInitializeSelector() internal pure returns (bytes4) {
        return PriceFeedCurvePTAssetSNG(address(0)).initialize.selector;
    }
}
