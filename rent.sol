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

contract RentContract  {

    address payable owner; 
    address payable renter; 
    uint256 time;
    address token;
    uint256 rentPrice;
    uint256 bailPrice;
    constructor(address payable _owner, address payable _renter, uint256 _time, address _token,uint256 _rentPrice,uint256 _bailPrice){
        owner = _owner;
        renter = _renter;
        time = block.timestamp + _time*60;
        token=_token;
        rentPrice=_rentPrice;
        bailPrice=_bailPrice;
    }

    function returnBike() payable public {

        MyToken newToken = MyToken(address(token));
        console.log("return 1");
        if (block.timestamp >= time){ //si se ha pasado del tiempo previstp
            //al owner le pagamos lo del contrato + fianza
            console.log("return se ha pasado de tiempo 1");
            newToken.transferTokens(rentPrice + bailPrice, renter, owner);
            console.log("return se ha pasado de tiempo 2");
           
        }
        else{
            //le pagamos al owner lo del contrato
            console.log("return NO se ha pasado de tiempo 1");

           // if (fianza < msg.value){
           //     console.log("return  if 1");
           //     newToken.transferTokens(msg.value - fianza, renter, owner);
           //     console.log("return  if 2");
           // }
            console.log("return end if");
            
            newToken.transferTokens(rentPrice,renter,owner ); 
            console.log("END retunr");
        }
    }
}