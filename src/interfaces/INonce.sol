// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

interface INonce {
    /// @notice Returns the current nonce for a given address
    /// @param maker The address whose nonce is being queried
    /// @return The current nonce of the given address
    function nonce(address maker) external view returns (uint256);

    /// @notice Advances the nonce of the sender by one
    /// @dev Calls `advanceNonce(1)` internally
    function increaseNonce() external;

    /// @notice Advances the nonce of the sender by a specified amount
    /// @param amount The amount by which to advance the nonce
    function advanceNonce(uint8 amount) external;

    /// @notice Checks if a given nonce matches the expected nonce for a maker
    /// @param makerAddress The address of the maker
    /// @param makerNonce The nonce to check against
    /// @return result True if `makerAddress` has the specified nonce, otherwise false
    function nonceEquals(address makerAddress, uint256 makerNonce) external view returns (bool);
}
