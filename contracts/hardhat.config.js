require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy"); // 适配：方便部署和测试

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19", // 适配：和合约的 Solidity 版本完全一致
    settings: {
      optimizer: {
        enabled: true, // 适配：优化合约大小，方便 B 前端调用
        runs: 200,
      },
    },
  },
  networks: {
    // 本地测试网（C 手动测试时用）
    hardhat: {},
    // Sepolia 测试网（协作要求里的推荐，方便 B/C 联调）
    sepolia: {
      url: "https://rpc.sepolia.org", // 公共 RPC，无需额外配置
      accounts: ["YOUR_PRIVATE_KEY"], // 替换成你的 MetaMask 私钥（测试网用，别放主网私钥）
    },
  },
  // 适配：输出清晰的编译信息，方便 C 测试时排查问题
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
