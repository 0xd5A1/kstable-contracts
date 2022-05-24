const TimeLockTest = artifacts.require("TimeLockTest");
const HuaMiuToken = artifacts.require("HuaMiuToken");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    return HuaMiuToken.deployed().then(huamiu => {
        let now = Math.floor(new Date().getTime() / 1000);
        return deployer.deploy(TimeLockTest, accounts[0], huamiu.address, now, 10).catch(e => {
            console.error(e);
        });
    });

};
