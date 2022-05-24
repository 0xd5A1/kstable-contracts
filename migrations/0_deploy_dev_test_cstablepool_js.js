const KStablePool = artifacts.require("KStablePool");
constKUSDToken = artifacts.require('CUSDToken');
const USDTToken = artifacts.require('USDTToken');
const USDCToken = artifacts.require('USDCToken');
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
	return deployer.deploy(CUSDToken, accounts).then(res => {
		return deployer.deploy(USDTToken, accounts).then(res => {
			return deployer.deploy(USDCToken, accounts).then(res => {
				let pArr = new Array();
				pArr.push(CUSDToken.deployed());
				pArr.push(USDTToken.deployed());
				pArr.push(USDCToken.deployed());
				return Promise.all(pArr).then(tokens => {
					let config = data[deployer.network_id];
					let stableCoins = [tokens[0].address, tokens[1].address, tokens[2].address];
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
				});
			});
		});
	}).catch(e => {
		console.log(e.message);
	});
};
