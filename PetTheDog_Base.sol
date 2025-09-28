// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PetTheDog {
    uint256 public totalPets;
    mapping(address => uint256) public userPets;
    address public owner;
    
    // Fee sistemi
    uint256 public constant FEE_AMOUNT = 0.000005 ether; // 0.000005 ETH fee

    event DogPet(address indexed user, uint256 newCount);
    event FeeCollected(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function pet() public payable {
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
        
        // Pet işlemi
        totalPets++;
        userPets[msg.sender]++;
        emit DogPet(msg.sender, userPets[msg.sender]);
    }

    function getMyPets(address user) public view returns (uint256) {
        return userPets[user];
    }

    function setTotal(uint256 value) public {
        require(msg.sender == owner, "Only owner can set total");
        totalPets = value;
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
