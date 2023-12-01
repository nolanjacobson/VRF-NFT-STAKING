// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Script.sol";
import "../src/SPNFT.sol"; // Adjust the path to your SPNFT contract
import "../src/RewardTokenERC20.sol";
import "../src/SPNFTStaking.sol";

// Sepolia VRF Coordinator - 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
// Sepolia KeyHash - 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c

contract DeployAndInteractSPNFT is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions
        // vm.gas(5000000); // Replace with your desired gas limit

        // SPNFT spnft = new SPNFT(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, 7362, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, "SPNFTest", "SP", true);
        // address spnftAddress = address(spnft);
        // PostRevealNFT postRevealNFT = new PostRevealNFT(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, 7362, 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, "PostRevealNFT", "PR", spnftAddress);
        // address postRevealAddress = address(postRevealNFT);
        // RewardTokenERC20 erc20 = new RewardTokenERC20("StakingRewards", "SR");
        // address erc20Address = address(erc20);
        // SPNFTStaking spNFTStaking = new SPNFTStaking(spnftAddress, postRevealAddress, erc20Address);

        address deployedSPNFTAddress = 0x9f8bbf3C9FD4AEF055A1196828bb5b6d7100C00A; // Replace with the actual address
        SPNFT spnft = SPNFT(deployedSPNFTAddress);

        address postRevealSPNFTAddress = 0x4a5Cd7B216e1A765F65d9d215B5b1CCd338d5D25; // Replace with the actual address
        PostRevealNFT postRevealNFT = PostRevealNFT(postRevealSPNFTAddress);

        address erc20Address = 0xd72b607FC03E4aa30319A45D8Cb13038fe46d420; // Replace with the actual address
        RewardTokenERC20 erc20 = RewardTokenERC20(erc20Address);

        address spNFTStakingAddress = 0x1cc0b45c324009629b19414Af77D942B7185C889; // Replace with the actual address
        SPNFTStaking spNFTStaking = SPNFTStaking(spNFTStakingAddress);

        // // Interact with the deployed contract
        // // For example, mint an NFT
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();
        // spnft.mint{value: 0.01 ether}();

        // gotta approve the staking nft to use this before spending
        // spnft.approve(0x1cc0b45c324009629b19414Af77D942B7185C889,1);
        // spNFTStaking.stake(1);
        spNFTStaking.claimReward(1);
        // string memory tokenURI = spnft.tokenURI(1);
        // console.log(tokenURI);

        // try spnft.revealAndTransfer{gas: 5000000}(1) {
        //     // Handle successful execution
        // } catch Error(string memory reason) {
        //     // Catch and log custom revert messages
        //     console.log("Transaction failed:", reason);
        // } catch {
        //     // Catch and log generic reverts
        //     console.log("Transaction failed due to revert");
        // }

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}
