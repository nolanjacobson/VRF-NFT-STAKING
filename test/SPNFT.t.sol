// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "../src/SPNFT.sol";
// import { VRFCoordinatorV2Interface } from "lib/chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
// import { MockVRFConsumerBaseV2 } from "./mocks/MockVRFConsumerBaseV2.sol";

// contract SPNFTTest is Test {
//     SPNFT spnft;
//     MockVRFConsumerBaseV2 mockVRFConsumer;
//     VRFCoordinatorV2Interface vrfCoordinator;

//     function setUp() public {
//         // Initialize mocks and the SPNFT contract
//         mockVRFConsumer = new MockVRFConsumerBaseV2();
//         vrfCoordinator = VRFCoordinatorV2Interface(address(mockVRFConsumer));
//         spnft = new SPNFT(address(vrfCoordinator), /* other args */);
//     }

//     function testMint() public {
//         // Test minting functionality
//     }

//     function testReveal() public {
//         // Test the reveal functionality, including interaction with Chainlink VRF
//     }

//     // Additional tests for token URI, staking, etc.
// }