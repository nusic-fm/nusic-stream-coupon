import { ethers } from 'hardhat';
import { NFTMock, NFTMockOwnable, NFTMockOwnable__factory, NFTMock__factory } from '../typechain';
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const NFTMockOwnable:NFTMockOwnable__factory =  await ethers.getContractFactory("NFTMockOwnable");
  const nftMockOwnable:NFTMockOwnable = await NFTMockOwnable.deploy();
  await nftMockOwnable.deployed(); 
  console.log("NFTMockOwnable deployed to:", nftMockOwnable.address);

  const NFTMock:NFTMock__factory =  await ethers.getContractFactory("NFTMock");
  const nftMock:NFTMock = await NFTMockOwnable.deploy();
  await nftMock.deployed(); 
  console.log("NFTMock deployed to:", nftMock.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
