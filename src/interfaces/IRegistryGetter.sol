// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

interface IRegistryGetter {
    /// @notice Returns the registry address
    /// @return registry address
    function getRegistry() external view returns (address registry);
}
