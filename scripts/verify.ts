import hre from "hardhat";

const main = async () => {
  const contractAddress = "0xc22D54E19a6d1AF0Ca99BF2c1Db560EC09E2B273";

  const allowedTokens = [
    "0x944B5C530f7112D8533BB87E3dCAb99D881B3C73",
    "0xB9e5D51908CCF86d91443e61a4C9d8e4FeE27e33",
    "0x220171b3F1883a21e29B4A8A53D15ce55e0E720c",
  ];

  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: [allowedTokens],
  });

  console.log(`Contract verified on Base Sepolia!`);
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
