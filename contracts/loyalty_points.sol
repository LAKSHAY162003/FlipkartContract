pragma solidity >=0.4.21 <0.6.0;

import "./token/ERC20/ERC20Mintable.sol";

contract loyalty_points is ERC20Mintable {
    address private owner;
    string private name;
    string private symbol;
    uint8 private decimal;


    constructor(address _bAd, string memory _name, string memory _symbol, uint8 _decimal) public {
        owner = _bAd;
        name = _name;
        symbol = _symbol;
        decimal = _decimal;

    }
}
