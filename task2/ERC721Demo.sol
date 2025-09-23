// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ERC721Demo is ERC721URIStorage {
    uint256 private _nextTokenId;

    constructor() ERC721("MyItem", "MIT") {}

    function mintNFT(address recipient, string memory tokenURI) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}
//合约地址
//0x25bCC59Ea21b9D29600fD8261B8DF8bf41E1D8A1