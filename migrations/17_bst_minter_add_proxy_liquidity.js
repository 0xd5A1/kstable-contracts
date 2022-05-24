const LiquidityFarmingProxy = artifacts.require("LiquidityFarmingProxy");
const KSTMinter = artifacts.require("KSTMinter");

module.exports = function (deployer, network, accounts) {

	return KSTMinter.deployed().then(bstMinter => {
		return LiquidityFarmingProxy.deployed().then(liquidity => {
			return bstMinter.addProxy(liquidity.address);
		});
	});

};
