# About

This is a crowd sourcing app

# Getting Started

## Requirement
* Requirements
* git
You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
foundry
You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (25f24e6 2024-09-28T00:21:16.976996664Z)`

## Quickstart

```ttps://github.com/liumOazed/foundry-fund-me-full.git```
```cd foundry-fund-me-full``
```make```

# Usage

## Deploy

``` forge script script/DeployFundMe.s.sol```

## Testing

We talk about 4 test tiers in the video.

1. Unit
2. Integration
3. Forked
4. Staging

This repo we cover #1 and #3.

``` forge test --mt testFunctionName```

or

``` forge test --fork-url $SEPOLIA_RPC_URL```

## Test Coverage

``` forge coverage```

# Deployment to a testnet or mainnet

1. Setup environment variables
You'll want to set your SEPOLIA_RPC_URL and PRIVATE_KEY as environment variables. You can add them to a .env file, similar to what you see in .env.example.

* PRIVATE_KEY: The private key of your account (like from metamask). NOTE: FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
You can learn how to export it here.
* SEPOLIA_RPC_URL: This is url of the sepolia testnet node you're working with. You can get setup with one for free from Alchemy
Optionally, add your ETHERSCAN_API_KEY if you want to verify your contract on Etherscan.

2. Get testnet ETH
Head over to faucets.chain.link and get some testnet ETH. You should see the ETH show up in your metamask.

3. Deploy

``` forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY```




