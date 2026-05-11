const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MirrorCourt Contract Tests (Aligned with B/C Requirements)", function () {
  let mirrorCourt;
  let owner;

  // Fresh contract deployment for each test (Member C's clean test environment)
  beforeEach(async function () {
    const MirrorCourt = await ethers.getContractFactory("MirrorCourt");
    mirrorCourt = await MirrorCourt.deploy();
    [owner] = await ethers.getSigners();
  });

  // Test 1: Basic story start (Member C's core story logic)
  it("✅ Should start a new story successfully", async function () {
    await mirrorCourt.startStory();
    const [currentScene, choices, isStarted, isCompleted] = await mirrorCourt.getStoryState();
    expect(isStarted).to.equal(true);
    expect(currentScene).to.equal(0);
  });

  // Test 2: Full story flow (Member C's story branch coverage)
  it("✅ Should complete story after all choices", async function () {
    await mirrorCourt.startStory();
    // Scene 0: Choose "Draw spiral"
    await mirrorCourt.makeChoice(0);
    // Scene 1: Choose "Encourage adventure"
    await mirrorCourt.makeChoice(0);
    // Scene 2: Choose "Regret words unsaid"
    await mirrorCourt.makeChoice(0);
    // Scene 3: Choose "Childhood Wonder"
    await mirrorCourt.makeChoice(0);

    const [, , , isCompleted] = await mirrorCourt.getStoryState();
    expect(isCompleted).to.equal(true);
  });

  // Test 3: Fixed getCurrentScene (Member B's frontend safety)
  it("✅ Should return completion message (no crash) when story ends", async function () {
    await mirrorCourt.startStory();
    // Complete all choices
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);

    const [description, options] = await mirrorCourt.getCurrentScene();
    expect(description).to.equal("Story completed. Mint your NFT to see the final reflection.");
    expect(options.length).to.equal(0);
  });

  // Test 4: NFT Mint (Member B's NFT display validation)
  it("✅ Should mint NFT after story completion", async function () {
    await mirrorCourt.startStory();
    // Complete story
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);

    // Mint NFT
    await mirrorCourt.finalizeAndMintNFT();
    const balance = await mirrorCourt.balanceOf(owner.address);
    expect(balance).to.equal(1);

    // Verify NFT metadata (Member B's SVG integration)
    const tokenURI = await mirrorCourt.tokenURI(0);
    expect(tokenURI).to.include("data:application/json;base64");
    expect(tokenURI).to.include("Childhood Wonder");
  });

  // Test 5: Boundary cases (Member C's error handling testing)
  it("❌ Should revert when minting NFT before story completion", async function () {
    await mirrorCourt.startStory();
    // Incomplete story (only 2 choices)
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);

    await expect(mirrorCourt.finalizeAndMintNFT()).to.be.revertedWith("Story not completed");
  });

  it("❌ Should revert when minting NFT multiple times", async function () {
    await mirrorCourt.startStory();
    // Complete story and mint once
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.makeChoice(0);
    await mirrorCourt.finalizeAndMintNFT();

    // Revert on second mint
    await expect(mirrorCourt.finalizeAndMintNFT()).to.be.revertedWith("Already minted NFT");
  });
});
