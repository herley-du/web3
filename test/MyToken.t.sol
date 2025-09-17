// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        // 模拟 alice 为部署者，给 alice 初始 1000 ether
        vm.prank(alice);
        token = new MyToken(1000 ether);
    }

    function testInitialSupply() public {
        assertEq(token.balanceOf(alice), 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);
    }

    function testTransfer() public {
        vm.prank(alice);
        bool ok = token.transfer(bob, 100 ether);
        assertTrue(ok);
        assertEq(token.balanceOf(bob), 100 ether);
        assertEq(token.balanceOf(alice), 900 ether);
    }

    function testApproveAndTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 50 ether);
        assertEq(token.allowance(alice, bob), 50 ether);

        vm.prank(bob);
        bool ok = token.transferFrom(alice, bob, 30 ether);
        assertTrue(ok);
        assertEq(token.balanceOf(bob), 30 ether);
        assertEq(token.allowance(alice, bob), 20 ether);
    }
}
