// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../Helpers/TokenBasics/StandardToken.sol";

/**
 * @title BasicERC20 Token
 * @dev Simple ERC20 Token with standard token functions.
 */
contract BasicERC20Token is StandardToken {
  string public constant NAME = "Basic Token";
  string public constant SYMBOL = "BCTT";
  uint256 public constant DECIMALS = 18;

  uint256 public constant INITIAL_SUPPLY = 500000000 * 10**18;

  /**
   * Token Constructor
   * @dev Create and issue tokens to msg.sender.
   */
  constructor() {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
