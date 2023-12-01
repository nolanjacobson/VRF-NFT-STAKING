// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SPNFTStaking {
    IERC721 public immutable nft;
    IERC20 public immutable rewardToken;

    struct Stake {
        uint256 timestamp;
        address owner;
    }

    // APY 5%
    uint256 public constant REWARD_RATE = 5; 
    mapping(uint256 => Stake) public stakes;

    constructor(address _nftAddress, address _rewardTokenAddress) {
        nft = IERC721(_nftAddress);
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function stake(uint256 tokenId) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        nft.transferFrom(msg.sender, address(this), tokenId);

        stakes[tokenId] = Stake(block.timestamp, msg.sender);
    }

    function claimReward(uint256 tokenId) external {
        require(stakes[tokenId].owner == msg.sender, "Not the NFT owner");
        require(nft.ownerOf(tokenId) == address(this), "NFT not staked");

        uint256 stakedTime = block.timestamp - stakes[tokenId].timestamp;
        uint256 rewardAmount = calculateReward(stakedTime);

        // Reset staking time
        stakes[tokenId].timestamp = block.timestamp;

        rewardToken.transfer(msg.sender, rewardAmount);
    }

    function calculateReward(uint256 stakedTime) private view returns (uint256) {
        // Calculate reward based on staked time and rate
        // This is a simplified formula and can be adjusted for more precision or different reward structures
        return (stakedTime / 1 days) * REWARD_RATE / 100;
    }
}
