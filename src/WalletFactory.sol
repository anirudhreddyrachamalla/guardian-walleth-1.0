// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "Wallet.sol";

contract WalletFactory {
    mapping(Wallet => bool) inactiveWallets;
    Wallet[] wallets;

    constructor() {}

    function updateInactiveWallets() external {
        uint currentTime = block.timestamp;
        for (uint i = 0; i < wallets.length; i++) {
            if (
                currentTime >
                wallets[i].getLastActiveTime() +
                    wallets[i].getInactivePeriodInDays()
            ) {
                inactiveWallets[wallets[i]] = true;
            } else {
                inactiveWallets[wallets[i]] = false;
            }
        }
    }
}
