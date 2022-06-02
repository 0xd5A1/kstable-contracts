const PaymentFarmingProxy = artifacts.require("PaymentFarmingProxy");
const TokenXUSD = artifacts.require("TokenXUSD");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	return PaymentFarmingProxy.deployed().then(async payment => {
		let xusd = await TokenXUSD.deployed();
		return payment.addCoins(xusd.address, 0);
	});
};
