const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FateMirror", function () {
  let fateMirror;
  let owner, user1, user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const FateMirror = await ethers.getContractFactory("FateMirror");
    fateMirror = await FateMirror.deploy();
    await fateMirror.deployed();
  });

  describe("Story lifecycle", function () {
    it("Should start a new story", async function () {
      await fateMirror.connect(user1).startStory();
      const [currentScene, options] = await fateMirror.connect(user1).getCurrentScene();
      expect(currentScene).to.include("magic mirror");
      expect(options.length).to.equal(2);
    });

    it("Should not allow starting twice", async function () {
      await fateMirror.connect(user1).startStory();
      await expect(fateMirror.connect(user1).startStory()).to.be.revertedWith("Story already started");
    });

    it("Should make choices and reach an ending", async function () {
      await fateMirror.connect(user1).startStory();

      // Scene 0: choose spiral (0)
      await fateMirror.connect(user1).makeChoice(0);
      let state = await fateMirror.connect(user1).getStoryState();
      expect(state[0]).to.equal(1); // currentScene = 1

      // Scene 1: choose stability (1)
      await fateMirror.connect(user1).makeChoice(1);
      state = await fateMirror.connect(user1).getStoryState();
      expect(state[0]).to.equal(2);

      // Scene 2: choose regret words unsaid (0)
      await fateMirror.connect(user1).makeChoice(0);
      state = await fateMirror.connect(user1).getStoryState();
      expect(state[0]).to.equal(3);

      // Scene 3: choose Midlife (2)
      await fateMirror.connect(user1).makeChoice(2);
      state = await fateMirror.connect(user1).getStoryState();
      expect(state[3]).to.equal(true); // isCompleted
      expect(state[0]).to.equal(99);
    });

    it("Should not allow minting before completion", async function () {
      await fateMirror.connect(user1).startStory();
      await expect(fateMirror.connect(user1).finalizeAndMintNFT()).to.be.revertedWith("Story not completed");
    });

    it("Should mint NFT only after full story", async function () {
      await fateMirror.connect(user1).startStory();
      // Full path: 0-0-0-1 (Youth ending)
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(1); // Youth

      const completed = (await fateMirror.connect(user1).getStoryState())[3];
      expect(completed).to.be.true;

      await fateMirror.connect(user1).finalizeAndMintNFT();
      const balance = await fateMirror.balanceOf(user1.address);
      expect(balance).to.equal(1);
    });

    it("Should not mint twice for same address", async function () {
      await fateMirror.connect(user1).startStory();
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0); // Childhood
      await fateMirror.connect(user1).finalizeAndMintNFT();

      await expect(fateMirror.connect(user1).finalizeAndMintNFT()).to.be.revertedWith("Already minted NFT");
    });

    it("Should return correct scene after story completed (no crash)", async function () {
      await fateMirror.connect(user1).startStory();
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0); // Childhood

      const [desc, options] = await fateMirror.connect(user1).getCurrentScene();
      expect(desc).to.include("story has ended");
      expect(options.length).to.equal(0);
    });

    it("Should generate different endings based on final choice", async function () {
      // User1 - Childhood ending
      await fateMirror.connect(user1).startStory();
      for (let i = 0; i < 3; i++) await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0); // Childhood
      await fateMirror.connect(user1).finalizeAndMintNFT();
      const tokenId1 = 0;
      const uri1 = await fateMirror.tokenURI(tokenId1);
      expect(uri1).to.include("Childhood");

      // User2 - Youth ending
      await fateMirror.connect(user2).startStory();
      for (let i = 0; i < 3; i++) await fateMirror.connect(user2).makeChoice(1);
      await fateMirror.connect(user2).makeChoice(1); // Youth
      await fateMirror.connect(user2).finalizeAndMintNFT();
      const tokenId2 = 1;
      const uri2 = await fateMirror.tokenURI(tokenId2);
      expect(uri2).to.include("Youth");
    });
  });
});
