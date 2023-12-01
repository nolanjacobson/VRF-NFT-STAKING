// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VRFCoordinatorV2Interface} from "lib/chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

import "./Base64.sol";
import "./PostRevealNFT.sol";

// contract size is 23,265 bytes at the moment

contract SPNFT is ERC721, Ownable, VRFConsumerBaseV2 {
    using Strings for uint256;

    struct Group {
        bytes32[5] values;
    }

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

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    bytes32 s_keyHash;
    uint32 s_callbackGasLimit = 800000;
    uint16 s_requestConfirmations = 3;
    uint32 s_numWords = 4; // Number of random values needed

    mapping(uint256 => uint256) public requestIdToTokenId;

    struct AttributeValues {
        bytes32 eyes;
        bytes32 hair;
        bytes32 nose;
        bytes32 mouth;
    }

    // Mapping from token ID to its attributes
    mapping(uint256 => AttributeValues) public _tokenAttributes;

    PostRevealNFT public revealedNFTContract;

    // Total Supply before reveal
    uint256 public constant MAX_TOTAL_SUPPLY = 5;
    uint256 public currentSupply;
    uint256 public mintPrice = 0.001 ether;

    bool public isInCollectionReveal;
    mapping(uint256 => bool) public revealed;

    constructor(
        address _vrfCoordinator, // VRF Coordinator V2 address
        uint64 subscriptionId,
        bytes32 keyHash,
        string memory name,
        string memory symbol,
        bool _isInCollectionReveal
    )
        VRFConsumerBaseV2(_vrfCoordinator)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        s_subscriptionId = subscriptionId;
        s_keyHash = keyHash;
        isInCollectionReveal = _isInCollectionReveal;
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

    function requestRandomnessForToken(uint256 tokenId) internal {
        // Ensure you have enough LINK and are subscribed to the VRF service
        // requestRandomWords(keyHash, subscriptionId, requestConfirmations, callbackGasLimit, numWords)
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            s_numWords
        );
        requestIdToTokenId[requestId] = tokenId;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 tokenId = requestIdToTokenId[requestId];
        // Use 'randomness' to assign attributes or other features to the token
        uint256 eyesIndex = randomWords[0] % 5;
        uint256 hairIndex = randomWords[1] % 5;
        uint256 noseIndex = randomWords[2] % 5;
        uint256 mouthIndex = randomWords[3] % 5;

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

    /// @notice Mint a new SP NFT to the msg.sender and increases supply.
    function mint() public payable {
        require(currentSupply + 1 <= MAX_TOTAL_SUPPLY, "Max supply exceeded");
        require(msg.value >= mintPrice, "Insufficient funds sent");

        uint256 newTokenId = currentSupply + 1;
        currentSupply = newTokenId;
        _mint(msg.sender, newTokenId);
    }

    // Function for admin (operator) to change the reveal approach (THIS IS ALSO DONE IN THE CONSTRUCTOR)
    function setInCollectionOrSeperateCollectionReveal(
        bool _isInCollectionReveal
    ) external onlyOwner {
        isInCollectionReveal = _isInCollectionReveal;
    }

    function setPostRevealNFT(address _postRevealNFT) external onlyOwner {
        revealedNFTContract = PostRevealNFT(_postRevealNFT);
    }

    function revealAndTransfer(uint256 tokenId) external onlyOwner {
        require(
            isInCollectionReveal == false,
            "This function does not work as the collection is InRevealCollection"
        );
        require(
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );
        require(ownerOf(tokenId) == msg.sender, "Invalid owner");
        address owner = ownerOf(tokenId);
        _burn(tokenId);
        revealedNFTContract.mint(owner, tokenId);
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
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );
        require(ownerOf(tokenId) == msg.sender, "Invalid owner");
        revealed[tokenId] = true;
        requestRandomnessForToken(tokenId);
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
        if (_tokenAttributes[tokenId].nose == bytes32(0)) {
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
                    bytes32ToString(attributes.eyes),
                    '"},',
                    '{"trait_type": "Hair", "value": "',
                    bytes32ToString(attributes.hair),
                    '"},',
                    '{"trait_type": "Nose", "value": "',
                    bytes32ToString(attributes.nose),
                    '"},',
                    '{"trait_type": "Mouth", "value": "',
                    bytes32ToString(attributes.mouth),
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

    function bytes32ToString(
        bytes32 _bytes32
    ) private pure returns (string memory) {
        uint256 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
