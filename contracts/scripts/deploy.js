const hre = require("hardhat");

async function main() {
  // 适配：合约名改为 MirrorCourt（和你的 Solidity 合约一致）
  const MirrorCourt = await hre.ethers.getContractFactory("MirrorCourt");
  const mirrorCourt = await MirrorCourt.deploy();

  await mirrorCourt.deployed();

  // 适配：输出清晰的部署地址，方便 B 前端集成、C 测试验证
  console.log(`✅ MirrorCourt 合约已部署到测试网`);
  console.log(`📜 合约地址: ${mirrorCourt.address}`);
  console.log(`💡 请把这个地址发给成员 B（前端）用于合约交互`);
}

// 适配：完善错误处理，方便 C 辅助测试时定位问题
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ 部署失败：", error);
    process.exit(1);
  });
