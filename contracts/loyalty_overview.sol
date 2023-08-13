pragma solidity >=0.4.21 <0.6.0;


import "./loyalty_points.sol";

//	@Title Loyalty Overview

///@dev Logic for the whole loyalty program system. Each business is assigned its own crypto token. Customers can choose which business loyalty program to join. Businesses can choose to partner up with other businesses. Customers can redeem tokens earned at one businesses at another business provided they have a partnership.


contract loyalty_overview {

	address private owner;

	constructor() public {
		owner = msg.sender;
	}

	//This is  complex type which will be used to identify a customer

	struct Customer {
        address cusAd;
        string firstName;
        string lastName;
        string email;
        bool isReg;
        mapping(address => bool) bus; //Check if customer is part of the loyalty program of the business
        //mapping(address => address) cont;
	}

	//This is  complex type which will be used to identify a business

	struct Business {
        address busAd;
        string name;
        string email;
        bool isReg;
        loyalty_points lt; //crypto token of the business
		uint256 count; // means store count of the tokens left !!
        mapping(address => bool) cus;//Check if customer is part of the loyalty program of the business
        // mapping(address => bool) bs;//Check if business has an arrangement with other businesses
        // mapping(address => uint256) rate;//Rate of exchange between the two crypto-tokens
	}

	///each address is mapped to a specific customer or business
	mapping(address => Customer) public customers;
	mapping(address => Business) public businesses;
	address public flipkartAccount;
	

	// all business will have same : address !! i.e flipkart's wallet !!
	
	function isAddressInitialized() public view returns (bool) {
    	return flipkartAccount != address(0);
	}

    	/**
     * @dev Registers a new business
     * @param _bName  name of business
     * @param _email email of business
     * @param _bAd Address business
     * @param _symbol of crypto token
     * @param _decimal precision of token
     */


	// during registeration the msg.sender==flipkart !! so private key of flipkart 
	// to be used there !!
	function regBusiness(address flipkartAddress,string memory _bName, string memory _email, address _bAd, string memory _symbol, uint8 _decimal) public {
		require(msg.sender == owner);
		require(!customers[_bAd].isReg, "Customer Registered");
		if(!isAddressInitialized()){
			flipkartAccount=flipkartAddress;
		}
		loyalty_points _newcon = new loyalty_points(_bAd, _bName, _symbol, _decimal); //creates new crypto-token
		businesses[_bAd]=Business(_bAd, _bName , _email, true, _newcon,uint256(10000));//creates new business
		businesses[_bAd].lt.mint(flipkartAccount, 10000);//transfers token into the 
		// account of flipkart !! 

	}

	    /**
     * @dev Registers a new customer
     * @param _firstName first name of customer
     * @param _lastName last name of customer
     * @param _email email of customer
     * @param _cAd address of customer

     */
  
	function regCustomer(string memory _firstName, string memory _lastName, string memory _email, address _cAd) public {
		require(msg.sender == owner);
		require(!customers[_cAd].isReg, "Customer Registered");
		customers[_cAd] = Customer(_cAd, _firstName, _lastName, _email, true);
	}

	/**
     * @dev Customer joins business loyalty program
     * @param _bAd address of business

     */
	
	// if this is being initiated means : flipkart account is with you !!
	// this is initiated by customer !! so customer add == msg.sender !! 
	function joinBusiness(address _bAd) public{
		require(customers[msg.sender].isReg, "This is not a valid customer account");//customer only can call this function
		require(businesses[_bAd].isReg, "This is not from the flipkart side");
		// means : calls me we will be using flipkart account only 
		// only for the : registeration purpose we are using business wallet address !!
 		businesses[_bAd].cus[msg.sender] = true;//putting customer in business's list and business in the customer's list.
		customers[msg.sender].bus[_bAd] = true;
	}



	/**
     * @dev Redeem points. Points are transfered from the customer to the business. This function can only be invoked by a customer
     * Emits an transfer event.
     *@param from_bus Address of Business from whose crypto token is to be redeemed
     *@param to_bus Address of Business to whom the tokens are being sent
     * @param _points Points to be transfered
     */

	// so like see : it will be from customer to : flipkart 
	// so see : customer's private key : will be get safely from metamask !!
	// and : flipkart's wallet address is with us only !! 
	// so msg.sender will be : customer !!
	// function spend(address from, address to, uint256 _points) public {
	// 	require(customers[msg.sender].isReg, "This is not a valid customer account");
	// 	require(businesses[to].isReg, "This is not a valid business account");

	// 	// so money should be transfered from : customer's account to : 
	// 	// flipkart's account !!
	// 	if(from_bus==to_bus){
	// 		//transaction is with the same business
	// 		businesses[to_bus].lt.transferFrom(msg.sender, to_bus, _points);
	// 	}
	// 	else{
	// 		//requires both businesses to have agreed to the terms
	// 		require(businesses[from_bus].bs[to_bus], "This is not a valid linked business account");
	// 		require(businesses[to_bus].bs[from_bus], "This is not a valid linked business account");
	// 		uint256 _r = businesses[from_bus].rate[to_bus];
	// 		//burn from first account(customer) and mint into the reciever's businesses 
	// 		businesses[from_bus].lt.burnFrom(msg.sender, _points);
	// 		businesses[to_bus].lt.mint(to_bus, _r*_points);

	// 	}


	// }


    /**
     * @dev Credit points to a customers account. This function can only be invoked by a business
     * Emits an transfer event.
     * @param _points Points to be transfered
     * @param _cAd Address of Customer
     */

	// execution of contract will be done by flipkart !! 
	// _cAd will be got from metamask !!
	// _bAd will be got from dropdown selection / mongodb !!
	function reward(address _cAd, uint256 _points,address _bAd) public{
		require(flipkartAccount==msg.sender, "This is not from side of flipkart");
		require(customers[_cAd].isReg, "This is not a valid customer account");
		// require(businesses[msg.sender].cus[_cAd], "This customer has not joined your business" );
		// require(customers[_cAd].bus[msg.sender], "This customer has not joined your business" );
		businesses[_bAd].lt.transferFrom(msg.sender, _cAd, _points); 
		// see the methods specified in the transferFrom() method in the interface er20 one 
		// is basically taking care of the : consistency issues and all !!
		businesses[_bAd].count-=_points;
		// thereby this helps in getting the : balance of business !! 
	}


	function getBusinessBalance(address _bAd) public view returns (uint256) {
		return businesses[_bAd].count;
	}



}