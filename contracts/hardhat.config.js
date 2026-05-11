require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // Solidity version matching contract (critical for compilation)
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true, // Optimize contract size for Member B's frontend calls
        runs: 200,
      },
    },
  },
  // Network config for Member C's testing (Sepolia + Local Hardhat)
  networks: {
    hardhat: {},
    sepolia: {
      url: "https://rpc.sepolia.org", // Public Sepolia RPC (no extra setup)
      accounts: ["YOUR_TESTNET_PRIVATE_KEY"], // Replace with MetaMask testnet key
    },
  },
  // Path config for Member C's test file access
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
