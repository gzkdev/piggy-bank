// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PiggyBank.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PiggyBankFactory is ReentrancyGuard {
    address public developer;
    uint256 public counter;

    mapping(address => address[]) private userPiggyBanks;
    address[] public allowedTokens;

    event PiggyBankCreated(address indexed user, address indexed piggyBank, string savingPurpose, uint256 salt);

    constructor(address[] memory _allowedTokens) {
        developer = msg.sender;
        allowedTokens = _allowedTokens;
    }

    function createPiggyBank(string memory savingPurpose, uint256 duration) external nonReentrant {
        uint256 salt = counter++;
        address piggyBank = deploy(type(PiggyBank).creationCode, salt);


        userPiggyBanks[msg.sender].push(piggyBank);

        PiggyBank(piggyBank).initialize(msg.sender, developer, savingPurpose, duration, allowedTokens);

        emit PiggyBankCreated(msg.sender, piggyBank, savingPurpose, salt);
    }

    function deploy(bytes memory bytecode, uint256 salt) internal returns (address) {
        address addr;

        assembly {
            addr := create2(
                callvalue(),
                add(bytecode, 0x20),  
                mload(bytecode),
                salt
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        return addr;
    }

    function getUserPiggyBanks(address user) external view returns (address[] memory) {
        return userPiggyBanks[user];
    }
}
