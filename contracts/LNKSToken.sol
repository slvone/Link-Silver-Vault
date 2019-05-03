pragma solidity ^0.4.11;

         
import './LNKSVault.sol';     

import "./OwnableMultiple.sol";


contract LNKSToken is StandardToken {
    using SafeMath for uint;

    string public name = "Link Platform Silver Gram";     // Name of the Token
    string public symbol = "LNKS";                        // ERC20 compliant Token code
    uint public decimals = 18;                            // Token has 18 digit precision
    uint public totalSupply;                              // Total supply

    uint public transferFee;                              // 6 decimal percentage
    uint public storageFee;
    uint private storageFeeLoopCounter;

    mapping(address => uint) balances;
    mapping(address => bool) balances_exist;
    address[] balances_list;                              // the list of token holders

    LNKSVault public vaultContract;
    
    /**
 * Upgrade agent interface inspired by Lunyr.
 *
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 */
contract UpgradeAgent {

  uint public originalSupply;

  /** Interface marker */
  function isUpgradeAgent() onlyController constant returns (bool) {
    return true;
  }

  function upgradeFrom(address _from, uint256 _value) public;

}


/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 */
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
  function upgrade(uint256 value) onlyController {

      UpgradeState state = getUpgradeState();
      if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
        // Called in a bad state
        require;
      }

      // Validate input value.
      if (value == 0) require;

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
  function setUpgradeAgent(address agent) onlyController {

      if(!canUpgrade()) {
        // The token is not yet in a state that we could think upgrading
        require;
      }

      if (agent == 0x0) require;
      // Only a master can designate the next agent
      if (msg.sender != upgradeMaster) require;
      // Upgrade has already begun for an agent
      if (getUpgradeState() == UpgradeState.Upgrading) require;

      upgradeAgent = UpgradeAgent(agent);

      // Bad interface
      if(!upgradeAgent.isUpgradeAgent()) require;
      // Make sure that token supplies match in source and target
      if (upgradeAgent.originalSupply() != totalSupply) require;

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
      if (master == 0x0) require;
      if (msg.sender != upgradeMaster) require;
      upgradeMaster = master;
  }

  /**
   * Child contract can enable to provide the condition when the upgrade can begun.
   */
  function canUpgrade() public constant returns(bool) {
     return true;
  }
 

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

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

    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) require;
        _;
    }

    modifier onlyVault() {
        if (msg.sender != address(vaultContract)) require;
        _;
    }

    function LNKSToken(address _purchase) {
        vaultContract = new LNKSPurchase(_purchase);
    }

    function setvaultContract(address _purchase) 
        onlyController {

        vaultContract = new LNKSPurchase(_purchase);
    }

    function setTransferFee(uint _transferFee)
       onlyController {

        transferFee = _transferFee;
    }

    function setStorageFee(uint _storageFee)
        onlyController {

        storageFee = _storageFee;
    }

    function setStorageFeePeriod(uint _storageFeePeriod)
        onlyController {

        storageFeePeriod = _storageFeePeriod;
    }

    function chargeStorageFees(uint _iterations) 
        onlyController {

        if (storageFeeLoopCounter != 0) {
            var iterEnd = storageFeeLoopCounter + _iterations;
            if (iterEnd > balances_list.length) iterEnd = balances_list.length;
            for (var i = storageFeeLoopCounter; i < iterEnd; i++) {
                var fee = balances[balances_list[iterEnd]].mul(storageFee);
            }
        

        var sinceLastCharge = now - lastStorageFeeCharged;        // the time since the last charge
        var chargeIterations = sinceLastCharge / storageFeePeriod;    // the charge cycles since the last charge

    }

    function transferFrom(address _from, address _to, uint _value) 
        onlyPayloadSize(3 * 32) {

        var _allowance = allowed[_from][msg.sender];

        var fee = doTransfer(_from, _to, _value);

        allowed[_from][msg.sender] = _allowance.sub(_value.add(fee));  
    }

    function transfer(address _to, uint _value) 
        onlyPayloadSize(2 * 32) {

        doTransfer(msg.sender, _to, _value);
    }

    function doTransfer(address _from, address _to, uint _value) 
        internal 
        returns (uint fee) {

        fee = calcFee(_value);

        if (balances[_from] < _value.add(fee)) require;

        if (!balances_exist(_to)) {
            balances_list.push(_to);          
            balances_exist(_to) = true;
        }

        balances[0] += fee;
        balances[_from] -= fee;

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);

        if (_to == address(vaultContract)) vaultContract.sellOrder(_from, _value);

        Transfer(_from, _to, _value);
    }

    function createTokens(address _to, uint _value) 
        external
        onlyController {

        if (!balances_exist(_to)) {
            balances_list.push(_to);          
            balances_exist(_to) = true;
        }

        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
    }

    function destroyTokens(uint _value) 
        external
        onlyController {

        address vault = address(vaultContract);

        balances[vault] = balances[vault].sub(_value);
        totalSupply = totalSupply.sub(_value);
    }
}
