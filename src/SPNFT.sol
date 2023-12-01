// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import "./Base64.sol";
import "./PostReveal.sol";

contract SPNFT is ERC721, Ownable, VRFConsumerBase {
    struct Group {
        uint256[5] values;
    }

    Group public eyes = Group(["brown", "blue", "gray", "green", "hazel"]);
    Group public hair = Group(["blonde", "brown", "black", "red", "orange"]);
    Group public nose = Group(["big", "small", "round", "skinny", "pointy"]);
    Group public mouth = Group(["yellow", "orange", "pink", "bronze", "red"]);

    using Counters for Counters.Counter;
    using Strings for uint256;

    bytes32 internal keyHash;
    uint256 internal fee;
    mapping(bytes32 => uint256) public requestIdToTokenId;

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

    constructor(
        address vrfCoordinator, // VRF Coordinator address
        address linkToken, // LINK token address
        bytes32 _keyHash, // Key hash
        uint256 _fee, // Fee (in LINK)
        string memory name,
        string memory symbol,
        uint256 _mintPrice,
        bool _isInCollectionReveal
    ) VRFConsumerBase(vrfCoordinator, linkToken) ERC721(name, symbol) {
        keyHash = _keyHash;
        fee = _fee;
        mintPrice = _mintPrice;
        isInCollectionReveal = _isInCollectionReveal;
    }

    function requestRandomnessForToken(
        uint256 tokenId
    ) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        requestId = requestRandomness(keyHash, fee);
        requestIdToTokenId[requestId] = tokenId;
    }

    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal override {
        uint256 tokenId = requestIdToTokenId[requestId];
        // Use 'randomness' to assign attributes or other features to the token
        // e.g., _tokenAttributes[tokenId] = ...;
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

    function revealAndTransfer(uint256 tokenId) external onlyOwner {
        require(
            isInCollectionReveal == false,
            "This function does not work as the collection is InRevealCollection"
        );
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        _burn(tokenId);
        revealedNFTContract.mint(msg.sender);
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
        return "";
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

        // initially had this as !revealed[tokenId], but there could be a delay in VRF fulfilling the response which updates tokenAttributes
        if (!_tokenAttributes[tokenId]) {
            string memory notRevealedJSON = Base64.encode(
                bytes(
                    abi.encodePacked(
                        '{"name": "Mystery Box",',
                        '"description": "This is an unrevealed mystery box.",',
                        '"attributes": ['
                        "]}"
                    )
                )
            );
            return string(abi.encodePacked("data:application/json;base64,", notRevealedJSON));
        }

        AttributeValues memory attributes = _tokenAttributes[tokenId];
        string memory revealedJSON = Base64.encode(
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

        return string(abi.encodePacked("data:application/json;base64,", revealedJSON));
    }
}
