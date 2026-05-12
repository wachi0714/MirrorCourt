const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MirrorCourt Contract Tests (Complete Coverage)", function () {
  let mirrorCourt;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    const MirrorCourt = await ethers.getContractFactory("MirrorCourt");
    mirrorCourt = await MirrorCourt.deploy();
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Story Initialization", function () {
    it("✅ Should start a new story successfully", async function () {
      await mirrorCourt.startStory();
      const [currentScene, choices, isStarted, isCompleted] = await mirrorCourt.getStoryState();
      expect(isStarted).to.equal(true);
      expect(currentScene).to.equal(0);
      expect(choices.length).to.equal(0);
      expect(isCompleted).to.equal(false);
    });

    it("❌ Should revert when starting story twice", async function () {
      await mirrorCourt.startStory();
      await expect(mirrorCourt.startStory()).to.be.revertedWith("Story already started");
    });

    it("✅ Should return correct initial scene", async function () {
      await mirrorCourt.startStory();
      const [description, options] = await mirrorCourt.getCurrentScene();
      expect(description).to.equal("You stand before a magic mirror. Draw a spiral or a straight line.");
      expect(options.length).to.equal(2);
      expect(options[0]).to.equal("Draw spiral");
      expect(options[1]).to.equal("Draw straight line");
    });
  });

  describe("Story Flow - All Paths", function () {
    it("✅ Should complete story with path 0-0-0-0 (Childhood Wonder)", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);

      const [currentScene, choices, isStarted, isCompleted] = await mirrorCourt.getStoryState();
      expect(isCompleted).to.equal(true);
      expect(choices.length).to.equal(4);
      expect(choices[3]).to.equal(0);
    });

    it("✅ Should complete story with path 1-1-1-1 (Blazing Youth)", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(1);

      const [currentScene, choices, isStarted, isCompleted] = await mirrorCourt.getStoryState();
      expect(isCompleted).to.equal(true);
      expect(choices[3]).to.equal(1);
    });

    it("✅ Should complete story with path 0-1-0-2 (Settled Midlife)", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(2);

      const [currentScene, choices, isStarted, isCompleted] = await mirrorCourt.getStoryState();
      expect(isCompleted).to.equal(true);
      expect(choices[3]).to.equal(2);
    });

    it("✅ Should complete story with path 1-0-1-3 (Shattered Serenity)", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(3);

      const [currentScene, choices, isStarted, isCompleted] = await mirrorCourt.getStoryState();
      expect(isCompleted).to.equal(true);
      expect(choices[3]).to.equal(3);
    });
  });

  describe("Scene Navigation", function () {
    it("✅ Should return completion message when story ends", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);

      const [description, options] = await mirrorCourt.getCurrentScene();
      expect(description).to.equal("Story completed. Mint your NFT to see the final reflection.");
      expect(options.length).to.equal(0);
    });

    it("❌ Should revert when making choice on non-started story", async function () {
      await expect(mirrorCourt.makeChoice(0)).to.be.revertedWith("No active story");
    });

    it("❌ Should revert when making choice with invalid index", async function () {
      await mirrorCourt.startStory();
      // Scene 0 has 2 options (0-1), so 2 is invalid
      await expect(mirrorCourt.makeChoice(2)).to.be.revertedWith("Invalid choice");
    });

    it("❌ Should revert when making choice after story completed", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);

      await expect(mirrorCourt.makeChoice(0)).to.be.revertedWith("Story already completed");
    });
  });

  describe("NFT Minting", function () {
    it("✅ Should mint NFT after story completion", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);

      await mirrorCourt.finalizeAndMintNFT();
      const balance = await mirrorCourt.balanceOf(owner.address);
      expect(balance).to.equal(1);
    });

    it("✅ Should have correct NFT metadata for Childhood Wonder", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);

      await mirrorCourt.finalizeAndMintNFT();
      const tokenURI = await mirrorCourt.tokenURI(0);
      
      expect(tokenURI).to.include("data:application/json;base64");
      expect(tokenURI).to.include("Childhood Wonder");
      expect(tokenURI).to.include("image");
    });

    it("✅ Should have correct NFT metadata for Blazing Youth", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(1);
      await mirrorCourt.makeChoice(1);

      await mirrorCourt.finalizeAndMintNFT();
      const tokenURI = await mirrorCourt.tokenURI(0);
      
      expect(tokenURI).to.include("Blazing Youth");
    });

    it("❌ Should revert when minting NFT before story completion", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);

      await expect(mirrorCourt.finalizeAndMintNFT()).to.be.revertedWith("Story not completed");
    });

    it("❌ Should revert when minting NFT multiple times", async function () {
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      
      await mirrorCourt.finalizeAndMintNFT();
      await expect(mirrorCourt.finalizeAndMintNFT()).to.be.revertedWith("Already minted NFT");
    });
  });

  describe("Multi-Player Support", function () {
    it("✅ Should allow multiple independent players", async function () {
      // Player 1
      await mirrorCourt.startStory();
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.makeChoice(0);
      await mirrorCourt.finalizeAndMintNFT();

      // Player 2
      await mirrorCourt.connect(addr1).startStory();
      await mirrorCourt.connect(addr1).makeChoice(1);
      await mirrorCourt.connect(addr1).makeChoice(1);
      await mirrorCourt.connect(addr1).makeChoice(1);
      await mirrorCourt.connect(addr1).makeChoice(1);
      await mirrorCourt.connect(addr1).finalizeAndMintNFT();

      // Verify both minted NFTs
      const ownerBalance = await mirrorCourt.balanceOf(owner.address);
      const addr1Balance = await mirrorCourt.balanceOf(addr1.address);
      
      expect(ownerBalance).to.equal(1);
      expect(addr1Balance).to.equal(1);

      // Verify different metadata
      const tokenURI0 = await mirrorCourt.tokenURI(0);
      const tokenURI1 = await mirrorCourt.tokenURI(1);
      
      expect(tokenURI0).to.include("Childhood Wonder");
      expect(tokenURI1).to.include("Blazing Youth");
    });
  });

  describe("Contract State", function () {
    it("✅ Should have correct contract name and symbol", async function () {
      const name = await mirrorCourt.name();
      const symbol = await mirrorCourt.symbol();
      
      expect(name).to.equal("Mirror Court");
      expect(symbol).to.equal("MIRROR");
    });

    it("✅ Should support ERC721 interface", async function () {
      const ERC721_INTERFACE = "0x80ac58cd";
      const isSupported = await mirrorCourt.supportsInterface(ERC721_INTERFACE);
      expect(isSupported).to.be.true;
    });
  });
});
