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

    //socaial recovery events
    event WalletCreated(address creator, address walletAddress);
    event VoteCasted(address senderAddress, address walletOwner);
    event VoteRevoked(address senderAddress, address walletOwner);
    event GuardianAdditionInitiated(address sender, address guardian);
    event GuardianAdded(address sender, address guardian);
    event GuardianRemovalInitiated(address sender, address guardian);
    event GuardianRemoved(address sender, address guardian);

    //multi sig events

    function createNewSmartWallet(address[] memory _guardians, 
    address[] memory _approvers, 
    uint _numConfirmationsRequired,
    uint _inactivePeriod,
    uint _transactionLimit
    ) public {
       SocialRecovery sRecovery = new SocialRecovery(_guardians);
       for (uint i = 0; i < _guardians.length; i++) {
        guardingAddresses[_guardians[i]].push(msg.sender);
       }
       MultiSigWallet mWallet = new MultiSigWallet(_numConfirmationsRequired, _approvers);
       for (uint i = 0; i < _approvers.length; i++) {
        approvalsRequired[_approvers[i]].push(msg.sender);
       }
       wallets[msg.sender] = RecoveryWallet(sRecovery, mWallet);
       emit WalletCreated(msg.sender, address(mWallet));
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
    // MultiSigWallet
    function initiateTransaction(address _to,uint _amount,bytes calldata _data) public {
        wallets[msg.sender].multiSigWallet.initiateTransaction(_to, _amount, _data);
    }

    function getNumberOfConfirmationsDone(uint _txIndex) external view returns(uint){
        uint result = wallets[msg.sender].multiSigWallet.getNumberOfConfirmationsDone(_txIndex);
        return result;
    }

    function approveTransaction(uint _txIndex) external {
        wallets[msg.sender].multiSigWallet.approveTransaction(_txIndex);
    }

    function getApprovalStatus(uint _txIndex) external view returns(bool){
         bool result = wallets[msg.sender].multiSigWallet.getStatusOfYourApproval(_txIndex);
         return result;
    }

    function revokeTransaction(uint _txIndex) external {
        wallets[msg.sender].multiSigWallet.revokeTransaction(_txIndex);
    }
}