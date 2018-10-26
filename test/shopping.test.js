const Shopping = artifacts.require("./Shopping");

contract('Testing Shopping contract', async (accounts) => {

	let instance;

	beforeEach(async () => {
	    instance = await Shopping.deployed();
	});

    it("Shopping deployment", async () => {
	     assert.ok(instance.address);
  	});

    it("Check admin of contract", async () => {
   		let deployerOfContract = await instance.admin();
  		assert.equal(deployerOfContract, accounts[0]);
  	});

    it("Add seller", async () => {
   		await instance.addSeller(accounts[1], {from: accounts[0]});
   		let checkIfSeller = await instance.sellers(accounts[1], {from: accounts[0]});
  		assert.equal(checkIfSeller, true);
  	});

    it("Add products", async () => {
   		await instance.addProduct("0x1234", web3.toWei('0.5', 'ether'), {from: accounts[1]});
   		let sellerProductList = await instance.sellersProductsList(accounts[1], 0);
  		assert.equal(sellerProductList[1].toNumber(), web3.toWei('0.5', 'ether'));
  	});

    it("Check product count", async () => {
      let productCount = await instance.getContentCount();
      assert.equal(productCount, 1);
    });


    it("accounts[2] buys the product", async () => {        
      await instance.buyContent("0x1234", accounts[1], {
        from: accounts[2], 
        value: web3.toWei('0.5', 'ether')
      });
      let checkIfPurchased = await instance.checkIfProductPurchased(accounts[2], "0x1234")
      assert.equal(checkIfPurchased, true);
    });

    it("accounts[3] buys the same product", async () => {        
      await instance.buyContent("0x1234", accounts[1], {
        from: accounts[3], 
        value: web3.toWei('0.5', 'ether')
      });
      let checkIfPurchased = await instance.checkIfProductPurchased(accounts[3], "0x1234")
      assert.equal(checkIfPurchased, true);
    });


    it("accounts[4] buys the same product", async () => {        
      await instance.buyContent("0x1234", accounts[1], {
        from: accounts[4], 
        value: web3.toWei('0.5', 'ether')
      });
      let checkIfPurchased = await instance.checkIfProductPurchased(accounts[4], "0x1234")
      assert.equal(checkIfPurchased, true);
    });

});