const { upgrades, ethers } = require("hardhat")
const fs = require("fs")
const path = require("path")

module.exports= async({getNamedAccounts,deployments})=>{

    const { firstAccount } = await getNamedAccounts()
    const { save } = deployments
    console.log("部署用户地址："+firstAccount)

    const storePath = path.resolve(__dirname,"./.cache/proxyNftAuction.json")
    const storeData = fs.readFileSync(storePath,"utf-8")
    const { proxyAddress , implAddress , abi } = JSON.parse(storeData)

    const factoryV2 = await ethers.getContractFactory("NftAuctionV2")

    const nftAuctionProxyV2 = await upgrades.upgradeProxy(proxyAddress,factoryV2, { call: "admin" })
    await nftAuctionProxyV2.waitForDeployment()
    const proxyNftAuctionV2 = await nftAuctionProxyV2.getAddress()

    // fs.writeFileSync(
    //     storePath,
    //     JSON.stringify({
    //         proxyAddress,
    //         implAddress,
    //         abi:NftAuction.interface.format("json"),
    //     })
    // )

    await save("NftAuctionProxyV2",{
        abi,
        address: proxyNftAuctionV2,
    })
}

module.exports.tags = ["upgrade"]