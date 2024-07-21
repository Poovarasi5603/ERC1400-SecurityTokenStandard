# ERC1400-SecurityTokenStandard

**Overview**
This project involves creating a decentralized exchange (DEX) that facilitates the handling of multiple security tokens using the ERC1400 token standard, along with ERC1594 and ERC1643 substandards. The platform is designed to support startup companies by allowing them to list their projects on the DEX. Retail investors can invest in these startups by purchasing security tokens, thus providing capital for innovative projects. The platform also enables the trading of these security tokens and offers Security Token Offerings (STO) for presales.

**Key Features :**
ERC1400 Token Standard
The ERC1400 token standard ensures compliance with security regulations for handling security tokens. It integrates various functionalities required for security tokens, including partitions, off-chain data, and transfer restrictions. This compliance is crucial for adhering to legal requirements and protecting investors.

**ERC1594 Substandard:**
The ERC1594 substandard facilitates token transfers with additional verification processes. It enhances the base functionality by enabling transfer restrictions, issuance and redemption, and providing transparency through off-chain data integration. This ensures that all token transactions meet regulatory standards.

**ERC1643 Substandard:**
The ERC1643 substandard allows for the storage and management of documentation related to the security tokens. This includes important documents like investor information, legal agreements, and compliance certificates. Storing these documents on-chain ensures immutability and accessibility, enhancing transparency and trust.

**Startup Support:**
The platform enables startups to list their projects and gain funding from retail investors. Startups can create and issue security tokens that represent equity or other types of investment opportunities. This democratizes access to capital, allowing retail investors to support and benefit from early-stage companies.

**Security Token Trading:**
The DEX provides a secure and efficient platform for trading security tokens. It ensures liquidity for these tokens, enabling investors to buy and sell them with ease. The trading platform incorporates features like order matching, real-time price updates, and robust security measures to protect user assets.

**Security Token Offerings (STO):**
The platform facilitates Security Token Offerings (STO) for presales of listed projects. STOs are a compliant way for startups to raise capital by issuing security tokens to investors. The platform provides tools for managing the STO process, including token issuance, investor accreditation, and regulatory compliance.

**Technologies Used:**
Solidity is the programming language used for writing smart contracts on the Ethereum blockchain. It is a statically-typed language designed for implementing smart contracts that run on the Ethereum Virtual Machine (EVM). Solidity provides the necessary tools for creating complex and secure smart contracts.

**Truffle Framework:**
Truffle is a development environment, testing framework, and asset pipeline for Ethereum. It provides a suite of tools for developing smart contracts, including a built-in smart contract compilation, linking, deployment, and binary management. Truffle simplifies the development process and ensures that smart contracts are correctly deployed and tested.

**Installation:**
```
npm install -g truffle
```

**Polygon and Sepolia Testnet:**
Polygon and Sepolia Testnet are deployment platforms used for testing the DEX. Polygon is a Layer 2 scaling solution that provides fast and low-cost transactions. Sepolia is an Ethereum testnet used for testing smart contracts in a controlled environment. Deploying on these platforms allows for thorough testing before going live on the mainnet.

**Web3.js and Ether.js:**
Web3.js and Ether.js are libraries for interacting with Ethereum smart contracts. Web3.js is a collection of libraries that allow you to interact with a local or remote Ethereum node using HTTP or IPC. Ether.js is a complete and compact library for interacting with the Ethereum blockchain and its ecosystem. Both libraries provide the necessary functions for interacting with smart contracts, including reading and writing data, handling events, and managing accounts.

**Installation:**

```
npm install web3 ethers
```

**IPFS and Pinata API:**
IPFS (InterPlanetary File System) is a protocol and peer-to-peer network for storing and sharing data in a distributed file system. Pinata API is a service that provides tools for managing files on IPFS. Using IPFS and Pinata API ensures that company documents are stored in a decentralized manner, providing security, immutability, and accessibility. This is crucial for maintaining the integrity and availability of important documents related to security tokens.

**Installation:**
```
npm install @pinata/sdk
```


