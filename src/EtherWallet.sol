// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Basic wallet:
// 1. Anyone can send ETH.
// 2. Only the owner can withdraw.

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
        // NOTE:
        // Although `owner` is of type `address payable`, `msg.sender` is still of type `address`.
        // Hence, `owner = msg.sender` throws an error:
        // "Type address is not implicitly convertible to expected type address payable."
        // The conversion must be explicit.
    }

    receive() external payable {}

    // Check docs: https://docs.soliditylang.org/en/latest/contracts.html#receive-ether-function
    // "A contract can have at most one `receive` function, declared using `receive() external
    // payable { ... }` (without the `function` keyword). This function cannot have arguments,
    // cannot return anything and must have `external` visibility and `payable` state mutability."
    // It is executed on a call to the contract with empty calldata. If no such function exists, but
    // a payable `fallback` function exists, the fallback function will be called on a plain Ether
    // transfer. If neither exists, the contract cannot receive Ether through a transaction that does
    // not represent a payable function call and throws an exception.

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "caller is not the owner");
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
        // `this.balance` alone refers to the contract instance.
        // Docs: https://docs.soliditylang.org/en/latest/types.html#contract-types
        // "Every contract defines its own type."
        // For example, if your contract is `EtherWallet`, then `this` is of type EtherWallet.
        // Nevertheless, contracts can be converted to and from the `address` type.
        // `address(this)` converts the contract instance into an address type, which allows you
        // to use all the properties and functions of an address, including `.balance`.
    }
}
