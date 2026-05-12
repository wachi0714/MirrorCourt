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

    string public constant ENDING_CHILDHOOD = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#FFD700"/><circle cx="250" cy="250" r="100" fill="#FF8C00"/><path d="M100 400 L400 400" stroke="#FF4500" stroke-width="10"/><text x="50%" y="80%" font-size="24" fill="#fff" text-anchor="middle">Childhood Rainbow</text></svg>';
    string public constant ENDING_YOUTH = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="url(#grad)"/><defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#FF4500"/><stop offset="100%" stop-color="#FFD700"/></linearGradient></defs><path d="M150 350 L250 150 L350 350" fill="none" stroke="#fff" stroke-width="8"/><text x="50%" y="80%" font-size="24" fill="#fff" text-anchor="middle">Youth Flame</text></svg>';
    string public constant ENDING_MIDLIFE = '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg"><rect width="500" height="500" fill="#191970"/><circle cx="250" cy="250" r="120" fill="none" stroke="#8FBC8F" stroke-width="6"/><circle cx="250" cy="250" r="80" fill="none" stroke="#8FBC8F" stroke-width="6"/><circle cx="250" cy="250" r="40" fill="none" stroke="#8FBC8F" stroke-width="6"/><text x="50%" y="80%" font-size="24" fill="#fff" text-anchor="middle">Midlife Rings</text></svg>';
    string public constant ENDING_SHATTER = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 500 500"><defs><linearGradient id="ssBg" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stop-color="#05070c"/><stop offset="55%" stop-color="#0b1119"/><stop offset="100%" stop-color="#020406"/></linearGradient><radialGradient id="ssClouds" cx="50%" cy="30%" r="60%"><stop offset="0%" stop-color="#7f909b" stop-opacity="0.72"/><stop offset="45%" stop-color="#314452" stop-opacity="0.35"/><stop offset="100%" stop-color="#0b1119" stop-opacity="0"/></radialGradient><radialGradient id="ssSeaGlow" cx="50%" cy="56%" r="42%"><stop offset="0%" stop-color="#9fb4bf" stop-opacity="0.35"/><stop offset="55%" stop-color="#58707d" stop-opacity="0.12"/><stop offset="100%" stop-color="#0a0f14" stop-opacity="0"/></radialGradient><radialGradient id="ssRingGlow" cx="50%" cy="50%" r="58%"><stop offset="0%" stop-color="#4f6672" stop-opacity="0.05"/><stop offset="60%" stop-color="#6f8792" stop-opacity="0.12"/><stop offset="100%" stop-color="#c1d3da" stop-opacity="0"/></radialGradient><clipPath id="ssCircleClip"><circle cx="250" cy="250" r="170"/></clipPath></defs><rect width="500" height="500" fill="url(#ssBg)"/><ellipse cx="250" cy="120" rx="220" ry="90" fill="url(#ssClouds)" opacity="0.95"/><ellipse cx="250" cy="355" rx="175" ry="95" fill="url(#ssSeaGlow)" opacity="0.7"/><g clip-path="url(#ssCircleClip)"><rect x="80" y="80" width="340" height="340" fill="#0a1017" opacity="0.55"/><rect x="100" y="120" width="300" height="220" fill="#0c131a" opacity="0.85"/><path d="M80 270 C120 245 145 250 175 260 C205 270 230 262 255 252 C280 242 305 240 335 250 C365 260 390 258 420 242 L420 500 L80 500 Z" fill="#101820" opacity="0.96"/><path d="M80 278 C115 264 142 268 174 276 C206 284 229 277 253 267 C278 257 304 255 336 264 C368 273 392 272 420 260" stroke="#4a6170" stroke-width="2" opacity="0.35" fill="none"/><path d="M80 292 C115 278 145 282 175 290 C205 298 229 292 252 282 C277 272 304 271 336 279 C368 287 392 286 420 274" stroke="#90a8b2" stroke-width="1.5" opacity="0.22" fill="none"/><path d="M110 240 C145 228 172 230 202 242 C231 254 260 255 292 244 C325 233 352 232 388 246" stroke="#7f8f99" stroke-width="1.5" opacity="0.25" fill="none"/><path d="M130 300 C160 287 188 289 220 300 C250 311 279 310 310 300 C340 290 365 289 385 296" stroke="#5f7480" stroke-width="1.2" opacity="0.18" fill="none"/><path d="M180 90 L150 330 L165 352 L210 80 Z" fill="#0a0f15" opacity="0.9"/><path d="M215 78 L205 340 L223 360 L246 82 Z" fill="#05080c" opacity="0.92"/><path d="M255 86 L250 345 L266 360 L272 88 Z" fill="#11181f" opacity="0.86"/><path d="M286 80 L315 336 L300 356 L262 84 Z" fill="#05080c" opacity="0.9"/><path d="M335 112 L355 212 L342 232 L324 124 Z" fill="#0d1319" opacity="0.85"/><path d="M123 232 L145 246 L132 270 L104 254 Z" fill="#111a21" opacity="0.82"/><path d="M350 286 L386 302 L374 322 L342 304 Z" fill="#151d24" opacity="0.8"/><path d="M104 344 L136 330 L150 360 L114 374 Z" fill="#0b1016" opacity="0.8"/><path d="M245 240 L268 228 L280 250 L252 262 Z" fill="#b8cbd4" opacity="0.14"/><path d="M188 252 L205 246 L214 264 L196 273 Z" fill="#d5e3ea" opacity="0.11"/><path d="M310 260 L330 253 L339 271 L321 282 Z" fill="#d3e0e6" opacity="0.1"/></g><circle cx="250" cy="250" r="194" fill="none" stroke="#0e1116" stroke-width="14"/><circle cx="250" cy="250" r="186" fill="none" stroke="#313b44" stroke-width="2" opacity="0.65"/><circle cx="250" cy="250" r="176" fill="none" stroke="url(#ssRingGlow)" stroke-width="10" opacity="0.95"/><circle cx="250" cy="250" r="164" fill="none" stroke="#141a1f" stroke-width="3" opacity="0.92"/><path d="M250 92 L236 172 L246 255 L238 392" stroke="#eef7fb" stroke-width="2.6" opacity="0.75" fill="none" stroke-linecap="round"/><path d="M256 98 L270 175 L263 251 L271 387" stroke="#7f95a0" stroke-width="1.4" opacity="0.7" fill="none" stroke-linecap="round"/><path d="M250 102 L258 175 L252 248 L257 390" stroke="#d6e4ea" stroke-width="1.1" opacity="0.45" fill="none" stroke-linecap="round"/><path d="M245 120 L222 180 L226 238 L214 325" stroke="#d6e3ea" stroke-width="1.2" opacity="0.28" fill="none"/><path d="M258 128 L279 186 L275 241 L288 320" stroke="#a9bec9" stroke-width="1.1" opacity="0.22" fill="none"/><path d="M238 286 L251 246 L263 286 L252 330 Z" fill="#e8f2f6" opacity="0.28"/><path d="M166 176 L188 158 L182 194 L162 206 Z" fill="#aebfc8" opacity="0.18"/><path d="M346 164 L330 150 L326 190 L346 200 Z" fill="#96aab5" opacity="0.16"/><path d="M122 304 L142 294 L132 332 L114 344 Z" fill="#d7e3ea" opacity="0.14"/><path d="M374 306 L388 296 L396 332 L378 342 Z" fill="#bfcdd5" opacity="0.12"/><path d="M180 242 L200 232 L212 252 L188 264 Z" fill="#dfe9ee" opacity="0.11"/><path d="M296 238 L320 230 L330 252 L306 266 Z" fill="#dfe9ee" opacity="0.11"/><text x="250" y="456" text-anchor="middle" font-family="Georgia, serif" font-size="18" fill="#c5d5dc" font-style="italic">Shattered Serenity</text></svg>';

    event StoryStarted(address indexed user);
    event ChoiceMade(address indexed user, uint8 choice, uint8 newScene);
    event NFTMinted(address indexed user, uint256 tokenId);

    constructor() ERC721("FateMirror", "MIRROR") {
        string[] memory opts0 = new string[](2);
        opts0[0] = "Draw a spiral";
        opts0[1] = "Draw a straight line";
        uint8[] memory next0 = new uint8[](2);
        next0[0] = 1;
        next0[1] = 1;
        scenes.push(Scene("You stand before a magic mirror. The surface trembles like water, waiting for your first stroke. Draw a spiral, or a straight line?", opts0, next0));

        string[] memory opts1 = new string[](2);
        opts1[0] = "Encourage adventure";
        opts1[1] = "Choose stability";
        uint8[] memory next1 = new uint8[](2);
        next1[0] = 2;
        next1[1] = 2;
        scenes.push(Scene("The reflection in the mirror begins to shift. It asks you: Life is short. Would you rather encourage yourself to take risks, or protect what is safe?", opts1, next1));

        string[] memory opts2 = new string[](2);
        opts2[0] = "Regret words unsaid";
        opts2[1] = "Regret things done";
        uint8[] memory next2 = new uint8[](2);
        next2[0] = 3;
        next2[1] = 3;
        scenes.push(Scene("Ripples spread across the water. Regret surfaces. Which hurts more deeply?", opts2, next2));

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
        require(choices.length >= 4, "Invalid story choices");

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

        string memory json = string(
            abi.encodePacked(
                '{"name":"FateMirror #',
                Strings.toString(tokenId),
                '","description":"',
                description,
                '","image":"data:image/svg+xml;base64,',
                Base64.encode(bytes(svg)),
                '"}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
