# Intuition Protocol

Intuition is an Ethereum-based attestation protocol harnessing the wisdom of the crowds to create an open knowledge and reputation graph. Our infrastructure makes it easy for applications and their users to capture, explore, and curate verifiable data. We’ve prioritized making developer integrations easy and have implemented incentive structures that prioritize ‘useful’ data and discourage spam.

In bringing this new data layer to the decentralized web, we’re opening the flood gates to countless new use cases that we believe will kick off a consumer application boom.

The Intuition Knowledge Graph will be recognized as an organic flywheel, where the more developers that implement it, the more valuable the data it houses becomes.

## Getting Started
- [Intuition Protocol](#intuition-protocol)
  - [Getting Started](#getting-started)
  - [Branching](#branching)
  - [Documentation](#documentation)
  - [Building and Running Tests](#building-and-running-tests)
    - [Prerequisites](#prerequisites)
    - [Step by Step Guide](#step-by-step-guide)
      - [Install Dependencies](#install-dependencies)
      - [Build](#build)
      - [Run Tests](#run-tests)
    - [Deployment Process using OpenZeppelin Defender](#deployment-process-using-openzeppelin-defender)
    - [Deployment Verification](#deployment-verification)
    - [Upgrade Process](#upgrade-process)
  - [Deployments](#deployments)
    - [Base Sepolia Testnet](#base-sepolia-testnet)

## Branching

The main branches we use are:
- [main (default)](https://github.com/0xIntuition/intuition-contracts/tree/main): The most up-to-date branch, containing the work-in-progress code for upcoming releases
- [tob-audit](https://github.com/0xIntuition/intuition-contracts/tree/tob-audit): The snapshot of the code that was audited by Trail of Bits in March and April 2024

## Documentation

To get a basic understanding of the Intuition protocol, please check out the following:
- [Official Website](https://intuition.systems)
- [Official Documentation](https://docs.intuition.systems)
- [Deep Dive into Our Smart Contracts](https://intuition.gitbook.io/intuition-or-beta-contracts)

## Building and Running Tests

To build the project and run tests, follow these steps:

### Prerequisites

- [Foundry](https://getfoundry.sh)
- (Optional) [VSCode Hardhat Solidity Plugin](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)
- (Optional) [VSCode Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters)

### Step by Step Guide

#### Install Dependencies

```shell
$ npm i
$ forge install
```

#### Build

```shell
$ forge build
```

#### Run Tests

```shell
$ forge test -vvv
```

### Deployment Process using OpenZeppelin Defender

To deploy the v1 smart contract system on to a public testnet or mainnet, you’ll need the following:
- Set the credentials DEFENDER_KEY and DEFENDER_SECRET on a .env file
- RPC URL of the network that you’re trying to deploy to (as for us, we’re targeting Base Sepolia testnet as our target chain for the testnet deployments)
- Export private key of a deployer account in the terminal, and fund it with some test ETH to be able to cover the gas fees for the smart contract deployments
- For Base Sepolia, there is a reliable [testnet faucet](https://alchemy.com/faucets/base-sepolia) deployed by Alchemy
- Deploy smart contracts using the following command:

```shell
$ forge script script/Deploy.s.sol --broadcast --rpc-url <your_rpc_url> --private-key $PRIVATE_KEY
```

After the deployment go to the Deploy dashboard on OpenZeppelin Defender and approve

### Deployment Verification

To verify the deployed smart contracts on Etherscan, you’ll need to export your Etherscan API key as `ETHERSCAN_API_KEY` in the terminal, and then run the following command:

```shell
$ forge verify-contract <0x_contract_address> ContractName --watch --chain-id <chain_id>
```

**Notes:**
- When verifying your smart conttacts, you can use an optional parameter `--constructor-args` to pass the constructor arguments of the smart contract in the ABI-encoded format
- The chain ID for Base Sepolia is `84532`, whereas the chain ID for Base Mainnet is `8453`

### Upgrade Process

To upgrade the smart contract you need:
- Deploy a new version of contracts you want to upgrade, for example `EthMultiVault`. You need to add the directive `@custom:oz-upgrades-from` on the line before where you define the contract and set the version of the upgrade on the `init` function (e.g. `reinitializer(2)`)
- If using a multisig as an upgrade admin, schedule the upgrade for some time in the future (e.g. 2 days) using this script to generate the parameters that can be used in Safe Transaction Builder:

```shell
$ forge script script/TimelockController.s.sol
```

- After the delay passes (e.g. 2 days) you can call this again, just change the method on the target to `execute`

## Deployments

### Base Sepolia Testnet
