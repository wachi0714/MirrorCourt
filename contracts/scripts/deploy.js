const hre = require("hardhat");

async function main() {
  // Deploy MirrorCourt contract (aligned with contract name)
  const MirrorCourt = await hre.ethers.getContractFactory("MirrorCourt");
  const mirrorCourt = await MirrorCourt.deploy();

  await mirrorCourt.deployed();

  // Clear output for Member B (frontend integration) and Member C (testing)
  console.log(`✅ MirrorCourt Contract Deployed Successfully`);
  console.log(`📜 Contract Address: ${mirrorCourt.address}`);
  console.log(`💡 Share this address with Member B for frontend integration`);
  console.log(`🔍 Use this address for Member C's testing validation`);
}

// Enhanced error handling (for Member C's debugging)
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment Failed: ", error);
    process.exit(1);
  });
