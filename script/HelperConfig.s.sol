// 1. We gonna deploy mocks when we are on a local anvil chain
// 2. We gonna keep track of contract addresses across different chains
// For example Sepolia ETH/USD has different address
// Mainnet ETH/USD has different address
// If we setup this helper config correctly we will be able to work with local chain (no problem) and work with any chain no problem

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil chain, we will deploy this mock contract for us to interact with
    // Otherwise, grab the existing address from the live network

    NetworkConfig public activeNewtworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNewtworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNewtworkConfig = getMainnetEthConfig();
        } else {
            activeNewtworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNewtworkConfig.priceFeed != address(0)) {
            return activeNewtworkConfig;
        }
        // price feed address

        // 1. Deploy the mocks (mocks are real but dummy cause we can own & control)
        // 2. Return the mock address

        vm.startBroadcast(); // this way we can deploy the mock contracts to the anvil chain we are working
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); // 8 decimals
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
