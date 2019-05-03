pragma solidity ^0.4.8;

/// @title LNKS Token. This Token will remain the cornerstone of the entire organization. It will have an Ethereum address and from the moment that address is publish until the end, it will remain the same, and should. The Token should be as simple as it possibly can be and should not be able to terminate. It's state remains so that those who control their Tokens will continue to do so.
/// @author Karolis Ramanauskas <hello@karolisram.com>

import "./SafeMath.sol";
import "./OwnableMultiple.sol";
import "./ERC20.sol";
import './LNKSExchange.sol';


/*
 * Basic token
 * Basic version of StandardToken, with no allowances
 */
contract StandardToken is ERC20 {
  using SafeMath for uint;

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;
  uint supply;

  // Get the total token supply in circulation
  function totalSupply() constant returns (uint) {
    return supply;
  }

  /*
   * Fix for the ERC20 short address attack  
   */
  modifier onlyPayloadSize(uint size) {
    require(msg.data.length < size + 4);
    _;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) returns (bool success){
    if (_value <= 0 || balances[msg.sender] < _value) return false; 

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);

    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
    if (_value <= 0 || allowance(_from, msg.sender) < _value || balances[_from] < _value) return false;

    var _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);

    Transfer(_from, _to, _value);

    return true;
  }

  function approve(address _spender, uint _value) returns (bool success) {
    if (_value <= 0 || balances[msg.sender] < _value) return false;

    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}


contract LNKSToken is StandardToken, OwnableMultiple {
  string public constant name = "Link Platform"; // Name of the Token
  string public constant symbol = "LNKS"; // ERC20 compliant Token code
  uint public constant decimals = 3; // Token has 3 digit precision

  function mint(address _spender, uint _value) onlyOwner {
    balances[_spender] += _value;
    supply += _value;
  }

  function destroyTokens(uint _value) external {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    supply = supply.sub(_value);

    DestroyTokens(msg.sender, _value);
  }

  event DestroyTokens(address indexed _from, uint _value);
}
