//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Ownable.sol";

contract SharedWallet is Ownable{

    event LimitChanges(address indexed _member, uint oldLimit, uint newLimit);

    constructor() Ownable(msg.sender) {}


    struct Member{
        string name;
        uint limit;
        bool isAdmin;
    }
    

    mapping(address => Member) public members;


    modifier ownerOrWithinLimits(uint _amount){
        require(isOwner() || members[msg.sender].isAdmin || members[msg.sender].limit >= _amount, "not allowed");
        _;
    }

    function isOwner() internal view returns(bool){
        return owner() == msg.sender;        
    }

    function addLimit(address _member, string memory _name, uint _limit, bool _isAdmin) external onlyOwner{
        members[_member] = Member({name: _name, limit: _limit, isAdmin: _isAdmin});
        emit LimitChanges(_member, 0 , members[_member].limit);
    }


    function deduceFromLimit(address _member, uint _amount) internal{
        members[_member].limit -= _amount;
        emit LimitChanges(_member, members[_member].limit +_amount, members[_member].limit);
    }


    function renounceOwnership() public view override onlyOwner{
        revert("can't renounce");
    }

    
    function deleteMember(address _member) external onlyOwner{
        delete members[_member];
    }


    function makeAdmin(address _member) external onlyOwner{
        members[_member].isAdmin = true;
    }


    function revokeAdmin(address _member) external onlyOwner{
        members[_member].isAdmin = false;
    }
}
