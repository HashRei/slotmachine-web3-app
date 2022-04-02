// contracts/SMTToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IERC20.sol";

contract SlotMachine is ReentrancyGuard {

  /** CONSTANTS **/


  /** VARIABLES **/

  address public smt;
  uint256 public jackpotBalance;
  address public player;
  mapping(address => uint256) public tokenBalanceToPlay; // Variables that holds the SMT token that the player has injected in the machine, can be more then 1

  // events
  event AddedLiquidity(uint256 oneNodeAmount, uint256 oneAmount);

  constructor() {}

  /** MAIN METHODS **/

  receive() external payable {}

  // Withdraw all the SMT tokens from the current player
  function withdrawAllTokens() public nonReentrant {
    require(msg.sender == player, "You are not the player");
    require(tokenBalanceToPlay[msg.sender] > 0, "No SMT tokens in the machine");

    //Send SMT tokens from the player which are in the machine to the players wallet
    
    IERC20(smt).transfer(msg.sender, tokenBalanceToPlay[msg.sender]);
  }

  // Get a random value from Chainlink VRF and check if the player has won
  function spin() public payable {
    require(tokenBalanceToPlay[msg.sender] >= 1, "Token balance too low");

    // should swap BNB for Link and send Link to the VRF contract and then should topUp the Subscription iwth topUpSubscription()
  }
}
