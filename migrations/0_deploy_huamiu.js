const HuaMiuToken = artifacts.require("HuaMiuToken");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    return deployer.deploy(HuaMiuToken).catch(e=>{
        console.error(e);
    });
};
