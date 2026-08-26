pragma solidity ^0.8.20;

/**
 * @title ITwapOracleFactory
 * @author Spectra Finance
 * @notice Interface of the Spectra TWAP oracle factories.
 */
interface ITwapOracleFactory {
    /**
     * @notice The types of oracles that can be deployed
     */
    enum OracleType {
        PTIBT,
        PTUND,
        YTIBT,
        YTUND,
        LPIBT,
        LPUND,
        PTUNDHYBRID
    }

    /**
     * Errors
     */
    error AddressError();
    error BeaconAddressNotSet(OracleType oracleType);

    /**
     * Events
     */
    event OracleDeployed(address indexed oracleAddress);
    event OracleBeaconChanged(
        OracleType indexed oracleType, address indexed oldBeaconAddress, address indexed newBeaconAddress
    );

    /**
     * @notice Initializes the oracle factory. First function called after deployment.
     * @param _initialAuthority The initial authority of the oracle factory
     * @param _oracleBeaconAddresses The addresses of the oracle beacons
     */
    function initialize(address _initialAuthority, address[7] memory _oracleBeaconAddresses) external;

    /**
     * @notice Sets the address of the oracle beacon for a given oracle type
     * @param _oracleType The type of oracle
     * @param _oracleBeaconAddress The address of the oracle beacon
     */
    function setOracleBeaconAddress(OracleType _oracleType, address _oracleBeaconAddress) external;

    /**
     * @notice Deploys an oracle for a given principal token, pool, and oracle type
     * @param _pt The address of the principal token
     * @param _pool The address of the pool
     * @param _oracleType The type of oracle
     * @return oracleAddress The address of the deployed oracle
     */
    function deployOracle(address _pt, address _pool, uint256 _impliedRate, OracleType _oracleType)
        external
        returns (address oracleAddress);
}
