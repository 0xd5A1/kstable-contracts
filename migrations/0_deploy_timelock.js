const TimeLock = artifacts.require("TimeLock");
const KSTToken = artifacts.require("KSTToken");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    return KSTToken.deployed().then(bst => {
        let config = data[deployer.network_id];
        let dDay = new Date();
        dDay.setFullYear(config.dDay[0], config.dDay[1], config.dDay[2]);
        dDay.setHours(config.hours[0], config.hours[1], config.hours[2], config.hours[3]);
        let startTime = Math.floor(new Date().getTime() / 1000);
        return deployer.deploy(TimeLock, config.beneficiary, bst.address, startTime, 0).catch(e => {
            console.error(e);
        });
    });

};
