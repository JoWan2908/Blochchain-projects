// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Auction{

    address payable public beneficiary;
    uint public auctionEndTime;
    string private secretMessage;

    uint public maxBidders;
    uint public bidderCounter;

    address public highestBidder;
    uint public highestBid;

    mapping (address=> uint) pendingReturns;
    mapping (address=> bool) hasBid;
    
    bool ended;

    event HighestBidIncreased(address bidder,uint bid);
    event AuctionEnd(uint highestBid, address highestBidder);
    error AuctionAlreadyEnded();
    error AuctionNotYetEnded();
    error BidNotHighEnough(uint highestBid);

    constructor(
        uint biddingTime,
        string memory secret,
        address payable beneficiaryAddress,
        uint maxbid
    ){
        beneficiary=beneficiaryAddress;
        auctionEndTime=block.timestamp + biddingTime;
        secretMessage=secret;
        maxBidders=maxbid;
    }

    function bid () external payable {
        require(bidderCounter<maxBidders || hasBid[msg.sender], "Max number of bidders reached");
        if (ended)
            revert AuctionAlreadyEnded();
        if(!hasBid[msg.sender]){
            hasBid[msg.sender]=true;
            bidderCounter++;
        }
        if(msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);
        if(highestBid!=0){
            pendingReturns[highestBidder]+= highestBid;
        }

        highestBid=msg.value;
        highestBidder=msg.sender;

        emit HighestBidIncreased(msg.sender, highestBid);
    }   
    function withdraw() external returns(bool){
        require(ended,"Auction must be ended");
        uint amount=pendingReturns[msg.sender];
        if(amount>0){
            pendingReturns[msg.sender]=0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if(!success){
                pendingReturns[msg.sender]=amount;
                return false;
        }
    }
    return true;
    }

    function auctionEnd() external {
        if (block.timestamp<auctionEndTime){
            revert AuctionNotYetEnded();
        }
        if(ended){
            revert AuctionAlreadyEnded();
        }        
        ended=true;
        emit AuctionEnd(highestBid, highestBidder);
        (bool success, ) = beneficiary.call{value: highestBid}("");
        require(success, "Transfer failed");
    }
    function getSecretMessage() external view returns (string memory){

        require(ended, "Auction has not ended. ");
        require(msg.sender==highestBidder, "You are not the highest bidder");
        return secretMessage;

    }
}