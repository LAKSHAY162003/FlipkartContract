pragma solidity >=0.4.21 <0.6.0;


import "./loyalty_points.sol";

//	@Title Loyalty Overview

///@dev Logic for the whole loyalty program system. 
/// Each business is assigned its own crypto token. 
/// Customers can choose which business loyalty program to join. 
/// Businesses can choose to partner up with other businesses.


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
	}

	//This is  complex type which will be used to identify a business

	struct Business {
        address busAd;
        string name;
        string email;
        bool isReg;
        loyalty_points lt; //crypto token of the business
        mapping(address => bool) cus;//Check if customer is part of the loyalty program of the business
	}

	///each address is mapped to a specific customer or business
	mapping(address => Customer) public customers;
	mapping(address => Business) public businesses;
	


    	/**
     * @dev Registers a new business
     * @param _bName  name of business
     * @param _email email of business
     * @param _bAd Address business
     * @param _symbol of crypto token
     * @param _decimal precision of token
     */

	function regBusiness(string memory _bName, string memory _email, address _bAd, 
	string memory _symbol, uint8 _decimal) public {
		require(!customers[_bAd].isReg, "Customer Registered with same address !!");
		require(!businesses[_bAd].isReg, "Business Already Registered !!");
		
		loyalty_points _newcon = new loyalty_points(_bAd, _bName, _symbol, _decimal); //creates new crypto-token
		businesses[_bAd]=Business(_bAd, _bName , _email, true, _newcon);//creates new business
		businesses[_bAd].lt.mint(_bAd, 20*(10**18));//transfers token into the 
		// account of flipkart !! : intitialy fix amount of tokens minted into the business 
		// wallet : again reason being : we need to ensure that flipkart is fare with every 
		// seller !! 

		// and then : based on there performance : they get incentivised !! 
	}

	function getBusinessCoin(address _bAd) public view returns(address){
		return address(businesses[_bAd].lt);
	}

	    /**
     * @dev Registers a new customer
     * @param _firstName first name of customer
     * @param _lastName last name of customer
     * @param _email email of customer
     * @param _cAd address of customer

     */
	function regCustomer(string memory _firstName, string memory _lastName, string memory _email, address _cAd) public {
		// require(msg.sender == owner);
		require(!customers[_cAd].isReg, "Customer Already Registered");
		customers[_cAd] = Customer(_cAd, _firstName, _lastName, _email, true);
	}

	/**
     * @dev Customer joins business loyalty program
     * @param _bAd address of business
     */

	 // this function of contract executed by customer only !! 
	 // So msg.sender == customer !!
	function joinBusiness(address _bAd) public{
		require(customers[msg.sender].isReg, "This is not a valid customer account");//customer only can call this function
		require(businesses[_bAd].isReg, "Please Register the Business First !");
		// means : calls me we will be using flipkart account only 
		// only for the : registeration purpose we are using business wallet address !!
 		businesses[_bAd].cus[msg.sender] = true;//putting customer in business's list and business in the customer's list.
		customers[msg.sender].bus[_bAd] = true;
	}

	
	/**
     * @dev Registers a new customer
     * @param _cAd address of customer
     * @param _points No of points to be rewarded { will be some percentage of price }
     * @param _bAd address of business
     */

	// this will be run on a product sell !! 
	function reward(address _cAd, uint256 _points,address _bAd) public{
		require(customers[_cAd].isReg, "This is not a valid customer account");
		require(businesses[_bAd].isReg, "This is not a valid business account");
		require(businesses[_bAd].cus[_cAd],"Please Enroll into the program First !!");

		// see during reward we need to mint !!
		businesses[_bAd].lt.mint(_bAd,_points); // so : points will be of the order 10**18 
		businesses[_cAd].lt.mint(_cAd,_points); // equal amount of incentives / tokens 
		// will be minted into the _cAd and _bAd to ensure equality !! 

		// see balanceOf() fnc is there !! 
	}

	/**
     * @dev Registers a new customer
     * @param _points No of points to be rewarded for product listing 
     * @param _bAd address of business
     */

	// this will be run on a product listing by the seller giving him/her incentive 
	// to list product on the flipkart's platform !! 
	function listProductReward(uint256 _points,address _bAd) public{
		require(businesses[_bAd].isReg, "This is not a valid business account");

		// see during reward we need to mint !!
		businesses[_bAd].lt.mint(_bAd,_points); // so : points will be of the order 10**18 

		// see balanceOf() fnc is there !! 
	}

	/**
     * @dev Registers a new customer
     * @param _points No of points to be detucted and thereby burnt from customer's account !!
     * @param _bAd address of business
	 * @param _cAd address of customer 
     */
	
	// will be run when a person reedem's some tokens !!! 
	function spend(address _cAd,uint256 _points,address _bAd) public{
		require(businesses[_bAd].isReg,"Not a registered Business");
		require(customers[_cAd].isReg,"Not a registered Customer");
		// just burn these tokens !! from the customer's account !! 

		businesses[_bAd].lt.burnFrom(_cAd, _points);
	}


}