// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import "./Base64.sol";

contract PostRevealNFT is ERC721, Ownable, VRFConsumerBase {
    using Strings for uint256;
    struct Group {
        bytes32[5] values;
    }

    address public spNft;

    Group private eyes =
        Group(
            [
                bytes32("brown"),
                bytes32("blue"),
                bytes32("gray"),
                bytes32("green"),
                bytes32("hazel")
            ]
        );
    Group private hair =
        Group(
            [
                bytes32("blonde"),
                bytes32("brown"),
                bytes32("black"),
                bytes32("red"),
                bytes32("orange")
            ]
        );
    Group private nose =
        Group(
            [
                bytes32("big"),
                bytes32("small"),
                bytes32("round"),
                bytes32("skinny"),
                bytes32("pointy")
            ]
        );
    Group private mouth =
        Group(
            [
                bytes32("yellow"),
                bytes32("orange"),
                bytes32("pink"),
                bytes32("bronze"),
                bytes32("red")
            ]
        );


    struct AttributeValues {
        bytes32 eyes;
        bytes32 hair;
        bytes32 nose;
        bytes32 mouth;
    }

    // Mapping from token ID to its attributes
    mapping(uint256 => AttributeValues) public _tokenAttributes;

    bytes32 internal keyHash;
    uint256 internal fee;
    mapping(bytes32 => uint256) public requestIdToTokenId;

    constructor(
        address vrfCoordinator, // VRF Coordinator address
        address linkToken, // LINK token address
        bytes32 _keyHash, // Key hash
        uint256 _fee, // Fee (in LINK)
        string memory name,
        string memory symbol,
        address _spNft
    )
        VRFConsumerBase(vrfCoordinator, linkToken)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {
        keyHash = _keyHash;
        fee = _fee;
        spNft = _spNft;
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
        // We need 4 random numbers, 1 for each trait type
        uint256[] memory randomNumbers = new uint256[](4);

        for (uint256 i = 0; i < 4; i++) {
            // Simple example of derivation, you can use more complex methods
            randomNumbers[i] = uint256(keccak256(abi.encode(randomness, i)));
        }
        // Use 'randomness' to assign attributes or other features to the token
        uint256 eyesIndex = randomNumbers[0] % 5;
        uint256 hairIndex = randomNumbers[1] % 5;
        uint256 noseIndex = randomNumbers[2] % 5;
        uint256 mouthIndex = randomNumbers[3] % 5;

        bytes32 eyesValue = getGroupValues(1, eyesIndex);
        bytes32 hairValue = getGroupValues(2, hairIndex);
        bytes32 noseValue = getGroupValues(3, noseIndex);
        bytes32 mouthValue = getGroupValues(4, mouthIndex);

        _tokenAttributes[tokenId] = AttributeValues(
            eyesValue,
            hairValue,
            noseValue,
            mouthValue
        );
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
        requestRandomnessForToken(tokenId);
    }

    function getGroupValues(
        uint groupId,
        uint index
    ) public view returns (bytes32) {
        require(index < 5, "Index out of bounds");

        if (groupId == 1) {
            return eyes.values[index];
        } else if (groupId == 2) {
            return hair.values[index];
        } else if (groupId == 3) {
            return nose.values[index];
        } else if (groupId == 4) {
            return mouth.values[index];
        }

        revert("Invalid group ID");
    }

    function setTokenAttributes(
        uint256 tokenId,
        bytes32 eyes,
        bytes32 hair,
        bytes32 nose,
        bytes32 mouth
    ) public {
        require(msg.sender == spNft, "Only the parent contract can call this");
        _tokenAttributes[tokenId] = AttributeValues(eyes, hair, nose, mouth);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );

        // initially had this as !revealed[tokenId], but there could be a delay in VRF fulfilling the response which updates tokenAttributes
        if (
            keccak256(abi.encodePacked(_tokenAttributes[tokenId].nose)) ==
            keccak256(abi.encodePacked(""))
        ) {
            // The struct is "empty" or not initialized
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
            return
                string(
                    abi.encodePacked(
                        "data:application/json;base64,",
                        notRevealedJSON
                    )
                );
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

        return
            string(
                abi.encodePacked("data:application/json;base64,", revealedJSON)
            );
    }
}
