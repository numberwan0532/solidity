// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract FindTarget{

    function findTargetNumber(uint256[] memory numbers, uint256 target) public pure returns (uint256) {

        require(target<numbers[numbers.length-1]&&target>numbers[0],"bu he fa");
        return _findTargetNumber(numbers,target,0,numbers.length-1);
    }

    function _findTargetNumber(uint256[] memory numbers, uint256 target,uint256 left,uint256 right) private  pure returns (uint256) {
        uint256 mid = left + (right - left)/2;

        if(numbers[mid]==target){
            return mid;
        }else if (numbers[mid]<target){
            return _findTargetNumber(numbers, target, mid+1, right);
        }else{
            return _findTargetNumber(numbers, target, left, mid);
        }
    }
}