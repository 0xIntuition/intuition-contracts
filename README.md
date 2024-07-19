# Intuition Protocol

Intuition is an Ethereum-based attestation protocol harnessing the wisdom of the crowds to create an open knowledge and reputation graph. Our infrastructure makes it easy for applications and their users to capture, explore, and curate verifiable data. We’ve prioritized making developer integrations easy and have implemented incentive structures that prioritize ‘useful’ data and discourage spam.

In bringing this new data layer to the decentralized web, we’re opening the flood gates to countless new use cases that we believe will kick off a consumer application boom.

The Intuition Knowledge Graph will be recognized as an organic flywheel, where the more developers that implement it, the more valuable the data it houses becomes.

## Getting Started
- [Intuition Protocol](#intuition-protocol)
  - [Getting Started](#getting-started)
  - [Branching](#branching)
  - [Documentation](#documentation)
    - [Known Nuances](#known-nuances)
  - [Building and Running Tests](#building-and-running-tests)
    - [Prerequisites](#prerequisites)
    - [Step by Step Guide](#step-by-step-guide)
      - [Install Dependencies](#install-dependencies)
      - [Build](#build)
      - [Run Tests](#run-tests)
    - [Deployment Process](#deployment-process)
    - [Deployment Verification](#deployment-verification)
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
- [Deep Dive into Our Smart Contracts](https://intuition.gitbook.io/intuition-contracts)

### Known Nuances 

- Share prices may get arbitrarily large as deposits/withdraws occur after Vault asset and share amounts approach 0 (ie if all users have withdrawn from the Vault), but this still elegantly achieves our desired functionality  - which is, Users earn fee revenue when they are shareholders of a vault and deposit/redeem activities occur while they remain shareholders. This novel share price mechanism is used in lieu of a side-pocket reward pool for gas efficiency.
- The Admin can pause the contracts, though there is an emergency withdraw that allows users to withdraw from the contract even while paused. This emergency withdraw bypasses all fees, to reduce the surface area of attack.
- Exit fees are configurable, but have a maximum limit which they can be set to, preventing loss of user funds. Users also have the timelock window to withdraw from the contracts if they do not agree with a parameter change.
 
## Building and Running Tests

To build the project and run tests, follow these steps:

### Prerequisites

- [Node.js](https://nodejs.org/en/download/)
- [Foundry](https://getfoundry.sh)

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

### Deployment Process

To deploy the v1 smart contract system on to a public testnet or mainnet, you’ll need the following:
- RPC URL of the network that you’re trying to deploy to (as for us, we’re targeting Base Sepolia testnet as our target chain for the testnet deployments)
- Export `PRIVATE_KEY` of a deployer account in the terminal, and fund it with some test ETH to be able to cover the gas fees for the smart contract deployments
- For Base Sepolia, there is a reliable [testnet faucet](https://alchemy.com/faucets/base-sepolia) deployed by Alchemy
- Deploy smart contracts using the following command:

```shell
$ forge script script/Deploy.s.sol --broadcast --rpc-url <your_rpc_url> --private-key $PRIVATE_KEY
```

### Deployment Verification

To verify the deployed smart contracts on Basescan, you’ll need to export your Basescan API key as `ETHERSCAN_API_KEY` in the terminal, and then run the following command:

```shell
$ forge verify-contract <0x_contract_address> ContractName --watch --chain-id <chain_id>
```

**Notes:**
- When verifying your smart contracts, you can use an optional parameter `--constructor-args` to pass the constructor arguments of the smart contract in the ABI-encoded format
- The chain ID for Base Sepolia is `84532`, whereas the chain ID for Base Mainnet is `8453`

## Deployments

### Base Sepolia Testnet

| Name | Proxy | Implementation | Notes |
| -------- | -------- | -------- | -------- |
| [`AtomWallet`](https://github.com/0xIntuition/intuition-contracts/blob/main/src/AtomWallet.sol) | [`0xf63c18b4588B1e62c099F0D8ED65Db269629B8F3`](https://sepolia.basescan.org/address/0xf63c18b4588B1e62c099F0D8ED65Db269629B8F3) | [`0x486f7B47F33e7B0f89639B33616e2a6a2C425982`](https://sepolia.basescan.org/address/0x486f7B47F33e7B0f89639B33616e2a6a2C425982) | Atom Wallets: [`BeaconProxy`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/proxy/beacon/BeaconProxy.sol) <br /> Atom Wallet Beacon: [`UpgradeableBeacon`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/proxy/beacon/UpgradeableBeacon.sol) |
| [`EthMultiVault`](https://github.com/0xIntuition/intuition-contracts/blob/main/src/EthMultiVault.sol) | [`0xa522FB1c1c5590b49019Ac14D5f0A6cBbCDB467A`](https://sepolia.basescan.org/address/0xa522FB1c1c5590b49019Ac14D5f0A6cBbCDB467A) | [`0x72D269f3A45aA2c7B3ed2307b0275bf20c409E87`](https://sepolia.basescan.org/address/0x72D269f3A45aA2c7B3ed2307b0275bf20c409E87) | Proxy: [`TUP@5.0.2`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/proxy/transparent/TransparentUpgradeableProxy.sol) |
| [`ProxyAdmin`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/proxy/transparent/ProxyAdmin.sol) | - | [`0x4d763645831394CA2F8d254b44c71b7646C0b8Be`](https://sepolia.basescan.org/address/0x4d763645831394CA2F8d254b44c71b7646C0b8Be) | Used for upgrading `EthMultiVault` proxy contract |
| [`TimelockController`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/governance/TimelockController.sol) | - | [`0x27314baDD2eB0a2C11917fA5eebcD2AA324A2bb1`](https://sepolia.basescan.org/address/0x27314baDD2eB0a2C11917fA5eebcD2AA324A2bb1) | Owner of the `ProxyAdmin` and `AtomWalletBeacon` |
| [`CustomMulticall3`](https://github.com/0xIntuition/intuition-contracts/blob/main/src/utils/CustomMulticall3.sol) | [`0xa5afBC0b53059921B2875dF24a619ffB866148C8`](https://sepolia.basescan.org/address/0xa5afBC0b53059921B2875dF24a619ffB866148C8) | [`0x937cED115a20720DD41FcaCb3c337d9a9F9561b0`](https://sepolia.basescan.org/address/0x937cED115a20720DD41FcaCb3c337d9a9F9561b0) | Proxy: [`TUP@5.0.2`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/proxy/transparent/TransparentUpgradeableProxy.sol) | 
| [`ProxyAdmin`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/governance/TimelockController.sol) | - | [`0x75039238162Cdb4cDc8d728a996C7394A361000A`](https://sepolia.basescan.org/address/0x75039238162Cdb4cDc8d728a996C7394A361000A) | Used for upgrading `CustomMulticall3` proxy contract |
