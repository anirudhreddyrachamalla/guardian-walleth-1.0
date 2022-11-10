// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "./Wallet.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract WalletFactory is AutomationCompatibleInterface {
    Wallet[] wallets;
    uint public immutable interval;
    uint public lastTimeStamp;
    uint public counter; // For testing

    constructor(uint updateInterval) {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        counter = 0;
    }

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

    // Runs off-chain to determine if performUpkeep should be executed on-chain
    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata performData) external override {
        // Chailink recommends we revalidate the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;

            counter = counter + 1;

            for (uint i = 0; i < wallets.length; i++) {
                if (
                    lastTimeStamp >
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
}
