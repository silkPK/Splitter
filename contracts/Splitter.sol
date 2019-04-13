pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Splitter is Ownable {
    
    using SafeMath for uint256;

    event EventSplitterCreated(
        address indexed caller
    );

    event EventEtherSplitted(
        address indexed caller,
        address beneficiary1,
        address beneficiary2,
        uint256 splittedValue,
        uint256 remainder
    );

    event EventWithdraw(
        address indexed caller,
        uint256 balance
    );

    mapping(address => uint256) public credit;

    constructor () public {
        emit EventSplitterCreated(msg.sender);
    }

    // whenever Alice sends ether to the contract for it to be split, 
    // half of it goes to Bob and the other half to Carol. 
    function splitEthers(address beneficiary1, address beneficiary2) public onlyOwner payable {
        require(msg.value != 0, "Send zero Ether is not allowed");
        require(beneficiary1 != address(0), "First beneficiary Address can not be null" );
        require(beneficiary2 != address(0), "Second beneficiary Address can not be null" );
        require(beneficiary1 != beneficiary2, "Beneficiary Addresses can not be the same" );

        uint256 remainder = msg.value.mod(2);

        uint256 splittedValue = msg.value.sub(remainder).div(2);

        if (splittedValue != 0) {
            credit[beneficiary1] = credit[beneficiary1].add(splittedValue);
            credit[beneficiary2] = credit[beneficiary2].add(splittedValue);

            emit EventEtherSplitted(msg.sender,beneficiary1, beneficiary2, splittedValue, remainder);
        }   
        
        if (remainder != 0) {
            msg.sender.transfer(remainder);
        }
    }

    function withdraw() public {
        uint256 aCredit = credit[msg.sender];

        require(aCredit != 0);

        credit[msg.sender] = 0;
        
        emit EventWithdraw(msg.sender, aCredit);   

        msg.sender.transfer(aCredit);
    }
}
