// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 @title NFT Minter for A Shadow - Assemblages album
 @author smur89
 @notice Mints a 1:1 NFt per song with a unique randomly selected artwork
 @custom:security-contact shane@swissborg.com
*/
contract AShadowAssemblages is ERC721, Pausable, Ownable, PullPayment {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    /// @dev Price to mint an NFT from this contract
    uint256 public MintPrice = 0.05 ether;
    /// @dev Total number of NFTs available (number of songs)
    uint8 public constant MaxSupply = 9;
    /// @dev Number of nfts allowed to be minted per wallet addres
    uint8 public constant NftsPerWallet = 1;

    mapping(address => uint256) public mintedWallets;

    constructor() ERC721("AShadowAssemblages", "ASHADOW") {
        /// @dev Increment in constructor to reduce gas fees on first mint
        _tokenIdCounter.increment();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /// @param to The address to send the NFT to
    function safeMint(address memory _to) external payable whenNotPaused {
        require(msg.value == MintPrice, "Wrong value");
        require(mintedWallets[_to] < NftsPerWallet, "Not enough ether sent");
        require(MaxSupply > _tokenIdCounter.current(), "Sold out");

        uint256 memory tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        mintedWallets[_to]++;
        _safeMint(_to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, tokenId);
    }

//    function withdraw() external onlyOwner {
//        uint256 memory contractBalance = address(this).balance;
//        require(contractBalance > 0, "Nothing to withdraw");
//        payable(owner()).transfer(contractBalance);
//    }
    /// @dev Overridden in order to make it an onlyOwner function
    function withdrawPayments(address payable payee) public override onlyOwner virtual {
        super.withdrawPayments(payee);
    }

    function contractURI() public view returns (string memory) {
        return _baseURI() + "a_shadow_assemblages.json";
    }
}
