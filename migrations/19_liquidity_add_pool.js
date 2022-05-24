const LiquidityFarmingProxy = artifacts.require("LiquidityFarmingProxy");
const KStablePool = artifacts.require("KStablePool");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	return LiquidityFarmingProxy.deployed().then(proxy => {
		return KStablePool.deployed().then(pool1 => {
			return proxy.add(pool1.address, config.pool.allocation, false);
		});
	});
};
