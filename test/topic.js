const web3 = global.web3;
const Topic = artifacts.require("./Topic.sol");
const assert = require('chai').assert;
const BlockHeightManager = require('./helpers/block_height_manager');

contract('Topic', function(accounts) {
	const blockHeightManager = new BlockHeightManager(web3);

	const testTopicParams = {
		_owner: accounts[0],
		_name: "test",
		_resultNames: ["first", "second", "third"],
		_bettingEndBlock: 1000
	};

	let testTopic;

	beforeEach(blockHeightManager.snapshot);
  	afterEach(blockHeightManager.revert);

  	describe("New Topic", async function() {
  		before(async function() {
			testTopic = await Topic.new(...Object.values(testTopicParams));
  		});

  		it("sets the first account as the contract creator", async function() {
	  		let owner = await testTopic.owner.call();
			assert.equal(owner, accounts[0], "Topic owner does not match.");
	    });

	    it("sets the topic name correctly", async function() {
	    	let name = await testTopic.name.call();
	    	assert.equal(web3.toUtf8(name), testTopicParams._name, "Topic name does not match.");
	    });

	    it("sets the topic result names correctly", async function() {
	    	let resultName1 = await testTopic.getResultName(0);
	    	assert.equal(web3.toUtf8(resultName1), testTopicParams._resultNames[0], "Result name 1 does not match.");

			let resultName2 = await testTopic.getResultName(1);
			assert.equal(web3.toUtf8(resultName2), testTopicParams._resultNames[1], "Result name 2 does not match.");

			let resultName3 = await testTopic.getResultName(2);
			assert.equal(web3.toUtf8(resultName3), testTopicParams._resultNames[2], "Result name 3 does not match.");
	    });

	    it("sets the topic betting end block correctly", async function() {
	    	let bettingEndBlock = await testTopic.bettingEndBlock.call();
			await assert.equal(bettingEndBlock, testTopicParams._bettingEndBlock, "Topic betting end block does not match.");
	    });
  	});

    it("allows users to bet if the betting end block has not been reached", async function() {
		testTopic = await Topic.new(...Object.values(testTopicParams));

		testTopic.BetAccepted().watch((error, response) => {
    		if (error) {
    			console.log("Event Error: " + error);
    		} else {
    			console.log("Event Triggered: " + JSON.stringify(response.event));
    			console.log("resultIndex: " + JSON.stringify(response.args._resultIndex));
    			console.log("betAmount: " + JSON.stringify(response.args._betAmount));
    			console.log("betBalance: " + JSON.stringify(response.args._betBalance));
    		}
    	});

		let initialBalance = web3.eth.getBalance(testTopic.address).toNumber();
		let betAmount = web3.toWei(1, 'ether');
		let betResultIndex = 0;

		await testTopic.bet(betResultIndex, { from: accounts[1], value: betAmount });
		let newBalance = web3.eth.getBalance(testTopic.address).toNumber();
		let difference = newBalance - initialBalance;
		assert.equal(difference, betAmount, "New result balance does not match added bet.");

		let resultBalance = await testTopic.getResultBalance(betResultIndex);
		assert.equal(resultBalance, betAmount, "Result balance does not match.");

		let betBalance = await testTopic.getBetBalance(betResultIndex);
		assert.equal(betBalance.toString(), betAmount, "Bet balance does not match.");
    });
 
    it("does not allow users to bet if the betting end block has been reached", async function() {
    	testTopic = await Topic.new(...Object.values(testTopicParams));

    	var currentBlock = web3.eth.blockNumber;
    	await blockHeightManager.mineTo(1001);
    	currentBlock = web3.eth.blockNumber;
    	assert.isAtLeast(currentBlock, testTopicParams._bettingEndBlock);

		let betAmount = web3.toWei(1, 'ether');
		let betResultIndex = 0;

		try {
	        await testTopic.bet(betResultIndex, { from: accounts[1], value: betAmount })
	        assert.fail();
		} catch(e) {
	        assert.match(e.message, /invalid opcode/);
	    }
    });
});
