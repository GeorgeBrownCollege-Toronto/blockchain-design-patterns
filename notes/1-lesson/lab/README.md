## Escrow Lab

* Write an escrow Smart Contract which helps users facilitate transactions. Alice should be able to deposit funds in the Smart Contract while Bob should be able to withdraw the previously deposited funds by Alice.

* The Escrow smart contract will have an `Agent` Role. (Typically Deployer of the Escrow contract)
* The Escrow smart contract will have an `Sender` Role. (Account address of Alice)
* The Escrow smart contract will have an `Receiver` Role. (Account address of Bob)

* Add a timelock feature where Bob can no more withdraw the funds after number of blocks has elapsed since the Escrow contract deployment. Alice can then get the funds back from the contract. (Make sure Alice should not be able to be to claim the funds back before the timelock period)

## Mandatory Submission Requirements
* IDE : Hardhat
* Unit tests required with 100% code coverage
* Use OpenZeppelin's [`AccessControl.sol`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/4961a51cc736c7d4aa9bd2e11e4cbbaff73efee9/contracts/access/AccessControl.sol).
* Upload the project to your GitHub in a **PRIVATE** repository and invite @dhruvinparikh with a to have read access to the repository for Escrow lab.
* Submit the the Repository link to BB as a part of submission