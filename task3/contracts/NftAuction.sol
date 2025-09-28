// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";


contract NftAuction is Initializable ,UUPSUpgradeable{
    struct Auction {
        //卖家
        address seller;
        //拍卖最低价格
        uint256 startPrice;
        //拍卖开始时间
        uint256 startTime;
        //拍卖持续时间
        uint256 lockTime;
        // 是否结束
        bool ended;
        //买家
        address highestBidder;
        //最高价
        uint256 highestPrice;
        //NFT合约地址
        address nftContract;
        //tokenId
        uint256 tokenId;
        // 参与竞价的资产类型 0x 地址表示eth，其他地址表示erc20
        address tokenAddress;
    }

    mapping(uint256 => Auction)  public auctions;

    uint256 public nextAuctionId;

    address public admin;

    // constructor(){
    //     admin = msg.sender;
    // }

    function initialize() public initializer {
        admin = msg.sender;
    }

    mapping(address tokenAddress => AggregatorV3Interface aggregatorV3) public priceFeeds;

    function setPriceFeed(address tokenAddress, address _feedAddress) public {
        priceFeeds[tokenAddress] = AggregatorV3Interface(_feedAddress);

    }
    function getChainlinkDataFeedLatestAnswer(address _tokenAddress) public view returns (int) {
        AggregatorV3Interface priceFeed = priceFeeds[_tokenAddress];
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return answer;
    }

    function createAuction(uint256 _lockTime,uint256 _startPrice,address _nftContract,uint256 _tokenId) public {
        require(msg.sender == admin,"Only admin can create auctions");
        require(_lockTime>5,"LockTime must be greater tan 5 second");
        require(_startPrice>0,"StartPrice must be greater tan 0");
        console.log("msg.sender:",msg.sender);
        console.log("address(this):",address(this));
        // 转移NFT到合约
        IERC721(_nftContract).safeTransferFrom(msg.sender, address(this), _tokenId);

        auctions[nextAuctionId] = Auction({
            seller: msg.sender,
            startPrice: _startPrice,
            startTime: block.timestamp,
            lockTime: _lockTime,
            ended: false,
            highestBidder: address(0),
            highestPrice: 0,
            tokenId:_tokenId,
            nftContract:_nftContract,
            tokenAddress: address(0)
        });
        nextAuctionId++;
    }

    function placeBid(uint256 _auctionId,uint256 amount,address _tokenAddress) external payable {
        Auction storage auction = auctions[_auctionId];
        require(!auction.ended && (auction.startTime + auction.lockTime)> block.timestamp,"auction has ended");

        uint payPrice;
        if (_tokenAddress != address(0)) {
            payPrice = amount * uint(getChainlinkDataFeedLatestAnswer(_tokenAddress));
        } else {
            // 处理 ETH
            amount = msg.value;
            payPrice = amount * uint(getChainlinkDataFeedLatestAnswer(address(0)));
        }
        
        uint startPriceValue = auction.startPrice *uint(getChainlinkDataFeedLatestAnswer(auction.tokenAddress));

        uint highestPriceValue = auction.highestPrice *uint(getChainlinkDataFeedLatestAnswer(auction.tokenAddress));

        require(payPrice >= startPriceValue && payPrice > highestPriceValue,"Bid must be higher than the current highest bid");

        // 转移 ERC20 到合约
        if (_tokenAddress != address(0)) {
            IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        }

        // 退还前最高价
        if (auction.highestPrice > 0) {
            if (auction.tokenAddress == address(0)) {
                payable(auction.highestBidder).transfer(auction.highestPrice);
            } else {
                // 退回之前的ERC20
                IERC20(auction.tokenAddress).transfer(auction.highestBidder,auction.highestPrice);
            }
        }
        
        auction.tokenAddress = _tokenAddress;
        auction.highestPrice = amount;
        auction.highestBidder = msg.sender;
    }

     // 结束拍卖
    function endAuction(uint256 _auctionID) external {
        Auction storage auction = auctions[_auctionID];
        // 判断当前拍卖是否结束
        require(!auction.ended && (auction.startTime + auction.lockTime) <= block.timestamp,"Auction has not ended");
        // 转移NFT到最高出价者
        IERC721(auction.nftContract).safeTransferFrom(address(this),auction.highestBidder,auction.tokenId);
        // 转移资金到卖家
        //如果是ERC20，则转移REC20资产，如果是EHT，则转移合约中的资金
        console.log("auction.tokenAddress:",auction.tokenAddress);
        console.log("auction.highestPrice:",auction.highestPrice);
        console.log("msg.sender:",msg.sender);
        console.log("address(this):",address(this));
        if (auction.tokenAddress != address(0)) {
            IERC20(auction.tokenAddress).transfer(auction.seller,auction.highestPrice);
        }else{
            payable(auction.seller).transfer(address(this).balance);
        }
        auction.ended = true;
    }

    function _authorizeUpgrade(address) internal view override {
        // 只有管理员可以升级合约
        require(msg.sender == admin, "Only admin can upgrade");
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}