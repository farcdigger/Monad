// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SlotsGame
 * @dev Monad Dog Slots Game Contract for Base Network
 * No payment required - just fee for each game
 * All fees go directly to owner
 */
contract SlotsGame {
    // Constants
    uint256 public constant FEE_AMOUNT = 0.00001 ether; // 0.00001 ETH fee per game
    
    // Game symbols (0=🐕, 1=🦮, 2=🐶, 3=🦴)
    uint8 public constant NUM_SYMBOLS = 4;
    uint8 public constant NUM_REELS = 4;
    
    // Owner
    address public owner;
    
    // Player game count mapping
    mapping(address => uint256) public playerGames;
    
    // Total fees collected (for tracking)
    uint256 public totalFeesCollected;
    
    // Events
    event FeeCollected(address indexed owner, uint256 amount);
    event GamePlayed(address indexed player, uint8[4] results, uint256 totalGames);
    event Jackpot(address indexed player, uint8 symbol, uint256 prize);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Play slots game with fee
     * Pays 0.00001 ETH fee per game
     * ✅ Fee goes directly to owner
     */
    function playSlots() external payable returns (uint8[4] memory) {
        // Fee kontrolü
        require(msg.value >= FEE_AMOUNT, "Insufficient fee. Need 0.00001 ETH");
        
        // Fee'yi owner'a gönder
        payable(owner).transfer(FEE_AMOUNT);
        emit FeeCollected(owner, FEE_AMOUNT);
        
        // Fazla ETH varsa geri gönder
        if (msg.value > FEE_AMOUNT) {
            uint256 refund = msg.value - FEE_AMOUNT;
            payable(msg.sender).transfer(refund);
        }
        
        // Update player game count
        playerGames[msg.sender] += 1;
        totalFeesCollected += FEE_AMOUNT;
        
        // Generate random results for 4 reels
        uint8[4] memory results;
        uint256 randomSeed = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            totalFeesCollected,
            playerGames[msg.sender]
        )));
        
        for (uint8 i = 0; i < NUM_REELS; i++) {
            results[i] = uint8((randomSeed >> (i * 8)) % NUM_SYMBOLS);
        }
        
        // Check for jackpot (4 of the same)
        if (isJackpot(results)) {
            emit Jackpot(msg.sender, results[0], 5000); // 5000 XP prize
        }
        
        emit GamePlayed(msg.sender, results, playerGames[msg.sender]);
        
        return results;
    }
    
    /**
     * @dev Check if results contain 4 of the same symbol
     */
    function isJackpot(uint8[4] memory results) internal pure returns (bool) {
        return (results[0] == results[1] && 
                results[1] == results[2] && 
                results[2] == results[3]);
    }
    
    /**
     * @dev Get player's total games played
     */
    function getCredits(address player) external view returns (uint256) {
        return playerGames[player];
    }
    
    /**
     * @dev Get contract balance (should be 0 since all fees go to owner)
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Get game statistics
     */
    function getGameStats() external view returns (
        uint256 contractBalance,
        uint256 totalFeesCollectedAmount,
        uint256 yourGames
    ) {
        return (
            address(this).balance,
            totalFeesCollected,
            playerGames[msg.sender]
        );
    }
    
    /**
     * @dev Emergency withdraw (if any funds are stuck)
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
        }
    }
    
    /**
     * @dev Update owner (if needed)
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}
