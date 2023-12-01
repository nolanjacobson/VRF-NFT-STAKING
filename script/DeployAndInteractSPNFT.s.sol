// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract

// Sepolia VRF Coordinator - 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
// Sepolia KeyHash - 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c

contract DeployAndInteractSPNFT is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        // vm.gas(5000000); // Replace with your desired gas limit

        // SPNFT spnft = new SPNFT(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, 7362, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, "SPNFTest", "SP", true);
        address deployedSPNFTAddress = 0xbE7fc37A5E8A543403aC177Ad202d3A47C87B6F0; // Replace with the actual address
        SPNFT spnft = SPNFT(deployedSPNFTAddress);

        // Interact with the deployed contract
        // For example, mint an NFT
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();

        string memory tokenURI = spnft.tokenURI(2);
        console.log(tokenURI);

        // try spnft.reveal{gas: 5000000}(1) {
        //     // Handle successful execution
        // } catch Error(string memory reason) {
        //     // Catch and log custom revert messages
        //     console.log("Transaction failed:", reason);
        // } catch {
        //     // Catch and log generic reverts
        //     console.log("Transaction failed due to revert");
        // }
        // spnft.reveal(1);
        // More interactions...

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
