// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@solady/tokens/ERC20.sol";

import {Registry} from "contracts/Registry.sol";
import {MaldoToken} from "contracts/tokens/MaldoToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {IRegistry} from "interfaces/IRegistry.sol";

contract RegistryTest is Test {
    address deployer = makeAddr("deployer");
    address tasker = makeAddr("tasker");
    address user = makeAddr("user");
    address anotherUser = makeAddr("anotherUser");

    Registry registry;
    MaldoToken token;

    function setUp() public {
        vm.startPrank(deployer);

        token = new MaldoToken();
        // should i pass the erc20 instance here instead?
        registry = new Registry(address(token));

        vm.stopPrank();
    }

    function test_integration() public {
        // registry doesn't have allowance to stake the user's tokens
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(ERC20.InsufficientAllowance.selector));
        registry.stake(100);
        vm.stopPrank();

        // not enough allowance (this one isn't needed)
        vm.startPrank(user);
        token.approve(address(registry), 99);
        vm.expectRevert(abi.encodeWithSelector(ERC20.InsufficientAllowance.selector));
        registry.stake(100);
        vm.stopPrank();

        // mint tokens to the user
        token.mint(user, 100);

        // approve the registry to spend the user's tokens and stake
        vm.startPrank(user);
        token.approve(address(registry), 100);
        registry.stake(100);
        vm.stopPrank();
        // check emitted event

        // check unstaking more than staked amount

        // unstake
        vm.prank(user);
        registry.unstake(100);
        // check emitted event

        // set profile
        vm.prank(tasker);
        registry.setProfile("profile");
        // check emitted event

        // add service
        vm.prank(tasker);
        registry.addService("service");
        // check emitted event

        // update service
        vm.prank(tasker);
        registry.updateService(0, "service, updated");
        // check emitted event

        // only the tasker can update its service
        vm.startPrank(anotherUser);
        vm.expectRevert(abi.encodeWithSelector(IRegistry.Unauthorized.selector));
        registry.updateService(0, "service, updated again");
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(IRegistry.Unauthorized.selector));
        registry.createDeal(0, 100, user);
        vm.stopPrank();

        vm.startPrank(tasker);
        vm.expectRevert(abi.encodeWithSelector(IRegistry.InvalidBeneficiary.selector));
        registry.createDeal(0, 100, address(0));
        vm.stopPrank();

        vm.startPrank(tasker);
        registry.createDeal(0, 100, user);
        vm.stopPrank();

        // rate a service
        vm.prank(user);
        registry.rate(0, 5, "good review");
        // check emitted event

        // can rate more than once
        vm.prank(user);
        registry.rate(0, 5, "another good review");

        // dispute reverts because the address is not set
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(IRegistry.DisputeResolverNotSet.selector));
        registry.dispute(0);
    }
}
