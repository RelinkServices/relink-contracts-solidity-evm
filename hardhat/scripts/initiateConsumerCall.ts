import { task, types } from "hardhat/config";
import "@nomiclabs/hardhat-ethers/internal/type-extensions";
// eslint-disable-next-line node/no-missing-import,camelcase
import { ChainlinkVRFv2DirectFundingConsumerExample__factory } from "../typechain";

task("init.consumer.request")
  .setDescription("Initiates a random number call in the test consumer")
  .setAction(
    async (
      input: {
        addr: string;
      },
      hre
    ) => {
      const [signer] = await hre.ethers.getSigners();
      const contract =
        ChainlinkVRFv2DirectFundingConsumerExample__factory.connect(
          input.addr,
          signer
        );

      const tx = await contract.initiateRandomnessRequest({
        value: hre.ethers.utils.parseEther("0.015"),
      });
      console.log("tx: ", tx.hash);
      await tx.wait();
    }
  )
  .addParam(
    "addr",
    "The address of the test consumer",
    undefined,
    types.string
  );
// npx hardhat --network proxyTestnet init.consumer.request --addr 0x099f0CC4F24Be804f5eEDC8F86fc69e114905B08
// npx hardhat --network proxyMainnet init.consumer.request --addr 0x7d27dA43512e4d6a6D1B3a9a5fC41e190734f920