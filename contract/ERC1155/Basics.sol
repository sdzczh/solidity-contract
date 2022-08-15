pragma solidity ^0.8.13;
// SPDX-License-Identifier: MIT
 
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract ContractName is ERC1155, Ownable {
    
    string public _uri = "https://future.mypinata.cloud/ipfs/QmVL5zj6fGqGNjhhv99KkM1tv5cArLzbjgx2HAqhfbJ7az/{id}"; 
    
    string public name;
    string public symbol;
 
    constructor() ERC1155(_uri) {
        setURI(_uri);
        name = "fish";
        symbol = "_symbol";
    }
 
    function mint() public {
        _mint(msg.sender, 1, 1, "");
    }

    function setURI(string memory URI) public onlyOwner {
        _setURI(URI);
    }

}