// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PiggyBank.sol";

contract PiggyBankFactory {
    address public developer;
    address[] public allowedTokens;

    mapping(address => address[]) private userPiggyBanks;

    event PiggyBankCreated(address indexed user, address indexed piggyBank, string savingPurpose);

    constructor(address[] memory _allowedTokens) {
        developer = msg.sender;
        allowedTokens = _allowedTokens;
    }

    function createPiggyBank(string memory savingPurpose, uint256 duration) external {
        bytes32 salt = keccak256(abi.encode(msg.sender, savingPurpose, block.timestamp, duration));

        PiggyBank piggyBank = new PiggyBank{salt: salt}(
            msg.sender,
            developer,
            savingPurpose,
            duration,
            allowedTokens
        );

        address piggyBankAddress = address(piggyBank);
        userPiggyBanks[msg.sender].push(piggyBankAddress);

        emit PiggyBankCreated(msg.sender, piggyBankAddress, savingPurpose);
    }

    function getUserPiggyBanks(address user) external view returns (address[] memory) {
        return userPiggyBanks[user];
    }
}
