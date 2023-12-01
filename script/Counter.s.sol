// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract

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