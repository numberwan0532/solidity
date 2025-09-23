// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BeggingContract{

    address[] public addressList;

    mapping(address account => uint amount) public amount;

    address public owner;

    event Donation(address from, uint amount);

    uint256 public timestamp;

    uint256 public lockTime = 3 minutes;

    constructor(){
        timestamp = block.timestamp;
        owner = msg.sender;
    }
    // 自定义修饰符，仅允许合约所有者调用
    modifier onlyOwner {
        require(msg.sender == owner, "only owner can call");
        _;
    }

    function donate() public payable {
        require(block.timestamp<=timestamp+lockTime,"time is over");
        amount[msg.sender] += msg.value;
        addressList.push(msg.sender);
        emit Donation(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner{
        require(block.timestamp>timestamp+lockTime,"time is not over");
        payable(msg.sender).transfer(address(this).balance);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getDonation(address _address) public view returns(uint256){
        return amount[_address];
    }

    function getTopThreeAddress() public view returns(address[] memory addrs){
        address[] memory addrList = new address[](3);
        for(uint i=0;i<addressList.length;i++){
            if(amount[addressList[i]] > amount[addrList[0]]){
                addrList[2] = addrList[1];
                addrList[1] = addrList[0];
                addrList[0] = addressList[i];
            }else if(amount[addressList[i]] > amount[addrList[1]]){
                addrList[2] = addrList[1];
                addrList[1] = addressList[i];
            }else if(amount[addressList[i]] > amount[addrList[2]]){
                addrList[2] = addressList[i];
            }
        }
        return addrList;
    }

}

//合约地址
//0x62762F7533827B8395660bdE2A82706e0F7e941d