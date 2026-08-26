// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

abstract contract SpectraConfigWriter is Script {
    struct OutputAddress { string label; address value; }
    struct OutputAddressArray { string label; address[] values; }
    struct OutputBytesArray { string label; bytes[] values; }

    OutputAddress[] private outputAddresses;
    OutputAddressArray[] private outputAddressArrays;
    OutputBytesArray[] private outputBytesArrays;

    function logAddress(string memory label, address value) internal { outputAddresses.push(OutputAddress(label, value)); }
    function logAddressArray(string memory label, address[] memory values) internal { outputAddressArrays.push(OutputAddressArray(label, values)); }
    function logBytesArray(string memory label, bytes[] memory values) internal { outputBytesArrays.push(OutputBytesArray(label, values)); }

    function saveOutput(string memory directoryPath, string memory prefix) internal {
        string memory objectKey = "deployment";
        string memory json;
        for (uint256 i; i < outputAddresses.length; ++i) {
            json = vm.serializeAddress(objectKey, outputAddresses[i].label, outputAddresses[i].value);
        }
        for (uint256 i; i < outputAddressArrays.length; ++i) {
            json = vm.serializeAddress(objectKey, outputAddressArrays[i].label, outputAddressArrays[i].values);
        }
        for (uint256 i; i < outputBytesArrays.length; ++i) {
            json = vm.serializeBytes(objectKey, outputBytesArrays[i].label, outputBytesArrays[i].values);
        }
        string memory chainName = block.chainid == 1 ? "mainnet" : "local";
        require(block.chainid == 1 || block.chainid == 31337, "Unsupported chain");
        vm.writeJson(json, string.concat(vm.projectRoot(), "/", directoryPath, "/", prefix, "-", chainName, ".json"));
    }
}
