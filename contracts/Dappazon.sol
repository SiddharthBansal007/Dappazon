// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {

    address public owner;
    
    struct Item {
        uint256 id;
        string name;
        string  category;
        string  image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 id;
        Item item;
    }


    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint => Order)) public orders;
    

    event List(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer, uint256 orderId, uint256 itemId);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //List products
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {

        //allow only owner to list but we are using modifier
        // require(msg.sender == owner);

        //Create an item struct
        Item memory item = Item(_id, _name, _category, _image, _cost, _rating, _stock);

        //Saving Item Struct to BlockChain
        items[_id] = item;

        //emit an event
        emit List(_name, _cost, _stock);
    }

    //Buy Products
    function buy(uint256 _id) public payable {

        //fetch item
        Item memory item = items[_id];

        //check if enough ether to buy item
        require(msg.value >= item.cost, "Not enough ether sent to purchase the item");

        //check if the item is in stock
        require(item.stock > 0, "Item is out of stock");

        //create an order
        Order memory order = Order(block.timestamp, item);

        //save order to chain
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        //subtract stock
        items[_id].stock = item.stock - 1;

        //emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);

    }

    //withdraw funds
    function withdraw() public onlyOwner{
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }


}
