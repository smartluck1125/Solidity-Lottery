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

    struct BettingEntry {
        address participant;
        uint number;
    }

    mapping(address => bool) private _isLotteryParticipant;
    BettingEntry[] private bettingEntries;

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

    /// @notice Set a bet on the given number
    function setBet(uint _number) external payable onlyParticipants noExistingBet {
        require(msg.value == bettingAmount, "The supplied betting amount is not the required amount");
        bettingEntries.push(BettingEntry(msg.sender, _number));
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
        require(_isLotteryParticipant[msg.sender], "You are not a lottery participant");
        _;
    }

    /// @notice Modifier that checks if the sender didn't aleady make a bet
    modifier noExistingBet() {
        require(hasExistingBet(msg.sender) == false, "You already registered a bet for this round");
        _;
    }

    /// @notice Check if an given address already has an existing bet placed
    /// @return true if an existing bet is placed, false if not
    function hasExistingBet(address _participant) private view returns (bool) {
        for(uint i = 0; i < bettingEntries.length; i++) {
            if (bettingEntries[i].participant == _participant) {
                return true;
            }
        }
        return false;
    }

    /// @notice Returns a random(ish) number between 1-1000 (including 1 and 1000)
    /// @return A uint between 1 and 1000 (including 1 and 1000)
    function getRandomNumber() private returns (uint) {
        randNonce++;
        return (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000) + 1;
    }
}
