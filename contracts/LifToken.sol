pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";

/**
   @title Líf, the Winding Tree token

   Implementation of Líf, the ERC20 token for Winding Tree, with extra methods
   to transfer value and data to execute a call on transfer.
   Uses OpenZeppelin MintableToken and Pausable.
 */
contract LifToken is MintableToken, Pausable {
  // Token Name
  string public constant NAME = "Líf";

  // Token Symbol
  string public constant SYMBOL = "LIF";

  // Token decimals
  uint public constant DECIMALS = 18;

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
     @dev `approveData` is an addition to ERC20 token methods. It allows to
     approve the transfer of value and execute a call with the sent data.

     Beware that changing an allowance with this method brings the risk that someone may use both the old
     and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     @param spender The address that will spend the funds.
     @param value The amount of tokens to be spent.
     @param data ABI-encoded contract call. For example generated using web3's getData method

     @return true if the call function was executed successfully
   */
  function approveData(address spender, uint256 value, bytes data) public whenNotPaused returns (bool) {

    require(spender != address(this));

    allowed[msg.sender][spender] = value;

    Approval(msg.sender, spender, value);
    assert(spender.call(data));

    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens to a specified
     address and execute a call with the sent data on the same transaction

     @param to address The address which you want to transfer to
     @param value uint256 the amout of tokens to be transfered
     @param data ABI-encoded contract call. For example generated using web3's
     getData method

     @return true if the call function was executed successfully
   */
  function transferData(address to, uint256 value, bytes data) public whenNotPaused returns (bool) {

    require(to != address(this));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);

    Transfer(msg.sender, to, value);
    assert(to.call(data));

    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens from one address to
     another and make a contract call on the same transaction

     @param from The address which you want to send tokens from
     @param to The address which you want to transfer to
     @param value The amout of tokens to be transferred
     @param data ABI-encoded contract call. For example generated using web3's
     getData method

     @return true if the call function was executed successfully
   */
  function transferDataFrom(address from, address to, uint256 value, bytes data) public whenNotPaused returns (bool) {

    require(to != address(this));

    uint256 allowance = allowed[from][msg.sender];

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    allowed[from][msg.sender] = allowance.sub(value);

    Transfer(msg.sender, to, value);
    assert(to.call(data));

    return true;
  }

  /**
     @dev Burns a specific amount of tokens.

     @param _value The amount of tokens to be burned.
   */
  function burn(uint256 _value) public whenNotPaused {
    require(_value > 0);

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);

    // a Transfer event to 0x0 can be useful for observers to keep track of
    // all the Lif by just looking at those events
    Transfer(burner, address(0), _value);
  }

  event Burn(address indexed burner, uint value);

}
