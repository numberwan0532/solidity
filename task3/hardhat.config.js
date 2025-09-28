require("@nomicfoundation/hardhat-toolbox");
require('hardhat-deploy')
require("@openzeppelin/hardhat-upgrades")
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  namedAccounts: {
    firstAccount: {
      default: 0
    },
    secondAccount: {
      default: 1
    }
  }
};
