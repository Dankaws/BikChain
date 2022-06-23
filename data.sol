//Daniel Salvadó 
//Amanda Pintado
//Antonio Pintado
//Jordi Alvarez
//Jaume Vaquer
//Daniela Cibotaru

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./rent.sol";
import "./sell.sol";
import "./token.sol";

contract DataContract {

    uint256 bikeCount = 0 ;
    uint256 peopleCount = 0;
    address public token;
    address payable public wallet;

    mapping(uint256 => Person) public people;
    mapping(uint256 => Bike) public bikes;


    struct Person {
        string firstName;
        string lastName;
        address payable payable_wallet;
    }

    struct Bike {
        uint256 id;
        address owner;
        uint256 price;
        uint rentPrice;
        uint bailPrice;
        bool is_rent;
        address rent_owner;
        bool is_sell;
        string state;
        RentContract rentContract;
        SellContract sellContract;
    }

    constructor(address _token, address payable _wallet) {
        token = _token;
        wallet = _wallet;
    }

    function addPerson(string memory _firstName, string memory _lastName,address payable _payable_wallet) public {
        uint256 owner_now = personPos(_payable_wallet); 
        require(owner_now == 0);
        peopleCount +=1; //contador no es una posicion d ela lista
        people[peopleCount] = Person(_firstName, _lastName, _payable_wallet);
    }

    function addBike(address _ownerAddress, uint256  _price,uint256  _Rentprice,uint256  _Bailprice, bool  _is_rent, bool  _is_sell ,string memory _state) public {
        bikeCount += 1;

        bikes[bikeCount] = 
            Bike(bikeCount, _ownerAddress, _price,_Rentprice,_Bailprice, _is_rent, _ownerAddress, _is_sell,_state,
            new RentContract(  payable(address(0)),payable(address(0)), 0, address(0),0,0 ) , 
            new SellContract(0, payable(address(0)), payable(address(0)),address(0)));
    }

    modifier isOwner(Bike memory _bike) {
        require(_bike.owner == msg.sender,"This is not your bike");
        _;
    }

    
    function personPos(address owner_addres) public view returns(uint){
        for(uint i = 1; i <= peopleCount; i++){
        
            if( people[i].payable_wallet == owner_addres){
                return i;
            }
        }
        return 0;
    }


    function printBikeIDs(address  owner_addres)  public view returns(uint256 [] memory){

        
        uint256 counter=0;

        for(uint i = 1; i <= bikeCount; i++){
        
            if( bikes[i].owner == owner_addres){
                
                counter++;
            }
        }

        uint256 [] memory bikeIDs=new uint256[](counter);
        uint256 counter2=0;

        for(uint i = 1; i <= bikeCount; i++){
        
            if( bikes[i].owner == owner_addres){
                uint256 bici = uint256 (bikes[i].id);
                bikeIDs[counter2]=bici;
                counter2++;
            }
        }

       return bikeIDs;
    }


    function updateState(uint bike_id,string memory _state) public  returns(string memory) {
        require(bikes[bike_id].owner == msg.sender,"this is not your bike");
        bikes[bike_id].state=_state;
        return  bikes[bike_id].state;
    }

    function viewState(uint bike_id) public view returns(string memory) {
        return  bikes[bike_id].state;
    }

    function rentBike(uint256  _bikeId, address payable _renter, uint256 _time ) payable public isOwner(bikes[_bikeId]) {
        Bike memory bikeToRent = bikes[_bikeId];
        
        //el usuario introduce el tiempo en minutos porque si porque es facil porque es la moda 
        require(bikeToRent.is_rent,"The bike is not rentalbe"); //la bici esta disponible
        require(_renter != address(0),"The address does not exist"); //la dirección del renter no es cero (nos puede pagar)
        require (_time > 0,"The time must be higher than 0"); //ha dado un tiempo
        MyToken _token = MyToken(address(token));
        //miramos si el renter tiene el dinero + la fianza
        require(_token.canPay(bikeToRent.rentPrice+ bikeToRent.bailPrice,_renter ),"No tiene el dinero");
        //creamos el contrato y SE MANDA EL DINERO
        RentContract bikeRentCont = new RentContract(payable(bikeToRent.owner),_renter, _time,token,bikeToRent.rentPrice,bikeToRent.bailPrice ); 
        //guardamos el contrato en la bici
        bikeToRent.rentContract = bikeRentCont;

        //hacemos que la bici no se pueda poner el alquiler
        bikeToRent.is_rent = false;

        //Canviamos el rentOwner
        bikeToRent.rent_owner=_renter;

        bikes[_bikeId] = bikeToRent;
    }

    function sellBike(uint256  _bikeId, address payable _buyer) payable public isOwner(bikes[_bikeId]) {
        Bike memory bikeToSell = bikes[_bikeId];
        
        //el usuario introduce el tiempo en minutos 
        require(bikeToSell.is_sell,"The bike must be sellable"); //la bici esta disponible
        require(_buyer != address(0),"The address does not exist"); //la dirección del renter no es cero (nos puede pagar)
    
        //creamos el contrato y SE MANDA EL DINERO
        SellContract bikeSellCont = new SellContract(bikeToSell.price, payable(bikeToSell.owner), _buyer, token); 
        //guardamos el contrato en la bici
        bikeToSell.sellContract = bikeSellCont;

        //hacemos que la bici no se pueda poner el alquiler
        bikeToSell.is_rent = false;

        //cambiamos dueño 
        bikeToSell.owner = _buyer;
        bikeToSell.rent_owner = _buyer;

        bikes[_bikeId] = bikeToSell;
    }

    function changeSellState(uint256 _bikeId) public isOwner(bikes[_bikeId]) returns  (bool){
        bikes[_bikeId].is_sell = !bikes[_bikeId].is_sell;
        return bikes[_bikeId].is_sell;
    }

    function changeRentState(uint256 _bikeId) public isOwner(bikes[_bikeId]) returns (bool){
        require(bikes[_bikeId].rent_owner==bikes[_bikeId].owner,"This bike is already rented");
        bikes[_bikeId].is_rent = !bikes[_bikeId].is_rent;
        return bikes[_bikeId].is_rent;
    }


    function returnedBike(uint256  _bikeId) public isOwner(bikes[_bikeId]) {

        Bike memory bikeToRent = bikes[_bikeId];
        //llamamos a la funcion delc ontrato rent para que se manage el dinero
        console.log("Init");
        bikeToRent.rentContract.returnBike();
        console.log("Aqui no va a llegar");
        // cambiar de owner
         bikeToRent.rent_owner=bikeToRent.owner;
        //cambiar bool a true de poner en renta
        bikeToRent.is_rent=true;

        bikes[_bikeId] = bikeToRent;
    }

    function buyToken(address recipient) public payable {
        MyToken _token = MyToken(address(token));
        _token.mint(recipient,msg.value);
        wallet.transfer(msg.value);
    }
    
}