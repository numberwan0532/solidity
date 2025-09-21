// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract MargeArray{

    function mergeSorted(uint256[] memory a, uint256[] memory b) public pure returns (uint256[] memory) {
        uint256 aLen = a.length;
        uint256 bLen = b.length;
        uint256[] memory result = new uint256[](aLen + bLen);
        
        uint256 aIndex = 0;
        uint256 bIndex = 0;
        uint256 resultIndex = 0;
        
        while (aIndex < aLen && bIndex < bLen) {
            if (a[aIndex] < b[bIndex]) {
                result[resultIndex++] = a[aIndex++];
            } else {
                result[resultIndex++] = b[bIndex++];
            }
        }
        
        while (aIndex < aLen) {
            result[resultIndex++] = a[aIndex++];
        }
        
        while (bIndex < bLen) {
            result[resultIndex++] = b[bIndex++];
        }
        
        return result;
    }
}