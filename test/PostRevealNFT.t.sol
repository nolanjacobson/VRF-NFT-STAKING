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

        vrfCoordinator.fundSubscription(subId, 1000);
        vrfCoordinator.addConsumer(subId, address(postRevealNFT));
    }
}
