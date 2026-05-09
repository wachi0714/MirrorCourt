// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MirrorCourt is ERC721, ERC721URIStorage {
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

    string public constant ENDING_1 = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#ffd700"/><text x="50%" y="50%" font-size="32" fill="#000" text-anchor="middle">Childhood Wonder</text></svg>';
    string public constant ENDING_2 = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#ff4500"/><text x="50%" y="50%" font-size="32" fill="#fff" text-anchor="middle">Blazing Youth</text></svg>';
    string public constant ENDING_3 = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#191970"/><text x="50%" y="50%" font-size="32" fill="#fff" text-anchor="middle">Settled Midlife</text></svg>';
    string public constant ENDING_4 = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#ffffff"/><text x="50%" y="50%" font-size="32" fill="#000" text-anchor="middle">Shattered Serenity</text></svg>';

    constructor() ERC721("Mirror Court", "MIRROR") {
        scenes.push(Scene(
            "You stand before a magic mirror. Draw a spiral or a straight line.",
            ["Draw spiral", "Draw straight line"],
            [1, 1]
        ));

        scenes.push(Scene(
            "The mirror shows your life path. What attitude do you choose?",
            ["Encourage adventure", "Choose stability"],
            [2, 2]
        ));

        scenes.push(Scene(
            "Regret emerges. Which do you feel more deeply?",
            ["Regret words unsaid", "Regret things done"],
            [3, 3]
        ));

        scenes.push(Scene(
            "Final choice. Which ending do you accept?",
            ["Childhood Wonder", "Blazing Youth", "Settled Midlife", "Shattered Serenity"],
            [99, 99, 99, 99]
        ));
    }

    function startStory() public {
        require(!players[msg.sender].isStarted, "Story already started");
        players[msg.sender] = PlayerStory({
            currentScene: 0,
            choices: new uint8[](0),
            isStarted: true,
            isCompleted: false
        });
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
    }

    function getCurrentScene() public view returns (string memory, string[] memory) {
        PlayerStory storage story = players[msg.sender];
        require(story.isStarted, "No active story");
        
        // 你要的修复：已结束故事返回提示
        if (story.isCompleted) {
            return ("故事已结束，请铸造 NFT 查看最终画面。", new string[](0));
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
        _setTokenURI(tokenId, generateURI(msg.sender));
    }

    function _generateArtByChoicePath(uint8[] memory choices) internal pure returns (string memory) {
        uint8 finalChoice = choices[3];
        if (finalChoice == 0) return ENDING_1;
        if (finalChoice == 1) return ENDING_2;
        if (finalChoice == 2) return ENDING_3;
        return ENDING_4;
    }

    function generateURI(address user) public view returns (string memory) {
        uint8[] memory choices = players[user].choices;
        string memory svg = _generateArtByChoicePath(choices);
        string memory description;

        if (choices[3] == 0) {
            description = "Childhood Wonder: You return to carefree days, where the world is always bright.";
        } else if (choices[3] == 1) {
            description = "Blazing Youth: Passion burns like fire; you become an unstoppable dreamer.";
        } else if (choices[3] == 2) {
            description = "Settled Midlife: Rings record years; wisdom is as deep as a lake.";
        } else {
            description = "Shattered Serenity: All mirrors shatter; you find quiet stillness in nothingness.";
        }

        string memory json = string(abi.encodePacked(
            '{"name":"Mirror Court #', Strings.toString(_tokenIdCounter.current() - 1), '",',
            '"description":"', description, '",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

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
