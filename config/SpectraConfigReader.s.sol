// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

abstract contract SpectraConfigReader is Script {
    function getAddressFromFile(string memory filePath, string memory key) internal view returns (address) {
        string memory json = vm.readFile(string.concat(vm.projectRoot(), "/", filePath));
        string memory normalizedKey = _normalizeKey(key);
        return vm.keyExistsJson(json, normalizedKey) ? vm.parseJsonAddress(json, normalizedKey) : address(0);
    }

    function getAddressFromFile(string memory directoryPath, string memory prefix, string memory key)
        internal view returns (address)
    {
        string memory json = vm.readFile(_configPath(directoryPath, prefix));
        string memory normalizedKey = _normalizeKey(key);
        return vm.keyExistsJson(json, normalizedKey) ? vm.parseJsonAddress(json, normalizedKey) : address(0);
    }

    function getUint256FromFile(string memory filePath, string memory key) internal view returns (uint256) {
        string memory json = vm.readFile(string.concat(vm.projectRoot(), "/", filePath));
        string memory normalizedKey = _normalizeKey(key);
        return vm.keyExistsJson(json, normalizedKey) ? vm.parseJsonUint(json, normalizedKey) : 0;
    }

    function getUint256FromFile(string memory directoryPath, string memory prefix, string memory key)
        internal view returns (uint256)
    {
        string memory json = vm.readFile(_configPath(directoryPath, prefix));
        string memory normalizedKey = _normalizeKey(key);
        return vm.keyExistsJson(json, normalizedKey) ? vm.parseJsonUint(json, normalizedKey) : 0;
    }

    function getAddressArrayFromFile(string memory directoryPath, string memory prefix, string memory key)
        internal view returns (address[] memory)
    {
        string memory json = vm.readFile(_configPath(directoryPath, prefix));
        string memory normalizedKey = _normalizeKey(key);
        return vm.keyExistsJson(json, normalizedKey)
            ? abi.decode(vm.parseJson(json, normalizedKey), (address[]))
            : new address[](0);
    }

    function getBytesArrayFromFile(string memory directoryPath, string memory prefix, string memory key)
        internal view returns (bytes[] memory)
    {
        string memory json = vm.readFile(_configPath(directoryPath, prefix));
        string memory normalizedKey = _normalizeKey(key);
        return vm.keyExistsJson(json, normalizedKey)
            ? abi.decode(vm.parseJson(json, normalizedKey), (bytes[]))
            : new bytes[](0);
    }

    function getSpectraDAO() internal pure returns (address) {
        revert("Global Spectra DAO address is not configured");
    }

    function getAccessManager() internal pure returns (address) {
        revert("Global AccessManager address is not configured");
    }

    function _normalizeKey(string memory key) private pure returns (string memory) {
        return bytes(key).length > 0 && bytes(key)[0] == "." ? key : string.concat(".", key);
    }

    function _configPath(string memory directoryPath, string memory prefix) internal view returns (string memory) {
        string memory chainName = block.chainid == 1 ? "mainnet" : "local";
        require(block.chainid == 1 || block.chainid == 31337, "Unsupported chain");
        return string.concat(vm.projectRoot(), "/", directoryPath, "/", prefix, "-", chainName, ".json");
    }
}
