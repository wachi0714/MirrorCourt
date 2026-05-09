const hre = require("hardhat");

async function main() {
  console.log("Deploying FateMirror contract...");

  const FateMirror = await hre.ethers.getContractFactory("FateMirror");
  const fateMirror = await FateMirror.deploy();

  await fateMirror.deployed();

  console.log(`✅ FateMirror deployed to: ${fateMirror.address}`);
  console.log(`📜 ABI saved in artifacts/contracts/FateMirror.sol/FateMirror.json`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
