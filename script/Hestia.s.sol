// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@solady/tokens/ERC20.sol";

import {Registry} from "contracts/Registry.sol";
import {HestiaToken} from "contracts/tokens/HestiaToken.sol";

contract HestiaScript is Script {
    
    function setUp() public {}

    function _deployer() internal returns (uint256, address) {
        uint256 deployerPK = vm.envUint("DEPLOYER_PRIVATE_KEY");
        return (deployerPK, vm.addr(deployerPK));
    }

    function run() public {
        console.log("Specify a function to run");
        (uint256 deployerPK, address deployer) = _deployer();
        console.log("DEPLOYER:", deployer);
    }

    function fullDeploy(address _token) public {
        deployRegistry(_token);
    }

    function deployRegistry(address _token) public returns (Registry) {
        uint256 privateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        Registry registry = new Registry(_token);
        console.log("Registry deployed at:", address(registry));
        vm.stopBroadcast();
    }
    
    function deployTokenHestia() public {
        uint256 privateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        ERC20 token = new HestiaToken();

        vm.stopBroadcast();
    }

    // function demo() public {
    //     uint256 deployerPK = vm.envUint("PRIVATE_KEY");
    //     vm.startBroadcast(deployerPK);

    //     Registry registry = deployRegistry();



    //     vm.stopBroadcast();
    // }
}
