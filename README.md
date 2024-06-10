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
    - [Deployment Process](#deployment-process)
    - [Deployment Verification](#deployment-verification)

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

- Share prices are weird, but elegantly achieve our desired functionality - which is, Users earn fee revenue when they are shareholders of a vault and other users deposit/redeem from the vault while they remain shareholders. This novel share price mechanism is used in lieu of a side-pocket reward pool for gas efficiency.
  - For example: User A deposits 1 ETH into a vault with a share price of 1 ETH. There is a 5% entry fee applied. User receives 0.95 shares. Assuming no other depositors in the vault, the Vault now has 1 ETH and 0.95 shares outstanding -> share price is now 1.052.
  - User A now redeems their shares from the pool, paying a 5% exit fee to the vault. The vault now has 0.05 ETH and 0 shares; for this reason, we mint some number of 'ghost shares' to the 0 address upon vault instantiation, so that the number of outstanding shares will never be 0; however, because of the small number of outstanding 'ghost' shares, share price becomes arbitrarily high because of the large discrepancy between [Oustanding Shares] and [Assets in the Vault]. 

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
