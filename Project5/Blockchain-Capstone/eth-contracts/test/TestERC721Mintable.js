var ERC721MintableComplete = artifacts.require("BaoHong");

contract("TestERC721Mintable", (accounts) => {
  const account_one = accounts[0];
  const account_two = accounts[1];
  const account_three = accounts[2];
  const totalSupply = 5;

  describe("match erc721 spec", function () {
    beforeEach(async function () {
      this.contract = await ERC721MintableComplete.new({ from: account_one });

      // TODO: mint multiple tokens
      for (var i = 0; i < totalSupply; i++) {
        await this.contract.mint(account_two, i, { from: account_one });
      }
    });

    it("should return total supply", async function () {
      let result = await this.contract.totalSupply.call();
      assert.equal(totalSupply, result);
    });

    it("should get token balance", async function () {
      let balance = await this.contract.balanceOf(account_two);
      assert.equal(parseInt(balance), totalSupply);
    });

    // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
    it("should return token uri", async function () {
      let uri = await this.contract.baseTokenURI();
      assert.equal(
        uri,
        "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"
      );
    });

    it("should transfer token from one owner to another", async function () {
      await this.contract.transferFrom(account_two, account_three, 1, {
        from: account_two,
      });
      let amount = await this.contract.ownerOf(1);
      assert.equal(amount, account_three);
    });
  });

  describe("have ownership properties", function () {
    beforeEach(async function () {
      this.contract = await ERC721MintableComplete.new({ from: account_one });
    });

    it("should fail when minting when address is not contract owner", async function () {
      let isFail = false;
      try {
        await this.contract.mint(account_three, 5, { from: account_two });
      } catch (error) {
        isFail = true;
      }
      assert.equal(isFail, true);
    });

    it("should return contract owner", async function () {
        let contractOwner = await this.contract.owner.call({from: account_one});
        assert.equal(contractOwner, account_one);
    });
  });
});
