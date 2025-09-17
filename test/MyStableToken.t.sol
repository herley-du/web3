// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MyStableToken.sol";

contract MyStableTokenTest is Test {
    MyStableToken token;
    address deployer = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);

    function setUp() public {
        vm.prank(deployer);
        token = new MyStableToken(1000 ether);
    }

    function testInitialSupplyAndOwner() public {
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.balanceOf(deployer), 1000 ether);
    }

    function testMintRole() public {
        vm.prank(deployer);
        token.mint(alice, 10 ether);
        assertEq(token.balanceOf(alice), 10 ether);
    }

    function testMintUnauthorized() public {
        vm.prank(bob);
        vm.expectRevert();
        token.mint(bob, 1 ether);
    }

    function testPauseUnpause() public {
        vm.prank(deployer);
        token.pause();
        vm.prank(deployer);
        vm.expectRevert();
        token.transfer(alice, 1 ether);
        vm.prank(deployer);
        token.unpause();
        vm.prank(deployer);
        token.transfer(alice, 1 ether);
        assertEq(token.balanceOf(alice), 1 ether);
    }

    function testBurn() public {
        vm.prank(deployer);
        token.transfer(alice, 5 ether);
        vm.prank(alice);
        token.burn(2 ether);
        assertEq(token.balanceOf(alice), 3 ether);
    }

    function testFuzz_transfer(uint256 x) public {
        vm.assume(x < 1000 ether);
        vm.prank(deployer);
        token.transfer(alice, x);
        assertEq(token.balanceOf(alice), x);
    }
}
