// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SPNFT.sol";
import { MockVRFCoordinatorV2 } from "../src/mocks/MockVRFCoordinatorV2.sol";

contract SPNFTTest is Test {
    SPNFT spnft;
    MockVRFCoordinatorV2 vrfCoordinator;
    uint64 subId;
    uint256 mintPrice = 0.001 ether; // Update with your contract's mint price
    uint256 MAX_TOTAL_SUPPLY = 5; // Update with your contract's max total supply

    function setUp() public {
        vrfCoordinator = new MockVRFCoordinatorV2(1, 1);
        subId = vrfCoordinator.createSubscription();
        spnft = new SPNFT(address(vrfCoordinator), subId, 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc, "SPNFT", "SP", true);
        vrfCoordinator.fundSubscription(subId, 1000);
        vrfCoordinator.addConsumer(subId, address(spnft));
    }

    function testSuccessfulMint() public {
        spnft.mint{value: mintPrice}();
        assertEq(spnft.currentSupply(), 1);
        assertEq(address(spnft).balance, mintPrice);
    }

    function testFailMintWithInsufficientFunds() public {
        spnft.mint{value: mintPrice - 0.1 ether}();
    }

    function testFailMintExceedingMaxSupply() public {
        for (uint256 i = 0; i < MAX_TOTAL_SUPPLY; i++) {
            spnft.mint{value: mintPrice}();
        }
        spnft.mint{value: mintPrice}(); // Expected to fail
    }

    function testTokenIdIncrement() public {
        spnft.mint{value: mintPrice}();
        uint256 newTokenId = spnft.currentSupply();
        assertEq(newTokenId, 1);
    }

    // Test Cases for reveal function
    function testSuccessfulReveal() public {
        for (uint256 i = 0; i < MAX_TOTAL_SUPPLY; i++) {
            vm.deal(address(this), mintPrice);
            spnft.mint{value: mintPrice}();
        }

        uint256 tokenId = 1; // Assuming the first token ID is 1
        spnft.reveal(tokenId);
        assertTrue(spnft.revealed(tokenId));
    }

    function testFailRevealWhenNotInCollectionReveal() public {
        uint256 tokenId = 1;
        spnft.setInCollectionOrSeperateCollectionReveal(false);
        spnft.reveal(tokenId); // Expected to fail
    }

    function testFailRevealBeforeMaxSupplyReached() public {
        SPNFT newNFT = new SPNFT(address(vrfCoordinator), subId, 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc, "SPNFT", "SP", true);
        newNFT.mint{value: mintPrice}();
        newNFT.reveal(1); // Expected to fail
    }

    function testFailRevealNonexistentToken() public {
        uint256 nonexistentTokenId = MAX_TOTAL_SUPPLY + 1;
        spnft.reveal(nonexistentTokenId); // Expected to fail
    }

    function testFailRevealByNonOwner() public {
        uint256 tokenId = 1;
        address nonOwner = address(0x123);
        vm.prank(nonOwner);
        spnft.reveal(tokenId); // Expected to fail
    }

    // Additional tests for token URI, staking, etc.
}
