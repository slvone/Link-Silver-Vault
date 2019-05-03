
//Smart Contract Escrow for LNK Platform Token
//
// The recipient can make a simple Ether transfer to get the tokens released to his address.
//
import 'LNKSToken.sol';              
import 'LNKSVault.sol';  

contract LNKToken {
  function balanceOf(address _address) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
}

 // user sells token for Silver
    // user must set allowance for this contract before calling
    function sell(uint256 amount) {
        if (buysTokens || msg.sender == owner) {
            uint256 can_buy = this.balance / buyPrice;  // token lots contract can buy
            uint256 order = amount / units;             // token lots available

            if(order > can_buy) order = can_buy;        // adjust order for funds

            if (order > 0)
            { 
                // extract user tokens
                if(!ERC20(asset).transferFrom(msg.sender, address(this), amount)) throw;

                // pay user
                if(!msg.sender.send(order * buyPrice)) throw;
            }
            UpdateEvent();
        }
    }
/////

contract TokenEscrow {
  address owner;
  modifier owneronly { if (msg.sender == owner) _ }
  function setOwner(address _owner) owneronly {
    owner = _owner;
  }

  function TokenEscrow() {
    owner = msg.sender;
  }

  struct Escrow {
    address token;           // address of the token contract
    uint tokenAmount;        // number of tokens requested
    bool tokenReceived;      // are tokens received?
    uint price;              // price to be paid by buyer
    address seller;          // seller's address
    address recipient;       // address to receive the tokens
  }

  mapping (address => Escrow) public escrows;

  function create(address token, uint tokenAmount, uint price, address seller, address buyer, address recipient) {
    escrows[buyer] = Escrow(token, tokenAmount, false, price, seller, recipient);
  }

  function create(address token, uint tokenAmount, uint price, address seller, address buyer) {
     create(token, tokenAmount, price, seller, buyer, buyer);
  }

  // Incoming transfer from the buyer
  function() {
    Escrow escrow = escrows[msg.sender];

    // Contract not set up
    if (escrow.token == 0)
      throw;

    LNKToken token = LNKToken(escrow.token);

    // Check the token contract if we have been issued tokens already
    if (!escrow.tokenReceived) {
      uint balance = token.balanceOf(this);
      if (balance >= escrow.tokenAmount)
        escrow.tokenReceived = true;
      // FIXME: what to do if we've received more tokens than required?
    }

    // No tokens yet
    if (!escrow.tokenReceived)
      throw;

    // Buyer's price is below the agreed
    if (msg.value < escrow.price)
      throw;

    // Transfer tokens to buyer
    token.transfer(escrow.recipient, escrow.tokenAmount);

    // Transfer money to seller
    escrow.seller.send(escrow.price);

    // Refund buyer if overpaid
    msg.sender.send(escrow.price - msg.value);

    delete escrows[msg.sender];
  }

  function kill() owneronly {
    suicide(msg.sender);
  }
  
  contract LNKtoken {
  address owner;
  modifier owneronly { if (msg.sender == owner) _ }
  function setOwner(address _owner) owneronly {
    owner = _owner;
  }

  function LNKtoken() {
    owner = msg.sender;
  }

  struct Escrow {
    address token;           // address of the token contract
    uint tokenAmount;        // number of tokens requested
    bool tokenReceived;      // are tokens received?
    uint price;              // price to be paid by buyer
    address seller;          // seller's address
    address recipient;       // address to receive the tokens
  }

}
