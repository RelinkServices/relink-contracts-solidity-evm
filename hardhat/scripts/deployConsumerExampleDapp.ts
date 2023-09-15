import "@nomiclabs/hardhat-ethers/internal/type-extensions";
import { task, types } from "hardhat/config";

// npx hardhat deploy.consumer.example 0x3D5b65E984D7D3a346B8d5065Cd8b3ACA8032013 0x08A9aF3408cE11f336eAd8336a3Fd959AbB917E8 0xf4Bb2ae87C61b4a1EaADf5e6809DFb8801E22f58 --network proxyTestnet --proxy 0x5f1bf0fDCCE9fA05CeBFf3071F1573fDb2C68206 --threshold 2 // Testnet
// npx hardhat deploy.consumer.example 0x3D5b65E984D7D3a346B8d5065Cd8b3ACA8032013 0x08A9aF3408cE11f336eAd8336a3Fd959AbB917E8 0xf4Bb2ae87C61b4a1EaADf5e6809DFb8801E22f58 --network proxyMainnet --proxy 0xC8e11C15cf94a456209B7AbF110481Eb86B50C0c --threshold 2 // Mainnet
task("deploy.consumer.example")
  .setDescription("Deploys the test consumer")
  .setAction(
    async (
      input: {
        proxy: string;
        oracles: string[];
        threshold: string;
      },
      hre
    ) => {
      const factory = await hre.ethers.getContractFactory(
        "ChainlinkVRFv2DirectFundingConsumerExample"
      );
      const contract = await factory.deploy(
        input.proxy,
        input.oracles,
        input.threshold
      );
      console.log("Deployment tx:", contract.deployTransaction.hash);
      console.log("Contract address:", contract.address);
    }
  )
  .addVariadicPositionalParam(
    "oracles",
    "The oracle addresses",
    undefined,
    types.string
  )
  .addParam("proxy", "The address of the proxy", undefined, types.string)
  .addParam(
    "threshold",
    "The minimum number of oracles needed",
    undefined,
    types.string
  );
