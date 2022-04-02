// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IUniswapV2Router02.sol";
import "../interfaces/IUniswapV2Factory.sol";

//TODO: lokks to connect 
// import "../interfaces/IVRFv2SubscriptionManager.sol";

contract SMT is ERC20 {
  /** CONSTANTS **/

  // BSC Testnet LINK token contract address
  address public LINK_ADDRESS = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;

  // BSC Testnet Chainlink Verifiable Random Function coordinator contract address
  address public VRF_COORDINATOR = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;

  /** SEMI-CONSTANTS **/

  IUniswapV2Router02 public pancakeRouter;
  // IVRFv2SubscriptionManager public vrfCoordinator;
  address public pancakeSmtBnbPair;

  /** VARIABLES **/

  mapping(address => uint256) public inSlotMachine;

  /** CONSTRUCTOR **/

  constructor(address _pancakeRouter, uint256 initialSupply) ERC20("SlotMachineToken", "SMT") {
    _mint(msg.sender, initialSupply);
    pancakeRouter = IUniswapV2Router02(_pancakeRouter);
    pancakeSmtBnbPair = IUniswapV2Factory(pancakeRouter.factory()).createPair(
      address(this),
      pancakeRouter.WETH()
    );
  }

  /** INTERNAL METHODS **/

  // Swaps "_smtAmount" SMT for LINK
  function _swapSmtForLink(uint256 _smtAmount) internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = LINK_ADDRESS;

    _approve(address(this), address(pancakeRouter), _smtAmount);

    pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
      _smtAmount,
      0, // Accept any amount of LINK
      path,
      VRF_COORDINATOR, // Recipient of the output tokensis the VRF contract
      block.timestamp // Unix timestamp after which the transaction will revert
    );
  }

  // Should top-up the subscription of the VRF contract
  //TODO: Possible issue with onlyOwner
  // TOD
  function _topUpSubscription(uint256 _amount) internal pure {
    address(VRF_COORDINATOR).topUpSubscription(_amount);
  }

  // Add _amount of SMT tokens to the SlotMachine
  function setInSlotMachine(address _account, uint256 _amount) public {
    inSlotMachine[_account] += _amount;
  }

  // Remove _amount of SMT tokens from the SlotMachine
  function removeInSlotMachine(address _account, uint256 _amount) public {
    inSlotMachine[_account] -= _amount;
  }

  // Remove all the SMT tokens from the SlotMachine
  function removeAllInSlotMachine(address _account) public {
    inSlotMachine[_account] = 0;
  }
}
