// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/PostRevealNFT.sol";

// Sepolia VRF Coordinator - 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
// Sepolia KeyHash - 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c

contract InteractSeperateCollectionScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        address spnftAddress = 0xA91D2D52496CAFC8A679d347E597b872d38ba5c7;
        SPNFT spnft = SPNFT(spnftAddress);
        address postRevealNFTAddress = 0x95043a6d7Ca8Bb1eA34Af0444e8Ff2D8ADC080fF;
        PostRevealNFT postRevealNFT = PostRevealNFT(postRevealNFTAddress);

        spnft.setPostRevealNFT(postRevealNFTAddress);

        // Mint out the collection (MAX_TOTAL_SUPPLY is currently set to 5)
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();

        // Reveal for tokenId 1, feel free to change this to whatever tokenId you'd like to reveal.
        uint256 tokenId = 1;
        try spnft.revealAndTransfer{gas: 5000000}(tokenId) {
            // Handle successful execution
        } catch Error(string memory reason) {
            // Catch and log custom revert messages
            console.log("Transaction failed:", reason);
        } catch {
            // Catch and log generic reverts
            console.log("Transaction failed due to revert");
        }

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
