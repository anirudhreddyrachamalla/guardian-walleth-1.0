// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract Wallet {
    address payable owner;
    address payable primaryWalletAddress;
    uint inactivePeriodInDays;
    uint withdrawalLimitInWei;
    uint lastActiveTime;
    bool locked;

    constructor(
        address payable _primaryWalletAddress,
        uint _inactivePeriodInDays,
        uint _withdrawalLimitInWei
    ) {
        owner = payable(msg.sender);
        primaryWalletAddress = _primaryWalletAddress;
        inactivePeriodInDays = _inactivePeriodInDays;
        withdrawalLimitInWei = _withdrawalLimitInWei;
        lastActiveTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notLocked() {
        require(!locked, "Account is locked");
        _;
    }

    modifier updateLastActiveTime() {
        _;
        lastActiveTime = block.timestamp;
    }

    receive() external payable {}

    function withdraw(uint _amount) external onlyOwner updateLastActiveTime {
        payable(msg.sender).transfer(_amount);
    }

    function updatePrimaryWalletAddress(address payable _primaryWalletAddress)
        external
        onlyOwner
        updateLastActiveTime
    {
        primaryWalletAddress = _primaryWalletAddress;
    }

    function updateInactivePeriod(uint _inactivePeriodInDays)
        external
        onlyOwner
        updateLastActiveTime
    {
        require(_inactivePeriodInDays > 0, "Invalid period");
        inactivePeriodInDays = _inactivePeriodInDays;
    }

    function updateWithdrawalLimitInWei(uint _withdrawalLimitInWei)
        external
        onlyOwner
        updateLastActiveTime
    {
        require(inactivePeriodInDays > 0, "Invalid withdrawal limit");
        withdrawalLimitInWei = _withdrawalLimitInWei;
    }

    function send(address payable _to)
        external
        payable
        onlyOwner
        updateLastActiveTime
    {
        require(msg.value <= withdrawalLimitInWei, "Amount is over the limit");
        _to.transfer(msg.value);
    }

    function updateLocked(bool _locked)
        external
        onlyOwner
        updateLastActiveTime
    {
        locked = _locked;
    }

    function getLastActiveTime() public view returns (uint) {
        return lastActiveTime;
    }

    function getInactivePeriodInDays() public view returns (uint) {
        return inactivePeriodInDays;
    }

    function getPrimaryWalletAddress() public view returns (address payable) {
        return primaryWalletAddress;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
