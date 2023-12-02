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

To set up and deploy the SCE-Take-Home project, follow these steps:

### Prerequisites

- Install [Git](https://git-scm.com/) for cloning the repository.
- Install [Foundry](https://getfoundry.sh/), which includes Forge, a command-line tool for Ethereum smart contract development. Follow the [official Foundry installation guide](https://book.getfoundry.sh/getting-started/installation.html) for detailed steps.
- Ensure you have a [Solidity](https://soliditylang.org/) environment set up.

### Setup

1) Clone the repository to your machine: `git clone https://github.com/nolanjacobson/SCE-Take-Home`
2) Change into the cloned repo: `cd SCE-Take-Home`
3) You need to install 3 libraries that are used by the smart contracts via Forge Modules: `forge install smartcontractkit/chainlink`, `forge install OpenZeppelin/openzeppelin-contracts`, `forge install foundry-rs/forge-std`
4) Build the smart contracts: `forge build --via-ir`

After following the 4 steps above, you can either interact via scripts or run the unit tests.

### Scripts


### Unit Tests

```
```