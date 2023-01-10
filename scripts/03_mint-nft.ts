import { ethers } from 'hardhat';
import { NFTMock, NFTMockOwnable, NFTMockOwnable__factory, NFTMock__factory } from '../typechain';
const addresses = require("./address.json");
/*
* Main deployment script to deploy all the relevent contracts
*/
async function main() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  const network = addresses.matic;

  const NFTMockOwnable:NFTMockOwnable__factory =  await ethers.getContractFactory("NFTMockOwnable");
  const nftMockOwnable:NFTMockOwnable = await NFTMockOwnable.attach(network.nftMockOwnable);
  console.log("NFTMockOwnable Address: ", nftMockOwnable.address);

  const NFTMock:NFTMock__factory =  await ethers.getContractFactory("NFTMock");
  const nftMock:NFTMock = await NFTMockOwnable.attach(network.nftMock);
  console.log("NFTMock Address: ", nftMock.address);

  console.log("Mint Ownable NFT");
  const txt = await nftMockOwnable.safeMint(owner.address);
  console.log("txt.hash = ",txt.hash);
  const txtReceipt = await txt.wait();

  const txt1 = await nftMockOwnable.safeMint(addr1.address);
  console.log("txt1.hash = ",txt1.hash);
  const txtReceipt1 = await txt1.wait();

  const txt2 = await nftMockOwnable.safeMint(addr2.address);
  console.log("txt2.hash = ",txt2.hash);
  const txtReceipt2 = await txt2.wait();

  console.log("Mint NFT");
  const txt3 = await nftMock.safeMint(owner.address);
  console.log("txt3.hash = ",txt3.hash);
  const txtReceipt3 = await txt3.wait();

  const txt4 = await nftMock.safeMint(addr1.address);
  console.log("txt4.hash = ",txt4.hash);
  const txtReceipt4 = await txt4.wait();

  const txt5 = await nftMock.safeMint(addr2.address);
  console.log("txt5.hash = ",txt5.hash);
  const txtReceipt5 = await txt5.wait();

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
