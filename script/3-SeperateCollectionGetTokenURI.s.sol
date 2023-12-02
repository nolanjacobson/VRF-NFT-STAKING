// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/PostRevealNFT.sol";

// Sepolia VRF Coordinator - 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
// Sepolia KeyHash - 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c

contract InteractSeperateCollectionScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        address postRevealNFTAddress = 0x95043a6d7Ca8Bb1eA34Af0444e8Ff2D8ADC080fF;
        PostRevealNFT postRevealNFT = PostRevealNFT(postRevealNFTAddress);

        // Mint out the collection (MAX_TOTAL_SUPPLY is currently set to 5)
        uint256 tokenId = 1;
        string memory tokenURI = postRevealNFT.tokenURI(tokenId);
        console.log(tokenURI);

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
