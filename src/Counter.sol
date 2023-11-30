// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TourPackERC721 is ERC721, PackMetadata {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // bool dictating if the pack is transferable or not
    bool public isTransferable;

    // typically Packs can be opened immediately. There may be some cases in the future where Packs may not be opened immediately, and must be saved to open later.
    bool isLockedForPeriodOfTime;

    string imageUrl;
    string animationUrl;

    event PackRevealed(address[] nftContracts, uint256[] tokenIds);

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `ADMIN_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     * @param _name - the name of the NFT
     * @param _symbol - the symbol of the NFT
     * @param _superAdmin - the owner of the contract
     * @param _tourAdmins - the tour admins of the contract
     * @param _isTransferable - whether or not the pack is transferable
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _imageUrl,
        string memory _animationUrl,
        PackProps memory _packProps,
        address _superAdmin,
        address[] memory _tourAdmins,
        bool _isTransferable
    )
        SuperAdminERC721(_name, _symbol, _superAdmin, _tourAdmins)
        PackMetadata(_packProps)
        ERC2771Context(0xf0fbcfd6675241D5F54207F64AD5E203380cF72e)
    {
        _grantRole(PAUSER_ROLE, _superAdmin);
        isTransferable = _isTransferable;
        imageUrl = _imageUrl;
        animationUrl = _animationUrl;
    }

    function _msgSender() internal view override(Context, ERC2771Context) returns (address sender) {
        sender = ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(tokenId), 'URI query for nonexistent token');
        return createPackMetadata(packProps, imageUrl, animationUrl, tokenId);
    }

    /// @notice Mint a new tour pack NFT to an address with a defined URI
    /// @param recipient recipient address to mint the NFT to
    function mint(address recipient, uint256 tokenId) external onlyRole(ADMIN_ROLE) returns (uint256) {
        require(
            packProps.pack_edition_count > tokenSupply.current(),
            'Number of total packs to be minted has been reached.'
        );

        tokenSupply.increment();

        _mint(recipient, tokenId);
        return tokenId;
    }

    /// @notice Batch Mint a new tour pack NFTs to addresses
    /// @param recipients recipient addressses to mint the NFTs to
    /// @param tokenIds tokenIds to set for the NFT
    function batchMint(address[] memory recipients, uint256[] memory tokenIds) external onlyRole(ADMIN_ROLE) {
        uint256 currentNumberOfPacksPlusMintingPack = tokenSupply.current() + recipients.length;
        require(
            packProps.pack_edition_count >= currentNumberOfPacksPlusMintingPack,
            'Number of total packs to be minted has been reached.'
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            tokenSupply.increment();
            _mint(recipients[i], tokenIds[i]);
        }
    }

    /// @notice Reveal a tour pack NFT using an array of NFT contracts that pack will contain
    /// @param tokenId tokenId of the pack to reveal
    /// @param nftContracts array of NFT contracts that the pack will contain
    function revealPack(
        address ownerAddress,
        uint256 tokenId,
        address[] calldata nftContracts,
        uint256[] calldata tokenIds
    ) external onlyRole(ADMIN_ROLE) {
        require(ownerOf(tokenId) == ownerAddress, 'Owner address must be owner of tokenId');
        // get the owner of the tokenId
        address owner = ownerOf(tokenId);

        // burn the pack
        burn(tokenId);

        uint256[] memory tokenIdsMinted = new uint256[](nftContracts.length);
        // mint or transfer the new NFTs that are revealed
        for (uint256 i = 0; i < nftContracts.length; i++) {
            uint256 tokenIdMinted = IERC721Mintable(nftContracts[i]).mint(owner, tokenIds[i]);
            tokenIdsMinted[i] = tokenIdMinted;
        }

        emit PackRevealed(nftContracts, tokenIdsMinted);
    }

    /// @notice Transfers a tour pack NFT to an address from a sender with an operator filter
    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        require(isTransferable == true, 'AutographXTourPack: Untransferable pack');
        super.transferFrom(from, to, tokenId);
    }

    /// @notice Safe Transfers a tour pack NFT to an address from a sender
    function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        require(isTransferable == true, 'AutographXTourPack: Untransferable pack');
        super.safeTransferFrom(from, to, tokenId);
    }

    /// @notice Safe Transfers a tour pack NFT to an address from a sender
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721, IERC721) {
        require(isTransferable == true, 'AutographXTourPack: Untransferable pack');
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function toggleIsTransferable() external onlyRole(PAUSER_ROLE) returns (bool) {
        isTransferable = !isTransferable;
        return isTransferable;
    }
}