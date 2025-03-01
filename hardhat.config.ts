import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";
import dotenv from "dotenv";

dotenv.config();

const {
  SEPOLIA_URL,
  BASE_SEPOLIA_URL,
  ETHERSCAN_API_KEY,
  ACCOUNT_PRIVATE_KEY,
  BLOCKSCOUT_API_KEY,
} = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  sourcify: {
    enabled: true,
  },
  networks: {
    sepolia: {
      url: SEPOLIA_URL,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    base_sepolia: {
      url: BASE_SEPOLIA_URL,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY!,
      base_sepolia: BLOCKSCOUT_API_KEY!,
    },
    customChains: [
      {
        network: "base_sepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://base-sepolia.blockscout.com/api",
          browserURL: "https://base-sepolia.blockscout.com",
        },
      },
    ],
  },
};

export default config;
