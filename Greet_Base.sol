// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Greet {
    mapping(address => uint256) public gmCount;
    mapping(address => uint256) public gnCount;
    address public owner;
    
    // Fee sistemi
    uint256 public constant FEE_AMOUNT = 0.000005 ether; // 0.000005 ETH fee

    event FeeCollected(address indexed owner, uint256 amount);
    event GmSaid(address indexed user, uint256 newCount);
    event GnSaid(address indexed user, uint256 newCount);

    constructor() {
        owner = msg.sender;
    }

    function gm() public payable {
        // Fee kontrolü
        require(msg.value >= FEE_AMOUNT, "Insufficient fee. Need 0.000005 ETH");
        
        // Fee'yi owner'a gönder
        payable(owner).transfer(FEE_AMOUNT);
        emit FeeCollected(owner, FEE_AMOUNT);
        
        // Fazla ETH varsa geri gönder
        if (msg.value > FEE_AMOUNT) {
            uint256 refund = msg.value - FEE_AMOUNT;
            payable(msg.sender).transfer(refund);
        }
        
        // GM işlemi
        gmCount[msg.sender]++;
        emit GmSaid(msg.sender, gmCount[msg.sender]);
    }

    function gn() public payable {
        // Fee kontrolü
        require(msg.value >= FEE_AMOUNT, "Insufficient fee. Need 0.000005 ETH");
        
        // Fee'yi owner'a gönder
        payable(owner).transfer(FEE_AMOUNT);
        emit FeeCollected(owner, FEE_AMOUNT);
        
        // Fazla ETH varsa geri gönder
        if (msg.value > FEE_AMOUNT) {
            uint256 refund = msg.value - FEE_AMOUNT;
            payable(msg.sender).transfer(refund);
        }
        
        // GN işlemi
        gnCount[msg.sender]++;
        emit GnSaid(msg.sender, gnCount[msg.sender]);
    }

    function getGmCount(address user) public view returns (uint256) {
        return gmCount[user];
    }

    function getGnCount(address user) public view returns (uint256) {
        return gnCount[user];
    }
    
    // Owner değiştirme fonksiyonu
    function setOwner(address newOwner) public {
        require(msg.sender == owner, "Only owner can change owner");
        owner = newOwner;
    }
    
    // Owner'ın kontratındaki ETH'yi çekme fonksiyonu
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
