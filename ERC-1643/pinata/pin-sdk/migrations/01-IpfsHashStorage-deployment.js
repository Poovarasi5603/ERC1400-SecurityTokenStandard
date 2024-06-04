const IpfsHashStorage = artifacts.require("IpfsHashStorage");

module.exports = async function (deployer, network, accounts) {
  await  deployer.deploy(IpfsHashStorage, { from: accounts[0] });
};
