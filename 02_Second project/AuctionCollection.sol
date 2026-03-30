// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Auction.sol";

contract AuctionCollection{
    Auction [] public auctions;

    function createAuction(uint biddingTime, string memory secretMessage, address payable beneficiary, uint max) public   {
        Auction newAuction = new Auction(biddingTime,secretMessage,beneficiary,max);
        auctions.push(newAuction);
    }
    function getLenght() external view returns(uint){
        return auctions.length;
    }
    function getAllAuction() public view returns (Auction[] memory){
        return auctions;
    }


}