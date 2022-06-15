// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 @title NFT Minter for A Shadow - Assemblages album
 @author smur89
 @notice Mints a 1:1 NFt per song with a unique randomly selected artwork
 @custom:security-contact shane@swissborg.com
*/
contract AShadowAssemblages is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public mintPrice = 0.05 ether;
    uint8 public maxSupply = 9; // number of songs
    uint8 public nftsPerWallet = 1;

    mapping(address => uint256) public mintedWallets;

    constructor() ERC721("AShadowAssemblages", "ASHADOW") {

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
        require(msg.value == mintPrice, "Wrong value");
        require(mintedWallets[_to] < nftsPerWallet, "Not enough ether sent");
        require(maxSupply > _tokenIdCounter.current(), "Sold out");

        uint256 memory tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        mintedWallets[_to]++;
        _safeMint(_to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function withdraw() external onlyOwner {
        uint256 memory contractBalance = address(this).balance;
        require(contractBalance > 0, "Nothing to withdraw");
        payable(owner()).transfer(contractBalance);
    }
}
