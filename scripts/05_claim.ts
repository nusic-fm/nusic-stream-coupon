import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { NusicStreamCoupon, NusicStreamCoupon__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const network = addresses.localhost;

  const NusicStreamCoupon:NusicStreamCoupon__factory =  await ethers.getContractFactory("NusicStreamCoupon");
    // Using address for localhost
  const nusicStreamCoupon:NusicStreamCoupon = await NusicStreamCoupon.attach(network.nusicStreamCoupon);
  console.log("NusicStreamCoupon Address: ", nusicStreamCoupon.address);

  let streamCount = 1000;
  //let timestamp = (new Date()).getTime();
  let timestamp = 111;
  //let configId = 345;
  let configId = BigNumber.from("93421307069507772285639416580684576036220280475292651263962894856226727966318");
  
  let tokenIdInContract = 0;
  //let fractions = 2;
  // Signature generations
  let messageHash = ethers.utils.solidityKeccak256(
    ["address","uint","address","uint","uint", "uint"],
    [addr1.address,configId, network.nftMock, tokenIdInContract, streamCount, timestamp]
  );
  let messageHashBinary = ethers.utils.arrayify(messageHash);
  let signature = await owner.signMessage(messageHashBinary);

  const txt = await nusicStreamCoupon.connect(addr1).claim(configId,network.nftMock, tokenIdInContract,streamCount,timestamp,signature);
  console.log("txt.hash = ",txt.hash);
  const txtReceipt = await txt.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
