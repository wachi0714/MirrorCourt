const hre = require("hardhat");

async function main() {
  console.log("Deploying FateMirror contract...");

  const FateMirror = await hre.ethers.getContractFactory("FateMirror");
  const fateMirror = await FateMirror.deploy();
  await fateMirror.waitForDeployment();

  const address = await fateMirror.getAddress();
  console.log(`FateMirror deployed to: ${address}`);
  console.log("ABI generated in artifacts/contracts/FateMirror.sol/FateMirror.json");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
