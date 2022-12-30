import { ethers } from 'hardhat';
import { NusicStreamCoupon, NusicStreamCoupon__factory } from '../typechain';
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const NusicStreamCoupon:NusicStreamCoupon__factory =  await ethers.getContractFactory("NusicStreamCoupon");
  
  // Using address for localhost
  const nusicStreamCoupon:NusicStreamCoupon = await NusicStreamCoupon.deploy();

  await nusicStreamCoupon.deployed(); 
  console.log("NusicStreamCoupon deployed to:", nusicStreamCoupon.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
