// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/PostRevealNFT.sol";

contract SeperateCollectionGetTokenURIScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        address postRevealNFTAddress = 0x376E14Cb1ceD4f3fCCfe2f82cBcAEf3E30Ea3335;
        PostRevealNFT postRevealNFT = PostRevealNFT(postRevealNFTAddress);

        // Mint out the collection (MAX_TOTAL_SUPPLY is currently set to 5)
        uint256 tokenId = 1;
        string memory tokenURI = postRevealNFT.tokenURI(tokenId);
        console.log(tokenURI);

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
