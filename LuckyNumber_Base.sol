// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title LuckyNumber
 * @dev Base Network Lucky Number Game Contract
 * Pay 0.000005 ETH fee to play
 * Guess a number between 1-100, get XP based on how close you are
 */
contract LuckyNumber {
    // Constants
    uint256 public constant FEE_AMOUNT = 0.000005 ether; // 0.000005 ETH fee
    uint256 public constant MAX_NUMBER = 100;
    uint256 public constant MIN_NUMBER = 1;
    
    // Owner
    address public owner;
    
    // Game stats
    uint256 public totalGamesPlayed;
    uint256 public totalFeesCollected;
    mapping(address => uint256) public playerGames;
    mapping(address => uint256) public playerWins;
    
    // Events
    event GamePlayed(address indexed player, uint256 guess, uint256 luckyNumber, uint256 xpEarned, bool isWin);
    event FeeCollected(address indexed owner, uint256 amount);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Play lucky number game
     * @param guess Number between 1-100
     * @return luckyNumber The generated lucky number
     * @return xpEarned XP earned based on how close the guess was
     * @return isWin Whether the guess was exact
     */
    function playLuckyNumber(uint256 guess) external payable returns (uint256 luckyNumber, uint256 xpEarned, bool isWin) {
        require(msg.value >= FEE_AMOUNT, "Insufficient fee");
        require(guess >= MIN_NUMBER && guess <= MAX_NUMBER, "Guess must be between 1-100");
        
        // Deduct fee and refund excess
        _deductFee();
        
        // Generate lucky number (deterministic but unpredictable)
        luckyNumber = _generateLuckyNumber();
        
        // Calculate XP based on how close the guess was
        uint256 difference = _absDiff(guess, luckyNumber);
        xpEarned = _calculateXP(difference);
        
        // Check if exact win
        isWin = (guess == luckyNumber);
        
        // Update stats
        totalGamesPlayed++;
        playerGames[msg.sender]++;
        if (isWin) {
            playerWins[msg.sender]++;
        }
        
        emit GamePlayed(msg.sender, guess, luckyNumber, xpEarned, isWin);
        
        return (luckyNumber, xpEarned, isWin);
    }
    
    /**
     * @dev Generate lucky number using block data
     */
    function _generateLuckyNumber() internal view returns (uint256) {
        uint256 randomSeed = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            totalGamesPlayed,
            block.number
        )));
        
        return (randomSeed % MAX_NUMBER) + 1;
    }
    
    /**
     * @dev Calculate absolute difference between two numbers
     */
    function _absDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }
    
    /**
     * @dev Calculate XP based on how close the guess was
     * Exact match: 100 XP
     * 1-5 difference: 50 XP
     * 6-10 difference: 25 XP
     * 11-20 difference: 10 XP
     * 21+ difference: 5 XP
     */
    function _calculateXP(uint256 difference) internal pure returns (uint256) {
        if (difference == 0) return 100; // Exact match
        if (difference <= 5) return 50;
        if (difference <= 10) return 25;
        if (difference <= 20) return 10;
        return 5;
    }
    
    /**
     * @dev Deduct fee and refund excess
     */
    function _deductFee() internal {
        uint256 excess = msg.value - FEE_AMOUNT;
        
        // Send fee to owner
        if (FEE_AMOUNT > 0) {
            payable(owner).transfer(FEE_AMOUNT);
            totalFeesCollected += FEE_AMOUNT;
            emit FeeCollected(owner, FEE_AMOUNT);
        }
        
        // Refund excess
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }
    
    /**
     * @dev Get player stats
     */
    function getPlayerStats(address player) external view returns (uint256 games, uint256 wins, uint256 winRate) {
        games = playerGames[player];
        wins = playerWins[player];
        winRate = games > 0 ? (wins * 100) / games : 0;
    }
    
    /**
     * @dev Get game statistics
     */
    function getGameStats() external view returns (uint256 totalGames, uint256 totalFees, uint256 contractBalance) {
        return (totalGamesPlayed, totalFeesCollected, address(this).balance);
    }
    
    /**
     * @dev Transfer ownership
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
    
    /**
     * @dev Emergency withdraw
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
        }
    }
}
