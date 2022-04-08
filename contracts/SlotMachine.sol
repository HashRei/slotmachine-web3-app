// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ISMT.sol";

contract SlotMachine is VRFConsumerBaseV2, ReentrancyGuard, Ownable {
  VRFCoordinatorV2Interface COORDINATOR;
  LinkTokenInterface LINKTOKEN;

  /** VRF CONSTANTS **/

  // BSC Testnet LINK token contract address
  address public LINK_TOKEN_ADDRESS = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;

  // BSC Testnet Chainlink Verifiable Random Function coordinator contract address
  address public VRF_COORDINATOR = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  bytes32 KEY_HASH = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;

  // Maximum amount of gas  that can be spend on the callback request
  uint32 CALLBACK_GAS_LIMIT = 100000; // Unit is gas

  uint16 REQUEST_CONFIRMATIONS = 3;

  // For this example, retrieve 1 random value in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 NUM_WORDS = 1;

  // Subsciption fee payed to request a random value
  // contains gas price on BSC Tesnet (= 10.5 gwei) https://explorer.bitquery.io/bsc_testnet/gas,
  // verification price(=200,000 gas) https://docs.chain.link/docs/chainlink-vrf/#subscription-billing,
  // callback gas limit (=100,000)
  // and link premium value(=0.005 LINK) https://docs.chain.link/docs/vrf-contracts/#configurations
  uint256 internal SUBSCRIPTION_FEE = 0.1 * 10**18; // 0.1 LINK - 0.092 would be enough but better safe then sorry

  /** VARIABLES **/

  address public smt;
  address public player;
  mapping(address => uint256) public tokenBalanceToPlay; // Variables that holds the SMT token that the player has injected in the machine, can be more then 1

  /**  VRF VARIABLES **/

  uint256 public randomResult;
  uint256 public s_requestId;
  uint64 public s_subscriptionId;
  address s_owner; // Address of the smart contract owner

  /**  Events **/
  event AddedLiquidity(uint256 smtAmount, uint256 bnbAmount);
  event SpinResult(bool result);

  /** CONSTRUCTOR **/

  constructor() VRFConsumerBaseV2(VRF_COORDINATOR) {
    COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR); // Processes the random number request and determines the final charge of it
    LINKTOKEN = LinkTokenInterface(LINK_TOKEN_ADDRESS);
    s_owner = msg.sender;
    player = msg.sender;
    // Create a new subscription the contract is deployed
    createNewSubscription();
  }

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
    tokenBalanceToPlay[msg.sender] -= 1;
    // Swap 1 SMT token for LINK, the swapped LINK is send to this contract
    ISMT(smt).manualSwapSmtForLink(1);
    // Random number request process, value is stored in randomResult
    fundAndRequestRandomWords();

    if (randomResult == 1) {
      tokenBalanceToPlay[msg.sender] += 3;
      emit SpinResult(true);
    } else {
      emit SpinResult(false);
    }
  }

  /** VRF METHODS **/

  // Assumes this contract owns link
  // Sends fund the subscription contract and request a random value
  function fundAndRequestRandomWords() internal onlyOwner {
    require(
      LINKTOKEN.balanceOf(address(this)) >= SUBSCRIPTION_FEE,
      "Not enough LINK - fill this contract with LINK"
    );

    // Sends LINK tokens from this contract to the COORDINATOR/subscription that allows the requesting of the random number
    LINKTOKEN.transferAndCall(address(COORDINATOR), SUBSCRIPTION_FEE, abi.encode(s_subscriptionId));

    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      KEY_HASH,
      s_subscriptionId,
      REQUEST_CONFIRMATIONS,
      CALLBACK_GAS_LIMIT,
      NUM_WORDS
    );
  }

  // Callback function to receive the random value
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    randomResult = (randomWords[0] % 2); // Number is either 0 or 1
  }

  // Create a new subscription when the contract is initially deployed.
  function createNewSubscription() private onlyOwner {
    // Create a subscription with a new subscription ID.
    address[] memory consumers = new address[](1);
    consumers[0] = address(this);
    s_subscriptionId = COORDINATOR.createSubscription();
    // Add this contract as a consumer of its own subscription.
    COORDINATOR.addConsumer(s_subscriptionId, consumers[0]);
  }

  function addConsumer(address consumerAddress) external onlyOwner {
    // Add a consumer contract to the subscription.
    COORDINATOR.addConsumer(s_subscriptionId, consumerAddress);
  }

  function removeConsumer(address consumerAddress) external onlyOwner {
    // Remove a consumer contract from the subscription.
    COORDINATOR.removeConsumer(s_subscriptionId, consumerAddress);
  }

  function cancelSubscription(address receivingWallet) external onlyOwner {
    // Cancel the subscription and send the remaining LINK to a wallet address.
    COORDINATOR.cancelSubscription(s_subscriptionId, receivingWallet);
    s_subscriptionId = 0;
  }

  // Transfer this contract's funds to an address.
  // 1000000000000000000 = 1 LINK
  function withdraw(uint256 amount, address to) external onlyOwner {
    LINKTOKEN.transfer(to, amount);
  }
}
