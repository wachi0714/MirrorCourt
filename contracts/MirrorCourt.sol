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

    // 4 Ending SVGs - Complete versions with full artwork
    string public constant ENDING_1 = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 500 500"><defs><radialGradient id="skyGlow" cx="50%" cy="35%" r="60%"><stop offset="0%" stop-color="#6EC6F5" stop-opacity="0.9"/><stop offset="40%" stop-color="#1A4A9C"/><stop offset="100%" stop-color="#0B0E2E"/></radialGradient><radialGradient id="galaxyCore" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="#FFFDE4" stop-opacity="1"/><stop offset="40%" stop-color="#A8D8F0" stop-opacity="0.8"/><stop offset="100%" stop-color="#1A4A9C" stop-opacity="0"/></radialGradient><radialGradient id="groundGrad" cx="50%" cy="0%" r="100%"><stop offset="0%" stop-color="#C87941"/><stop offset="100%" stop-color="#5A3010"/></radialGradient></defs><rect width="500" height="500" fill="url(#skyGlow)"/><ellipse cx="80" cy="420" rx="200" ry="80" fill="#5B2D8E" opacity="0.45"/><ellipse cx="430" cy="380" rx="160" ry="70" fill="#3A1C72" opacity="0.5"/><ellipse cx="360" cy="160" rx="130" ry="55" fill="#2255A4" opacity="0.4"/><ellipse cx="130" cy="200" rx="110" ry="45" fill="#1B3A8C" opacity="0.35"/><circle cx="250" cy="165" r="55" fill="url(#galaxyCore)" opacity="0.85"/><circle cx="250" cy="165" r="28" fill="#FFFDE4" opacity="0.7"/><circle cx="250" cy="165" r="12" fill="#FFFFFF" opacity="0.95"/><g fill="#FFFFFF"><circle cx="60" cy="40" r="1.5" opacity="0.9"/><circle cx="110" cy="70" r="1" opacity="0.8"/><circle cx="170" cy="30" r="1.8" opacity="0.85"/><circle cx="200" cy="90" r="1" opacity="0.7"/><circle cx="310" cy="55" r="1.5" opacity="0.9"/><circle cx="370" cy="30" r="1" opacity="0.8"/><circle cx="420" cy="80" r="2" opacity="0.75"/></g><path d="M0 370 Q120 320 250 335 Q380 350 500 310 L500 500 L0 500 Z" fill="url(#groundGrad)"/><circle cx="50" cy="375" r="5" fill="#E8334A"/><circle cx="75" cy="365" r="4" fill="#FFFFFF"/><circle cx="100" cy="372" r="5" fill="#E8334A"/><circle cx="125" cy="362" r="4" fill="#4A90D9"/><circle cx="148" cy="370" r="5" fill="#FF6B6B"/><circle cx="170" cy="360" r="4" fill="#E8334A"/><circle cx="355" cy="365" r="5" fill="#4A90D9"/><circle cx="380" cy="373" r="4" fill="#E8334A"/><circle cx="400" cy="362" r="5" fill="#FF9ECD"/><circle cx="425" cy="370" r="4" fill="#4A90D9"/><circle cx="450" cy="360" r="5" fill="#E8334A"/><circle cx="472" cy="368" r="4" fill="#FFFFFF"/><rect x="233" y="400" width="14" height="55" rx="6" fill="#5A1A1A"/><rect x="253" y="400" width="14" height="55" rx="6" fill="#5A1A1A"/><rect x="225" y="340" width="50" height="65" rx="10" fill="#2A7DC0"/><path d="M225 355 Q205 375 210 395" stroke="#2A7DC0" stroke-width="13" fill="none" stroke-linecap="round"/><path d="M275 355 Q295 375 290 395" stroke="#2A7DC0" stroke-width="13" fill="none" stroke-linecap="round"/><rect x="243" y="325" width="14" height="18" rx="5" fill="#E8C49A"/><ellipse cx="250" cy="312" rx="22" ry="24" fill="#E8C49A"/><ellipse cx="250" cy="295" rx="22" ry="14" fill="#D4A843"/><ellipse cx="238" cy="293" rx="10" ry="10" fill="#C89630"/><ellipse cx="262" cy="292" rx="9" ry="9" fill="#DEB84A"/><ellipse cx="250" cy="289" rx="14" ry="8" fill="#E8C855"/><text x="250" y="478" text-anchor="middle" font-family="Georgia, serif" font-size="18" fill="#C8E8FF" font-weight="bold" opacity="0.95">✨ Childhood Wonder</text></svg>';
    
    string public constant ENDING_2 = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 500 500"><defs><radialGradient id="sky" cx="50%" cy="45%" r="65%"><stop offset="0%" stop-color="#FFE566"/><stop offset="45%" stop-color="#FF8C00"/><stop offset="100%" stop-color="#CC2200"/></radialGradient><linearGradient id="streetGrad" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stop-color="#5A3A10"/><stop offset="50%" stop-color="#3A2208" stop-opacity="0.9"/><stop offset="100%" stop-color="#1A1008"/></linearGradient></defs><rect width="500" height="500" fill="url(#sky)"/><rect x="0" y="0" width="160" height="220" fill="#CC2200" opacity="0.45"/><rect x="340" y="0" width="160" height="200" fill="#1A6AAA" opacity="0.55"/><ellipse cx="250" cy="140" rx="130" ry="90" fill="#FFE566" opacity="0.45"/><rect x="0" y="30" width="110" height="280" fill="#CC3300"/><rect x="390" y="30" width="110" height="280" fill="#1A6AAA"/><rect x="10" y="50" width="13" height="16" fill="#FFD700" opacity="0.7"/><rect x="30" y="55" width="13" height="16" fill="#FFD700" opacity="0.55"/><rect x="50" y="48" width="13" height="16" fill="#FFD700" opacity="0.65"/><rect x="10" y="82" width="13" height="16" fill="#FFD700" opacity="0.45"/><rect x="35" y="88" width="13" height="16" fill="#FFD700" opacity="0.6"/><rect x="0" y="130" width="75" height="180" fill="#AA2200" opacity="0.75"/><rect x="90" y="90" width="65" height="220" fill="#FF7733" opacity="0.85"/><rect x="400" y="50" width="13" height="16" fill="#FFD700" opacity="0.65"/><rect x="422" y="55" width="13" height="16" fill="#FFD700" opacity="0.5"/><rect x="448" y="48" width="13" height="16" fill="#FFD700" opacity="0.7"/><polygon points="155,500 345,500 278,268 222,268" fill="url(#streetGrad)"/><polygon points="247,500 253,500 251,268 249,268" fill="#FFB800" opacity="0.35"/><ellipse cx="205" cy="440" rx="28" ry="7" fill="#FF9900" opacity="0.38"/><ellipse cx="300" cy="420" rx="22" ry="6" fill="#FF6600" opacity="0.32"/><polygon points="0,295 155,295 155,500 0,500" fill="#6B4820" opacity="0.55"/><polygon points="345,295 500,295 500,500 345,500" fill="#6B4820" opacity="0.55"/><circle cx="100" cy="305" r="13" fill="#E8C49A"/><path d="M87 303 Q100 288 113 303 L113 310 Q100 306 87 310Z" fill="#8B4513"/><rect x="87" y="300" width="26" height="5" rx="2" fill="#FF4466" opacity="0.85"/><rect x="90" y="318" width="20" height="30" rx="4" fill="#7EC8E3"/><line x1="90" y1="324" x2="72" y2="335" stroke="#E8C49A" stroke-width="6" stroke-linecap="round"/><line x1="110" y1="322" x2="126" y2="330" stroke="#E8C49A" stroke-width="6" stroke-linecap="round"/><rect x="90" y="346" width="9" height="22" rx="3" fill="#2A4A7A"/><rect x="101" y="346" width="9" height="22" rx="3" fill="#2A4A7A"/><circle cx="222" cy="290" r="15" fill="#8B5A2B"/><path d="M207 288 Q222 273 237 288 Q233 277 222 275 Q211 277 207 288Z" fill="#1A0A00"/><rect x="210" y="305" width="24" height="40" rx="5" fill="#CC2200"/><line x1="210" y1="314" x2="188" y2="328" stroke="#CC2200" stroke-width="9" stroke-linecap="round"/><line x1="234" y1="312" x2="256" y2="305" stroke="#CC2200" stroke-width="9" stroke-linecap="round"/><rect x="210" y="343" width="10" height="28" rx="3" fill="#555"/><rect x="222" y="343" width="10" height="28" rx="3" fill="#555"/><rect x="198" y="378" width="48" height="9" rx="4" fill="#FF9900"/><circle cx="206" cy="387" r="5" fill="#222"/><circle cx="238" cy="387" r="5" fill="#222"/><text x="250" y="478" text-anchor="middle" font-family="Georgia, serif" font-size="18" fill="#FFE566" font-weight="bold">⚡ Blazing Youth</text></svg>';
    
    string public constant ENDING_3 = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 500 500"><defs><linearGradient id="sunsetSky" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stop-color="#7B3A10"/><stop offset="30%" stop-color="#D4601A"/><stop offset="60%" stop-color="#F0A030"/><stop offset="100%" stop-color="#FFD080"/></linearGradient><radialGradient id="sunGlow" cx="62%" cy="52%" r="18%"><stop offset="0%" stop-color="#FFF5A0" stop-opacity="1"/><stop offset="50%" stop-color="#FFB830" stop-opacity="0.6"/><stop offset="100%" stop-color="#FF8800" stop-opacity="0"/></radialGradient><linearGradient id="lakeGrad" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stop-color="#C07020"/><stop offset="40%" stop-color="#3A5A40"/><stop offset="100%" stop-color="#1A2A1E"/></linearGradient><linearGradient id="deckGrad" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stop-color="#8B5A2B"/><stop offset="100%" stop-color="#5A3010"/></linearGradient></defs><rect width="500" height="500" fill="url(#sunsetSky)"/><ellipse cx="80" cy="60" rx="120" ry="60" fill="#5A2010" opacity="0.4"/><ellipse cx="420" cy="80" rx="100" ry="55" fill="#AA4010" opacity="0.3"/><ellipse cx="250" cy="100" rx="180" ry="70" fill="#F0A030" opacity="0.2"/><circle cx="310" cy="195" r="22" fill="#FFF5A0" opacity="0.95"/><circle cx="310" cy="195" r="38" fill="#FFD060" opacity="0.4"/><rect width="500" height="500" fill="url(#sunGlow)" opacity="0.6"/><ellipse cx="250" cy="215" rx="280" ry="30" fill="#6A8070" opacity="0.5"/><rect x="0" y="185" width="18" height="35" rx="4" fill="#4A6050" opacity="0.6"/><rect x="14" y="178" width="20" height="42" rx="5" fill="#3A5040" opacity="0.6"/><rect x="30" y="182" width="16" height="38" rx="4" fill="#4A6050" opacity="0.55"/><rect x="44" y="175" width="18" height="45" rx="5" fill="#3A5040" opacity="0.6"/><rect x="340" y="172" width="18" height="48" rx="5" fill="#3A5040" opacity="0.6"/><rect x="356" y="178" width="16" height="42" rx="4" fill="#4A6050" opacity="0.55"/><rect x="370" y="170" width="20" height="50" rx="5" fill="#3A5040" opacity="0.6"/><rect x="18" y="270" width="8" height="100" fill="#3A2010"/><rect x="52" y="260" width="9" height="110" fill="#3A2010"/><polygon points="22,270 2,310 42,310" fill="#1E4020"/><polygon points="22,248 -2,295 46,295" fill="#246030"/><polygon points="22,228 0,278 44,278" fill="#2A7040"/><polygon points="22,210 2,260 42,260" fill="#1E4828"/><polygon points="56,260 34,302 78,302" fill="#1E4020"/><polygon points="56,238 30,288 82,288" fill="#246030"/><polygon points="56,218 32,272 80,272" fill="#2A7040"/><polygon points="56,200 34,254 78,254" fill="#1E4828"/><rect x="420" y="250" width="8" height="120" fill="#3A2010"/><rect x="455" y="240" width="9" height="130" fill="#3A2010"/><rect x="484" y="255" width="8" height="115" fill="#3A2010"/><polygon points="424,250 402,295 446,295" fill="#1E4020"/><polygon points="424,228 398,280 450,280" fill="#246030"/><polygon points="424,208 400,264 448,264" fill="#2A7040"/><polygon points="424,190 402,248 446,248" fill="#1E4828"/><ellipse cx="260" cy="295" rx="175" ry="55" fill="url(#lakeGrad)"/><ellipse cx="295" cy="295" rx="28" ry="10" fill="#FFD060" opacity="0.7"/><ellipse cx="295" cy="295" rx="12" ry="4" fill="#FFFAA0" opacity="0.9"/><line x1="140" y1="288" x2="200" y2="290" stroke="#C07830" stroke-width="1.5" opacity="0.45"/><line x1="145" y1="296" x2="215" y2="298" stroke="#A06020" stroke-width="1.5" opacity="0.4"/><line x1="340" y1="286" x2="400" y2="289" stroke="#C07830" stroke-width="1.5" opacity="0.4"/><rect x="0" y="350" width="500" height="150" fill="url(#deckGrad)"/><line x1="0" y1="365" x2="500" y2="365" stroke="#6B4010" stroke-width="1.5" opacity="0.5"/><line x1="0" y1="382" x2="500" y2="382" stroke="#6B4010" stroke-width="1.5" opacity="0.5"/><line x1="0" y1="399" x2="500" y2="399" stroke="#6B4010" stroke-width="1.5" opacity="0.4"/><line x1="0" y1="418" x2="500" y2="418" stroke="#6B4010" stroke-width="1.5" opacity="0.4"/><rect x="0" y="348" width="500" height="8" rx="2" fill="#B0B8C0"/><rect x="0" y="370" width="500" height="5" rx="1" fill="#909AA0" opacity="0.8"/><rect x="20" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="50" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="80" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="110" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="140" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="170" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="200" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="230" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="260" y="348" width="4" height="30" rx="1" fill="#8A9298"/><rect x="290" y="348" width="4" height="30" rx="1" fill="#8A9298"/><ellipse cx="155" cy="430" rx="45" ry="10" fill="#2A1A08" opacity="0.4"/><rect x="128" y="380" width="18" height="90" rx="5" fill="#1E2A3A"/><rect x="148" y="380" width="18" height="90" rx="5" fill="#253040"/><rect x="125" y="378" width="44" height="6" rx="2" fill="#1A1008"/><rect x="120" y="290" width="52" height="95" rx="8" fill="#B07830"/><polygon points="152,290 162,290 160,350 148,350" fill="#E8DCC8" opacity="0.9"/><rect x="155" y="290" width="17" height="90" rx="5" fill="#D4A050" opacity="0.45"/><rect x="108" y="300" width="14" height="65" rx="6" fill="#A06820"/><path d="M170 330 Q190 345 200 352" stroke="#A06820" stroke-width="14" fill="none" stroke-linecap="round"/><ellipse cx="202" cy="354" rx="9" ry="6" fill="#C8945A"/><rect x="148" y="275" width="16" height="18" rx="4" fill="#C8945A"/><ellipse cx="162" cy="258" rx="24" ry="26" fill="#C8945A"/><path d="M140 248 Q150 228 175 232 Q185 240 178 248 Q168 238 155 240 Q145 244 140 248Z" fill="#3A3028"/><path d="M140 248 Q138 255 142 262 Q144 250 150 246" fill="#3A3028"/><ellipse cx="140" cy="260" rx="5" ry="7" fill="#B87848"/><ellipse cx="166" cy="256" rx="10" ry="7" fill="none" stroke="#5A4A30" stroke-width="2"/><line x1="156" y1="256" x2="145" y2="257" stroke="#5A4A30" stroke-width="2"/><path d="M175 262 Q182 268 178 275" stroke="#B07848" stroke-width="2.5" fill="none" stroke-linecap="round"/><path d="M175 275 Q178 285 172 292" stroke="#B07848" stroke-width="2" fill="none" stroke-linecap="round"/><ellipse cx="170" cy="260" rx="12" ry="14" fill="#FFB830" opacity="0.18"/><text x="250" y="488" text-anchor="middle" font-family="Georgia, serif" font-size="18" fill="#FFD080" font-weight="bold">🌲 Settled Midlife</text></svg>';
    
    string public constant ENDING_4 = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 500 500"><defs><linearGradient id="mirBg" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="#8E9BA8"/><stop offset="45%" stop-color="#C4A8B2"/><stop offset="100%" stop-color="#EEC8CC"/></linearGradient><radialGradient id="fGlow" cx="50%" cy="40%" r="45%"><stop offset="0%" stop-color="#FFFFFF"/><stop offset="35%" stop-color="#FFF5EE" stop-opacity="0.9"/><stop offset="75%" stop-color="#FFE8DC" stop-opacity="0.4"/><stop offset="100%" stop-color="#F0C8C0" stop-opacity="0"/></radialGradient><radialGradient id="cGlow" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="#FFFFFF"/><stop offset="50%" stop-color="#F8F8F0" stop-opacity="0.7"/><stop offset="100%" stop-color="#E0E8E8" stop-opacity="0"/></radialGradient></defs><rect width="500" height="500" fill="url(#mirBg)"/><ellipse cx="75" cy="95" rx="88" ry="55" fill="#8A97A4" opacity="0.5" transform="rotate(-15 75 95)"/><ellipse cx="125" cy="55" rx="65" ry="38" fill="#9DAAB5" opacity="0.4" transform="rotate(-22 125 55)"/><ellipse cx="38" cy="178" rx="58" ry="36" fill="#87969F" opacity="0.45" transform="rotate(12 38 178)"/><ellipse cx="160" cy="150" rx="55" ry="25" fill="#9AA5B0" opacity="0.3" transform="rotate(-8 160 150)"/><ellipse cx="418" cy="75" rx="95" ry="52" fill="#E4B2BC" opacity="0.55" transform="rotate(8 418 75)"/><ellipse cx="458" cy="138" rx="68" ry="42" fill="#ECC0C8" opacity="0.45" transform="rotate(-6 458 138)"/><ellipse cx="375" cy="38" rx="58" ry="32" fill="#D0A4B0" opacity="0.4" transform="rotate(18 375 38)"/><ellipse cx="345" cy="195" rx="72" ry="28" fill="#D8BCBE" opacity="0.3" transform="rotate(14 345 195)"/><ellipse cx="345" cy="418" rx="95" ry="52" fill="#E4C4C8" opacity="0.38" transform="rotate(-10 345 418)"/><ellipse cx="145" cy="435" rx="78" ry="38" fill="#C8ACAC" opacity="0.32" transform="rotate(7 145 435)"/><g stroke="#303030" stroke-width="1.5" opacity="0.5"><line x1="250" y1="315" x2="155" y2="215"/><line x1="250" y1="315" x2="345" y2="215"/><line x1="250" y1="315" x2="108" y2="278"/><line x1="250" y1="315" x2="392" y2="275"/><line x1="250" y1="315" x2="160" y2="358"/><line x1="250" y1="315" x2="340" y2="358"/><line x1="250" y1="315" x2="208" y2="185"/><line x1="250" y1="315" x2="292" y2="185"/><line x1="250" y1="315" x2="250" y2="155"/></g><ellipse cx="250" cy="225" rx="85" ry="120" fill="url(#fGlow)" opacity="0.85"/><ellipse cx="250" cy="215" rx="50" ry="70" fill="#FFFCF8" opacity="0.65"/><ellipse cx="250" cy="188" rx="36" ry="18" fill="#F8F2EE" opacity="0.82"/><ellipse cx="250" cy="222" rx="26" ry="42" fill="#F5EDE8" opacity="0.88"/><ellipse cx="250" cy="153" rx="19" ry="21" fill="#EEE6E2" opacity="0.85"/><ellipse cx="250" cy="143" rx="21" ry="11" fill="#8C7868" opacity="0.72"/><path d="M232,142 Q238,132 246,145" stroke="#8C7868" stroke-width="6" fill="none" stroke-linecap="round" opacity="0.6"/><path d="M255,140 Q262,130 268,143" stroke="#8C7868" stroke-width="5" fill="none" stroke-linecap="round" opacity="0.6"/><ellipse cx="250" cy="228" rx="28" ry="48" fill="#FFFFFF" opacity="0.45"/><ellipse cx="222" cy="218" rx="7.5" ry="26" fill="#F0E6E0" opacity="0.78" transform="rotate(-6 222 218)"/><ellipse cx="278" cy="218" rx="7.5" ry="26" fill="#F0E6E0" opacity="0.78" transform="rotate(6 278 218)"/><circle cx="250" cy="315" r="28" fill="url(#cGlow)" opacity="0.88"/><circle cx="250" cy="315" r="12" fill="#FFFFFF" opacity="0.95"/><circle cx="250" cy="315" r="5" fill="#FFFFFF" opacity="1"/><g fill="#FFFFFF" opacity="0.92"><circle cx="205" cy="196" r="2.5"/><circle cx="295" cy="196" r="2.5"/><circle cx="160" cy="218" r="2.2"/><circle cx="340" cy="218" r="2.2"/><circle cx="118" cy="283" r="2"/><circle cx="382" cy="275" r="2"/><circle cx="163" cy="358" r="2"/><circle cx="337" cy="358" r="2"/><circle cx="220" cy="428" r="1.8"/><circle cx="280" cy="428" r="1.8"/></g><g fill="#FFFFFF" opacity="0.78"><circle cx="162" cy="73" r="1.5"/><circle cx="318" cy="66" r="1.5"/><circle cx="246" cy="46" r="1.2"/><circle cx="435" cy="98" r="1.3"/><circle cx="53" cy="128" r="1.3"/><circle cx="474" cy="238" r="1.2"/><circle cx="12" cy="240" r="1.2"/><circle cx="58" cy="342" r="1.3"/><circle cx="442" cy="336" r="1.3"/><circle cx="195" cy="33" r="1.1"/><circle cx="305" cy="29" r="1.1"/></g><text x="250" y="480" font-family="Georgia, serif" font-size="15" fill="#C89098" text-anchor="middle" font-style="italic">🕊️ Shattered Serenity</text></svg>';

    constructor() ERC721("Mirror Court", "MIRROR") {
        // Scene 0: Start (Aligned with Member C's story flow)
        scenes.push(Scene(
            "You stand before a magic mirror. Draw a spiral or a straight line.",
            ["Draw spiral", "Draw straight line"],
            [1, 1]
        ));

        // Scene 1: Life Path Choice
        scenes.push(Scene(
            "The mirror shows your life path. What attitude do you choose?",
            ["Encourage adventure", "Choose stability"],
            [2, 2]
        ));

        // Scene 2: Regret Reflection
        scenes.push(Scene(
            "Regret emerges. Which do you feel more deeply?",
            ["Regret words unsaid", "Regret things done"],
            [3, 3]
        ));

        // Scene 3: Final Choice (Aligned with 4 endings from B/C)
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

    // Fixed: Safe for frontend (Member B) - no crashes when story ends
    function getCurrentScene() public view returns (string memory, string[] memory) {
        PlayerStory storage story = players[msg.sender];
        require(story.isStarted, "No active story");
        
        if (story.isCompleted) {
            return ("Story completed. Mint your NFT to see the final reflection.", new string[](0));
        }
        
        Scene storage s = scenes[story.currentScene];
        return (s.description, s.options);
    }

    function getStoryState() public view returns (uint8, uint8[] memory, bool, bool) {
        PlayerStory memory s = players[msg.sender];
        return (s.currentScene, s.choices, s.isStarted, s.isCompleted);
    }

    // NFT Mint (Aligned with Member B's frontend NFT display)
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
        require(choices.length > 0, "No choices made");
        uint8 finalChoice = choices[choices.length - 1];
        if (finalChoice == 0) return ENDING_1;
        if (finalChoice == 1) return ENDING_2;
        if (finalChoice == 2) return ENDING_3;
        return ENDING_4;
    }

    // On-chain metadata (Compatible with Member B's SVG rendering)
    function generateURI(address user) public view returns (string memory) {
        uint8[] memory choices = players[user].choices;
        string memory svg = _generateArtByChoicePath(choices);
        string memory description;

        if (choices.length == 0) {
            description = "Childhood Wonder: You return to carefree days, world bright and warm.";
        } else {
            uint8 finalChoice = choices[choices.length - 1];
            if (finalChoice == 0) {
                description = "Childhood Wonder: You return to carefree days, world bright and warm.";
            } else if (finalChoice == 1) {
                description = "Blazing Youth: Passion burns like fire, brave and unstoppable.";
            } else if (finalChoice == 2) {
                description = "Settled Midlife: Years of wisdom, calm and deep like a lake.";
            } else {
                description = "Shattered Serenity: Mirror broken, peace found in pure emptiness.";
            }
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

    // Required ERC721 overrides
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
