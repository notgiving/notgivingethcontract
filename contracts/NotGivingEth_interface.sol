pragma solidity ^0.4.24;

interface NotGivingEthInterface {
    function balanceOf(address who) constant external returns (uint);
    event SpottedSpam(address victim, address  spammer, uint value);
}
