// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanToInteger {
    function romanToInt(string memory s) public pure returns (uint256) {
        bytes memory roman = bytes(s);
        uint256 total = 0;
        uint256 length = roman.length;
        
        for (uint256 i = 0; i < length; i++) {
            uint256 current = getValue(roman[i]);
            
            // 如果当前字符不是最后一个，且当前值小于下一个字符的值，则减去当前值
            if (i < length - 1 && current < getValue(roman[i + 1])) {
                total -= current;
            } else {
                total += current;
            }
        }
        
        return total;
    }
    
    function getValue(bytes1 romanChar) private pure returns (uint256) {
        if (romanChar == 'I') return 1;
        if (romanChar == 'V') return 5;
        if (romanChar == 'X') return 10;
        if (romanChar == 'L') return 50;
        if (romanChar == 'C') return 100;
        if (romanChar == 'D') return 500;
        if (romanChar == 'M') return 1000;
        revert("Invalid Roman numeral");
    }
}