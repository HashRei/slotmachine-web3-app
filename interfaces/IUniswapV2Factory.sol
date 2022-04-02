// SPDX-License-Identifier: MIT
// Uniswap V2
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}
