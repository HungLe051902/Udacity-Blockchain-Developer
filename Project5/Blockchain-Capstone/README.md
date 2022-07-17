# Udacity Blockchain Capstone

The capstone will build upon the knowledge you have gained in the course in order to build a decentralized housing product. 

## Getting Started 

### Install
To install, download libray for repo, run those commands in eth-contracts folder:

```npm install ``` 

### Generate proof with Zokrates (Win 10)
- Navigate to folder: ```zokrates\code\square2```
- Run zokrates with docker: ```docker run -v $(pwd):/home/zokrates/code -ti zokrates/zokrates:0.6.0 /bin/bash```
- Compile code: ```cd code```, ```~/zokrates compile -i square.code```
- Generate the Trusted Setup: ```~/zokrates setup ```
- Compute Witness: ```~/zokrates compute-witness -a 3 9```
- Generate Proof: ```~/zokrates generate-proof```
- Export Verifier: ```~/zokrates export-verifier```

### Build with
- Node v16.14.0
- Truffle v5.0.2
- Zokrates 0.6.0 

### Test 
To run test cases, go to eth-contracts folder and run:

```truffle  test ```

### Deployment to Rinkeby

# Project Resources

* [Remix - Solidity IDE](https://remix.ethereum.org/)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Truffle Framework](https://truffleframework.com/)
* [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
* [Open Zeppelin ](https://openzeppelin.org/)
* [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
* [Docker](https://docs.docker.com/install/)
* [ZoKrates](https://github.com/Zokrates/ZoKrates)
