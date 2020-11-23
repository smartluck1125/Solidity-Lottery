// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.5.15 <0.8.0;

import './Ownable.sol';

contract Lottery is Ownable {
    function getRandomNumber() private view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return (randomHash % 1000) + 1;
    } 
}