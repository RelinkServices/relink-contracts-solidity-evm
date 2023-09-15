import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@typechain/hardhat";
import "@typechain/ethers-v5";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-docgen";
import "@nomicfoundation/hardhat-chai-matchers";

require("./hardhat/scripts");

dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.14",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100,
          },
        },
      },
      {
        version: "0.4.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100,
          },
        },
      },
    ],
  },
  networks: {
    proxyMainnet: {
      url: process.env.PROXY_MAINNET_RPC_URL || "",
      accounts:
        process.env.PROXY_MAINNET_PRIVATE_KEY !== undefined
          ? [process.env.PROXY_MAINNET_PRIVATE_KEY]
          : [],
    },
    proxyTestnet: {
      url: process.env.PROXY_TESTNET_RPC_URL || "",
      accounts:
        process.env.PROXY_TESTNET_PRIVATE_KEY !== undefined
          ? [process.env.PROXY_TESTNET_PRIVATE_KEY]
          : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
    gasPrice: Number(process.env.GAS_PRICE) ?? 100,
    showMethodSig: true,
    showTimeSpent: true,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
    root: "./hardhat",
  },
  typechain: {
    outDir: "./typechain",
    target: "ethers-v5",
  },
  docgen: {
    runOnCompile: false,
    clear: true,
    except: ["test"],
  },
  etherscan: {
    apiKey: process.env.HARDHAT_ETHERSCAN_API_KEY, // no API key needed for fantom
  },
};

export default config;
