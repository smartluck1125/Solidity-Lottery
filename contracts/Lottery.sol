pragma solidity >=0.5.15 <0.8.0;
// SPDX-License-Identifier: UNLICENCED

contract Lottery {
    function getRandomNumber() private view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return (randomHash % 1000) + 1;
    } 
}