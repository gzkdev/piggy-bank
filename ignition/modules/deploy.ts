import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const PiggyBankFactory = buildModule("PiggyBankFactory", (m) => {
  const allowedTokens = [
    "0x944B5C530f7112D8533BB87E3dCAb99D881B3C73",
    "0xB9e5D51908CCF86d91443e61a4C9d8e4FeE27e33",
    "0x220171b3F1883a21e29B4A8A53D15ce55e0E720c",
  ];

  const piggyBankFactory = m.contract("PiggyBankFactory", [allowedTokens]);

  return { piggyBankFactory };
});

export default PiggyBankFactory;
