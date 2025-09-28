const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { assert ,expect } = require("chai")

describe("test nftAuction contract",async function () {
    // it("test deploy and create nftAuction",async function () {
    //     const factory = await ethers.getContractFactory("NftAuction")
    //     const contract = await factory.deploy()
    //     await contract.waitForDeployment()

    //     await contract.createAuction(
    //       100,
    //       ethers.parseEther("0.00000001"),
    //       ethers.ZeroAddress,
    //       0
    //     )

    //     const auction = await contract.auctions(0)
    //     console.log(auction)
    // })

  it("test deployProxy and create nftAuction and upgrade",async function () {
    const [seller, buyer] = await ethers.getSigners()
    await deployments.fixture("deploy")
    console.log("创建合约成功：")
    const nftAuctionProxy = await deployments.get("NftAuctionProxy")
    const nftAuction = await ethers.getContractAt("NftAuction",nftAuctionProxy.address)
    
    const implAddress = await upgrades.erc1967.getImplementationAddress(nftAuctionProxy.address)
    console.log("实现合约地址：",implAddress)

    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy();
    await myToken.waitForDeployment();
    const myTokenAddress = await myToken.getAddress();
    console.log("myTokenAddress:", myTokenAddress);

    await myToken.mint(seller.address,0);
    const tokenId = 0;    

    // 给代理合约授权
    await myToken.connect(seller).setApprovalForAll(nftAuctionProxy.address, true);
      console.log("给代理合约授权完成:");
    await nftAuction.createAuction(
        10,
        ethers.parseEther("0.01"),
        myTokenAddress,
        tokenId
    );
    const auction = await nftAuction.auctions(0)
    console.log("创建拍卖成功：",auction)

    await deployments.fixture("upgrade")
    const auction2 = await nftAuction.auctions(0)
    console.log("升级合约成功：")
    const implAddress2 = await upgrades.erc1967.getImplementationAddress(nftAuctionProxy.address)
    console.log("实现合约地址2:",implAddress2)

    const nftAuctionV2 = await ethers.getContractAt("NftAuctionV2",nftAuctionProxy.address)
    const upgarde = nftAuctionV2.testUpgrade()
    console.log("upgardeTest:",upgarde)

    expect(auction.startTime).to.equal(auction2.startTime)
    expect(implAddress).to.not.equal(implAddress2)

  })
})