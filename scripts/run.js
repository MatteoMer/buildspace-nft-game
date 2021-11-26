const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame')
    const gameContract = await gameContractFactory.deploy(
        ["Ciri", "Geralt", "Triss"],
        ["https://i.imgur.com/I4dqAdq.png",
        "https://i.imgur.com/kHMlG8N.png",
        "https://i.imgur.com/Z3ekOSa.png"],
        ["200", "300", "100"],
        ["70", "130", "20"],
        ["70", "30", "150"],
        ["The Caretaker", "Imlerith", "Eredin"],
        ["https://i.imgur.com/KYL4d5v.png",
        "https://i.imgur.com/59tYmNR.png",
        "https://i.imgur.com/tfGV3K2.png"],
        ["5000", "5000", "5000"],
        ["50", "50", "50"],
        ["3", "2", "1"],
        ["1", "2", "3"]
    )
    await gameContract.deployed()
    console.log("Contract deployed to:", gameContract.address)

    let txn = await gameContract.mintNFT(1)
    await txn.wait()

    txn = await gameContract.attackBoss()
    await txn.wait()

    txn = await gameContract.attackBoss()
    await txn.wait()

    let tokenURI = await gameContract.tokenURI(1)
    console.log("Token URI:", tokenURI);

  };
  
const runMain = async () => {
    try {
        await main()
        process.exit(0)
    } catch (error) {
        console.log(error)
        process.exit(1)
    }
}

runMain()