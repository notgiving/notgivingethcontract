var NotGivingEth = artifacts.require("./NotGivingToken.sol");

module.exports = function(deployer) {
  deployer.deploy(NotGivingEth);
};
