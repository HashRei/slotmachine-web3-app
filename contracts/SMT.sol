// contracts/SMTToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SMT is ERC20 {
  constructor() ERC20("SlotMachineToken", "SMT") {
    _mint(msg.sender, 10000);
  }
}
