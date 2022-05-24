const KStablePool = artifacts.require("KStablePool");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	let config = data[deployer.network_id];
	let stableCoins = [config.cusd, config.usdt, config.usdc];
	let A = config.pool.A;
	let fee = config.pool.fee; // 0.003
	let adminFee = config.pool.adminFee; // 2/3
	let name = config.pool.name;
	let symbol = config.pool.symbol;
	return deployer.deploy(KStablePool, stableCoins, A, fee, adminFee, accounts[0]).then(res => {
		console.log('constructor[2]:' + JSON.stringify(stableCoins));
		console.log('constructor[3]:' + A);
		console.log('constructor[4]:' + fee);
		console.log('constructor[5]:' + adminFee);
		console.log('constructor[6]:' + accounts[0]);
	}).catch(e => {
		console.log(e.message);
	});
};
