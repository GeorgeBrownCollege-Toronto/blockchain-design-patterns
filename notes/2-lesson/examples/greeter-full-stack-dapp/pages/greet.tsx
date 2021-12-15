import { useEffect, useState } from "react";
import { ethers } from "ethers";
import Link from "next/link";
import Layout from "../components/Layout";
import { Web3Provider } from "@ethersproject/providers";
import { Contract } from "@ethersproject/contracts";
import { abi as GreeterABI } from "../artifacts/contracts/Greeter.sol/Greeter.json";

const address = "0x1d80895db5567d4752fc052eb272fa3270c7e363";

export default function GreetPage() {
  const [greetingValue, setGreetingValue] = useState<string>("");
  const [account, setAccount] = useState<string>("");
  const [balance, setBalance] = useState<string>("");
  const [provider, setProvider] = useState<Web3Provider>();
  const [greeterInstance, setGreeterInstance] = useState<Contract>();
  const [displayGreetingMessage, setDisplayGreetingMessage] = useState<string>("");

  async function handleInit() {
    if (typeof window !== "undefined") {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAccount(accounts[0]);
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setProvider(provider);
      const balance = await provider.getBalance(accounts[0]);
      setBalance(ethers.utils.formatEther(balance));
      const greeterInstance = new ethers.Contract(
        address,
        GreeterABI,
        provider.getSigner()
      );
      setGreeterInstance(greeterInstance);
      fetchGreeting()
    }
  }

  useEffect(() => {
    handleInit();
  }, []);

  async function fetchGreeting() {
    console.log(await greeterInstance?.greet());
    setDisplayGreetingMessage(await greeterInstance?.greet())
  }

  async function setGreeting() {
    const tx = await greeterInstance?.setGreeting(greetingValue, {
      from: account,
    });
    await tx.wait();
    await fetchGreeting();
  }

  return (
    <Layout title="Greet | Next.js + hardhat + ethers.js ">
      <h1>Greet</h1>
      <p>This is my first DApp</p>
      <p>Greeting Message : {displayGreetingMessage}</p>
      <button onClick={fetchGreeting}>Fetch Greeting</button>
      <br />
      <br />
      <input
        onChange={(e) => setGreetingValue(e.target.value)}
        placeholder="e.g. Hello, World!"
      />
      <button onClick={setGreeting}>Set Greeting</button>

      <p>Account Address : </p>
      <p>{account}</p>
      <p>{balance} ETH</p>

      <p>
        <Link href="/">
          <a>Go home</a>
        </Link>
      </p>
    </Layout>
  );
}
