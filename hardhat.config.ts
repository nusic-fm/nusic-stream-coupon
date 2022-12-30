import { task } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";
import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'
import 'hardhat-contract-sizer';
import "@nomiclabs/hardhat-etherscan";
//import "hardhat-gas-reporter";
import dotenv from 'dotenv';

dotenv.config();

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const PRIVATE_KEY = process.env.PRIVATE_KEY;
//const ALCHEMY_KEY = process.env.ALCHEMY_KEY;
//const ALCHEMY_KEY_GOERLI = process.env.ALCHEMY_KEY_GOERLI;
const PROD_PRIVATE_KEY = process.env.PROD_PRIVATE_KEY;
//const ALCHEMY_MAINNET_KEY = process.env.ALCHEMY_MAINNET_KEY;
const ALCHEMY_KEY_MUMBAI = process.env.ALCHEMY_KEY_MUMBAI;
const ALCHEMY_KEY_POLYGON_MAINNET = process.env.ALCHEMY_KEY_POLYGON_MAINNET;


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  solidity: {
    compilers: [
        {
            version: "0.8.4",
            settings: {
                metadata: {
                    bytecodeHash: "none",
                },
                optimizer: {
                    enabled: true,
                    runs: 1337,
                },
            },
        },
    ],
    settings: {
        outputSelection: {
            "*": {
                "*": ["storageLayout"],
            },
        },
    },
  },
  paths: {
    artifacts: "build/artifacts",
    cache: "build/cache",
    deploy: "src/deploy",
    sources: "contracts",
  },
  networks: {
    /*
    localhost: {
      url:' http://127.0.0.1:8545/'
    },
    */
    
    moonbase: {
      url: 'https://rpc.api.moonbase.moonbeam.network',
      chainId: 1287, // (hex: 0x507),
      //accounts: [`0x${PRIVATE_KEY}`]
      accounts: [`0x${PRIVATE_KEY}`]
    },
    
    /*
    moonriver: {
      url: 'https://rpc.api.moonriver.moonbeam.network',
      chainId: 1285, // (hex: 0x507),
      //accounts: [`0x${PRIVATE_KEY}`]
      accounts: [`0x${PRIVATE_KEY}`]
    },
    */
    /*
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${ROPSTEN_PRIVATE_KEY}`]
    },*/
    /*
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    */
    /*
    matic: {
      url: "https://matic-mumbai.chainstacklabs.com",
      accounts: [`0x${PRIVATE_KEY}`]
    },
    */
    matic: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_KEY_MUMBAI}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    /*
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_KEY_GOERLI}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    */

    polygon: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_KEY_POLYGON_MAINNET}`,
      accounts: [`0x${PROD_PRIVATE_KEY}`]
    },
    
    /*
    mainnet: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_MAINNET_KEY}`,
      accounts: [`0x${PROD_PRIVATE_KEY}`]
    }*/
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    //apiKey: process.env.MAINNET_ETHERSCAN_API_KEY
    apiKey: process.env.POLYSCAN_API_KEY
    //apiKey: process.env.MOONRIVER_ETHERSCAN_API_KEY
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 21
  }
};