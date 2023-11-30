// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./Base64.sol";

contract SPNFT is ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // Total Supply before reveal
    uint256 public constant MAX_TOTAL_SUPPLY = 5;
    uint256 public currentSupply;

    event PackRevealed(address[] nftContracts, uint256[] tokenIds);

    mapping(uint256 => bool) public revealed;
    string private _baseURIextended;
    string private _notRevealedURI;

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

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function setNotRevealedURI(string memory notRevealedURI) external onlyOwner {
        _notRevealedURI = notRevealedURI;
    }

    function reveal(uint256 tokenId) public onlyOwner {
        require(currentSupply == MAX_TOTAL_SUPPLY, "Max supply hasn't been sold yet.");
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        revealed[tokenId] = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if(!revealed[tokenId]) {
            return _notRevealedURI;
        }

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
}
