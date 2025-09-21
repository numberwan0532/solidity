// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntegerToRomanSimple {
    function intToRoman(uint256 num) public pure returns (string memory) {
        require(num > 0 && num <= 3999, "Number must be between 1 and 3999");
        
        bytes memory result;
        
        // 处理千位
        while (num >= 1000) {
            result = abi.encodePacked(result, "M");
            num -= 1000;
        }
        
        // 处理百位
        if (num >= 900) {
            result = abi.encodePacked(result, "CM");
            num -= 900;
        } else if (num >= 500) {
            result = abi.encodePacked(result, "D");
            num -= 500;
            while (num >= 100) {
                result = abi.encodePacked(result, "C");
                num -= 100;
            }
        } else if (num >= 400) {
            result = abi.encodePacked(result, "CD");
            num -= 400;
        } else if (num >= 100) {
            while (num >= 100) {
                result = abi.encodePacked(result, "C");
                num -= 100;
            }
        }
        
        // 处理十位
        if (num >= 90) {
            result = abi.encodePacked(result, "XC");
            num -= 90;
        } else if (num >= 50) {
            result = abi.encodePacked(result, "L");
            num -= 50;
            while (num >= 10) {
                result = abi.encodePacked(result, "X");
                num -= 10;
            }
        } else if (num >= 40) {
            result = abi.encodePacked(result, "XL");
            num -= 40;
        } else if (num >= 10) {
            while (num >= 10) {
                result = abi.encodePacked(result, "X");
                num -= 10;
            }
        }
        
        // 处理个位
        if (num >= 9) {
            result = abi.encodePacked(result, "IX");
            num -= 9;
        } else if (num >= 5) {
            result = abi.encodePacked(result, "V");
            num -= 5;
            while (num >= 1) {
                result = abi.encodePacked(result, "I");
                num -= 1;
            }
        } else if (num >= 4) {
            result = abi.encodePacked(result, "IV");
            num -= 4;
        } else if (num >= 1) {
            while (num >= 1) {
                result = abi.encodePacked(result, "I");
                num -= 1;
            }
        }
        
        return string(result);
    }
}