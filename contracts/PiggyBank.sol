// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PiggyBank is ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    address public owner;
    address public developer;
    string public savingPurpose;
    uint256 public startTime;
    uint256 public duration;

    mapping(address => uint256) public balances;
    mapping(address => bool) public isWithdrawn;
    address[] public allowedTokens;

    event Deposited(address indexed token, address indexed user, uint256 amount);
    event Withdrawn(address indexed token, address indexed user, uint256 amount, bool earlyWithdrawal);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier isTokenAllowed(address token) {
        require(isAllowedToken(token), "Token not allowed");
        _;
    }

    constructor(
        address _owner,
        address _developer,
        string memory _savingPurpose,
        uint256 _duration,
        address[] memory _allowedTokens
    ) {
        owner = _owner;
        developer = _developer;
        savingPurpose = _savingPurpose;
        startTime = block.timestamp;
        duration = _duration;
        allowedTokens = _allowedTokens;
    }

    function deposit(address token, uint256 amount) external onlyOwner isTokenAllowed(token) {
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        balances[token] += amount;

        emit Deposited(token, msg.sender, amount);
    }

    function withdraw(address token) external onlyOwner isTokenAllowed(token) {
        require(!isWithdrawn[token], "Already withdrawn");
        require(balances[token] > 0, "No balance to withdraw");

        uint256 amount = balances[token];
        uint256 penalty = 0;

        if (block.timestamp < startTime + duration) {
            penalty = (amount * 15) / 100;
            IERC20(token).safeTransfer(developer, penalty);
        }

        uint256 finalAmount = amount - penalty;
        IERC20(token).safeTransfer(owner, finalAmount);

        isWithdrawn[token] = true;
        balances[token] = 0;

        emit Withdrawn(token, msg.sender, finalAmount, penalty > 0);
    }

    function isAllowedToken(address token) public view returns (bool) {
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            if (allowedTokens[i] == token) {
                return true;
            }
        }
        return false;
    }
}
