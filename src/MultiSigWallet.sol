// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet{
    uint public immutable numOfConfirmationsRequired;
    // uint public txIndex;
    uint immutable TIME_AFTER_TRANSACTION_WILL_GET_CANCELLED = 4 hours;

    struct Transaction{
        address to;
        uint amount;
        uint initiationTime;
        uint confirmationsDone;
        bytes data;
    }

    mapping(address=>bool) isOwner;
    mapping(address=>bool) approvedAccounts;
    address[] public owners;

    Transaction currentTransction;
    // TODO: Might want to keep an array of all the transactions as a history

    event MoneyDeposited(address _depositor,uint _amount);
    event TransactionInitiated(address _owner,address _to,uint _amount);
    event TransactionPartiallyApproved(address _owner,uint _amount,uint _confirmationsDone );
    event TransactionCompletelyApproved(uint _amount);
    event TransactionPartiallyRevoked(address _owner);
    event TransactionCompletelyRevoked(address ,uint _amount);


    constructor(uint _numOfConfirmationsRequired,address[] memory _owners){

        require(_owners.length>0,"Owners required");

        bool isNumberOfConfirmationsRequiredValid =  _numOfConfirmationsRequired>0 && _numOfConfirmationsRequired <= _owners.length;
        require(isNumberOfConfirmationsRequiredValid,"Please enter valid number of confirmations required for a transaction");

        uint len = _owners.length;
        for(uint i =0;i<len;){
            address owner = _owners[i];
            require(owner!=address(0),"Invalid Owner");
            require(isOwner[owner],"Owner not unique");
            isOwner[owner]=true;
            unchecked{
                ++i;
            }
            owners.push(owner);
        }
        numOfConfirmationsRequired = _numOfConfirmationsRequired;
    }

    receive() external payable{
        emit MoneyDeposited(msg.sender,msg.value);
    }

    function initiateTransaction(address _to,uint _amount,bytes calldata _data) external {
        cancelTransaction(); // Remove any stale transactions that has not been completed within TIME_AFTER_TRANSACTION_WILL_GET_CANCELLED
        //TODO : Cancel any other transactions pending
        bool isTransactionInitiatedByOwner = isOwner[msg.sender];
        require(isTransactionInitiatedByOwner,"Transaction can only be initaited by owners");

        uint contractBalance = address(this).balance;
        bool isEnoughContractBalance = contractBalance >= _amount;
        require(isEnoughContractBalance,"Not Enough Money in your wallet");
        
        // Means there has not been any transaction from this smart contract
        currentTransction = Transaction(_to,_amount, block.timestamp,1,_data);
        approvedAccounts[msg.sender] = true;

        // Trigger the cancelTransaction after transactionPeriod just once, can be done using chainlink
        emit TransactionInitiated(msg.sender,_to,_amount);
    }

    function approveTransaction() external {
        require(isOwner[msg.sender]==true,"Not an owner");

        bool hasTransactionInitiated = currentTransction.initiationTime >0;
        require(hasTransactionInitiated,"Please initiate a new transaction");
        
        // TODO : Might be a good idea to remove it
        bool hasAlreadyApproved = approvedAccounts[msg.sender];
        require(hasAlreadyApproved,"You have already approved the transaction");

        approvedAccounts[msg.sender]=true;
        currentTransction.confirmationsDone++;

        emit TransactionPartiallyApproved(msg.sender,currentTransction.amount,currentTransction.confirmationsDone);
        if(currentTransction.confirmationsDone==numOfConfirmationsRequired){
            publishTransaction(); 
        }
    }

    function revokeTransaction() external {

        require(isOwner[msg.sender]==true,"Not an owner");

        bool hasTransactionInitiated = currentTransction.initiationTime >0;
        require(hasTransactionInitiated,"No transaction to revoke");
        
        bool hasAlreadyApproved = approvedAccounts[msg.sender];
        require(hasAlreadyApproved,"You have NOT approved the transaction YET");

        approvedAccounts[msg.sender]=false;
        currentTransction.confirmationsDone--;
        emit TransactionPartiallyRevoked(msg.sender);

        if(currentTransction.confirmationsDone==0){
            emit TransactionCompletelyRevoked(msg.sender,currentTransction.amount);
            currentTransction = Transaction(address(0),0,0,0,"");
        }
    }

    function publishTransaction() internal {
        // TODO : Write publish logic here
        (bool sent, ) = currentTransction.to.call{value: currentTransction.amount}(currentTransction.data);
        require(sent, "Failed to send Ether");
        
        currentTransction = Transaction(address(0),0,0,0,""); // Check whether we can delete an object or not
        for(uint i =0;i<owners.length;){
            address owner = owners[i];
            bool hasOwnerVoted = approvedAccounts[owner];
            if(hasOwnerVoted){
                approvedAccounts[owner]=false;
            }
            unchecked {
                ++i;
            }
        }
        emit TransactionCompletelyApproved(currentTransction.amount);
    }

    // This function can be called every four hours, so that it cancels all the transactions 
    // once it has elapsed more than 4 hrs being in the mempool
    function cancelTransaction() internal {
        // We will have to make sure that this transaction cancels after the transactionTimePeriod
        // Also, we will also want to make sure that once the transaction completes then there is a new time 
        // scheduled for this function call.
        if(currentTransction.initiationTime >0){
            bool isDeadlineOver = block.timestamp > currentTransction.initiationTime + TIME_AFTER_TRANSACTION_WILL_GET_CANCELLED; 
            if(isDeadlineOver){
                currentTransction = Transaction(address(0),0,0,0,"");
                for(uint i =0;i<owners.length;){
                    address owner = owners[i];
                    bool hasOwnerVoted = approvedAccounts[owner];
                    if(hasOwnerVoted){
                        approvedAccounts[owner]=false;
                    }
                    unchecked {
                        ++i;
                    }
                }
            }
        }
        
    }
}


// TODO: Multiple transactions handle