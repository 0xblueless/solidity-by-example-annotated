// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Any contract that follows the ERC20 standard is an ERC20 token.
// ERC20 tokens provide functionalities to: 1) transfer tokens,
// 2) allow others to transfer tokens on behalf of the token holder.

contract ERC20 {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    /*
    `approve()` sets a limit (an allowance) on how many tokens a third-party address (the spender) 
    is allowed to spend on the caller's behalf. 
    
    On many DEXs, to execute a trade, you first call `approve()` on the token contract, setting an 
    allowance for the DEX's smart contract. It then acts as the Spender, calling `transferFrom()`
    to send the required amount of Token A to the exchange pool from your balance and simultaneously 
    sending you Token B. This allows the exchange to happen in a single, atomic transaction.

    Recall that: This contract stores balances for only one type of token. Another contract will store
    balances for another type of token. To execute a trade on a DEX, it has to interact with these two
    ERC20 contracts on your behalf. That's why the `approve()` + `transferFrom()` logic exists.
    */
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply = +amount;
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(to, amount);
    }
}
