pragma solidity ^0.8.15;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {

    //买入费率
    uint public constant inRate = 15;
    //卖出费率
    uint public constant outRate = 5;
    //买入分红地址
    address public inAddr = 0x378B55b63Bcb416D8401C8f358A33681e3627771;
    //卖出分红地址
    address public outAddr = 0x378B55b63Bcb416D8401C8f358A33681e3627771;
    address public pair;

    constructor() ERC20("TokenName", "Symbol") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        if(pair != address(0)){
            if(sender == pair){
                uint x = amount * inRate / 100;
                super._transfer(sender, inAddr, x);
                super._transfer(sender, recipient, amount - x);
            }else if(recipient == pair){
                uint x = amount * outRate / 100;
                super._transfer(sender, outAddr, x);
                super._transfer(sender, recipient, amount - x);
            }else{
                super._transfer(sender, recipient, amount);
            }
        }else{
            super._transfer(sender, recipient, amount);
        }
    }

    //添加流动性后设置pair地址
    function setPair(address _pair) public onlyOwner {
        pair = _pair;
    }
    

}