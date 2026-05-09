// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FateMirror is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct Scene {
        string description;
        string[] options;
        uint8[] nextScenes;
    }

    struct PlayerStory {
        uint8 currentScene;
        uint8[] choices;
        bool isStarted;
        bool isCompleted;
    }

    Scene[] public scenes;
    mapping(address => PlayerStory) public players;

    // Four ending SVG artworks (Member B will replace with real art)
    string public constant ENDING_CHILDHOOD = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#FFD700"/><circle cx="250" cy="250" r="100" fill="#FF8C00"/><path d="M100 400 L400 400" stroke="#FF4500" stroke-width="10"/><text x="50%" y="80%" font-size="24" fill="#fff" text-anchor="middle">Childhood · Rainbow</text></svg>';
    string public constant ENDING_YOUTH = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="url(#grad)"/><defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#FF4500"/><stop offset="100%" stop-color="#FFD700"/></linearGradient></defs><path d="M150 350 L250 150 L350 350" fill="none" stroke="#fff" stroke-width="8"/><text x="50%" y="80%" font-size="24" fill="#fff" text-anchor="middle">Youth · Flame</text></svg>';
    string public constant ENDING_MIDLIFE = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#191970"/><circle cx="250" cy="250" r="120" fill="none" stroke="#8FBC8F" stroke-width="6"/><circle cx="250" cy="250" r="80" fill="none" stroke="#8FBC8F" stroke-width="6"/><circle cx="250" cy="250" r="40" fill="none" stroke="#8FBC8F" stroke-width="6"/><text x="50%" y="80%" font-size="24" fill="#fff" text-anchor="middle">Midlife · Rings</text></svg>';
    string public constant ENDING_SHATTER = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#FFFFFF"/><polygon points="250,100 300,150 280,220 200,200 180,150" fill="#E0E0E0" stroke="#999" stroke-width="2"/><polygon points="350,250 420,280 380,350 300,320" fill="#D0D0D0" stroke="#999" stroke-width="2"/><polygon points="100,300 180,330 120,400 60,370" fill="#C0C0C0" stroke="#999" stroke-width="2"/><text x="50%" y="80%" font-size="24" fill="#000" text-anchor="middle">Shattered · Serenity</text></svg>';

    event StoryStarted(address indexed user);
    event ChoiceMade(address indexed user, uint8 choice, uint8 newScene);
    event NFTMinted(address indexed user, uint256 tokenId);

    constructor() ERC721("FateMirror", "MIRROR") {
        // Scene 0: Starting point
        string[] memory opts0 = new string[](2);
        opts0[0] = "Draw a spiral";
        opts0[1] = "Draw a straight line";
        uint8[] memory next0 = new uint8[](2);
        next0[0] = 1;
        next0[1] = 1;
        scenes.push(Scene("You stand before a magic mirror. The surface trembles like water, waiting for your first stroke. Draw a spiral, or a straight line?", opts0, next0));

        // Scene 1: Life attitude
        string[] memory opts1 = new string[](2);
        opts1[0] = "Encourage adventure";
        opts1[1] = "Choose stability";
        uint8[] memory next1 = new uint8[](2);
        next1[0] = 2;
        next1[1] = 2;
        scenes.push(Scene("The reflection in the mirror begins to shift. It asks you: Life is short. Would you rather encourage yourself to take risks, or protect what is safe?", opts1, next1));

        // Scene 2: Regret
        string[] memory opts2 = new string[](2);
        opts2[0] = "Regret words unsaid";
        opts2[1] = "Regret things done";
        uint8[] memory next2 = new uint8[](2);
        next2[0] = 3;
        next2[1] = 3;
        scenes.push(Scene("Ripples spread across the water. Regret surfaces. Which hurts more deeply?", opts2, next2));

        // Scene 3: Final choice (four endings)
        string[] memory opts3 = new string[](4);
        opts3[0] = "Childhood";
        opts3[1] = "Youth";
        opts3[2] = "Midlife";
        opts3[3] = "Present Serenity";
        uint8[] memory next3 = new uint8[](4);
        next3[0] = 99;
        next3[1] = 99;
        next3[2] = 99;
        next3[3] = 99;
        scenes.push(Scene("Four mirrored doors open before you. Which one do you push open?", opts3, next3));
    }

    function startStory() public {
        require(!players[msg.sender].isStarted, "Story already started");
        players[msg.sender] = PlayerStory({
            currentScene: 0,
            choices: new uint8[](0),
            isStarted: true,
            isCompleted: false
        });
        emit StoryStarted(msg.sender);
    }

    function makeChoice(uint8 choice) public {
        PlayerStory storage story = players[msg.sender];
        require(story.isStarted, "Story not started");
        require(!story.isCompleted, "Story already completed");
        require(choice < scenes[story.currentScene].options.length, "Invalid choice");

        story.choices.push(choice);
        story.currentScene = scenes[story.currentScene].nextScenes[choice];

        if (story.currentScene == 99) {
            story.isCompleted = true;
        }
        emit ChoiceMade(msg.sender, choice, story.currentScene);
    }

    // ✅ Fixed: completed story does not crash
    function getCurrentScene() public view returns (string memory, string[] memory) {
        PlayerStory storage story = players[msg.sender];
        require(story.isStarted, "No active story");
        if (story.isCompleted) {
            string[] memory empty = new string[](0);
            return ("The story has ended. Mint your NFT to see your final reflection.", empty);
        }
        Scene storage s = scenes[story.currentScene];
        return (s.description, s.options);
    }

    function getStoryState() public view returns (uint8, uint8[] memory, bool, bool) {
        PlayerStory memory s = players[msg.sender];
        return (s.currentScene, s.choices, s.isStarted, s.isCompleted);
    }

    function finalizeAndMintNFT() public {
        PlayerStory storage story = players[msg.sender];
        require(story.isCompleted, "Story not completed");
        require(balanceOf(msg.sender) == 0, "Already minted NFT");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _generateURI(tokenId, story.choices));
        emit NFTMinted(msg.sender, tokenId);
    }

    function _generateArtByChoicePath(uint8[] memory choices) internal pure returns (string memory) {
        uint8 finalChoice = choices[3];
        if (finalChoice == 0) return ENDING_CHILDHOOD;
        if (finalChoice == 1) return ENDING_YOUTH;
        if (finalChoice == 2) return ENDING_MIDLIFE;
        return ENDING_SHATTER;
    }

    function _generateURI(uint256 tokenId, uint8[] memory choices) internal view returns (string memory) {
        string memory svg = _generateArtByChoicePath(choices);
        string memory description;
        if (choices[3] == 0) {
            description = "You return to carefree childhood, crayons painting rainbows, the world forever bright.";
        } else if (choices[3] == 1) {
            description = "Blazing passion surges within you. You become an unstoppable dreamer.";
        } else if (choices[3] == 2) {
            description = "Tree rings record the years. Wisdom is as deep as a still lake.";
        } else {
            description = "All mirrors shatter. You find nothing at all, only the quiet serenity of pure white.";
        }

        string memory json = string(abi.encodePacked(
            '{"name":"FateMirror #', Strings.toString(tokenId), '",',
            '"description":"', description, '",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ));
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    // Overrides required by ERC721URIStorage
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
