pragma solidity ^0.4.24;

import './NotgivingEth_interface.sol';
import './SafeMath.sol';

contract NotGivingEthToken is NotGivingEthInterface {
    using SafeMath for uint;

    mapping(address => bool) private signersList;
    
    mapping(address => uint) private whiteBalance;
    mapping(address => uint) private blackBalance;
    mapping(address => uint) public lastBlock;
    mapping(address => SubmittedProposal) private proposals;

    event TransferWhiteCoin(address indexed _sellto, uint _value);
    event SpotSubmitted(address indexed _victim, address indexed _spammer, uint _value);
    event SpotApproved(address indexed _signer, address indexed _victim, uint _value);
    
    event BalanceOf(address indexed _owner);
    event BalanceOfWhite(address indexed _owner);
    
    uint public signerCount = 0;
    address private contractOwner;
    address[] private signersArray;
    address[] private openVictimList;
    
    enum SpotState {
        Open,
        Close
    }

    struct SubmittedProposal {
        address victim;
        address spammer;
        uint amountRequested;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    SpotState public state;

    modifier isSigner() {
        require(signersList[msg.sender],"You are not a signer!!!");
        _;
    }
    
    modifier inState(SpotState _state) {
        require(state == _state, "Please check the required state for this activity!!!");
        _;
    }
    
    constructor () public {
        contractOwner = msg.sender;

/*
        for(uint i=0; i<signers.length;i++) {
            signersList[address(signers[i])] = true; signerCount = signerCount.add(1);
            signersArray.push(signers[i]);
        }
*/        
        signersList[address(0xd6a2Af5F1622b0A25A346A7b048c1dc25e0012Fc)] = true; signerCount = signerCount.add(1);
        signersList[address(0xE504E82E9B335e600837C0acf74Bb233b888c8Ec)] = true; signerCount = signerCount.add(1);
        signersList[address(0x011756c887D37dBb3d06E442c1113ABDBC98e36E)] = true; signerCount = signerCount.add(1);
        signersList[address(0xAE120c0a38c622B62ce505e0349ab27Ced036e5d)] = true; signerCount = signerCount.add(1);
        signersList[address(0xD296e44f382BC0F6c2B1DdBdB03551E509635f1f)] = true; signerCount = signerCount.add(1);
        signersList[address(0x44c46Ed496B94fafE8A81b9Ab93B27935fcA1603)] = true; signerCount = signerCount.add(1);
 
        signersArray.push(0xd6a2Af5F1622b0A25A346A7b048c1dc25e0012Fc);
        signersArray.push(0xE504E82E9B335e600837C0acf74Bb233b888c8Ec);
        signersArray.push(0x011756c887D37dBb3d06E442c1113ABDBC98e36E);
        signersArray.push(0xAE120c0a38c622B62ce505e0349ab27Ced036e5d);
        signersArray.push(0xD296e44f382BC0F6c2B1DdBdB03551E509635f1f);
        signersArray.push(0x44c46Ed496B94fafE8A81b9Ab93B27935fcA1603);
 /*
  //my test in remix to be removed
        signersList[address(0x00dd870fa1b7c4700f2bd7f44238821c26f7392148)] = true; signerCount = signerCount.add(1);
        signersList[address(0x00583031d1113ad414f02576bd6afabfb302140225)] = true; signerCount = signerCount.add(1);
        signersList[address(0x004b0897b0513fdc7c541b6d9d7e929c4e5364d2db)] = true; signerCount = signerCount.add(1);
  */  
    }

    function getSigners() public view returns(address[]) {
        return signersArray;
    }
    
    //this will be called by owner, in our case trading ui
    function transferWhiteCoin(address _sellto, uint _value) public {
      //Burn white token of sellfrom
      //Burn Black Token of sellTo
      require(whiteBalance[msg.sender] >= _value ,"Not sufficient White coin to sell");
      require(blackBalance[_sellto] >= _value ,"Not sufficient Black coin to receive White coin");
      whiteBalance[msg.sender] = whiteBalance[msg.sender].sub(_value);
      blackBalance[_sellto] = blackBalance[_sellto].sub(_value);
      
      emit TransferWhiteCoin(_sellto, _value);
    }

    //only owner can call, called from dapp
    function spot(address _victim, address _spammer, uint _value) public {
        require(_victim != address(0),"Victim cannot be address(0)");
        require(_spammer != address(0),"Spammer cannot be address(0)");
        
        state = SpotState.Open;
        
        SubmittedProposal memory newProposal = SubmittedProposal({
           victim: _victim,
           spammer: _spammer,
           amountRequested: _value,
           approvalCount: 0
        });
        
        proposals[_victim] = newProposal;
        openVictimList.push(_victim);
         
        emit SpotSubmitted(_victim, _spammer, _value);
    }

    function approve(address _victim) public isSigner inState(SpotState.Open) {
        SubmittedProposal storage aProposal = proposals[_victim];

        require(!aProposal.approvals[msg.sender],"You can approve only once!!!");
        aProposal.approvalCount = aProposal.approvalCount.add(1);
        
        if(aProposal.approvalCount >= 3) {
                            
            if(lastBlock[_victim] != 0) {
                //dont allow to spot transaction for 5000 block passed
                require(lastBlock[aProposal.victim].add(5) < block.number,"Allowed only every 5 blocks");
            }
            
            if(aProposal.victim == aProposal.spammer) {
                blackBalance[aProposal.spammer] = blackBalance[aProposal.spammer].add(aProposal.amountRequested).mul(2);
            } else {
                whiteBalance[aProposal.victim] = whiteBalance[aProposal.victim].add(aProposal.amountRequested);
                blackBalance[aProposal.spammer] = blackBalance[aProposal.spammer].add(aProposal.amountRequested);    
            }
            
            lastBlock[aProposal.victim] = block.number;
            removeByValue(aProposal.victim);
            aProposal.approvals[msg.sender] = true;
        }
            
        emit SpotApproved(msg.sender, aProposal.victim, aProposal.amountRequested);
    }

    function listOpenVictims() public view returns (address[]) {
         return openVictimList;
    }
    
    // send balance of black token, for wallets
    function balanceOf(address _owner) public returns (uint balance) {
        require(_owner != address(0),"Balance of address(0) is not possible");
        SubmittedProposal storage getProp = proposals[_owner];
        
        require(getProp.approvals[_owner],"Proposal not approved.");
        
        emit BalanceOf(_owner);
        
        return blackBalance[_owner];
    }

    // send balance of while token, for dapp
    function balanceOfWhite(address _owner) public returns (uint balance) {
        require(_owner != address(0),"Balance of address(0) is not possible");
        
        SubmittedProposal storage getProp = proposals[_owner];
        
        require(getProp.approvals[_owner],"Proposal not approved.");
        
        emit BalanceOfWhite(_owner);
        
        return whiteBalance[_owner];
    }
    
    function getBN() returns(uint) {
        return block.number;
    }
    
      // functions for listOpenBeneficiariesProposals
    function find(address _addr) private view returns(uint) {
        uint i = 0;
        while (openVictimList[i] != _addr) {
            i++;
        }
        return i;
    }

    function removeByIndex(uint i) private {
        while (i<openVictimList.length-1) {
            openVictimList[i] = openVictimList[i+1];
            i++;
        }
        openVictimList.length--;
    }

    function removeByValue(address _addr) private {
        uint i = find(_addr);
        removeByIndex(i);
    }
}
