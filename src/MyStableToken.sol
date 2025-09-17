// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// MyStableToken - OpenZeppelin-based example with AccessControl, Pausable, Permit, Burnable
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract MyStableToken is ERC20Pausable, ERC20Burnable, ERC20Permit, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(uint256 initialSupply) ERC20("MyStableToken", "MST") ERC20Permit("MyStableToken") {
        // initialize roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply);
        }
    }

    /// @notice mint only callable by MINTER_ROLE
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice pause / unpause
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // ERC20 v5 uses internal function named _update; ERC20Pausable also defines it.
    // Because multiple bases define _update, we must explicitly override here.
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
