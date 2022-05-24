const KSTMinter = artifacts.require("KSTMinter");
const HuaHuaToken = artifacts.require("HuaHuaToken");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let config = data[deployer.network_id];
        let dDay = new Date();
        dDay.setFullYear(config.dDay[0], config.dDay[1], config.dDay[2]);
        dDay.setHours(config.hours[0], config.hours[1], config.hours[2], config.hours[3]);
        let now = new Date();
        let blocks = Math.floor((Math.floor(dDay.getTime() / 1000) - Math.floor(now.getTime() / 1000)) / config.blockSpan);
        return web3.eth.getBlock('latest').then(latestBlock => {
            let startBlock = latestBlock.number + blocks; // farming will start 
            return deployer.deploy(KSTMinter, config.dev, startBlock, accounts[0]).then(res => {
                console.log('constructor[0]:' + config.dev);
                console.log('constructor[1]:' + startBlock);
                console.log('constructor[2]:' + accounts[0]);
            });
        });
};
