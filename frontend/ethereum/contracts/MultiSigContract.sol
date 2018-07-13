pragma solidity ^0.4.20;

interface AbstractMultiSig {

  /*
   * This function should return the onwer of this contract or whoever you
   * want to receive the Gyaan Tokens reward if it's coded correctly.
   */
  function owner() external returns(address);

  /*
   * This event should be dispatched whenever the contract receives
   * any contribution.
   */
  event ReceivedContribution(address indexed _contributor, uint _valueInWei);

  /*
   * When this contract is initially created, it's in the state
   * "Accepting contributions". No proposals can be sent, no withdraw
   * and no vote can be made while in this state. After this function
   * is called, the contract state changes to "Active" in which it will
   * not accept contributions anymore and will accept all other functions
   * (submit proposal, vote, withdraw)
   */
  function endContributionPeriod() external;

  /*
   * Sends a withdraw proposal to the contract. The beneficiary would
   * be "_beneficiary" and if approved, this address will be able to
   * withdraw "value" Ethers.
   *
   * This contract should be able to handle many proposals at once.
   */
  function submitProposal(uint _valueInWei) external;
  event ProposalSubmitted(address indexed _beneficiary, uint _valueInWei);

  /*
   * Returns a list of beneficiaries for the open proposals. Open
   * proposal is the one in which the majority of voters have not
   * voted yet.
   */
  function listOpenBeneficiariesProposals() external view returns (address[]);

  /*
   * Returns the value requested by the given beneficiary in his proposal.
   */
  function getBeneficiaryProposal(address _beneficiary) external view returns (uint);

  /*
   * List the addresses of the contributors, which are people that sent
   * Ether to this contract.
   */
  function listContributors() external view returns (address[]);

  /*
   * Returns the amount sent by the given contributor in Wei.
   */
  function getContributorAmount(address _contributor) external view returns (uint);

  /*
   * Approve the proposal for the given beneficiary
   */
  function approve(address _beneficiary) external;
  event ProposalApproved(address indexed _approver, address indexed _beneficiary, uint _valueInWei);

  /*
   * Reject the proposal of the given beneficiary
   */
  function reject(address _beneficiary) external;
  event ProposalRejected(address indexed _approver, address indexed _beneficiary, uint _valueInWei);

  /*
   * Withdraw the specified value in Wei from the wallet.
   * The beneficiary can withdraw any value less than or equal the value
   * he/she proposed. If he/she wants to withdraw more, a new proposal
   * should be sent.
   *
   */
  function withdraw(uint _valueInWei) external payable;
  event WithdrawPerformed(address indexed _beneficiary, uint _valueInWei);

  function getSignerVote(address _signer, address _beneficiary) view external returns(uint);

}

