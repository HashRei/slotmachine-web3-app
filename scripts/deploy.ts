import { ethers } from "hardhat"

async function main() {
  const SMT = await ethers.getContractFactory("SMT")
  const smt = await SMT.deploy()

  await smt.deployed()

  console.log("SlotMachineToken deployed to:", smt.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
