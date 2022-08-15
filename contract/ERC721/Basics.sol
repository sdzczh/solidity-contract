// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract utils{
     function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
     bytes memory _ba = bytes(_a);
     bytes memory _bb = bytes(_b);
     string memory ret = new string(_ba.length + _bb.length);
     bytes memory bret = bytes(ret);
     uint k = 0;
     for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
     for (uint i = 0; i < _bb.length; i++) {
         bret[k++] = _bb[i];
         
     }
     return string(ret);
 } 
   function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
  }
}

contract MyToken is ERC721, ERC721URIStorage, Ownable, utils {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK") {}

    //替换此部分元数据
    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/~/";
    }

    //铸造nft
    function mint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, strConcat(_baseURI(), toString(tokenId)));
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}