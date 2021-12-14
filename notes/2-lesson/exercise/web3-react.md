## wallet integration using web3-react
In this exercise, you will learn integrating wallet using Uniswap’s Noah Zinmeister’s [web3react](https://github.com/NoahZinsmeister/web3-react) library 

Table of Contents
* [Initial Setup](#Initial-Setup)
* [Wallet and Provider Connectors](#Wallet-and-Provider-Connectors)
* [Connecting Wallets](#Connecting-Wallets)
* [Connecting with the Wallet](#Connecting-with-the-Wallet)
* [Interacting with Wallets and Providers](#Interacting-with-Wallets-and-Providers)
* [Disconnecting a Wallet](#Disconnecting-a-Wallet)
* [Web3React API Reference](#Web3React-API-Reference)
  * [`connector`](#connector)
  * [`account`](#account)
  * [`activate`](#activate)
  * [`active`](#active)
  * [`chainId`](#chainId)
  * [`deactivate`](#deactivate)
  * [`error`](#error)
  * [`provider`](#provider)
  * [`setError`](#setError)
  * [Custom Functions](#Custom-Functions)
* [Conclusion](#Conclusion)

### Initial Setup

The first thing you'll need to do is install the `web3react` packages. You'll always need the `core` package, and will also need the `web3react` connectors for any wallets you plan on integrating. Wallet connectors is covered separately [here](#Wallet-and-Provider-Connectors). For core, if you're using Yarn, you'd use:
```
$ yarn add @web3-react/core
```

if you're using npm, you'd use:
```
npm install --save @web3-react/core
```

In order to make use of `web3react` inside your React app, you'll need to do a few things inside the `App` component:
* import the `Web3ReactProvider` from `@web3-react/core`
* wrap the app with a special `Web3ReactProvider` component
* add a `getLibrary` function

Your `App` component might look something like this:
```typescript
import { Web3ReactProvider } from '@web3-react/core'
import { Web3Provider } from "@ethersproject/providers";

function getLibrary(provider, connector) {
  return new Web3Provider(provider);
}

const App => () {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <YourAwesomeComponent />
    </Web3ReactProvider>
  )
}
```
(This example is loosely based on the `web3react` [docs](https://github.com/NoahZinsmeister/web3-react/tree/v6/docs#web3reactprovider).) The code above assumes that you're using [Ethers.js](https://docs.ethers.io) (specifically the [`Web3Provider`](https://docs.ethers.io/v5/api/providers/other/#Web3Provider) from Ethers), but the same can be done in web3.js. The idea is that you need to import a provider (generally via Ethers or Web3.js in the JavaScript/TypeScript space), and then instantiate and return it in the `getLibrary` function.

### Wallet and Provider Connectors

Wallets and web3 providers (such as Infura) connect to an app in `web3react` via a `connector`.  If you wish to add a new wallet or provider, there is likely already a web3react package to aid the process. There is a list of packages on the landing page of the GitHub repo ([here](https://github.com/NoahZinsmeister/web3-react)).

### Connecting Wallets

We'll describe the process of connecting a wallet using `web3-react`, and also use MetaMask and Portis as examples with code snippets.

First you'll need to get the connector for the desired wallet from the `web3-react` repo. You can find the code for the connectors [here](https://github.com/NoahZinsmeister/web3-react/tree/v6/packages), though each is also its own npm package, and should be added to your project using Yarn or NPM, installing each separately as needed. 

If we wanted MetaMask, we would get the package using `yarn add @web3-react/injected-connector`. (The `injected-connector` isn't specific to MetaMask - any wallet which works by injecting itself into the browser (like Brave) will also use this package.) For Portis, it would be `yarn add @web3react/portis-connector`.

Each wallet needs its own unique instantiation details. In this exercise, we have mentioned about wallet connect example. For more details, head over to the package details in the `web3-react` repo.

We'll start with the Portis example since most other wallets follow the same pattern. We'd head over to the [`portis-connector` directory](https://github.com/NoahZinsmeister/web3-react/tree/v6/packages/portis-connector). In the `src/` directory there we can see an `index.ts` file, which has a TypeScript interface called `PortisConstructorArguments`. These are the arguments you'll need when creating a Portis connector inside your app:
```typescript
interface PortisConnectorArguments {
  dAppId: string
  networks: Network[]
  config?: any
}
```
MetaMask (and other injected wallets) work a bit differently than most of the other connectors, as its only argument is an array called `supportedchainIds`, which, as its name implies, is a list of `chainId` numbers the dapp should support. 

| Network | Chain Id |
|---------|----------|
| Mainnet | 1|
| Kovan | 42|
| Rinkeby | 4 |
| Ropsten | 3 |
|Goerli | 5 |

```typescript
export interface AbstractConnectorArguments {
  supportedChainIds?: number[]
}
```
We'll need this information in a minute.

To connect MetaMask in your app, import the injected connector:
```typescript
import { InjectedConnector } from '@web3-react/injected-connector'
```
For Portis:
```typescript
import { PortisConnector } from '@web3-react/portis-connector'
```
This is something you'll want to have run when your app instantiates (most likely), and you'd like it to be available anywhere in your app that interacts with the blockchain. As a result, in a global state store or high up in the tree make sense.

As mentioned before, the only argument is an array of `supportedChainId`s. If we're testing on Goerli, this means all we'd need to add is:
```typescript
export const injectedProvider = new InjectedConnector({ supportedChainIds: [5] });
```
(`chainId 5` is the Goerli testnet, you can replace that with whatever chain you want to work with or add several if your app is deployed on more than one network.)

Portis has more arguments. For one, you'll need to set up a dApp ID at [Portis](https://portis.io). The optional config argument is specified in [their docs](https://docs.portis.io/#/configuration); it allows you to set a number of options, and is worth checking out if you're building with Portis. `network` works identically to `supportedChainIds` in the injected connector - it's an array of `chainId` numbers to be supported.
```typescript
export const portis = new PortisConnector({ 
  dAppId: "YOUR_DAPP_ID",
  network: [5] 
});
```
Next, if you are instantiating the connector in one place, but need access to the wallet in another, import your wallet wherever you need it like this:
```typescript
import { injectedProvider, portis } from "wherever/you/put/the/connector/instantiation";
```
### Connecting with the Wallet
In order to connect with the wallet we've added, you'll need to form a `handleConnect` function, which takes a connector as an argument. There is an example of how you might want a function like this to look.

We'll assume you're using [web3.js](https://web3js.readthedocs.io/en/v1.3.4/index.html), and that you have a connection to [Infura](https://infura.io), [Alchemy](https://alchemy.com), or a similar provider in order to instantiate a provider, and that you're storing your API key using `dotenv`. (If you don't, go and set up a free account by either.) If you're using this snippet, make sure the entire endpoint URL is in the `.env` file, like `https://eth-goerli.alchemyapi.io/v2/deadbeef_deadbeef_deadbeef`.
```typescript
const handleConnect = (connector: any) => {
    // read-only
    let web3 = new Web3(new Web3.providers(proccess.env.API_ENDPOINT));
    await activate(connector);
    let { provider } = await connector.activate();
    // signer
    web3 = new Web3(provider); 
}
```
If you're using [ethers](https://docs.ethers.io):
```typescript
import { Web3Provider } from '@ethersproject/providers';

const handleConnect = (connector: any) => {
    // read-only
    let ethersProvider = new ethers.providers.JsonRpcProvider(proccess.env.API_ENDPOINT);
    let { provider } = await connector.activate();
    // signer
    const signer = provider.getSigner();
    ethersProvider = new Web3Provider(signer);
}
```
This is a very basic function - there's a good chance that you'll want to add some functionality to it, like reloading contracts once there's a signer attached, or a `try/catch` for disconnecting the wallet on a failed connection attempt. From a UI perspective, there are also intermediate states that you'll want to handle, like connecting (to provide a spinner) and the like.

### Interacting With Wallets and Providers

Once you have a connected provider and/or wallet, `web3react` gives you a number of modules for interacting with the wallet. In any component interacting with the wallet, first import `useWeb3React`:
```typescript
import { useWeb3React } from "@web3-react/core";
```
Then destructure the relevant modules from `web3react` like so:
```typescript
const {
    account,
    activate,
    active,
    chainId,
    connector,
    deactivate,
    error,
    provider,
    setError,
} = useWeb3React();

```
We'll give a detailed rundown of what you can do with this in the section called [Web3React API Reference](#web3react-api-reference). Before we get to that, we'll detail how to disconnect a wallet.

### Disconnecting a Wallet

`web3react` provides two different functions for disconnecting a wallet: `deactivate` and `close` before. You can see `deactivate` in the code above - it can be destructured directly from the object you get when you call `userWeb3React`. `close` is a custom function that most, but not all, wallets have. Unfortunately, it can be hard to know which to call when. In addition, MetaMask and the injected connectors do not have a `close` function, which can cause an error if it is called, and some wallets will not be cleared from the DOM _unless_  `close` is called, meaning that you cannot rely on `deactivate`. As a result, you may want to implement a generic `disconnectWallet` function which ensures that the right functions are called for disconnecting the wallet fully.

### Web3React API Reference

It's worth noting that since we're using `web3react`, all wallet interactions should now go through `web3react` using `web3react`'s syntax, as opposed to using the wallet's own API.

#### `connector`

This object represents that `connector` that is connected right now. It extends `Abstract-Connector`. 

A number of the functions that `connector` exposes are also available directly through `useWeb3React()`, even without using `connector` directly. The rest of the functions that `connector` expose can change from wallet to wallet - not everything here will necessarily be implemented in every wallet, and the functions might behave differently from wallet to wallet. One particularly pertinent example is the `connector.close()` functions, which removes a wallet from the DOM. This can mean needing various checks when calling these functions, such as a `try/catch` or an `if` checking which wallet is connected (`if connector === walletConnect`, for example). We discussed disconnecting wallets in more detail above, in the [Disconnecting a Wallet](#Disconnecting-a-Wallet) section.

If a `supportedChainIds` array was provided when the wallet was instantiated (highly recommended), it is also available through `connector.supportedChainIds`.

In addition, there are a number of outputs sent to the console from `connector`. You can see these in the abstract class [here](https://github.com/NoahZinsmeister/web3-react/blob/v6/packages/abstract-connector/src/index.ts).

#### `account`

_(Also accessible as `connector.getAccount()`)_

This is the address of the connected wallet - anytime you need the user's address, you can use `account`.
```typescript
const displayAddress = () => (
  <div>Your address is: {account}</div>
)
```
#### `activate`

_(Also accessible as `connector.activate(<WALLET_NAME>)`)_

Used when connecting a new wallet. If you have a `walletConnect` built from `WalletConnectConnector`:
```typescript
activate(walletConnect);
```
This is used in the example above for connecting a wallet.

#### `active`

A boolean showing if the user has a connected wallet, useful in conditional rendering.
```typescript
if(active){
  ...
} // or:
active && <PaymentModal>
```
#### `chainId`

_(Also accessible as `connector.getChainId()`)_

Number representation of the `chainId` the user is connected to. Useful for only displaying modals when the user is connected to supported networks, or displaying an alert when they are not.

For a comprehensive list of chains (both production and test networks), see [ChainList](https://chainlist.org/).
```typescript
if(chainId === 1){
  return <PaymentModal>
} else {
  return <>Please connect to Ethereum's Mainnet</>
}
```

#### `deactivate`

_(Also accessible as `connector.deactivate()`)_

Deactivate disconnects the wallet from the app. It is important to note that if the wallet has injected an iframe (like Portis, for example), it will not be removed from the DOM, which can lead to issues if the user tries to reconnect. In these cases, it is better to use `connector.close()`. We'll discuss disconnecting the user separately.
```typescript
const disconnect = () => (
  <button onClick={deactivate}>Disconnect</button>
)
```
#### `error`

The `error` library exposes a number of potential errors that it recognizes. It does not stop execution when they are triggered, but rather gives the architect room to catch each error and customize how the application should react to it.

Most of these errors vary from wallet to wallet, and unfortunately not all are documented. Here one example is given for an idea of how they work and then list errors from MetaMask/injected providers and Portis.

Most dApps support some chains (generally mainnet and some testnets), but not all. Properly identifying if the user is on a supported chain is a critical part of good UX in a dApp. `web3-react` exposes a `UnsupportedChainIdError` that allows you to detect when a user is on an unsupported chain.

This error relies on an array of supported chains being supplied when the wallet is instantiated. You can pass in a supportedChainIds as an argument when instantiating a wallet, an array of numbers.  This, or something like it, is either a mandatory or optional argument for every connector/wallet that `web3-react` recognizes. This example assumes you've passed in an array with supported chains.

First, import the error:
```typescript
import { UnsupportedChainIdError } from '@web3-react/core';
```
Then destructure it from the `useWeb3React` object:
```typescript
const {
  // whichever other web3-react libraries you need,
  chainId,
  error
} = useWeb3React();
```
Now if you wanted to have a specific reaction in the app, you can now use it. (Remember that `supportedChainIds` is an optional argument.) Here's one example:
```typescript
if(Boolean(connector.supportedChainIds) && !connector.supportedChainIds.includes(chainId)) {
  throw new UnsupportedChainIdError(chainId, connector.supportedChainIds);
}
```
The other globally available error is `StaleConnectorError`.

There are also custom errors depending on your wallet. We'll list MetaMask's:

 - `NoEthereumProviderError`: used when an injected provider is expected to be there but isn't ([example](https://github.com/NoahZinsmeister/web3-react/blob/v6/packages/injected-connector/src/index.ts#L70))
 - `UserRejectedRequestError`: used if the user rejects a transaction through the injected provider

**Portis** does not have any custom errors.

#### `provider`

_(Also accessible as `connector.getProvider()`)_

This is the same as the concept of a provider in web3.js. It also contains a signer unlike the Ethers paradigm where the provider and signer are two separated entities. This means that when using web3, the `provider` is passed in at contract instantiation, but with Ethers a simple provider (for example, using `ethers.getDefaultProvider()`) is sufficient for instantiating a contract, but the `web3react` provider will need to be connected to send transactions. (This might be a bit confusing. There is a dedicated section for working with contracts in Warp Core later.)
```typescript
myContract.connect(provider).myFunction{ value: 1 }(); //ethers
myContract = new web3.Contract(abi, address, provider); // web3
```
#### `setError`

`setError` takes an `Error` as an argument. `Error` is a built-in TypeScript type:
```typescript
interface Error {
    name: string;
    message: string;
    stack?: string;
}
```
When called, it reloads `web3react`. This is used internally in the library when errors happen - `web3react` will call `setError` and try to reload. You can also use this manually if you'd like to create a custom error which will then be available throughout the project.

You can set a new error type like this

```typescript
const { setError } = useWeb3React();

setError({ name: "fooError", message: "you got a foo error"});
```
Then you can use that error anywhere in the app:
```typescript
const { error } = useWeb3React();

if(error && error.name === "fooError"){
  doSomething();
}
```

#### Custom Functions

In addition to the global functions above, some wallets (connectors) have their own unique functions exposed by `web3react`. These can be very important. `close()`, for example, will fully clear DOM-based wallets from the DOM, which `deactivate()` will not. 

If you'd like to find the custom functions for a given wallet, as of this writing you will need to actually look through the code of the connector to see what's there. The directory of all the connectors is [here](https://github.com/NoahZinsmeister/web3-react/tree/v6/packages). For example, if we're looking to see if there are any special functions for Portis, we'd go to the [Portis connector](https://github.com/NoahZinsmeister/web3-react/blob/v6/packages/portis-connector/src/index.ts), where we'd see the global (public) functions (`activate`, `getProvider`, `getChainId`, `getAccount`, `deactivate`), and then also a[`changeNetwork`](https://github.com/NoahZinsmeister/web3-react/blob/v6/packages/portis-connector/src/index.ts#L115) and [`close`](https://github.com/NoahZinsmeister/web3-react/blob/v6/packages/walletconnect-connector/src/index.ts#L126) function.

### Other Resources

* The go-to interface for integrating wallet to the web application is Pedro Gomes's [web3modal](https://github.com/web3modal/web3modal), which is an excellent resource as well.

* Another library for rapid development is Ethwork's [useDApp](https://github.com/EthWorks/useDApp). This is also worth taking a look.


##### Reference
* [web3-react documentation](https://github.com/NoahZinsmeister/web3-react/tree/v6/docs)
[Beginner Example](https://github.com/NoahZinsmeister/web3-react/tree/v6/example)
* [How to use Web3React in your Next project](https://hackmd.io/Ykpp1MWLTjixIZG2ZJEShA?view)