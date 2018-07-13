var NotGivingEth = artifacts.require("./NotGivingEthToken.sol");

module.exports = function(deployer) {
  deployer.deploy(NotGivingEth);
};
