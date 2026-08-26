// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Utils.sol";
import "config/SpectraConfigReader.s.sol";

contract UpgradeTransparentProxyScript is Script, SpectraConfigReader {
    address private testAddressTransparentProxy;
    address private testAddressNewInstance;
    bool private forTest;
    string private configFilePath = "script/constants/15_upgradeTransparentProxy";
    string private configFilePrefix = "15_upgradeTransparentProxy";

    function run() public {
        vm.startBroadcast();
        if (forTest) {
            bytes32 adminSlot = vm.load(testAddressTransparentProxy, ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));

            ProxyAdmin(proxyAdmin)
                .upgradeAndCall(ITransparentUpgradeableProxy(testAddressTransparentProxy), testAddressNewInstance, "");
            console.log("Instance of proxy updated to", testAddressNewInstance);
        } else {
            address payable proxy = payable(getAddressFromFile(configFilePath, configFilePrefix, ".proxy"));

            bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));

            address newInstance = getAddressFromFile(configFilePath, configFilePrefix, ".newInstance");

            ProxyAdmin(proxyAdmin).upgradeAndCall(ITransparentUpgradeableProxy(proxy), newInstance, "");
            console.log("Instance of proxy updated to", newInstance);
        }
        vm.stopBroadcast();
    }

    function upgradeForTest(address proxy, address newInstance) public {
        forTest = true;
        testAddressTransparentProxy = proxy;
        testAddressNewInstance = newInstance;
        run();
        forTest = false;
        testAddressTransparentProxy = address(0);
        testAddressNewInstance = address(0);
    }
}
