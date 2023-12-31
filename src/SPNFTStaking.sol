// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SPNFTStaking {
    IERC721 public immutable spNFT;
    IERC721 public immutable postRevealNFT;
    IERC20 public immutable rewardToken;

    struct Stake {
        uint256 timestamp;
        address owner;
    }

    // APY 5%
    uint256 public constant REWARD_RATE = 5;
    mapping(uint256 => Stake) public stakes;

    constructor(
        address _spNFT,
        address _postRevealNFT,
        address _rewardTokenAddress
    ) {
        spNFT = IERC721(_spNFT);
        postRevealNFT = IERC721(_postRevealNFT);
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function stake(uint256 tokenId) external {
        // require(
        //     spNFT.ownerOf(tokenId) == msg.sender ||
        //         postRevealNFT.ownerOf(tokenId) == msg.sender,
        //     "Not the NFT owner"
        // );

        // TODO: Revist this for security reasons
        stakes[tokenId] = Stake(block.timestamp, msg.sender);

        bool isOwner = false;

        try spNFT.ownerOf(tokenId) returns (address owner) {
            if (owner == msg.sender) {
                isOwner = true;
                spNFT.transferFrom(msg.sender, address(this), tokenId);
            }
        } catch {
            // Catch block if spNFT.ownerOf(tokenId) reverts
        }

        if (!isOwner) {
            try postRevealNFT.ownerOf(tokenId) returns (address postOwner) {
                require(postOwner == msg.sender, "Not the NFT owner");
                postRevealNFT.transferFrom(msg.sender, address(this), tokenId);
            } catch {
                revert("Not the NFT owner");
            }
        }
        // logic to check that the token isn't burned or owned by 0 address which means the spNFT is an in collection reveal, if owned by 0 address ownerOf reverts
    }

    function claimReward(uint256 tokenId) external {
        require(stakes[tokenId].owner == msg.sender, "Not the NFT owner");
        require(
            spNFT.ownerOf(tokenId) == address(this) ||
                postRevealNFT.ownerOf(tokenId) == address(this),
            "NFT not staked"
        );

        uint256 stakedTime = block.timestamp - stakes[tokenId].timestamp;
        uint256 rewardAmount = calculateReward(stakedTime);

        // Reset staking time
        stakes[tokenId].timestamp = block.timestamp;

        rewardToken.transfer(msg.sender, rewardAmount);
    }

    function calculateReward(
        uint256 stakedTime
    ) private view returns (uint256) {
        // Calculate reward based on staked time and rate
        // This is a simplified formula and can be adjusted for more precision or different reward structures
        return ((stakedTime / 1 days) * REWARD_RATE) / 100;
    }
}
