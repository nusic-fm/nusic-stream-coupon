import { ethers } from 'hardhat';
import { NusicStreamCoupon, NusicStreamCoupon__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const network = addresses.localhost;

  const NusicStreamCoupon:NusicStreamCoupon__factory =  await ethers.getContractFactory("NusicStreamCoupon");
  const nusicStreamCoupon:NusicStreamCoupon = await NusicStreamCoupon.attach(network.nusicStreamCoupon);
  console.log("NusicStreamCoupon address: ", nusicStreamCoupon.address);

  let fractions = 5;

  let messageHash = ethers.utils.solidityKeccak256(
    ["address","address","uint"],
    [addr1.address, network.nftMock, fractions]
  );
  let messageHashBinary = ethers.utils.arrayify(messageHash);
  let signature = await owner.signMessage(messageHashBinary);

  const txt = await nusicStreamCoupon.connect(addr1).registerEdition(network.nftMock,fractions,"",signature);
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
