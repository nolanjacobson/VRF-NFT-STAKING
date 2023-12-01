# SCE-Take-Home

The goal of this exercise is to design and implement a SP NFT (ERC-721) with different 
metadata revealing approaches. The solution should leverage Chainlink for random 
number generation and allow for two distinct revealing approaches, with the potential to 
support future approaches.

## Contracts

### SPNFT.sol

- **Purpose**: SPNFT is an ERC721 contract which is used in both the in-collection and seperate collection reveal approaches.
- **Key Features**: NFT minting w/ payable option, on-chain base64 encoded metadata, VRF functionality, burning functionality
- **Interactions**: This contract will either be standalone with the VRF contract or it will standalone with the PostRevealNFT contract depending on
if the operator (admin) decides on the InCollection or SeperateCollection reveal approach.

### PostRevealNFT.sol

- **Purpose**: PostRevealNFT is an ERC721 contract which is used solely for the seperate collection reveal approach.
- **Functionality**: Allows for SPNFT to mint an NFT, on-chain base64 encoded metadata, and VRF functionality.
- **Interactions**: This contract will always interact with VRF to get the random numbers needed for selecting random pieces of metadata, and will be
invoked by the SPNFT during the `revealAndTransfer` call in the parent contract.

### SPNFTStaking.sol

- **Purpose**: Describe the staking functionality provided by `SPNFTStaking.sol`.
- **Staking Mechanism**: Users can use this contract with both the in-collection and seperate collection reveal approaches. Users can call `stake(tokenId)`
and effectively stake their NFT for 5% APY. When the user wants to claim rewards they can call `claim(tokenId)`. Future suggestion would be to add a function
to release the staked NFT.
- **Reward Calculation**: `((stakedTime / 1 days) * REWARD_RATE) / 100;` - 5% APY

### RewardTokenERC20.sol

- **Purpose**: Simple ERC20 token for staking rewards.
- **Tokenomics**: N/A
- **Usage**: This token is used as a rewards mechanism for SPNFT stakers.

## Setup and Deployment

Provide instructions on how to set up and deploy these contracts. Include any prerequisites.

```
```