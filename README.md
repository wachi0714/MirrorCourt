# 🎭 Mirror Court — The Mirror Court

An on-chain interactive story + NFT minting project.  
Every choice you make will be eternally etched into the mirror, becoming your unique life reflection.

## ✨ Project Introduction

You push open an ancient wooden door entwined with vines and step into the moonlit **Mirror Court**.  
At its center stands a massive bronze mirror that reflects not only your appearance, but the entirety of your life.

Make meaningful choices. Shape your destiny.  
**Finally mint your personal NFT** — a permanent on-chain artwork of your journey.

## 🎨 The Four Endings

<div align="center">

### 1. Childhood Wonder
![Childhood Wonder](./images/childhood.jpg)
*Return to a carefree childhood. The world remains soft and bright forever.*

### 2. Blazing Youth
![Blazing Youth](./images/youth.jpg)  
*Flames roar within your chest. Become an unstoppable dreamer.*

### 3. Settled Midlife
![Settled Midlife](./images/midlife.jpg)  
*Growth rings record the years. Wisdom as deep as a serene lake.*

### 4. Shattered Serenity
![Shattered Serenity](./images/serenity.jpg)  
*All reflections shatter. Only pure, tranquil whiteness remains.*

</div>

## 🎯 How to Play

1. Start your story in the Mirror Court  
2. Make 4 key life choices  
3. Complete the story and mint your unique ending as an NFT

## 🛠️ Tech Stack

- **Smart Contract**: Solidity ^0.8.19 + Hardhat + OpenZeppelin ERC721
- **Frontend**: HTML + CSS + JavaScript + ethers.js
- **NFT Art**: Fully on-chain SVG + High-quality ending images
- **Testnet**: Sepolia

## 📁 Project Structure

```bash
MirrorCourt/                      # 项目根目录
├── contracts/
│   └── MirrorCourt.sol
├── frontend/
│   ├── index.html
│   └── svg_generator.html
├── scripts/
│   └── deploy.js
├── test/
│   └── MirrorCourt.test.js
├── images/                       # NFT 结局展示图片
│   ├── childhood-wonder.jpg
│   ├── blazing-youth.jpg
│   ├── settled-midlife.jpg
│   └── shattered-serenity.jpg
├── storydata.js
├── hardhat.config.js
├── package.json
└── README.md
