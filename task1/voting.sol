// SPDX-License-Identifier: MIT
pragma solidity ~0.8;

contract voting {
    mapping(address adr => uint256 count) public voteMapping;
    address[] public personAdr;

    function vote(address adr) public {
        if(voteMapping[adr]==0){
            personAdr.push(adr);
        }
        voteMapping[adr] = voteMapping[adr]+1;
    }

    function getVotes(address adr) public view returns (uint256){
        return voteMapping[adr];
    }

    function resetVotes() public {
        for (uint i=0;i<personAdr.length;i++){
            address adr = personAdr[i];
            voteMapping[adr]=0;
        }
    }

}