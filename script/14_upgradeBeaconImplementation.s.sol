// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/mocks/MockIBT.sol";
import "openzeppelin-contracts/proxy/beacon/UpgradeableBeacon.sol";
import "config/SpectraConfigReader.s.sol";

contract UpgradeBeaconLogicScript is Script, SpectraConfigReader {
    address private testAddressBeacon;
    address private testAddressNewInstance;
    bool private forTest;
    string private configFilePath = "script/constants/14_upgradeBeaconImplementation";
    string private configFilePrefix = "14_upgradeBeaconImplementation";

    function run() public {
        vm.startBroadcast();
        if (forTest) {
            UpgradeableBeacon(testAddressBeacon).upgradeTo(testAddressNewInstance);
            console.log("Instance of beacon updated to", testAddressNewInstance);
        } else {
            address beacon = getAddressFromFile(configFilePath, configFilePrefix, ".beacon");
            address newInstance = getAddressFromFile(configFilePath, configFilePrefix, ".newInstance");

            UpgradeableBeacon(beacon).upgradeTo(newInstance);
            console.log("Instance of beacon updated to", newInstance);
        }
        vm.stopBroadcast();
    }

    function upgradeForTest(address beacon, address newInstance) public {
        forTest = true;
        testAddressBeacon = beacon;
        testAddressNewInstance = newInstance;
        run();
        forTest = false;
        testAddressBeacon = address(0);
        testAddressNewInstance = address(0);
    }
}
