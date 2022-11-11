// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./MultiSigWallet.sol";
import "./SocialRecovery.sol";

contract SmartWallet {

    struct RecoveryWallet{
        SocialRecovery socialRecovery;
        MultiSigWallet multiSigWallet;
    }

    mapping(address => RecoveryWallet) wallets;

    //socaial recovery events
    event WalletCreated(address _newAddress);
    event castedVote(bool _voted);
    event revokedVote(bool _revoked);
    event addedGuardian(address _guardian);
    event removedGuardian(address _guardian);

    //multi sig events
    event transactionInitiated(address from, address to, uint amount);

    function createNewSmartWallet(address[] memory _guardians, 
    address[] memory _approvers, 
    uint _numConfirmationsRequired,
    uint _inactivePeriod,
    uint _transactionLimit
    ) public {
       SocialRecovery sRecovery = new SocialRecovery(_guardians);
       MultiSigWallet mWallet = new MultiSigWallet(_numConfirmationsRequired, _approvers);
       
        wallets[msg.sender] = RecoveryWallet(sRecovery, mWallet);
        // emit WalletCreated(address(mWallet));
    }

    // SocialRecovery
    function castRecoveryVote(address _newOwnerAddress) public{
       wallets[msg.sender].socialRecovery.castVote(_newOwnerAddress);
    //    emit castedVote(true);
    }

    function removeRecoveryVote(address _guardian) public{
        wallets[msg.sender].socialRecovery.removeVote(_guardian);
        // emit revokedVote(true);
    }

    function addGuardian(address _guardian) public {
        wallets[msg.sender].socialRecovery.initiateAddGuardian(_guardian);
        // emit addedGuardian(_guardian);
    }

    function initiateGuardianRemoval(address _guardian) public{
        wallets[msg.sender].socialRecovery.initiateGuardianRemoval(_guardian);
    }

    function removeGuardian(address _guardian) public {
        wallets[msg.sender].socialRecovery.removeGuardian(_guardian);
        // emit removedGuardian(_guardian);
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