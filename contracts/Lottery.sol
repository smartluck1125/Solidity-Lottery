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
    uint8 amountParticipants = 0; // The group consists of 5 friends, but who knows maybe they want to add more (up to 255)

    mapping(address => bool) private _isLotteryParticipant;

    //////////////////////////////////////
    ///        Public functions        ///
    //////////////////////////////////////

    /// @notice Get the current round number
    /// @dev We return + 1 since roundsPlayed keeps track of the amount of rounds that have been played (and finished)
    /// @return The current lottery round
    function getCurrentRound() public view returns (uint) {
        return roundsPlayed + 1;
    }

    /// @notice Get the current pot balance
    /// @return The current pot balance in Wei
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

    /// @notice Add a participant address to the lottery (Owner only)
    /// @param _participant The address of the participant to add to the lottery
    function addParticipant(address _participant) external onlyOwner {
        require(_isLotteryParticipant[_participant] == false, "This address is already a participant");
        _isLotteryParticipant[_participant] = true;
        amountParticipants++;
    }

    /// @notice Remove a participant address to the lottery (Owner only)
    /// @param _participant The address of the participant to remove from the lottery
    function removeParticipant(address _participant) external onlyOwner {
        require(_isLotteryParticipant[_participant], "This address is not a known participant");
        _isLotteryParticipant[_participant] = false;
        amountParticipants--;
    }

    //////////////////////////////////////
    ///  Internal & private functions  ///
    //////////////////////////////////////

    /// @notice Modifier that checks if the sender is a lottery participant
    modifier onlyParticipants() {
        require(_isLotteryParticipant[msg.sender]);
        _;
    } 

    /// @notice Returns a random(ish) number between 1-1000 (including 1 and 1000)
    /// @return A uint between 1 and 1000 (including 1 and 1000)
    function getRandomNumber() internal returns (uint) {
        randNonce++;
        return (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000) + 1;
    }
}
