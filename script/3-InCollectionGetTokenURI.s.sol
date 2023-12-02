// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/PostRevealNFT.sol";

contract InCollectionGetTokenURIScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        address spnftAddress = 0xF1887DAEeE664014bFAE9BA6CE9d9fc5995a034E;
        SPNFT spnft = SPNFT(payable(spnftAddress));

        // Mint out the collection (MAX_TOTAL_SUPPLY is currently set to 5)
        uint256 tokenId = 1;
        string memory tokenURI = spnft.tokenURI(tokenId);
        console.log(tokenURI);

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
