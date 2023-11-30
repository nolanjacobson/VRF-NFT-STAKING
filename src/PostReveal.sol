// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract PostRevealNFT is ERC721, Ownable {
    uint256 public nextTokenId;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint(address to) external onlyOwner {
        _safeMint(to, nextTokenId);
        nextTokenId++;
    }
}