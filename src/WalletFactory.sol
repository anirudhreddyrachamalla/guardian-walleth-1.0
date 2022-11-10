// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "Wallet.sol";

contract WalletFactory {
    Wallet[] wallets;

    constructor() {}

    function createWallet(
        address payable _primaryWalletAddress,
        uint _inactivePeriodInDays,
        uint _withdrawalLimitInWei
    ) external {
        wallets.push(
            new Wallet(
                _primaryWalletAddress,
                _inactivePeriodInDays,
                _withdrawalLimitInWei
            )
        );
    }

    function updateInactiveWallets() external {
        uint currentTime = block.timestamp;

        for (uint i = 0; i < wallets.length; i++) {
            if (
                currentTime >
                wallets[i].getLastActiveTime() +
                    (wallets[i].getInactivePeriodInDays() * 1 days)
            ) {
                wallets[i].getPrimaryWalletAddress().transfer(
                    wallets[i].getBalance()
                );
            }
        }
    }
}
