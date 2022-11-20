const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env"});
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL, } = require("../constants");

async function main() {
  //address of the whitelist contract you previously deployed 
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
  //url from where we can obtain metadata for crypto devs
  const metadataURL = METADATA_URL;
  /**
   * cryptodevsContract here is a factory for instances of our cryptodevs contract
   */
const cryptoDevsContract = await hre.ethers.getContractFactory("CryptoDevs");

//deploy the contract
const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
  metadataURL,
  whitelistContract
);
//print the address of the deployed contract 
console.log(
  "Crypto Devs Contract Address:",
  deployedCryptoDevsContract.address
);
}
//call the main function and catch any errors
main() 
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
  