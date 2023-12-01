// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract

// Sepolia VRF Coordinator - 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
// Sepolia KeyHash - 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
 
contract DeployAndInteractSPNFT is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions

        // Deploy the SPNFT contract
        SPNFT spnft = new SPNFT(/* parameters for the constructor */);

        // Interact with the deployed contract
        // For example, mint an NFT
        spnft.mint{value: 1 ether}();

        // More interactions...
        
        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}