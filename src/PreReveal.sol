// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract PreRevealNFT is ERC721, Ownable {
    RevealedNFT public revealedNFTContract;

    // Total Supply before reveal
    uint256 public constant MAX_TOTAL_SUPPLY = 5;
    uint256 public currentSupply;

    constructor(string memory name, string memory symbol, uint256 mintPrice) ERC721(name, symbol) {}

    /// @notice Mint a new SP NFT to the msg.sender and increases supply.
    function mint() public payable {
        require(currentSupply + 1 <= MAX_TOTAL_SUPPLY, "Max supply exceeded");
        require(msg.value >= mintPrice, "Insufficient funds sent");

        uint256 newTokenId = currentSupply + 1;
        currentSupply = newTokenId;
        _mint(msg.sender, newTokenId);
        return newTokenId;
    }

    function setRevealedNFTAddress(address _revealedNFTAddress) external onlyOwner {
        revealedNFTContract = RevealedNFT(_revealedNFTAddress);
    }

    function revealAndTransfer(uint256 tokenId, address user) external onlyOwner {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        _burn(tokenId);
        revealedNFTContract.mint(user);
    }
}