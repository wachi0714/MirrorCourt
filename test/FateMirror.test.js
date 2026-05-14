const { expect } = require("chai");
const { ethers } = require("hardhat");

function decodeTokenMetadata(dataUri) {
  const prefix = "data:application/json;base64,";
  expect(dataUri.startsWith(prefix)).to.equal(true);
  const b64 = dataUri.slice(prefix.length);
  const json = Buffer.from(b64, "base64").toString("utf8");
  return JSON.parse(json);
}

describe("FateMirror", function () {
  let fateMirror;
  let user1, user2;

  beforeEach(async function () {
    [, user1, user2] = await ethers.getSigners();
    const FateMirror = await ethers.getContractFactory("FateMirror");
    fateMirror = await FateMirror.deploy();
    await fateMirror.waitForDeployment();
  });

  describe("Story lifecycle", function () {
    it("starts a new story", async function () {
      await fateMirror.connect(user1).startStory();
      const [currentScene, options] = await fateMirror.connect(user1).getCurrentScene();
      expect(currentScene).to.include("magic mirror");
      expect(options.length).to.equal(2);
    });

    it("does not allow starting twice", async function () {
      await fateMirror.connect(user1).startStory();
      await expect(fateMirror.connect(user1).startStory()).to.be.revertedWith("Story already started");
    });

    it("makes choices and reaches an ending", async function () {
      await fateMirror.connect(user1).startStory();

      await fateMirror.connect(user1).makeChoice(0);
      let state = await fateMirror.connect(user1).getStoryState();
      expect(state[0]).to.equal(1n);

      await fateMirror.connect(user1).makeChoice(1);
      state = await fateMirror.connect(user1).getStoryState();
      expect(state[0]).to.equal(2n);

      await fateMirror.connect(user1).makeChoice(0);
      state = await fateMirror.connect(user1).getStoryState();
      expect(state[0]).to.equal(3n);

      await fateMirror.connect(user1).makeChoice(2);
      state = await fateMirror.connect(user1).getStoryState();
      expect(state[3]).to.equal(true);
      expect(state[0]).to.equal(99n);
    });

    it("does not allow minting before completion", async function () {
      await fateMirror.connect(user1).startStory();
      await expect(fateMirror.connect(user1).finalizeAndMintNFT()).to.be.revertedWith("Story not completed");
    });

    it("mints NFT only after full story", async function () {
      await fateMirror.connect(user1).startStory();
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(1);

      const completed = (await fateMirror.connect(user1).getStoryState())[3];
      expect(completed).to.equal(true);

      await fateMirror.connect(user1).finalizeAndMintNFT();
      const balance = await fateMirror.balanceOf(user1.address);
      expect(balance).to.equal(1n);
    });

    it("does not mint twice for same address", async function () {
      await fateMirror.connect(user1).startStory();
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).finalizeAndMintNFT();

      await expect(fateMirror.connect(user1).finalizeAndMintNFT()).to.be.revertedWith("Already minted NFT");
    });

    it("returns final scene response after completion", async function () {
      await fateMirror.connect(user1).startStory();
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);

      const [desc, options] = await fateMirror.connect(user1).getCurrentScene();
      expect(desc).to.include("story has ended");
      expect(options.length).to.equal(0);
    });

    it("generates different endings from final choice", async function () {
      await fateMirror.connect(user1).startStory();
      for (let i = 0; i < 3; i += 1) await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).makeChoice(0);
      await fateMirror.connect(user1).finalizeAndMintNFT();
      const uri1 = await fateMirror.tokenURI(0n);
      const meta1 = decodeTokenMetadata(uri1);
      expect(meta1.description).to.include("childhood");

      await fateMirror.connect(user2).startStory();
      for (let i = 0; i < 3; i += 1) await fateMirror.connect(user2).makeChoice(1);
      await fateMirror.connect(user2).makeChoice(1);
      await fateMirror.connect(user2).finalizeAndMintNFT();
      const uri2 = await fateMirror.tokenURI(1n);
      const meta2 = decodeTokenMetadata(uri2);
      expect(meta2.description).to.include("unstoppable dreamer");
    });
  });
});
