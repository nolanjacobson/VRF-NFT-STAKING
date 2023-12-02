// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SPNFT.sol";
import {VRFCoordinatorV2Interface} from "lib/chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {MockVRFCoordinatorV2} from "../src/mocks/MockVRFCoordinatorV2.sol";

contract SPNFTTest is Test {
    SPNFT spnft;
    MockVRFCoordinatorV2 vrfCoordinator;
    uint64 subId;
    uint256 mintPrice = 0.001 ether; // Update with your contract's mint price
    uint256 MAX_TOTAL_SUPPLY = 5; // Update with your contract's max total supply

    function setUp() public {
        // Initialize mocks and the SPNFT contract
        // Deploy the MockVRFCoordinatorV2 with some arbitrary base fee and gas price link
        vrfCoordinator = new MockVRFCoordinatorV2(1, 1);

        // Create a new subscription
        subId = vrfCoordinator.createSubscription();

        // Deploy your VRF consumer contract, passing any necessary constructor arguments
        spnft = new SPNFT(
            address(vrfCoordinator),
            subId,
            0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc,
            "SPNFT",
            "SP",
            true
        );

        // Fund the subscription with an arbitrary amount
        vrfCoordinator.fundSubscription(subId, 1000);

        // Add your consumer contract to your subscription
        vrfCoordinator.addConsumer(subId, address(spnft));
    }

    function testSuccessfulMint() public {
        console.log("Initial Supply:", spnft.currentSupply());
        spnft.mint{value: mintPrice}();
        console.log("New Supply:", spnft.currentSupply());
        assertEq(spnft.currentSupply(), 1);
        assertEq(address(spnft).balance, mintPrice);
    }

    function testFailMintWithInsufficientFunds() public {
        // Call the mint function with less than the required mint price
        spnft.mint{value: mintPrice - 0.1 ether}();
    }

    function testFailMintExceedingMaxSupply() public {
        for (uint256 i = 0; i < MAX_TOTAL_SUPPLY; i++) {
            spnft.mint{value: mintPrice}();
        }

        // This should fail
        spnft.mint{value: mintPrice}();
    }

    function testTokenIdIncrement() public {
        spnft.mint{value: mintPrice}();

        uint256 newTokenId = spnft.currentSupply();
        console.log(newTokenId);
        // assertEq(newTokenId, 1);
    }

    function testReveal() public {
        // Test the reveal functionality, including interaction with Chainlink VRF
    }

    // Additional tests for token URI, staking, etc.
}
