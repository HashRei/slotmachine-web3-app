// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISMT {
  function manualSwapSmtForLink(uint256 _smtAmount) external returns (bool);
}
