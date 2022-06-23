//Daniel Salvadó 
//Amanda Pintado
//Antonio Pintado
//Jordi Alvarez
//Jaume Vaquer
//Daniela Cibotaru
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;
import "./data.sol";
import "./token.sol";

contract SellContract  {

    uint256 price; 
    address payable owner;
    address payable buyer; 
    address token;

    constructor(uint256 _price, address payable _owner, address payable _buyer, address _token)  { 
        price = _price;
        owner = _owner;
        buyer = _buyer;
        token = _token;
    }

    function buyBike() internal {
        MyToken newToken = MyToken(address(token));
        newToken.transferTokens(price, buyer, owner);
    }

    


}