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
    // Using address for localhost
  const nusicStreamCoupon:NusicStreamCoupon = await NusicStreamCoupon.attach(network.nusicStreamCoupon);
  console.log("NusicStreamCoupon Address: ", nusicStreamCoupon.address);

  const supply = await nusicStreamCoupon.totalSupply();
  console.log("nusicStreamCoupon.totalSupply = ",supply.toString());

  const tokenURI = await nusicStreamCoupon.tokenURI(0);
  console.log("nusicStreamCoupon.totalSupply = ",tokenURI);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
