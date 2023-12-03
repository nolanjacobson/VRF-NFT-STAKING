// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SPNFT.sol";
import "../src/PostRevealNFT.sol";
import {MockVRFCoordinatorV2} from "../src/mocks/MockVRFCoordinatorV2.sol";

contract PostRevealNFTTest is Test {
    SPNFT spnft;
    PostRevealNFT postRevealNFT;
    MockVRFCoordinatorV2 vrfCoordinator;
    uint64 subId;
    uint256 mintPrice = 0.001 ether; // Update with your contract's mint price
    uint256 MAX_TOTAL_SUPPLY = 5; // Update with your contract's max total supply

    event Transfer(address from, address to, uint256 tokenId);
    event RandomWordsRequested(
        bytes32 indexed keyHash,
        uint256 requestId,
        uint256 preSeed,
        uint64 indexed subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords,
        address indexed sender
    );

    function setUp() public {
        vrfCoordinator = new MockVRFCoordinatorV2(1, 1);
        subId = vrfCoordinator.createSubscription();
        spnft = new SPNFT(
            address(vrfCoordinator),
            subId,
            0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc,
            "SPNFT",
            "SP",
            false
        );
        address spnftAddress = address(spnft);
        postRevealNFT = new PostRevealNFT(
            address(vrfCoordinator),
            subId,
            0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc,
            "PostRevealNFT",
            "PR",
            spnftAddress
        );
        address postRevealNFTAddress = address(postRevealNFT);
        spnft.setPostRevealNFT(postRevealNFTAddress);

        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();
        spnft.mint{value: mintPrice}();

        vrfCoordinator.fundSubscription(subId, 1000);
        vrfCoordinator.addConsumer(subId, address(postRevealNFT));
    }

    function testRevealAndTransferSuccess() public {
        uint256 tokenId = 1;

        spnft.revealAndTransfer(tokenId);

        assertEq(postRevealNFT.ownerOf(1), address(this));

        vm.expectRevert();
        spnft.ownerOf(tokenId);

        // couldn't get fetchLogs working :/
        // Vm.Log[] memory logs = vm.fetchLogs();
        // assertEq(logs.length, expectedNumberOfLogs);

        // // Example: Assert the first Transfer event
        // (address from, address to, uint256 emittedTokenId) = abi.decode(
        //     logs[0].data,
        //     (address, address, uint256)
        // );
        // assertEq(from, address(0));
        // assertEq(to, address(this));
        // assertEq(emittedTokenId, tokenId);
    }

    function testFailMintByAnyoneThatIsNotSPNFT() public {
        // This should fail as the call is not made by spNft
        postRevealNFT.mint(address(this), 2);
    }

    function testFailTokenURINonexistentToken() public {
        uint256 nonexistentTokenId = 9999; // Token does not exist
        spnft.tokenURI(nonexistentTokenId); // Expected to fail
    }

    function testTokenURIRevealedToken() public {
        uint256 tokenId = 1; // Assume this is the minted token ID
        spnft.revealAndTransfer(tokenId);

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
            address(postRevealNFT),
            randomWords
        );

        string
            memory mysteryBoxURI = "data:application/json;base64,eyJuYW1lIjogIk15c3RlcnkgQm94IiwiZGVzY3JpcHRpb24iOiAiVGhpcyBpcyBhbiB1bnJldmVhbGVkIG15c3RlcnkgYm94LiIsImF0dHJpYnV0ZXMiOiBbXX0=";
        // Check token URI for a revealed token
        string memory uri = postRevealNFT.tokenURI(tokenId);
        assertNotEq(uri, mysteryBoxURI);
    }
}
