// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract reverseString{
    bytes a;
    bytes b;
    string public result;

    function reverse(string memory _s) public returns (string memory){
        a = bytes(_s);
        b = new bytes(a.length);
        for(uint i = 0; i < a.length; i++){
            b[i] = a[a.length - i - 1];
        }
        result = string(b);
        return result;
    }

    function getResult() public view returns(string memory){
        return result;
    }
}