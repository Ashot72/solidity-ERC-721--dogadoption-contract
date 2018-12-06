This is going to be a dog adoption dApp (decentralized application). A dog owner (someone from animal rescue organization) posts a dog for an adoption (dog owner info and dog picture) via Ethereum smart contract. A dog owner should be certain that a possible dog adopter already owned a dog (dog adopter info and dog picture) before bringing a new dog home. 

The contract is based on  [ERC-721](http://erc721.org/) open standard that describes how to build non-fungible or unique tokens on the Ethereum blockchain.

 The frond end of the app will be built on [Nuxt.js](https://nuxtjs.org/) (framework for Vue.js apps)  and will make use of [Vuetify.js](https://vuetifyjs.com/en/) component framework for Vue.js. 
 
 [Truffle](https://truffleframework.com/) will be chosen as a development environment to make smart contracts compilation, development, testing easier. 
 
A dog owner info and picture will be stored on  [IPFS](https://ipfs.infura.io/ipfs/) (Interplanetary File System) as Ethereum is too heavy/expensive to store large blobs like images, video etc.

We will connect to  [Rinkeby](https://www.rinkeby.io/) test network to test the app. 

We will not install a Geth or Parity node on our computer as it is not that easy and is time consuming. Instead, we will use [Infura](https://infura.io/) which is a Hosted Ethereum node cluster that lets your users run your application without requiring them to set up their own Ethereum node or wallet. 

The app will make use of  [Metamask](https://metamask.io/) browser extension which turns Google Chrome into an Ethereum browser, letting websites retrieve data from the blockchain, and letting users securely manage identities and sign transactions.

Only dog adoption Ethereum smart contract in Solidity is built at this stage, not the dApp. 
The smart contract follows common principals and one of them is  [Withdrawal](https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html#withdrawal-from-contracts) pattern. Instead of proactively sending money to dog adopters we use withdraw pattern which helps us to avoid re-entrance bugs that could cause unexpected behavior including financial loss. We should only send ETH to a dog adopter when they explicitly request it. 

Time in Solidity is a bit tricky – block timestamps are set by miners, and are not necessarily safe from spoofing. A best practice is to demarcate time based on block number. We know that Ethereum blocks are generated roughly  every 15 seconds so we can infer timestamps from these numbers rather than the spoofable timestamp fields.

It is always better to start developing Ethereum Smart contracts in  [Remix](https://remix.ethereum.org). Remix is a suite of tools to interact with the Ethereum blockchain in order to develop, test, debug and deploy smart contracts and much more.

Go to [Dog Adoption Smart Contract Remix Video](https://youtu.be/mziWxy2k_pE) page

Go to [Dog Adoption description ](https://ashot72.github.io/Nuxt2Forum/index.html) page 


