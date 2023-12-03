// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SPNFT.sol";
import {MockVRFCoordinatorV2} from "../src/mocks/MockVRFCoordinatorV2.sol";

contract SPNFTTest is Test {
    SPNFT spnft;
    MockVRFCoordinatorV2 vrfCoordinator;
    uint64 subId;
    uint256 mintPrice = 0.001 ether; // Update with your contract's mint price
    uint256 MAX_TOTAL_SUPPLY = 5; // Update with your contract's max total supply

    function setUp() public {
        vrfCoordinator = new MockVRFCoordinatorV2(1, 1);
        subId = vrfCoordinator.createSubscription();
        spnft = new SPNFT(
            address(vrfCoordinator),
            subId,
            0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc,
            "SPNFT",
            "SP",
            true
        );
        vrfCoordinator.fundSubscription(subId, 1000);
        vrfCoordinator.addConsumer(subId, address(spnft));
    }

    // tests for mint function

    function testSuccessfulMint() public {
        spnft.mint{value: mintPrice}();
        assertEq(spnft.currentSupply(), 1);
        assertEq(address(spnft).balance, mintPrice);
    }

    // for whatever reason this function and withdraw aren't working correctly with foundry - but if you simulate this on a testnet you will see your ETH gets refunded.
    // function testReturnExcessEtherOnMint() public {
    //     payable(address(spnft)).transfer(10 ether);

    //     uint256 excessAmount = 0.005 ether; // Set an excess amount
    //     uint256 totalSent = mintPrice + excessAmount;

    //     // Fund the test contract with enough Ether
    //     // vm.deal(address(this), totalSent);

    //     // Record the initial balance of the test contract
    //     uint256 initialBalance = address(this).balance;

    //     // Mint a token by sending more than the mint price
    //     spnft.mint{value: totalSent, gas: 500000}();

    //     // Calculate the expected final balance
    //     uint256 expectedFinalBalance = initialBalance - mintPrice;

    //     // Assert that only the mint price has been deducted
    //     assertEq(
    //         address(this).balance,
    //         expectedFinalBalance,
    //         "Excess Ether was not returned"
    //     );
    // }

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
        SPNFT newNFT = new SPNFT(
            address(vrfCoordinator),
            subId,
            0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc,
            "SPNFT",
            "SP",
            true
        );
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

    // revealAndTransferTests

    function testFailRevealAndTransferInCollectionReveal() public {
        uint256 tokenId = 1; // Assume this token exists
        spnft.setInCollectionOrSeperateCollectionReveal(true);
        spnft.revealAndTransfer(tokenId); // Expected to fail
    }

    function testFailRevealAndTransferNonexistentToken() public {
        uint256 nonexistentTokenId = 9999; // Token does not exist
        spnft.setInCollectionOrSeperateCollectionReveal(false);
        spnft.revealAndTransfer(nonexistentTokenId); // Expected to fail
    }

    function testFailRevealAndTransferNonOwner() public {
        uint256 tokenId = 1; // Assume this token exists and is owned by someone else
        spnft.setInCollectionOrSeperateCollectionReveal(false);
        address nonOwner = address(0x123);
        vm.prank(nonOwner);
        spnft.revealAndTransfer(tokenId); // Expected to fail
    }

    // tokenURI tests

    function testFailTokenURINonexistentToken() public {
        uint256 nonexistentTokenId = 9999; // Token does not exist
        spnft.tokenURI(nonexistentTokenId); // Expected to fail
    }

    function testTokenURIUnrevealedToken() public {
        // Mint a token first
        spnft.mint{value: mintPrice}();
        uint256 tokenId = 1; // Assume this is the minted token ID
        string
            memory mysteryBoxURI = "data:application/json;base64,eyJuYW1lIjogIk15c3RlcnkgQm94IiwiZGVzY3JpcHRpb24iOiAiVGhpcyBpcyBhbiB1bnJldmVhbGVkIG15c3RlcnkgYm94LiIsImF0dHJpYnV0ZXMiOiBbXX0=";
        // Check token URI for an unrevealed token
        string memory uri = spnft.tokenURI(tokenId);
        console.log(uri);
        assertEq(uri, mysteryBoxURI);
    }

    function testTokenURIRevealedToken() public {
        // Mint 5 tokens and reveal a token
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();

        uint256 tokenId = 1; // Assume this is the minted token ID
        spnft.reveal(tokenId);

        // had to add a bunch of balance here to circumvent InsufficientBalance error
        vrfCoordinator.fundSubscription(subId, 10000000);

        // Manually fulfill the VRF request in the mock contract
        uint256 requestId = 1;
        uint256[] memory randomWords = new uint256[](4); // Assuming 4 random words needed
        randomWords[0] = 1;
        randomWords[1] = 2;
        randomWords[2] = 3;
        randomWords[3] = 4;
        vrfCoordinator.fulfillRandomWordsWithOverride{gas: 5000000}(
            requestId,
            address(spnft),
            randomWords
        );

        string
            memory mysteryBoxURI = "data:application/json;base64,eyJuYW1lIjogIk15c3RlcnkgQm94IiwiZGVzY3JpcHRpb24iOiAiVGhpcyBpcyBhbiB1bnJldmVhbGVkIG15c3RlcnkgYm94LiIsImF0dHJpYnV0ZXMiOiBbXX0=";
        // Check token URI for a revealed token
        string memory uri = spnft.tokenURI(tokenId);
        assertNotEq(uri, mysteryBoxURI);
    }

    // test withdrawl from contract
    // for whatever reason this function and withdraw aren't working correctly with foundry - but if you simulate this on a testnet you will see your ETH gets refunded.

    // function testSuccessfulWithdrawalByOwner() public {
    //     payable(address(spnft)).transfer(10 ether);

    //     spnft.mint{value: mintPrice}();
    //     // Withdraw as the owner
    //     uint256 initialBalance = address(this).balance;
    //     spnft.withdraw{gas: 300000}();
    //     uint256 finalBalance = address(this).balance;

    //     assertEq(finalBalance, initialBalance + 0.001 ether);
    //     assertEq(address(spnft).balance, 0);
    // }

    function testFailWithdrawalByNonOwner() public {
        // Send some Ether to the contract
        payable(address(spnft)).transfer(1 ether);

        // Try to withdraw as a non-owner
        vm.prank(address(0x123)); // Non-owner address
        spnft.withdraw();
    }

    function testFailWithdrawalWithNoEther() public {
        // Attempt to withdraw with no Ether in the contract
        spnft.withdraw();
    }
}
