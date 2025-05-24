import { ethers } from "ethers";
import axios from "axios";
import * as dotenv from "dotenv";

dotenv.config();

const SNOWSCAN_API_KEY = process.env.SNOWSCAN_API_KEY;

const provider = new ethers.JsonRpcProvider("https://api.avax-test.network/ext/bc/C/rpc");

async function getABI(address: string, isTestnet: boolean = true): Promise<ethers.InterfaceAbi> {
    const baseUrl = isTestnet ? "https://api-testnet.snowscan.xyz/api" : "https://api.snowscan.xyz/api";
    const response = await axios.get(`${baseUrl}?module=contract&action=getabi&address=${address}&apikey=${SNOWSCAN_API_KEY}`);
    if (response.data.status === "1" && response.data.result) {
        try {
            return JSON.parse(response.data.result);
        } catch (e) {
            console.error("Error parsing JSON:", e);
            throw new Error("Error parsing ABI");
        }
    } else {
        throw new Error("Error Snowscan API : " + response.data.message);
    }
}

async function main() {
    try {
        // MiddlewareL1
        const MiddlewareL1 = "0xbf9e863cF9F00f48D3Ed9D009515114365502569";
        const abi1 = await getABI(MiddlewareL1);
        const MiddlewareL1_contract = new ethers.Contract(MiddlewareL1, abi1, provider);

        // CollateralFactory
        const CollateralFactory = "0x6441cA48f9d19E68e8AEb572De5c4836f8329903";
        const abi2 = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"ERC1167FailedCreateClone","type":"error"},{"inputs":[],"name":"EntityNotExist","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"entity","type":"address"}],"name":"AddEntity","type":"event"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"initialLimit","type":"uint256"},{"internalType":"address","name":"limitIncreaser","type":"address"}],"name":"create","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"index","type":"uint256"}],"name":"entity","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"entity_","type":"address"}],"name":"isEntity","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalEntities","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];
        const CollateralFactory_contract = new ethers.Contract(CollateralFactory, abi2, provider);

        // VaultFactory
        const VaultFactory = "0xC3b09a650c78daFb79e3C5B782402C8dc523fE88";
        const abi3 = await getABI(VaultFactory);
        const VaultFactory_contract = new ethers.Contract(VaultFactory, abi3, provider);

        return {
            MiddlewareL1_contract,
            CollateralFactory_contract,
            VaultFactory_contract
        };
    } catch (error) {
        console.error("Error:", error);
        throw error;
    }
}

export const contracts = main();





