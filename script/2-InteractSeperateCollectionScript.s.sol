// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/PostRevealNFT.sol";

// Sepolia VRF Coordinator - 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
// Sepolia KeyHash - 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c

contract InteractSeperateCollectionScript is Script {
    function run(address _spnft, address _postRevealNFT) external {
        vm.startBroadcast(); // Start broadcasting transactions
        SPNFT spnft = SPNFT(_spnft);
        address spnftAddress = address(spnft);
        console.log(spnftAddress);
        PostRevealNFT postRevealNFT = PostRevealNFT(_postRevealNFT);
        address postRevealNFTAddress = address(postRevealNFT);
        console.log(postRevealNFTAddress);
        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
