pragma solidity ^0.4.11;

import 'LNKSToken.sol'; 
import 'Escrow.sol'; 


/// @title 
/// @author Riaan F Venter~ RFVenter~ <msg@rfv.io>
contract LNKSVault is Drainable {
    uint public storageFee;                               // 6 decimal percentage
    uint public storageFeePeriod;                         // how many seconds between each storage fee
    uint public lastStorageFeeCharged;                    // the unix timestamp of when the last stoarge fee was charged

    ERC20 private lnkToken;                               
    address private lnkTokenAddress;

    address[] public lnksHolders;
    address[] public lnkHolders;

    Order[] public buyOrders;
    Order[] public sellOrders;

    
    struct Order { 
        address address; 
        uint amount;
    }

    modifier onlyToken() {
        if (msg.sender != address(lnkToken)) throw;
        _;
    }

    function buyOrder() {

      buyOrders.push(Order(msg.sender, msg.value));
    }

    function sellOrder(address _from, uint _value) 
        onlyToken {

        sellOrders.push(Order(_from, _value));
    }

    function buy()
        onlyOwner {

        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
          array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;

        buyOrders.push(Order(msg.sender, msg.value));
    }

    function sell() 
      onlyOwner {

      buyOrders.push(Order(msg.sender, msg.value));
    }


    function setToken(address _token) 
      onlyOwner {

      lnkTokenAddress = _token;
      lnkToken = ERC20(_token);
    }

    function removelnksHolder(address _lnksHolder)
      internal {

      for (uint i = 0; i < lnksHolders.length; i++) {
        if (lnksHolders[i] == _lnksHolder) {
          lnksHolders[i] = 0;
          break;
    }

    function addLnkHolder(address _lnkHolder)
      external
      returns (bool _success) {

      for (uint i = 0; i < lnkHolders.length; i++) {
        if (lnkHolders[i] == _lnkHolder) return false;
      }
      if (lnkToken.balanceOf(_lnkHolder) == 0) return false;
      lnkHolders.push(_lnkHolder);
      return true;
        }


    function setToken(address _token) 
      onlyOwner {

      lnkTokenAddress = _token;
      lnkToken = ERC20(_token);
    }

    function removelnksHolder(address _lnksHolder)
      internal {

      for (uint i = 0; i < lnksHolders.length; i++) {
        if (lnksHolders[i] == _lnksHolder) {
          lnksHolders[i] = 0;
          break;
    }

    function addLnkHolder(address _lnkHolder)
      external
      returns (bool _success) {

      for (uint i = 0; i < lnkHolders.length; i++) {
        if (lnkHolders[i] == _lnkHolder) return false;
      }
      if (lnkToken.balanceOf(_lnkHolder) == 0) return false;
      lnkHolders.push(_lnkHolder);
      return true;
    }
    contract UpgradeAgent {

  uint public originalSupply;

  /** Interface marker */
  function isUpgradeAgent() public constant returns (bool) {
    return true;
  }

  function upgradeFrom(address _from, uint256 _value) public;

}


contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }

function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

contract UpgradeableToken is StandardToken {

  /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
  address public upgradeMaster;

  /** The next contract where the tokens will be migrated. */
  UpgradeAgent public upgradeAgent;

  /** How many tokens we have upgraded by now. */
  uint256 public totalUpgraded;

  /**
   * Upgrade states.
   *
   * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
   * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
   * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
   * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
   *
   */
  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

  /**
   * Somebody has upgraded some of his tokens.
   */
  event Upgrade(address indexed _from, address indexed _to, uint256 _value);

  /**
   * New upgrade agent available.
   */
  event UpgradeAgentSet(address agent);

  /**
   * Do not allow construction without upgrade master set.
   */
  function UpgradeableToken(address _upgradeMaster) {
    upgradeMaster = _upgradeMaster;
  }

  /**
   * Allow the token holder to upgrade some of their tokens to a new contract.
   */
  function upgrade(uint256 value) public {

      UpgradeState state = getUpgradeState();
      if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
        // Called in a bad state
        throw;
      }

      // Validate input value.
      if (value == 0) throw;

      balances[msg.sender] = safeSub(balances[msg.sender], value);

      // Take tokens out from circulation
      totalSupply = safeSub(totalSupply, value);
      totalUpgraded = safeAdd(totalUpgraded, value);

      // Upgrade agent reissues the tokens
      upgradeAgent.upgradeFrom(msg.sender, value);
      Upgrade(msg.sender, upgradeAgent, value);
  }

  /**
   * Set an upgrade agent that handles
   */
  function setUpgradeAgent(address agent) external {

      if(!canUpgrade()) {
        // The token is not yet in a state that we could think upgrading
        throw;
      }

      if (agent == 0x0) throw;
      // Only a master can designate the next agent
      if (msg.sender != upgradeMaster) throw;
      // Upgrade has already begun for an agent
      if (getUpgradeState() == UpgradeState.Upgrading) throw;

      upgradeAgent = UpgradeAgent(agent);

      // Bad interface
      if(!upgradeAgent.isUpgradeAgent()) throw;
      // Make sure that token supplies match in source and target
      if (upgradeAgent.originalSupply() != totalSupply) throw;

      UpgradeAgentSet(upgradeAgent);
  }

  /**
   * Get the state of the token upgrade.
   */
  function getUpgradeState() public constant returns(UpgradeState) {
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

  /**
   * Change the upgrade master.
   *
   * This allows us to set a new owner for the upgrade mechanism.
   */
  function setUpgradeMaster(address master) onlyController {
      if (master == 0x0) throw;
      if (msg.sender != upgradeMaster) throw;
      upgradeMaster = master;
  }

  /**
   * Child contract can enable to provide the condition when the upgrade can begun.
   */
  function canUpgrade() public constant returns(bool) {
     return true;
  }

}

        
    function refund() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var gntValue = balances[msg.sender];
        if (gntValue == 0) throw;
        balances[msg.sender] = 0;
        totalTokens -= gntValue;

        var ethValue = gntValue / tokenCreationRate;
        Refund(msg.sender, ethValue);
        if (!msg.sender.send(ethValue)) throw;
    }
    contract IController {
    function assertIsWhitelisted(address _target) public constant returns(bool);
    function lookup(bytes32 _key) public constant returns(address);
    function assertOnlySpecifiedCaller(address _caller, bytes32 _allowedCaller) public constant returns(bool);
    function stopInEmergency() constant returns(bool);
    function onlyInEmergency() constant returns(bool);
     }
    contract Caller {
    function callTest(Test test) {
        test.call(0x00000);
}
}
