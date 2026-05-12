# 🎭 **Mirror Court** — *The Mirror Court*

An **on-chain interactive story + NFT minting** project.  
Every choice you make will be eternally etched into the mirror, becoming your unique life reflection.

## ✨ Project Introduction

You push open an ancient wooden door entwined with vines and step into the moonlit **Mirror Court**.  
At its center stands a massive bronze mirror that reflects not only your appearance, but the entirety of your life.  

Make meaningful choices. Shape your destiny.  
**Finally mint your personal NFT** — a permanent on-chain artwork of your journey.

## 🎯 How to Play

1. Start your story in the Mirror Court
2. Make 4 key life choices
3. Complete the story and mint your unique ending as an NFT

## 🛠️ Tech Stack

- **Smart Contract**: Solidity ^0.8.19 + Hardhat + OpenZeppelin ERC721
- **Frontend**: HTML + CSS + JavaScript + ethers.js
- **NFT Art**: Fully on-chain SVG (4 unique artistic endings)
- **Testnet**: Sepolia

## 📁 Project Structure
MirrorCourt/
├── contracts/
│   └── MirrorCourt.sol                 # Main contract with on-chain SVGs
├── scripts/
│   └── deploy.js                       # Deployment script
├── test/
│   └── MirrorCourt.test.js             # Unit tests
├── index.html                          # Frontend dApp
├── svg_generator.html                  # SVG design tool
├── storydata.js                        # Story content data
├── hardhat.config.js
├── package.json
└── README.md
text## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
2. Compile & Test
Bashnpx hardhat compile
npx hardhat test
3. Deploy Contract
Bash# Local Hardhat Network
npx hardhat run scripts/deploy.js --network hardhat

# Sepolia Testnet
npx hardhat run scripts/deploy.js --network sepolia
4. Run Frontend

Open index.html using Live Server (VS Code) or any static file server
Enter the deployed contract address
Connect MetaMask (switch to Sepolia network)
Start your Mirror Court journey

📖 Story Endings

Childhood Wonder — Return to a carefree childhood. The world remains soft and bright forever.
Blazing Youth — Flames roar within your chest. Become an unstoppable dreamer.
Settled Midlife — Growth rings record the years. Wisdom as deep as a serene lake.
Shattered Serenity — All reflections shatter. Only pure, tranquil whiteness remains.

🔧 Main Contract Functions

startStory() — Begin a new story
makeChoice(uint8 choice) — Make a choice
getCurrentScene() — Get current scene description and options
finalizeAndMintNFT() — Complete story and mint NFT
tokenURI(uint256 tokenId) — Get NFT metadata with embedded SVG

🎨 Highlights

All 4 endings are pure SVG stored directly on-chain (no IPFS)
Fully decentralized and permanent
Beautiful on-chain generative art

🙏 Acknowledgments
A collaborative project by a 3-member team specializing in smart contracts, frontend development, story writing, and on-chain art.
