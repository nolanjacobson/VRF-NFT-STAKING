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
- Create a [VRF subscription](https://vrf.chain.link/sepolia/) on Sepolia.
- Get some sETH (Sepolia ETH) from a faucet like [Alchemy](https://sepoliafaucet.com/) or [Infura](https://www.infura.io/faucet/sepolia)

### Setup

1) Clone the repository to your machine: `git clone https://github.com/nolanjacobson/SCE-Take-Home`
2) Change into the cloned repo: `cd SCE-Take-Home`
3) You need to install 3 libraries that are used by the smart contracts via Forge Modules: `forge install smartcontractkit/chainlink`, `forge install OpenZeppelin/openzeppelin-contracts`, `forge install foundry-rs/forge-std`
4) Build the smart contracts: `forge build --via-ir`

After following the 4 steps above, you can either interact via scripts or run the unit tests.

### Scripts

Note: You will need to replace $YOUR_PRIVATE_KEY, and $YOUR_ETHERSCAN_API_KEY with your private key env variables.

1) Depending on if you want to deploy the `InCollection` or `SeperateCollection` approach, you will run one of the following scripts:

- You will need to go locate the `uint64 subscriptionId` variable and assign the value to your subscription id from your [VRF subscription](https://vrf.chain.link/sepolia/).

```forge script ./script/1-DeployInCollectionScript.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --etherscan-api-key $YOUR_ETHERSCAN_API_KEY --broadcast -vvvv --via-ir```

```forge script ./script/1-DeploySeperateCollectionScript.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --etherscan-api-key $YOUR_ETHERSCAN_API_KEY --broadcast -vvvv --via-ir```


1A) You will need to take note of the newly deployed SPNFT contract address for the `InCollectionScript` and you will need to take note of the newly deployed PostRevealNFT contract addresses for the `SeperateCollectionScript`. You will then go to your [VRF subscription](https://vrf.chain.link/sepolia/) on Sepolia and register a new consumer with the newly deployed contract address.

2) You will run the interact `InCollection` or interact `SeperateCollection` scripts. This will mint 5 tokens and call reveal on 1 tokenId, there is a variable
in the script that will allow you to change the `tokenId` you would like to reveal.

- For the `InCollection` approach, you will need to go to `2-InteractInCollectionScript` and update `address spnftAddress = YOUR_SPNFT_ADDRESS;`. For the `SeperateCollection` approach, you will need to go to `2-InteractSeperateCollectionScript` and update `address spnftAddress = YOUR_SPNFT_ADDRESS;` and `address postRevealNFTAddress = YOUR_POST_REVEAL_ADDRESS;`

```forge script ./script/2-InteractInCollectionScript.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --broadcast --via-ir```
```forge script ./script/2-InteractSeperateCollectionScript.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --broadcast --via-ir```

3) You can get the tokenURI for the newly revealed token. 

- For the `InCollection` approach, you will need to go to `3-InCollectionGetTokenURI` and update `address spnftAddress = YOUR_SPNFT_ADDRESS;`. For the `SeperateCollection` approach, you will need to go to `3-SeperateCollectionGetTokenURI` and update `address postRevealNFTAddress = YOUR_POST_REVEAL_ADDRESS;`

```forge script ./script/3-InCollectionGetTokenURI.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --broadcast --via-ir```
```forge script ./script/3-SeperateCollectionGetTokenURI.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --broadcast --via-ir```

This will return a base64 encoded string that you can paste in your browser to render the JSON metadata to the screen.

4) You can stake your NFT for 5% APY!

- For the `InCollection` approach, you will need to go to `4-SimulateInCollectionStakingMechanism` and update `address spnftAddress = YOUR_SPNFT_ADDRESS;`. For the `SeperateCollection` approach, you will need to go to `4-SimulateSeperateCollectionStakingMechanism` and update `address postRevealNFTAddress = YOUR_POST_REVEAL_ADDRESS;`

```forge script ./script/4-SimulateInCollectionStakingMechanism.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --broadcast --via-ir```
```forge script ./script/4-SimulateSeperateCollectionStakingMechanism.s.sol --rpc-url https://eth-sepolia.public.blastapi.io --private-key $YOUR_PRIVATE_KEY --broadcast --via-ir```

### Unit Tests

```
forge test
```