contract MultiSigContract is AbstractMultiSig {

    enum ProposalStatus { OPEN, APPROVED, REJECTED, CLOSED }
    enum VoteStatus { APPROVED, REJECTED,NO_VOTE }
    enum ContractStaus { ACTIVE, CONTRIBUTING }
    mapping(address => bool) private signers;
    struct Votes{
        address signer;
        VoteStatus status;
    }
    struct Proposal{
        ProposalStatus status;
        uint valueInWei;
        address beneficiaryAddr;
        bool exists;
        Votes[] voterList;
    }
    struct Contribution{
        uint valueInWei;
        bool exists;
    }
    mapping(address => Proposal) private proposals;
    Proposal[] private proposalList;
    Proposal[] private proposalHistoryList;

    mapping(address => Contribution) private contributors;
    address[] private contributorList;

    uint availableContribution = 0;
    uint blockedWei = 0;
    Votes[] private defaultVotes;
    Proposal private po;
    address public owner = msg.sender;
    ContractStaus contractStatus = ContractStaus.CONTRIBUTING;


    constructor() public{
        signers[0xfA3C6a1d480A14c546F12cdBB6d1BaCBf02A1610] = true;
        signers[0x2f47343208d8Db38A64f49d7384Ce70367FC98c0] = true;
        signers[0x7c0e7b2418141F492653C6bF9ceD144c338Ba740] = true;

        defaultVotes.push(Votes(0xfA3C6a1d480A14c546F12cdBB6d1BaCBf02A1610,VoteStatus.NO_VOTE));
        defaultVotes.push(Votes(0x2f47343208d8Db38A64f49d7384Ce70367FC98c0,VoteStatus.NO_VOTE));
        defaultVotes.push(Votes(0x7c0e7b2418141F492653C6bF9ceD144c338Ba740,VoteStatus.NO_VOTE));
    }

    function owner() public view returns(address){
        return owner;
    }

    function () payable public {
        require(contractStatus == ContractStaus.CONTRIBUTING);
        require(msg.value != 0);
        if(contributors[msg.sender].exists){
            contributors[msg.sender].valueInWei += msg.value;
        }
        else{
            contributors[msg.sender] = Contribution({exists:true, valueInWei:msg.value});
            contributorList.push(msg.sender);
        }
        availableContribution += msg.value;
        emit ReceivedContribution(msg.sender,msg.value);
    }

    function endContributionPeriod() external{
        require(signers[msg.sender] == true);
        contractStatus = ContractStaus.ACTIVE;
    }

    function submitProposal(uint _valueInWei) external{
        require(contractStatus == ContractStaus.ACTIVE);
        require(_valueInWei != 0);
        require(proposals[msg.sender].exists == false);
        require(signers[msg.sender] == false);

        if(((_valueInWei/(availableContribution - blockedWei))*100) <= 10){
            po.status = ProposalStatus.OPEN;
            po.valueInWei = _valueInWei;
            po.beneficiaryAddr = msg.sender;
            po.exists = true;
            po.voterList = defaultVotes;
            proposalList.push(po);
            proposals[msg.sender] = po;
            blockedWei += _valueInWei;
            emit ProposalSubmitted(msg.sender,_valueInWei);
        }
    }

    function listOpenBeneficiariesProposals() external view returns (address[]){
        address[] memory beneficiariesAdr;
        uint index = 0;
        for(uint i = 0; i < proposalList.length; i++) {
            if(proposalList[i].status == ProposalStatus.OPEN){
                beneficiariesAdr[index] = proposalList[i].beneficiaryAddr;
                index += 1;
            }
        }
        return beneficiariesAdr;
    }

    function getBeneficiaryProposal(address _beneficiary) external view returns (uint){
        require(_beneficiary != address(0x0));
        require(proposals[_beneficiary].exists == true);
        return proposals[_beneficiary].valueInWei;
    }

    function listContributors() external view returns (address[]){
        return contributorList;
    }

    function getContributorAmount(address _contributor) external view returns (uint){
        require(_contributor != address(0x0));
        require(contributors[_contributor].exists == true);
        return contributors[_contributor].valueInWei;
    }

    function approve(address _beneficiary) external{
        require(contractStatus == ContractStaus.ACTIVE);
        require(proposals[_beneficiary].status == ProposalStatus.OPEN);
        require(_beneficiary != address(0x0));
        require(proposals[_beneficiary].exists == true);
        require(contributors[_beneficiary].exists == false);//contributors should not vote
        require(msg.sender != _beneficiary);//approver and sender should not be same
        uint approvedCount = 0;
        for(uint i = 0; i < proposals[_beneficiary].voterList.length; i++){
            if(proposals[_beneficiary].voterList[i].signer == msg.sender){
                proposals[_beneficiary].voterList[i].status = VoteStatus.APPROVED;
            }
            if(proposals[_beneficiary].voterList[i].status == VoteStatus.APPROVED){
                approvedCount += 1;
            }
        }

        if(approvedCount >= 2){
            proposals[_beneficiary].status = ProposalStatus.APPROVED;
            for(uint j = 0; j < proposalList.length; i++) {
                if(proposalList[i].beneficiaryAddr == _beneficiary)
                    proposalList[i].status = ProposalStatus.APPROVED;
            }
        }
        emit ProposalApproved(msg.sender,_beneficiary,proposals[_beneficiary].valueInWei);
    }

    function reject(address _beneficiary) external{
        require(contractStatus == ContractStaus.ACTIVE);
        require(_beneficiary != address(0x0));
        require(proposals[_beneficiary].status == ProposalStatus.OPEN);
        require(proposals[_beneficiary].exists == true);
        require(contributors[_beneficiary].exists == false);//contributors should not vote
        require(msg.sender != _beneficiary);//approver and sender should not be same
        uint rejectedCount = 0;
        for(uint i = 0; i < proposals[_beneficiary].voterList.length; i++){
            if(proposals[_beneficiary].voterList[i].signer == msg.sender){
                proposals[_beneficiary].voterList[i].status = VoteStatus.REJECTED;
            }
            if(proposals[_beneficiary].voterList[i].status == VoteStatus.REJECTED){
                rejectedCount += 1;
            }
        }

        if(rejectedCount >= 2){
            proposals[_beneficiary].status = ProposalStatus.REJECTED;
            for(uint j = 0; j < proposalList.length; j++) {
                if(proposalList[j].beneficiaryAddr == _beneficiary)
                    proposalList[j].status = ProposalStatus.REJECTED;
            }
            blockedWei -= proposals[_beneficiary].valueInWei;
            proposalHistoryList.push(proposals[_beneficiary]);
            proposals[_beneficiary].exists = false;
        }
        emit ProposalRejected(msg.sender,_beneficiary,proposals[_beneficiary].valueInWei);
    }

    function withdraw(uint _valueInWei) external payable {
        require(contractStatus == ContractStaus.ACTIVE);
        require(_valueInWei > 0);
        require(proposals[msg.sender].exists == true);
        require(proposals[msg.sender].valueInWei > 0);
        require(proposals[msg.sender].status == ProposalStatus.APPROVED);
        require(proposals[msg.sender].valueInWei >= _valueInWei);

        msg.sender.transfer(msg.value);
        proposals[msg.sender].valueInWei -= _valueInWei;
        availableContribution -= _valueInWei;
        blockedWei -= _valueInWei;
        if(proposals[msg.sender].valueInWei == 0){
            proposalHistoryList.push(proposals[msg.sender]);
            proposals[msg.sender].exists = false;
        }
        emit WithdrawPerformed(msg.sender,_valueInWei);
    }

    function getSignerVote(address _signer, address _beneficiary) view external returns(uint){
        require(_signer != _beneficiary);
        require(_signer != address(0x0));
        require(_beneficiary != address(0x0));
        if(proposals[_beneficiary].exists == true){
            for(uint i = 0; i < proposals[_beneficiary].voterList.length; i++){
                if(proposals[_beneficiary].voterList[i].signer == _signer){
                    if(proposals[_beneficiary].voterList[i].status == VoteStatus.REJECTED)
                        return 0;
                    if(proposals[_beneficiary].voterList[i].status == VoteStatus.APPROVED)
                        return 1;
                    if(proposals[_beneficiary].voterList[i].status == VoteStatus.NO_VOTE)
                        return 2;
                }
            }
        }

        if(proposals[_beneficiary].exists == false){
            for(uint r = 0; r < proposalHistoryList.length; r++){
                if(proposalHistoryList[r].beneficiaryAddr == _beneficiary){
                 for(uint j = 0; j < proposalHistoryList[r].voterList.length; j++){
                        if(proposalHistoryList[r].voterList[j].signer == _signer){
                            if(proposalHistoryList[r].voterList[j].status == VoteStatus.REJECTED)
                                return 0;
                            if(proposalHistoryList[r].voterList[j].status == VoteStatus.APPROVED)
                                return 1;
                            if(proposalHistoryList[r].voterList[j].status == VoteStatus.NO_VOTE)
                                return 2;
                        }
                    }
                }
            }
        }

        return 1;
    }

}