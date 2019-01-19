The contract is based on  [ERC-721](http://erc721.org/) open standard that describes how to build non-fungible or unique tokens on the Ethereum blockchain.

A dog owner (someone from animal rescue organization) posts a dog for an adoption (dog owner info and dog picture) via Ethereum smart contract. A dog owner should be certain that a possible dog adopter already owned a dog (dog adopter info and dog picture) before bringing a new dog home. 

The smart contract follows common principals and one of them is  [Withdrawal](https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html#withdrawal-from-contracts) pattern. Instead of proactively sending money to dog adopters we use withdraw pattern which helps us to avoid re-entrance bugs that could cause unexpected behavior including financial loss. We should only send ETH to a dog adopter when they explicitly request it. 

Time in Solidity is a bit tricky – block timestamps are set by miners, and are not necessarily safe from spoofing. A best practice is to demarcate time based on block number. We know that Ethereum blocks are generated roughly  every 15 seconds so we can infer timestamps from these numbers rather than the spoofable timestamp fields.

It is always better to start developing Ethereum Smart contracts in  [Remix](https://remix.ethereum.org). Remix is a suite of tools to interact with the Ethereum blockchain in order to develop, test, debug and deploy smart contracts and much more.

Go to [Dog Adoption Smart Contract Remix Video](https://youtu.be/mziWxy2k_pE) page

Go to [Dog Adoption description ](https://ashot72.github.io/solidity-ERC-721--dogadoption-contract/index.html) page 

Go to [Dog Adoption dApp based on this contract](https://github.com/Ashot72/Dog-Adoption-dApp) page 


