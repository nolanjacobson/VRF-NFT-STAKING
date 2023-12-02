// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/RewardTokenERC20.sol";
import "../src/SPNFTStaking.sol";

contract SimulateInCollectionStakingMechanismScript is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions

        address spnftAddress = 0xF1887DAEeE664014bFAE9BA6CE9d9fc5995a034E;

        SPNFT spnft = SPNFT(spnftAddress);

        RewardTokenERC20 erc20 = new RewardTokenERC20("StakingRewards", "SR");
        address erc20Address = address(erc20);
        SPNFTStaking spNFTStaking = new SPNFTStaking(
            spnftAddress,
            0x0000000000000000000000000000000000000000,
            erc20Address
        );
        address spNFTStakingAddress = address(spNFTStaking);

        uint256 tokenId = 1;

        // Gotta approve the staking nft to use this before spending
        spnft.approve(spNFTStakingAddress, tokenId);
        spNFTStaking.stake(tokenId);

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
