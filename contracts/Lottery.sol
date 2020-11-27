// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.5.15 <0.8.0;

import './Ownable.sol';

/// @title A Smart Contract based closed lottery
/// @author Nathan Hoekstra
contract Lottery is Ownable {
    uint randNonce = 0;
    uint roundsPlayed = 0;
    uint cooldownTime = 4 weeks;
    uint bettingAmount = 0.1 ether;

    //////////////////////////////////////
    ///        Public functions        ///
    //////////////////////////////////////

    /// @notice Get the current round number
    /// @dev We return + 1 since roundsPlayed keeps track of the amount of rounds that have been played (and finished)
    /// @return the current lottery round
    function getCurrentRound() public view returns (uint) {
        return roundsPlayed + 1;
    }

    /// @notice Get the current pot balance
    /// @return the current pot balance in Wei
    function getPotBalance() public view returns (uint) {
        return address(this).balance;
    }

    //////////////////////////////////////
    ///      Owner only functions      ///
    //////////////////////////////////////

    /// @notice Change the betting amount for the lottery (Owner only)
    /// @param _amount The new betting amount
    function changeBettingAmount(uint _amount) external onlyOwner {
        bettingAmount = _amount;
    }

    //////////////////////////////////////
    ///  Internal & private functions  ///
    //////////////////////////////////////

    /// @notice Returns a random(ish) number between 1-1000 (including 1 and 1000)
    /// @return a uint between 1 and 1000 (including 1 and 1000)
    function getRandomNumber() internal returns (uint) {
        randNonce++;
        return (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000) + 1;
    }
}
