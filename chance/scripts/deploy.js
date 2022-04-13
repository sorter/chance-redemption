async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const ChanceTickets = await ethers.getContractFactory("ChanceTickets");
    const chanceTickets = await ChanceTickets.deploy("chance");
  
    console.log("ChanceTickets address:", chanceTickets.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });