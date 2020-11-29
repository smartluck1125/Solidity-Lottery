// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.5.15 <0.8.0;

import './Ownable.sol';

/// @title A Smart Contract based closed lottery
/// @author Nathan Hoekstra
contract Lottery is Ownable {
    uint randNonce = 0;
    uint roundsPlayed = 0;
    uint lastLotteryDraw = 0;
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
    ///             Events             ///
    //////////////////////////////////////
    event NewRoundStarted(uint roundNumber);
    event RoundWinner(address winner, uint amount);
    event NoWinners();

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

    /// @notice Draw a winner
    /// @dev Not sure if it is bettingEntries.length or with a -1 need to test
    function drawWinner() external onlyOwner {
        // Check if a month has been passed since the last draw
        require(lastLotteryDraw + cooldownTime <= block.timestamp, "The lottery can only be executed once a month");
        // Check if every participant has placed a bet
        require(bettingEntries.length == amountParticipants && amountParticipants > 2, "Not every participant has placed a bet yet or there are not enough participants");
        // Generate a random(ish) number
        uint winningNumber = getRandomNumber();
        // Create an array to push the winners into
        address[] storage winners;
        // Loop over the bettingEntries to check if anyone has won
        for (uint i = 0; i < bettingEntries.length; i++) {
            // If someone has won push the address onto the winners array
            if (bettingEntries[i].number == winningNumber) {
                winners.push(bettingEntries[i].participant);
            }
        }
        // Are there any winners?
        if (winners.length > 0) {
            // Calculate the prize that every winner receives
            uint prize = address(this).balance / winners.length;
            // Loop through the winners, transfer the prize and emit a event
            for (uint i = 0; i < winners.length; i++) {
                payable(winners[i]).transfer(prize);
                emit RoundWinner(winners[i], prize);
            }
        } else {
            // Emit event that no winners are drawn
            emit NoWinners();
        }
        // Start a new round
        startNewRound();
        // TODO: Emit event to notify that a new round has started
        emit NewRoundStarted(getCurrentRound());
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
        for (uint i = 0; i < bettingEntries.length; i++) {
            if (bettingEntries[i].participant == _participant) {
                return true;
            }
        }
        return false;
    }

    /// @notice Start the lottery for a new round
    /// @dev This is a pretty dangerous function since it doesn't do any checks
    /// for example: checking if it has been a month since last "reset"
    function startNewRound() private {
        // Increase the rounds played counter
        roundsPlayed++;
        // Clear the previous betting entries inside the array
        delete bettingEntries;
        // Set the last lottery draw to the current block timestamp
        lastLotteryDraw = block.timestamp;
    }

    /// @notice Returns a random(ish) number between 1-1000 (including 1 and 1000)
    /// @return A uint between 1 and 1000 (including 1 and 1000)
    function getRandomNumber() private returns (uint) {
        randNonce++;
        return (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 1000) + 1;
    }
}
