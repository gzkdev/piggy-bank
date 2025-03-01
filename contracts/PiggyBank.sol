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
    uint256 public duration;
    uint256 public startTime;

    mapping(address => uint256) public balances;
    mapping(address => bool) public isWithdrawn;
    mapping(address => bool) public allowedTokens;

    event Deposited(address indexed token, address indexed user, uint256 amount);
    event Withdrawn(address indexed token, address indexed user, uint256 amount, bool withPenalty);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier isTokenAllowed(address token) {
        require(allowedTokens[token], "Token not allowed");
        _;
    }

    function initialize(
        address _owner,
        address _developer,
        string memory _savingPurpose,
        uint256 _duration,
        address[] memory _allowedTokens
    ) external {
        require(owner == address(0), "Already initialized");

        owner = _owner;
        developer = _developer;
        savingPurpose = _savingPurpose;
        duration = _duration;
        startTime = block.timestamp;

        for (uint256 i = 0; i < _allowedTokens.length; i++) {
            allowedTokens[_allowedTokens[i]] = true;
        }
    }

   function deposit(address token, uint256 amount) external onlyOwner isTokenAllowed(token) nonReentrant {
        require(amount > 0, "Amount must be greater than 0");

        balances[token] += amount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(token, msg.sender, amount);
    }


    function withdraw(address token) external onlyOwner isTokenAllowed(token) nonReentrant {
        require(!isWithdrawn[token], "Already withdrawn");
        require(balances[token] > 0, "No balance to withdraw");

        uint256 amount = balances[token];
        uint256 penalty = 0;

        isWithdrawn[token] = true;
        balances[token] = 0;

        if (block.timestamp < startTime + duration) {
            penalty = (amount * 15) / 100;
            IERC20(token).safeTransfer(developer, penalty);
        }

        uint256 finalAmount = amount - penalty;
        IERC20(token).safeTransfer(owner, finalAmount);

        emit Withdrawn(token, msg.sender, finalAmount, penalty > 0);
    }
}
