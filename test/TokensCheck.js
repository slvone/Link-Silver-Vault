var Token = artifacts.require("./LinkToken.sol");
const assertJump = require('./helpers/assertJump');

contract('Token Setup|', function(accounts) {
  const owner1  = accounts[0];

  let token;
  let number;

  before(async () => {
    token = await Token.deployed();
  });

  it('owner should be correct', async () => {

    number = await token.balanceOf.call("0x5bebe260779764fbd6cea88dfe1bf4932f7c33b8");
    assert.equal(number.toNumber(), 17691812200000000000000, "0x5bebe260779764fbd6cea88dfe1bf4932f7c33b8");
    number = await token.balanceOf.call("0x123456793b94455b0371f1e21b62c766f3a659d8");
    assert.equal(number.toNumber(), 3615004700000000000000, "0x123456793b94455b0371f1e21b62c766f3a659d8");
    
    number = await token.totalSupply();
    assert.equal(number.toNumber(), 42286000000000000000000, "total supply should be 42286");
  })  
})
