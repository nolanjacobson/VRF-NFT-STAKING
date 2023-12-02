// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/PostRevealNFT.sol";

contract InteractInCollectionScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        address spnftAddress = 0xF1887DAEeE664014bFAE9BA6CE9d9fc5995a034E;
        SPNFT spnft = SPNFT(spnftAddress);

        // Mint out the collection (MAX_TOTAL_SUPPLY is currently set to 5)
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();
        spnft.mint{value: 0.01 ether}();

        // Reveal for tokenId 1, feel free to change this to whatever tokenId you'd like to reveal.
        uint256 tokenId = 1;
        try spnft.reveal{gas: 5000000}(tokenId) {
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
