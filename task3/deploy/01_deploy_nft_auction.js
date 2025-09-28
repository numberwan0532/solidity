const { deployments, upgrades, ethers } = require("hardhat")
const fs = require("fs")
const path = require("path")


module.exports= async({getNamedAccounts,deployments})=>{

    const { firstAccount } = await getNamedAccounts()
    const { save } = deployments
    console.log("部署用户地址："+firstAccount)
    const factory = await ethers.getContractFactory("NftAuction")

    //部署代理合约
    const nftAuctionProxy = await upgrades.deployProxy(factory,[],{
        initializer:"initialize",
    })
    await nftAuctionProxy.waitForDeployment()
    const proxyAddress  = await nftAuctionProxy.getAddress();
    console.log("代理合约地址："+proxyAddress)
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress)
    console.log("实现合约地址：",implAddress)
    
    const storePath = path.resolve(__dirname,"./.cache/proxyNftAuction.json")
    fs.writeFileSync(
        storePath,
        JSON.stringify({
            proxyAddress,
            implAddress,
            abi:factory.interface.format("json"),
        })
    )

    await save("NftAuctionProxy",{
        abi:factory.interface.format("json"),
        address: proxyAddress,
    })

}

module.exports.tags = ["deploy"]
