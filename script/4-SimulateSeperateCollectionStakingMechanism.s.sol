// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/RewardTokenERC20.sol";
import "../src/SPNFTStaking.sol";

contract SimulateSeperateCollectionStakingMechanismScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions

        address spnftAddress = 0xB5066199A73F0528b2Ec3108e7358C5DAce3Ccf9;
        address postRevealAddress = 0x376E14Cb1ceD4f3fCCfe2f82cBcAEf3E30Ea3335;

        SPNFT spnft = SPNFT(spnftAddress);
        PostRevealNFT postRevealNFT = PostRevealNFT(postRevealAddress);

        RewardTokenERC20 erc20 = new RewardTokenERC20("StakingRewards", "SR");
        address erc20Address = address(erc20);
        SPNFTStaking spNFTStaking = new SPNFTStaking(
            spnftAddress,
            postRevealAddress,
            erc20Address
        );
        address spNFTStakingAddress = address(spNFTStaking);

        uint256 tokenId = 1;

        // // Gotta approve the staking nft to use this before spending
        postRevealNFT.approve(spNFTStakingAddress, tokenId);
        spNFTStaking.stake(tokenId);

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
