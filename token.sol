//Daniel Salvadó 
//Amanda Pintado
//Antonio Pintado
//Jordi Alvarez
//Jaume Vaquer
//Daniela Cibotaru
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;
import "hardhat/console.sol";

contract ERC20Token {
    mapping(address => uint256) public balances;

    function mint(address buyer,uint256 _value) virtual payable public {
        balances[buyer] += 1;
    } 
}

 contract MyToken is ERC20Token {
    string public symbol;
    uint256 public ownerCount=0;
    address []  owners = new address[](100);
    uint256 public conversionValue = 50 wei;

    function mint(address buyer, uint256 _value) payable override public {  
        if(!searchInMap(buyer)){
            ownerCount += 1;
            balances[buyer] =  0; 
            owners[ownerCount]=buyer;
        }
        require(_value >= conversionValue,"You do not have enough money");
        super.mint(buyer,_value);
    }

    function transferTokens(uint256 _numTokens, address _buyer, address _receiver) public {
        require(searchInMap(_buyer),"buyer not found");
        console.log("Init transfer");
        if(!searchInMap(_receiver)){
            ownerCount += 1;
            balances[_receiver] =  0; 
            owners.push(_receiver);
        }
        require(balances[_buyer] >= _numTokens);
        balances[_buyer] -= _numTokens;
        balances[_receiver] += _numTokens;
    }

    function searchInMap(address _address) internal view returns(bool) {
        for(uint256 i = 1; i < ownerCount + 1; i++){
            if(owners[i] == _address){
                return true;
            }
        }
        return false;
    }

    function tokensToCrypto(uint256  ammount, address payable person) internal  {

        require (person==tx.origin,"");
        require(person != address(0));
        require(balances[person] != 0);
        require(balances[person] >= ammount);
       
        //We retrive the correct ammount from the balance
        balances[person]=balances[person]-ammount;

        uint256 variable  = conversionValue*ammount;

        person.transfer(variable);


    }
    
    function canPay(uint256 num_tokens,address payer ) public view returns(bool ) {
        return(balances[payer] >= num_tokens);

    }

}

    

