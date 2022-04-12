export enum ChainId {
    BSC_MAINNET = 56,
    BSC_TESTNET = 97
  }
  
  export const BSC_MAINNET = 56
  export const BSC_TESTNET = 97

  export const MAX_UINT256 = "115792089237316195423570985008687907853269984665640564039457584007913129639935"


  // https://forum.openzeppelin.com/t/using-the-maximum-integer-in-solidity/3000
  export const EIGHTEEN_ZEROES = "000000000000000000"
  
  export const WBNB = {
    [ChainId.BSC_MAINNET]: "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
    [ChainId.BSC_TESTNET]: ""
  }
  
  export const PANCAKE_ROUTER = {
    [ChainId.BSC_MAINNET]: "0x10ed43c718714eb63d5aa57b78b54704e256024e",
    [ChainId.BSC_TESTNET]: "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"
  }
  
  export const PANCAKE_FACTORY = {
    [ChainId.BSC_MAINNET]: "0xca143ce32fe78f1f7019d7d551a6402fc5350c73",
    [ChainId.BSC_TESTNET]: ""
  }
  
  