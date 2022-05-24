const BalanceSnapshot = artifacts.require("BalanceSnapshot");
const data = require('./conf');

module.exports = function (deployer, network, accounts) {
    let holders = ["0x1ad41cc71ff5d15b51e16283514875edce3994fb",
        "0x20b7a7a3bf89e04235ce9b5f9b9bc50101165f4b",
        "0x24d589a95aa70d2372382da0a4833cc00831bc2a",
        "0x29639af42aeb01ec689e436cc1aa26a399383537",
        "0x331c5db26401cc329e007e57d4b4fc34ac3568f9",
        "0x3c438d63c9001378c32a730c6493494e94d251fe",
        "0x4194309fc05f3458e234e4625018a1f4e55ff473",
        "0x5ab28b076929ec513ad168068dc3ac58de7d995f",
        "0x5bde89fde4c26562ed6037c086a6d06deacb9c90",
        "0x61a374d65c1623a9c482d8b1c09144ff24c6418e",
        "0x70c443a9f57b5c30c55805c92a62c37738e25339",
        "0x769af4895c8d7c92af4ab899d83e40659a5632a5",
        "0x82e72b211e57e1550e8d09f721550d5510c12d1d",
        "0x830a40032fea261e57736fce9bb6cc04124a8459",
        "0x8cafae9a97005f1adc49d5742739bc5b3f8521ba",
        "0x8f36c5cce9d4a7de7e528041c6519d6ea7841694",
        "0x8fbf3f7b39ae1a5893b2ce5667b3bb820ad6823d",
        "0x907c07c1c2bd667c6c8caf0783106fc0a43524a9",
        "0x931b226ebb7134a19b970cbf74f18e40a4239178",
        "0x977943f56cdd5e50ee4bfbe3aeb1e538ebb5311f",
        "0x9b97873ab4644b7a14a1fb698cef3c6965f9b878",
        "0xa0f14f6f344403c4d8c37c8b9acb4ae2d65f7f65",
        "0xa16f71f1eab128200c466b81ff018b3087aeef8a",
        "0xad387a2a8fec2d82d1bf07891dcfa468079f5af7",
        "0xcfeb29eda107b91bf2130f9c831c49ada5083019",
        "0xd5f59c7366e38945ae224b3684fbfda414f340be",
        "0xd90bee59757a0da470720835314457837fa4e8d1",
        "0xdaada0006ae1bc3222d587dedb3f34068be9192c",
        "0xdffb1be63561039692723be556302346aab09d0c",
        "0xe0a04884f5efa284c769fc771101446e2f616f3e",
        "0xe3350e9c9398cafdc7d87d2a864e19388b0cc8cf",
        "0xe392e892727cc9864433918ffc499913d137363c",
        "0xe7c73ceaa83e60d75a09aa10eff2f1248b0dddfa",
        "0xf3535908157df2ea2ed852fb5ee1c6a4d8a62ee4",
        "0xf44582fb6f71c3a3c512ff54a349d7b2d684ab00",
        "0xf90a1e5b60744c8e8545587be986f2ddff9d5340"];
    deployer.deploy(BalanceSnapshot).then(r => {
        return BalanceSnapshot.deployed().then(i => {
            return i.snapshot();
        });
    });

};
