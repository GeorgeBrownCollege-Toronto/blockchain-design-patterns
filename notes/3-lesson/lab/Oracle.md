## Oracle lab

* In this lab, you are supposed to

    - Create a Smart Contract
    - Create an Express (or NestJS) server app
    - Call a REST (or GraphQL) interface to get data
    - Create a simple React (or NextJS) app
    - Call server from client to get data
    - Write the data to the smart contract
    - Read back from the smart contract

### Oracle Smart Contract

- Use Remix and Metamask
- Create state data

```sol
/// quote structure
struct stock {
    uint price;
    uint volume;
}

/// quotes by symbol
mapping( bytes4 => stock) stockQuote;

/// Contract owner
address oracleOwner;
```

- Create functions

```
/// Set the value of a stock
function setStock(bytes4 symbol, uint price, uint volume) public {
    // ...
}

/// Get the value of a stock
function getStockPrice(bytes4 symbol) public view returns (uint) {
    // ...
}
/// Get the value of volume traded for a stock
function getStockVolume(bytes4 symbol) public view returns (uint) {
    // ...
}
```

- Test in Remix

### Oracle Express.js server app

- Use the Express app generator

```
$ npx express-generator
$ cd myapp
$ npm install axios
$ npm start
```

- Make call to your REST API to gather data

### REST call

- Register for your free access to REST call https://www.alphavantage.co/

```js
fetch(
  "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=MSFT&apikey=KEY"
)
  .then((res) => res.json())
  .then((data) => {
    this.setState({ quote: data["Global Quote"] });
  })
  .catch(console.log);
```

### Oracle React App

- Install and run Ganache locally
- Create new app with `create-react-app`

```
$ npx create-react-app new-oracle
$ cd new-oracle
$ npm start
$ npm install web3
```

### Connect React to Smart Contract using Web3

- Get a copy of your ABI and contract address from remix
- Put them in a file that we can use like `src/quotecontract.js`

```js
export const STOCK_ORACLE_ADDRESS = '0x0YOURADDRESS'
export const STOCK_ORACLE_ABI = [ ... YOUR ABI ... ]
```

- Import in the stuff we need to connect

```js
import Web3 from "web3";
import { STOCK_ORACLE_ABI, STOCK_ORACLE_ADDRESS } from "./quotecontract";
const web3 = new Web3("http://localhost:7545");
const accounts = await web3.eth.getAccounts();
console.log("Account 0 = ", accounts[0]);
const stockQuote = new web3.eth.Contract(
  STOCK_ORACLE_ABI,
  STOCK_ORACLE_ADDRESS
);
var retval = await stockQuote.methods
  .getStockPrice(web3.utils.fromAscii("AAAA"))
  .call();
console.log(retval);
```

### React Interface

* Create an interface in React
    * Ask for stock symbol
    * Lookup symbol using REST call
    * Write it to smart contract using `setStock` call
    * Read back and display results from smart contract using `getStockPrice`, `getStockVolume`
    * Verify that it works by using `getStockPrice`, `getStockVolume` on remix with the symbol

### Submission Requirements
* Commit the changes in a **private** GitHub repository and provide read-only access to [@dhruvinparikh](https://github.com/dhruvinparikh)
* Submit the GitHub repository url to BB