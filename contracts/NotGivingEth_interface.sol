pragma solidity ^0.4.11;

contract NotGivingEthInterface {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    event SpottedSpam(address victim, address  spammer, uint value);
}
