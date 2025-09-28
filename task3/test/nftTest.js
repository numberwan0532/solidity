const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { assert ,expect } = require("chai")

describe("test nftAuction contract all",async function () {

  it("test create bid end",async function () {
    const [seller, buyer] = await ethers.getSigners()
    await deployments.fixture(["deploy"]);
    
    const nftAuctionProxy = await deployments.get("NftAuctionProxy");
    const nftAuction = await ethers.getContractAt("NftAuction",nftAuctionProxy.address);

    const MyERC20 = await ethers.getContractFactory("MyERC20");
    const myERC20 = await MyERC20.deploy();
    await myERC20.waitForDeployment();
    const UsdcAddress = await myERC20.getAddress();
    
    let tx = await myERC20.connect(seller).transfer(buyer, ethers.parseEther("1000"))
    await tx.wait()

    const aggreagatorV3 = await ethers.getContractFactory("AggreagatorV3")
    const priceFeedEthDeploy = await aggreagatorV3.deploy(ethers.parseEther("10000"))
    const priceFeedEth = await priceFeedEthDeploy.waitForDeployment()
    const priceFeedEthAddress = await priceFeedEth.getAddress()
    console.log("ethFeed: ", priceFeedEthAddress)
    const priceFeedUSDCDeploy = await aggreagatorV3.deploy(ethers.parseEther("1"))
    const priceFeedUSDC = await priceFeedUSDCDeploy.waitForDeployment()
    const priceFeedUSDCAddress = await priceFeedUSDC.getAddress()
    console.log("usdcFeed: ", await priceFeedUSDCAddress)

    const token2Usd = [{
        token: ethers.ZeroAddress,
        priceFeed: priceFeedEthAddress
    }, {
        token: UsdcAddress,
        priceFeed: priceFeedUSDCAddress
    }]

    for (let i = 0; i < token2Usd.length; i++) {
        const { token, priceFeed } = token2Usd[i];
        await nftAuction.setPriceFeed(token, priceFeed);
    }
    // nftAuctionProxy.setPriceFeed()

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

    const auction = await nftAuction.auctions(0);

    console.log("创建拍卖成功：：", auction);

    // ETH参与竞价
    tx = await nftAuction.connect(buyer).placeBid(0, 0, ethers.ZeroAddress, { value: ethers.parseEther("0.01") });
    await tx.wait()
    console.log("ETH参与竞价成功：：");

    //101000000000000000000
    console.log("ERC20 授权金额：",ethers.MaxUint256);
    // USDC参与竞价
    tx = await myERC20.connect(buyer).approve(nftAuctionProxy.address, ethers.MaxUint256)
    await tx.wait()
    console.log("USDC参与授权成功：：");
    tx = await nftAuction.connect(buyer).placeBid(0, ethers.parseEther("101"), UsdcAddress);
    await tx.wait()
    console.log("USDC参与竞价成功：：");

    // 等待 10 s
    await new Promise((resolve) => setTimeout(resolve, 10 * 1000));

    await nftAuction.connect(seller).endAuction(0);

    // 验证结果
    const auctionResult = await nftAuction.auctions(0);
    console.log("结束拍卖后读取拍卖成功：：", auctionResult);
    expect(auctionResult.highestBidder).to.equal(buyer.address);
    expect(auctionResult.highestPrice).to.equal(ethers.parseEther("101"));

    // 验证 NFT 所有权
    const owner = await myToken.ownerOf(tokenId);
    console.log("owner::", owner);
    expect(owner).to.equal(buyer.address);

  })
})