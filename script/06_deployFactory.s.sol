// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/factory/Factory.sol";
import "src/proxy/AMTransparentUpgradeableProxy.sol";
import "src/proxy/AMProxyAdmin.sol";
import "roles/Roles.sol";
import "openzeppelin-contracts/access/manager/IAccessManager.sol";
import "config/SpectraConfigReader.s.sol";
import "config/SpectraConfigWriter.s.sol";

// script to deploy the Factory Instance and Proxy
contract FactoryScript is Script, SpectraConfigReader, SpectraConfigWriter {
    bytes4[] private selectors_proxy_admin = new bytes4[](1);
    bytes4[] private factory_selector = new bytes4[](1);
    address private testRes;
    address private registry;
    address private curveFactoryAddress;
    address private accessManager;
    bool private forTest;
    string private configFilePath = "script/constants/06_deployFactory";
    string private configFilePrefix = "06_deployFactory";
    string private outputFilePath = "script/output/06_deployFactory";
    string private outputFilePrefix = "06_deployFactory";

    function run() public {
        vm.startBroadcast();
        selectors_proxy_admin[0] = AMProxyAdmin(address(0)).upgradeAndCall.selector;
        factory_selector[0] = Factory(address(0)).setCurveFactory.selector;
        if (forTest) {
            address factoryInstance = address(new Factory(registry));
            console.log("Factory instance deployed at", factoryInstance);

            address FactoryProxy = address(
                new AMTransparentUpgradeableProxy(
                    factoryInstance,
                    accessManager,
                    abi.encodeWithSelector(Factory(address(0)).initialize.selector, accessManager, curveFactoryAddress)
                )
            );
            console.log("Factory proxy deployed at", FactoryProxy);
            bytes32 adminSlot = vm.load(address(FactoryProxy), ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));
            IRegistry(registry).setFactory(FactoryProxy);
            IAccessManager(accessManager).setTargetFunctionRole(proxyAdmin, selectors_proxy_admin, Roles.UPGRADE_ROLE);
            IAccessManager(accessManager).setTargetFunctionRole(FactoryProxy, factory_selector, Roles.REGISTRY_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
            testRes = FactoryProxy;
        } else {
            accessManager = getAccessManager();
            registry = getAddressFromFile(configFilePath, configFilePrefix, ".registry");
            curveFactoryAddress = getAddressFromFile(configFilePath, configFilePrefix, ".curveFactory");

            address factoryInstance = address(new Factory(registry));
            logAddress("factoryImplementation", factoryInstance);
            console.log("Factory instance deployed at", factoryInstance);

            address FactoryProxy = address(
                new AMTransparentUpgradeableProxy(
                    factoryInstance,
                    accessManager,
                    abi.encodeWithSelector(Factory(address(0)).initialize.selector, accessManager, curveFactoryAddress)
                )
            );
            logAddress("factoryProxy", FactoryProxy);
            console.log("Factory proxy deployed at", FactoryProxy);
            IRegistry(registry).setFactory(FactoryProxy);
            bytes32 adminSlot = vm.load(address(FactoryProxy), ERC1967Utils.ADMIN_SLOT);
            address proxyAdmin = address(uint160(uint256(adminSlot)));
            logAddress("factoryProxyAdmin", proxyAdmin);
            console.log("Factory Proxy Admin Address:", address(proxyAdmin));
            IAccessManager(accessManager).setTargetFunctionRole(proxyAdmin, selectors_proxy_admin, Roles.UPGRADE_ROLE);
            IAccessManager(accessManager).setTargetFunctionRole(FactoryProxy, factory_selector, Roles.REGISTRY_ROLE);
            console.log("Function setTargetFunctionRole Role set for ProxyAdmin");
        }
        vm.stopBroadcast();
        if (!forTest) {
            saveOutput(outputFilePath, outputFilePrefix);
        }
    }

    function deployForTest(address _registry, address _curveFactoryAddress, address _accessManager)
        public
        returns (address _testRes)
    {
        forTest = true;
        registry = _registry;
        curveFactoryAddress = _curveFactoryAddress;
        accessManager = _accessManager;
        run();
        forTest = false;
        _testRes = testRes;
        testRes = address(0);
        curveFactoryAddress = address(0);
        registry = address(0);
        accessManager = address(0);
    }
}
