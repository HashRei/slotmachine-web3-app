// contracts/SMTToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SMT is ERC20 {

  mapping(address => uint256) public inSlotMachine;

  constructor(uint256 initialSupply) ERC20("SlotMachineToken", "SMT") {
    _mint(msg.sender, initialSupply);
  }

  // Add _amount of SMT tokens to the SlotMachine
  function setInSlotMachine(address _account, uint256 _amount) public{
    
    inSlotMachine[_account] += _amount;
  }

  // Remove _amount of SMT tokens from the SlotMachine
  function removeInSlotMachine(address _account, uint256 _amount) public{
    inSlotMachine[_account] -= _amount;
  }

  // Remove all the SMT tokens from the SlotMachine
  function removeAllInSlotMachine(address _account) public{
    inSlotMachine[_account] = 0;
  }
}
