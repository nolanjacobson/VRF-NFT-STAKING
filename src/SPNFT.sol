// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./Base64.sol";
import "./PostReveal.sol";

contract SPNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    struct AttributeValues {
        string eyes;
        string hair;
        string nose;
        string mouth;
    }

    // Mapping from token ID to its attributes
    mapping(uint256 => AttributeValues) public _tokenAttributes;

    PostRevealNFT public revealedNFTContract;

    // Total Supply before reveal
    uint256 public constant MAX_TOTAL_SUPPLY = 5;
    uint256 public currentSupply;

    bool public isInCollectionReveal;
    mapping(uint256 => bool) public revealed;
    string private _baseURIextended;
    string private _notRevealedURI;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _mintPrice,
        bool _isInCollectionReveal
    ) ERC721(name, symbol) {
        mintPrice = _mintPrice;
        isInCollectionReveal = _isInCollectionReveal;
    }

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

    function setNotRevealedURI(
        string memory notRevealedURI
    ) external onlyOwner {
        _notRevealedURI = notRevealedURI;
    }

    function setRevealedNFTAddress(
        address _revealedNFTAddress
    ) external onlyOwner {
        revealedNFTContract = RevealedNFT(_revealedNFTAddress);
    }

    function revealAndTransfer(
        uint256 tokenId,
        address user
    ) external onlyOwner {
        require(
            isInCollectionReveal == false,
            "This function does not work as the collection is InRevealCollection"
        );
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        _burn(tokenId);
        revealedNFTContract.mint(user);
    }

    function reveal(uint256 tokenId) public onlyOwner {
        require(
            isInCollectionReveal == true,
            "This function does not work as the collection is not InRevealCollection"
        );
        require(
            currentSupply == MAX_TOTAL_SUPPLY,
            "Max supply hasn't been sold yet."
        );
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        revealed[tokenId] = true;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function setTokenAttributes(
        uint256 tokenId,
        string memory eyes,
        string memory hair,
        string memory nose,
        string memory mouth
    ) public {
        // Add access control as needed
        _tokenAttributes[tokenId] = AttributeValues(eyes, hair, nose, mouth);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (!revealed[tokenId]) {
            return _notRevealedURI;
        }

        AttributeValues memory attributes = _tokenAttributes[tokenId];
        string memory json = Base64.encode(
            bytes(
                abi.encodePacked(
                    '{"name": "SP',
                    tokenId.toString(),
                    '",',
                    '"description": "Story Protocol NFT",',
                    '"attributes": [',
                    '{"trait_type": "Eyes", "value": "',
                    attributes.eyes,
                    '"},',
                    '{"trait_type": "Hair", "value": "',
                    attributes.hair,
                    '"},',
                    '{"trait_type": "Nose", "value": "',
                    attributes.nose,
                    '"},',
                    '{"trait_type": "Mouth", "value": "',
                    attributes.mouth,
                    '"}',
                    "]}"
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
