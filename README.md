<img width="958" height="968" alt="abfe432ec40d06ed98b4459b57e12da3" src="https://github.com/user-attachments/assets/0e8f27c4-996f-427c-a1b2-033894514d85" /># 🎭 Mirror Court — The Mirror Court

An on-chain interactive story + NFT minting project.  
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

```bash
MirrorCourt/
├── contracts/
│   └── MirrorCourt.sol          # Main contract with on-chain SVGs
├── scripts/
│   └── deploy.js                # Deployment script
├── test/
│   └── MirrorCourt.test.js      # Unit tests
├── index.html                   # Frontend dApp
├── svg_generator.html           # SVG design tool
├── storydata.js                 # Story content data
├── hardhat.config.js
├── package.json
└── README.md
