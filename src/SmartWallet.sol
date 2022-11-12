// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./MultiSigWallet.sol";
import "./SocialRecovery.sol";

contract SmartWallet {

    struct RecoveryWallet{
        SocialRecovery socialRecovery;
        MultiSigWallet multiSigWallet;
    }

    struct Transaction{
        uint id;
        address to;
        uint amount;
    }

    mapping(address => RecoveryWallet) wallets;
    mapping (address => address[]) approvalsRequired;
    mapping (address => address[]) guardingAddresses;

    //social recovery events
    event VoteCasted(address senderAddress, address walletOwner);
    event VoteRevoked(address senderAddress, address walletOwner);
    event GuardianAdditionInitiated(address sender, address guardian);
    event GuardianAdded(address sender, address guardian);
    event GuardianRemovalInitiated(address sender, address guardian);
    event GuardianRemoved(address sender, address guardian);

    //multi sig events
    event WalletCreated(address creator, address walletAddress);
    event ApproverAdded(address walletOwner, address approver);
    event TransactionInitiated(address from, address to, uint amount);
    event TransactionApproved(address from, address owner, uint txIndex);
    event TransactionRevoked(address from, address owner, uint txIndex);
    function createNewSmartWallet(address[] memory _guardians, 
    address[] memory _approvers, 
    uint _numConfirmationsRequired,
    uint _inactivePeriod,
    uint _transactionLimit
    ) public {
       SocialRecovery sRecovery = new SocialRecovery(_guardians);
       for (uint i = 0; i < _guardians.length; i++) {
        guardingAddresses[_guardians[i]].push(msg.sender);
        emit GuardianAdded(msg.sender, _guardian[i]);
       }
       MultiSigWallet mWallet = new MultiSigWallet(_numConfirmationsRequired, _approvers);
       for (uint i = 0; i < _approvers.length; i++) {
        approvalsRequired[_approvers[i]].push(msg.sender);
        emit ApproverAdded(msg.sender, _approvers[i]);
       }
       wallets[msg.sender] = RecoveryWallet(sRecovery, mWallet);
       emit WalletCreated(msg.sender, address(mWallet));
       //TODO: Store this mwallet address and listen to events in UI.
    }

    // MultiSigWallet
    function initiateTransaction(address _to,uint _amount,bytes calldata _data) public {
        uint txIndex = wallets[msg.sender].multiSigWallet.initiateTransaction(_to, _amount, _data);
        uint numConfirmationsRequired = wallets[msg.sender].multiSigWallet.getNumberOfConfirmations();
        emit TransactionStatus(msg.sender, _to, _amount, 1, numConfirmationsRequired);
        address[] approvers = wallets[msg.sender].multiSigWallet.getApprovers();
        for(uint i;i<approvers.length;i++){
            emit ApprovalRequired(approvers[i], msg.sender,_to, _amount, txIndex);
        }
        //TODO: handle no wallet present for a user case.
        //Doubt: can we make this view? this doesn't the state of this contract but it does change of overall blockchain
    }

    function getNumberOfConfirmationsDone(uint _txIndex) external view returns(uint){
        uint result = wallets[msg.sender].multiSigWallet.getNumberOfConfirmationsDone(_txIndex);
        return result;
    }

    function approveTransaction(uint _txIndex, address _owner) external {
        uint numConfirmationsDone = wallets[_owner].multiSigWallet.approveTransaction(_txIndex);
        uint numConfirmationsRequired = wallets[_owner].multiSigWallet.getNumberOfConfirmations();
        emit TransactionApproved(msg.sender, _owner, _txIndex);
        emit TransactionStatus(_owner, _txIndex, numConfirmationsDone, numConfirmationsRequired);
    }

    function getApprovalStatus(uint _txIndex) external view returns(bool){
         bool result = wallets[msg.sender].multiSigWallet.getStatusOfYourApproval(_txIndex);
         return result;
    }

    function revokeTransaction(uint _txIndex, address _owner) external {
        uint numConfirmationsDone = wallets[_owner].multiSigWallet.revokeTransaction(_txIndex);
        uint numConfirmationsRequired = wallets[_owner].multiSigWallet.getNumberOfConfirmations();
        emit TransactionRevoked(msg.sender, _owner, _txIndex);
        emit TransactionStatus(_owner, _txIndex, numConfirmationsDone, numConfirmationsRequired);
    }

    function deleteTransaction(uint _txIndex) external {
        wallets[msg.sender].multiSigWallet.deleteTrasaction(_txIndex);
        emit TransactionDeleted(msg.sender, _to, _amount, _txIndex);
        address[] approvers = wallets[msg.sender].multiSigWallet.getApprovers();
        for(uint i;i<approvers.length;i++){
            emit ApprovalNotRequired(approvers[i], msg.sender,_to, _amount, txIndex);
        }
    }

    function publishTransaction(uint _txIndex)  returns () {
        wallets[msg.sender].multiSigWallet.publishTrasaction(_txIndex);
        emit TransactionCompleted(msg.sender, _to, _amount, _txIndex);
        address[] approvers = wallets[msg.sender].multiSigWallet.getApprovers();
        for(uint i;i<approvers.length;i++){
            emit ApprovalNotRequired(approvers[i], msg.sender,_to, _amount, txIndex);
        }
    }

    // SocialRecovery
    function castRecoveryVote(address walletOwner, address _newOwnerAddress) public{
       wallets[walletOwner].socialRecovery.castVote(_newOwnerAddress);
       emit VoteCasted(msg.sender, walletOwner);
    }

    //TODO: Function to fetch casted votes by a guardian when they try to login

    function removeRecoveryVote(address walletOwner, address _guardian) public{
        wallets[msg.sender].socialRecovery.removeVote(_guardian);
        emit VoteRevoked(msg.sender, walletOwner);
    }

    function initiateAddGuardian(address _guardian) public {
        wallets[msg.sender].socialRecovery.initiateAddGuardian(_guardian);
        emit GuardianAdditionInitiated(msg.sender, _guardian);
    }

    function addGuardian(address _guardian) public {
        wallets[msg.sender].socialRecovery.addGuardian(_guardian);
        guardingAddresses[_guardian].push(msg.sender);
        emit GuardianAdded(msg.sender, _guardian);
    }

    function initiateGuardianRemoval(address _guardian) public{
        wallets[msg.sender].socialRecovery.initiateGuardianRemoval(_guardian);
        emit GuardianRemovalInitiated(msg.sender, _guardian);
    }

    function removeGuardian(address _guardian) public {
        wallets[msg.sender].socialRecovery.removeGuardian(_guardian);
        removeElementFromArray(_guardian, msg.sender);
        emit GuardianRemoved(msg.sender, _guardian);
    }

    function removeElementFromArray(address guardian, address element) internal {
        uint i;
        address[] storage addressArray = guardingAddresses[guardian];
        uint length = addressArray.length;
        for(i;i<length;i++){
            if (addressArray[i] == element) {
                break;
            }
        }
        addressArray[i] = addressArray[length-1];
        addressArray.pop();
    }

    //TODO: Add login functionality
    
}