// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9;

contract firstcontract{
    function hello() public pure returns(string memory){
        return "hello world";
    }
    int private number;
    uint private anotherNumber = 1;

    function setNumber (int value) public{
        number=value;
    }

    function getNumber() public view returns(int ){
        return number;
    }

    function add (int x, int y) private view returns(int){
        return number+x+y;
    }

    function addAndReturn(int a,int b) public returns(int){
        int result = add(a,b);
        number=result;
        return result;
    }
}