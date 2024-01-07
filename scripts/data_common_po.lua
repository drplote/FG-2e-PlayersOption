aDefaultArmorVsDamageTypeModifiers = {};
aHitLocations = {};
aDefaultRaceSizes = {};
aCritCharts = {};
aDefaultWeaponSizes = {};
aDefaultCreatureTypesByName = {};
aDefaultCreatureTypesByType = {};
aNaturalWeapons = {};
aDefaultArmorDamageReduction = {};
aDefaultArmorHp = {};
aThac0ByHd = {};
aStrength = {};
aDexterity = {};
aWisdom = {};
aConstitution = {};
aCharisma = {};
aIntelligence = {};
aComeliness = {};
aHonorDice = {};
aHonorThresholdsByLevel = {};
aCalledShotModifiers = {};
aHackmasterCalledShotsRanges = {};

function onInit()

    initializeDefaultArmorVsDamageTypeModifiers();
    initializeHitLocations();
    initializeDefaultRaceSizes();
    initializelocationCategorys();
    initializeDefaultWeaponSizes();
    initializeDefaultCreatureTypes();
    initializeNaturalWeapons();
    initializeDefaultArmorDamageReduction();
    initializeDefaultArmorHp();
    initializeStats();
    initializeThac0ByHd();
    initializeHonor();
    initializeCalledShots();

    table.insert(DataCommon.powertypes, "phantasm");

end

function initializeHonor()
    -- index is honor index,values are levels 1-20
    aHonorDice[1] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"};
    aHonorDice[2] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"};
    aHonorDice[3] = {"d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3", "d3",
                     "d3", "d3", "d3", "d3"};
    aHonorDice[4] = {"d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4", "d4",
                     "d4", "d4", "d4", "d4"};
    aHonorDice[5] = {"d3", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1",
                     "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1", "d4+1"};
    aHonorDice[6] = {"d3", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6", "d6",
                     "d6", "d6", "d6", "d6"};
    aHonorDice[7] = {"1", "d4+1", "d6", "d6", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1",
                     "d6+1", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1", "d6+1"};
    aHonorDice[8] = {"1", "d4", "d6+1", "d6+1", "d6+1", "d8", "d8", "d8", "d8", "d8", "d8", "d8", "d8", "d8", "d8",
                     "d8", "d8", "d8", "d8", "d8"};
    aHonorDice[9] = {"1", "d3", "d6", "d6+1", "d6+1", "d8", "d8+1", "d8+1", "d8+1", "d8+1", "d8+1", "d8+1", "d8+1",
                     "d8+1", "d8+1", "d8+1", "d8+1", "d8+1", "d8+1", "d8+1"};
    aHonorDice[10] = {"1", "d3", "d4+1", "d8", "d8+1", "d8", "d8+1", "d10", "d10", "d10", "d10", "d10", "d10", "d10",
                      "d10", "d10", "d10", "d10", "d10", "d10"};
    aHonorDice[11] = {"1", "1", "d4+1", "d6+1", "d8", "d8+1", "d8+1", "d10", "d10+1", "d10+1", "d10+1", "d10+1",
                      "d10+1", "d10+1", "d10+1", "d10+1", "d10+1", "d10+1", "d10+1", "d10+1"};
    aHonorDice[12] = {"1", "1", "d4", "d6", "d8+1", "d8+1", "d8+1", "d10", "d10+1", "d12", "d12", "d12", "d12", "d12",
                      "d12", "d12", "d12", "d12", "d12", "d12"};
    aHonorDice[13] = {"1", "1", "d4", "d4+1", "d8", "d8+1", "d10", "d10", "d10+1", "d12", "d12+1", "d12+1", "d12+1",
                      "d12+1", "d12+1", "d12+1", "d12+1", "d12+1", "d12+1", "d12+1"};
    aHonorDice[14] = {"1", "1", "d3", "d4+1", "d6+1", "d10", "d10", "d10+1", "d10+1", "d12", "d12+1", "d12+1", "d12+1",
                      "d12+1", "d12+1", "d12+1", "d12+1", "d12+1", "d12+1", "d12+2"};
    aHonorDice[15] = {"1", "1", "d3", "d4", "d6+1", "d8+1", "d10", "d10+1", "d10+1", "d12", "d12+1", "d12+1", "d12+2",
                      "d12+2", "d12+2", "d12+2", "d12+2", "d12+2", "d12+2", "d20"};
    aHonorDice[16] = {"1", "1", "d3", "d4", "d6", "d8", "d10+1", "d10+1", "d12", "d12", "d12+1", "d12+1", "d12+2",
                      "d12+2", "d12+2", "d12+2", "d12+2", "d12+2", "d20", "d20"};
    aHonorDice[17] = {"1", "1", "1", "d3", "d6", "d6+1", "d10", "d10+1", "d12", "d12+1", "d12+1", "d12+1", "d12+2",
                      "d12+2", "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[18] = {"1", "1", "1", "d3", "d4+1", "d6+1", "d8+1", "d12", "d12", "d12+1", "d12+1", "d12+2", "d12+2",
                      "d12+2", "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[19] = {"1", "1", "1", "d3", "d4+1", "d6", "d8+1", "d10+1", "d12", "d12+1", "d12+2", "d12+2", "d12+2",
                      "d20", "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[20] = {"1", "1", "1", "1", "d4+1", "d6", "d8", "d10", "d12+1", "d12+1", "d12+2", "d12+2", "d12+2", "d20",
                      "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[21] = {"1", "1", "1", "1", "d4", "d4+1", "d8", "d8+1", "d12", "d12+1", "d12+2", "d12+2", "d12+2", "d20",
                      "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[22] = {"1", "1", "1", "1", "d4", "d4+1", "d6+1", "d8+1", "d10+1", "d12+2", "d12+2", "d12+2", "d20",
                      "d20", "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[23] = {"1", "1", "1", "1", "d4", "d4+1", "d6+1", "d8", "d10+1", "d12+1", "d12+2", "d12+2", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[24] = {"1", "1", "1", "1", "d3", "d4", "d6+1", "d8", "d10", "d12", "d20", "d20", "d20", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[25] = {"1", "1", "1", "1", "d3", "d4", "d6", "d6+1", "d10", "d10+1", "d12+2", "d20", "d20", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[26] = {"1", "1", "1", "1", "d3", "d4", "d6", "d6+1", "d8+1", "d10+1", "d12+1", "d20", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[27] = {"1", "1", "1", "1", "d3", "d3", "d6", "d6+1", "d8+1", "d10", "d12", "d12+2", "d20", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[28] = {"1", "1", "1", "1", "1", "d3", "d4+1", "d6", "d8+1", "d10", "d10+1", "d12+1", "d20", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[29] = {"1", "1", "1", "1", "1", "d3", "d4+1", "d6", "d8", "d8+1", "d10+1", "d12", "d12+2", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[30] = {"1", "1", "1", "1", "1", "d3", "d4+1", "d6", "d8", "d8+1", "d10", "d10+1", "d12+1", "d20", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[31] = {"1", "1", "1", "1", "1", "1", "d4+1", "d4+1", "d8", "d8+1", "d10", "d10+1", "d12", "d12+2", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[32] = {"1", "1", "1", "1", "1", "1", "d4", "d4+1", "d6+1", "d8", "d8+1", "d10", "d10+1", "d12+1", "d20",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[33] = {"1", "1", "1", "1", "1", "1", "d4", "d4+1", "d6+1", "d8", "d8+1", "d10", "d10+1", "d12", "d12+2",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[34] = {"1", "1", "1", "1", "1", "1", "d4", "d4+1", "d6+1", "d8", "d8+1", "d8+1", "d10", "d10+1", "d12+1",
                      "d20", "d20", "d20", "d20", "d20"};
    aHonorDice[35] = {"1", "1", "1", "1", "1", "1", "d4", "d4", "d6+1", "d6+1", "d8", "d8+1", "d10", "d10+1", "d12",
                      "d12+2", "d20", "d20", "d20", "d20"};
    aHonorDice[36] = {"1", "1", "1", "1", "1", "1", "d3", "d4", "d6", "d6+1", "d8", "d8+1", "d8+1", "d10", "d10+1",
                      "d12+1", "d20", "d20", "d20", "d20"};
    aHonorDice[37] = {"1", "1", "1", "1", "1", "1", "d3", "d4", "d6", "d6+1", "d8", "d8", "d8+1", "d10", "d10+1", "d12",
                      "d12+2", "d20", "d20", "d20"};
    aHonorDice[38] = {"1", "1", "1", "1", "1", "1", "d3", "d4", "d6", "d6+1", "d6+1", "d8", "d8+1", "d8+1", "d10",
                      "d10+1", "d12+1", "d20", "d20", "d20"};
    aHonorDice[39] = {"1", "1", "1", "1", "1", "1", "d3", "d3", "d6", "d6", "d6+1", "d8", "d8", "d8+1", "d10", "d10+1",
                      "d12", "d12+2", "d20", "d20"};
    aHonorDice[40] = {"1", "1", "1", "1", "1", "1", "d3", "d3", "d4+1", "d6", "d6+1", "d6+1", "d8", "d8+1", "d8+1",
                      "d10", "d10+1", "d12+1", "d20", "d20"};
    aHonorDice[41] = {"1", "1", "1", "1", "1", "1", "d3", "d3", "d4+1", "d6", "d6+1", "d6+1", "d8", "d8", "d8+1", "d10",
                      "d10+1", "d12", "d12+2", "d20"};
    aHonorDice[42] = {"1", "1", "1", "1", "1", "1", "d3", "d3", "d4+1", "d6", "d6", "d6+1", "d6+1", "d8", "d8+1",
                      "d8+1", "d10", "d10+1", "d12+1", "d20"};
    aHonorDice[43] = {"1", "1", "1", "1", "1", "1", "d3", "d3", "d4+1", "d4+1", "d6", "d6+1", "d6+1", "d8", "d8",
                      "d8+1", "d10", "d10+1", "d12", "d12+2"};
    aHonorDice[44] = {"1", "1", "1", "1", "1", "1", "1", "1", "d4+1", "d4+1", "d6", "d6", "d6+1", "d6+1", "d8", "d8+1",
                      "d8+1", "d10", "d10+1", "d12+1"};
    aHonorDice[45] = {"1", "1", "1", "1", "1", "1", "1", "1", "d4", "d4+1", "d6", "d6", "d6+1", "d6+1", "d8", "d8",
                      "d8+1", "d10", "d10+1", "d12"};
    aHonorDice[46] = {"1", "1", "1", "1", "1", "1", "1", "1", "d4", "d4+1", "d4+1", "d6", "d6", "d6+1", "d6+1", "d8",
                      "d8+1", "d8+1", "d10", "d10+1"};
    aHonorDice[47] = {"1", "1", "1", "1", "1", "1", "1", "1", "d4", "d4+1", "d4+1", "d6", "d6", "d6+1", "d6+1", "d8",
                      "d8", "d8+1", "d10", "d10+1"};
    aHonorDice[48] = {"1", "1", "1", "1", "1", "1", "1", "1", "d4", "d4", "d4+1", "d4+1", "d6", "d6", "d6+1", "d6+1",
                      "d8", "d8+1", "d8+1", "d10"};
    aHonorDice[49] = {"1", "1", "1", "1", "1", "1", "1", "1", "d4", "d4", "d4+1", "d4+1", "d6", "d6", "d6+1", "d6+1",
                      "d8", "d8", "d8+1", "d10"};
    aHonorDice[50] = {"1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4+1", "d4+1", "d4+1", "d6", "d6", "d6+1",
                      "d6+1", "d8", "d8+1", "d8+1"};
    aHonorDice[51] = {"1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4", "d4+1", "d4+1", "d6", "d6", "d6+1",
                      "d6+1", "d8", "d8", "d8+1"};
    aHonorDice[52] = {"1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4", "d4+1", "d4+1", "d4+1", "d6", "d6",
                      "d6+1", "d6+1", "d8", "d8+1"};
    aHonorDice[53] = {"1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4+1", "d4+1", "d6", "d6",
                      "d6+1", "d6+1", "d8", "d8"};
    aHonorDice[54] = {"1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4+1", "d4+1", "d4+1", "d6",
                      "d6", "d6+1", "d6+1", "d8"};
    aHonorDice[55] = {"1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4+1", "d4+1", "d4+1", "d6",
                      "d6", "d6+1", "d6+1", "d8"};
    aHonorDice[56] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4", "d4", "d4+1", "d4+1", "d6", "d6",
                      "d6+1", "d6+1", "d8"};
    aHonorDice[57] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4", "d4", "d4+1", "d4+1", "d4+1", "d6",
                      "d6", "d6+1", "d6+1"};
    aHonorDice[58] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4", "d4+1", "d4+1", "d4+1",
                      "d4+1", "d6", "d6", "d6+1"};
    aHonorDice[59] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d4", "d4", "d4", "d4+1", "d4+1", "d4+1",
                      "d6", "d6", "d6+1"};
    aHonorDice[60] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4", "d4+1", "d4+1",
                      "d4+1", "d6", "d6"};
    aHonorDice[61] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4", "d4", "d4+1",
                      "d4+1", "d6", "d6"};
    aHonorDice[62] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3", "d4", "d4", "d4", "d4+1",
                      "d4+1", "d4+1", "d6"};
    aHonorDice[63] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4", "d4", "d4+1",
                      "d4+1", "d6"};
    aHonorDice[64] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3", "d4", "d4", "d4", "d4+1",
                      "d4+1", "d4+1"};
    aHonorDice[65] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4", "d4",
                      "d4+1", "d4+1"};
    aHonorDice[66] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3", "d4", "d4", "d4",
                      "d4+1", "d4+1"};
    aHonorDice[67] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4", "d4",
                      "d4", "d4+1"};
    aHonorDice[68] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3", "d4", "d4",
                      "d4", "d4+1"};
    aHonorDice[69] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4",
                      "d4", "d4"};
    aHonorDice[70] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3", "d4",
                      "d4", "d4"};
    aHonorDice[71] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4", "d4",
                      "d4"};
    aHonorDice[72] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3", "d4",
                      "d4"};
    aHonorDice[73] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d4",
                      "d4"};
    aHonorDice[74] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3", "d3",
                      "d4"};
    aHonorDice[75] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3",
                      "d4"};
    aHonorDice[76] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3", "d3",
                      "d3"};
    aHonorDice[77] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3",
                      "d3"};
    aHonorDice[78] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "d3",
                      "d3"};
    aHonorDice[79] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1",
                      "d3"};
    aHonorDice[80] = {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1",
                      "d3"};
    aHonorDice[81] =
        {"1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"};

    aHonorThresholdsByLevel[1] = {6, 17, 20};
    aHonorThresholdsByLevel[2] = {9, 25, 30};
    aHonorThresholdsByLevel[3] = {12, 33, 40};
    aHonorThresholdsByLevel[4] = {15, 41, 50};
    aHonorThresholdsByLevel[5] = {18, 49, 60};
    aHonorThresholdsByLevel[6] = {21, 57, 70};
    aHonorThresholdsByLevel[7] = {24, 65, 80};
    aHonorThresholdsByLevel[8] = {27, 73, 90};
    aHonorThresholdsByLevel[9] = {30, 81, 100};
    aHonorThresholdsByLevel[10] = {33, 89, 110};
    aHonorThresholdsByLevel[11] = {36, 97, 120};
    aHonorThresholdsByLevel[12] = {39, 105, 130};
    aHonorThresholdsByLevel[13] = {42, 113, 140};
    aHonorThresholdsByLevel[14] = {45, 121, 150};
    aHonorThresholdsByLevel[15] = {48, 129, 160};
    aHonorThresholdsByLevel[16] = {51, 137, 170};
    aHonorThresholdsByLevel[17] = {54, 145, 180};
    aHonorThresholdsByLevel[18] = {57, 153, 190};
    aHonorThresholdsByLevel[19] = {60, 161, 200};
    aHonorThresholdsByLevel[20] = {63, 169, 210};

end

function initializeStats()
    -- aStrength[abilityScore]={hit adj, dam adj, weight allow, max press, open doors, bend bars, light enc, moderate enc, heavy enc, severe enc, max enc}
    aStrength[1] = {-3, -8, 1, 3, "1(0)", 0, 2, 4, 6, 8, 10};
    aStrength[2] = {-3, -8, 2, 4, "1(0)", 0, 3, 5, 7, 9, 11};

    aStrength[3] = {-3, -7, 3, 5, "1(0)", 0, 4, 6, 8, 10, 12};
    aStrength[4] = {-3, -7, 4, 7, "1(0)", 0, 5, 7, 9, 11, 13};

    aStrength[5] = {-3, -6, 5, 10, "2(0)", 0, 6, 8, 10, 12, 16};
    aStrength[6] = {-3, -6, 7, 20, "2(0)", 0, 8, 10, 12, 15, 22};

    aStrength[7] = {-2, -5, 9, 25, "3(0)", 0, 10, 12, 15, 19, 28};
    aStrength[8] = {-2, -5, 11, 35, "3(0)", 0, 12, 15, 18, 23, 34};

    aStrength[9] = {-2, -4, 13, 30, "3(0)", 0, 14, 17, 21, 27, 40};
    aStrength[10] = {-2, -4, 15, 40, "3(0)", 0, 16, 20, 24, 31, 46};

    aStrength[11] = {-2, -3, 18, 55, "4(0)", 0, 19, 24, 28, 37, 55};
    aStrength[12] = {-2, -3, 21, 68, "4(0)", 0, 22, 27, 33, 43, 55};

    aStrength[13] = {-1, -2, 24, 70, "4(0)", 0, 25, 31, 37, 49, 73};
    aStrength[14] = {-1, -2, 27, 80, "5(0)", 0, 28, 35, 42, 55, 82};

    aStrength[15] = {-1, -1, 30, 90, "5(0)", 1, 31, 39, 46, 61, 91};
    aStrength[16] = {-1, -1, 33, 95, "5(0)", 1, 34, 42, 51, 67, 100};

    aStrength[17] = {0, -1, 36, 100, "5(0)", 1, 37, 46, 55, 73, 109};
    aStrength[18] = {0, -1, 39, 110, "6(0)", 1, 40, 50, 60, 79, 118};

    aStrength[19] = {0, 0, 43, 115, "6(0)", 2, 44, 55, 88, 87, 130};
    aStrength[20] = {0, 0, 47, 125, "6(0)", 3, 48, 60, 72, 95, 142};

    aStrength[21] = {0, 0, 51, 130, "6(0)", 4, 52, 65, 78, 103, 154};
    aStrength[22] = {0, 0, 55, 135, "7(0)", 4, 56, 70, 84, 111, 166};

    aStrength[23] = {0, 1, 59, 140, "7(0)", 5, 60, 75, 90, 119, 178};
    aStrength[24] = {0, 1, 63, 145, "7(0)", 5, 64, 80, 96, 127, 190};

    aStrength[25] = {1, 1, 67, 150, "7(0)", 6, 68, 85, 102, 135, 202};
    aStrength[26] = {1, 1, 71, 160, "8(0)", 6, 72, 90, 108, 143, 214};

    aStrength[27] = {1, 2, 76, 170, "8(0)", 7, 77, 96, 115, 153, 229};
    aStrength[28] = {1, 2, 81, 175, "8(0)", 8, 82, 102, 123, 163, 244};

    aStrength[29] = {1, 3, 86, 185, "9(0)", 9, 87, 109, 130, 173, 259};
    aStrength[30] = {1, 3, 91, 190, "9(0)", 10, 92, 115, 138, 183, 274};

    aStrength[31] = {2, 4, 97, 195, "10(0)", 11, 98, 122, 147, 195, 292};
    aStrength[32] = {2, 4, 103, 220, "10(0)", 12, 104, 130, 156, 207, 310};

    aStrength[33] = {2, 5, 109, 255, "11(0)", 15, 110, 137, 165, 219, 328};
    aStrength[34] = {2, 5, 115, 290, "11(0)", 20, 116, 145, 174, 231, 346};

    aStrength[35] = {3, 6, 130, 350, "12(3)", 25, 131, 164, 196, 261, 391};
    aStrength[36] = {3, 6, 160, 480, "14(6)", 35, 161, 201, 241, 321, 481};

    aStrength[37] = {3, 7, 200, 640, "15(8)", 50, 201, 251, 301, 401, 601};
    aStrength[38] = {3, 7, 300, 660, "16(9)", 50, 301, 376, 451, 601, 901};

    aStrength[39] = {3, 8, 400, 700, "17(10)", 60, 401, 501, 601, 801, 1201};
    aStrength[40] = {3, 8, 500, 625, "17(11)", 65, 501, 626, 751, 1001, 1501};

    aStrength[41] = {4, 9, 600, 810, "17(12)", 70, 601, 751, 901, 1201, 1801};
    aStrength[42] = {4, 9, 700, 865, "18(13)", 75, 701, 876, 1051, 1401, 2101};

    aStrength[43] = {4, 10, 800, 970, "18(14)", 80, 801, 1001, 1201, 1601, 2401};
    aStrength[44] = {4, 10, 900, 1050, "18(15)", 85, 901, 1126, 1351, 1801, 2701};

    aStrength[45] = {5, 11, 1000, 1130, "18(16)", 90, 1001, 1251, 1501, 2001, 3001};
    aStrength[46] = {5, 11, 1100, 1320, "19(16)", 95, 1101, 1376, 1651, 2201, 3301};

    aStrength[47] = {6, 12, 1200, 1440, "19(16)", 97, 1201, 1501, 1801, 2401, 3601};
    aStrength[48] = {6, 12, 1300, 1540, "19(17)", 98, 1301, 1626, 1951, 2601, 3901};

    aStrength[49] = {7, 14, 1500, 1750, "19(18)", 99, 1501, 1876, 2251, 3001, 4501};
    aStrength[50] = {7, 14, 1500, 1750, "19(18)", 99, 1501, 1876, 2251, 3001, 4501};

    -- aDexterity[abilityScore]={reaction, missile, defensive}
    aDexterity[1] = {-5, -6, 5};
    aDexterity[2] = {-5, -5, 5};

    aDexterity[3] = {-5, -5, 4};
    aDexterity[4] = {-4, -5, 4};

    aDexterity[5] = {-4, -4, 4};
    aDexterity[6] = {-4, -4, 3};

    aDexterity[7] = {-3, -4, 3};
    aDexterity[8] = {-3, -3, 3};

    aDexterity[9] = {-3, -3, 2};
    aDexterity[10] = {-2, -3, 2};

    aDexterity[11] = {-2, -2, 2};
    aDexterity[12] = {-2, -2, 1};

    aDexterity[13] = {-1, -2, 1};
    aDexterity[14] = {-1, -1, 1};

    aDexterity[15] = {-1, -1, 0};
    aDexterity[16] = {0, -1, 0};

    aDexterity[17] = {0, 0, 0};
    aDexterity[18] = {0, 0, 0};

    aDexterity[19] = {0, 0, 0};
    aDexterity[20] = {0, 0, 0};

    aDexterity[21] = {0, 0, 0};
    aDexterity[22] = {0, 0, 0};

    aDexterity[23] = {0, 0, 0};
    aDexterity[24] = {0, 1, 0};

    aDexterity[25] = {1, 1, 0};
    aDexterity[26] = {1, 1, -1};

    aDexterity[27] = {1, 2, -1};
    aDexterity[28] = {2, 2, -1};

    aDexterity[29] = {2, 2, -2};
    aDexterity[30] = {2, 3, -2};

    aDexterity[31] = {3, 3, -2};
    aDexterity[32] = {3, 3, -3};

    aDexterity[33] = {3, 4, -3};
    aDexterity[34] = {4, 4, -3};

    aDexterity[35] = {4, 4, -4};
    aDexterity[36] = {4, 5, -4};

    aDexterity[37] = {5, 5, -4};
    aDexterity[38] = {5, 5, -5};

    aDexterity[39] = {5, 6, -5};
    aDexterity[40] = {6, 6, -5};

    aDexterity[41] = {6, 6, -6};
    aDexterity[42] = {6, 7, -6};

    aDexterity[43] = {7, 7, -6};
    aDexterity[44] = {7, 7, -7};

    aDexterity[45] = {7, 8, -7};
    aDexterity[46] = {8, 8, -7};

    aDexterity[47] = {8, 8, -8};
    aDexterity[48] = {8, 9, -8};

    aDexterity[49] = {9, 9, -8};
    aDexterity[50] = {9, 9, -8};

    -- aWisdom[abilityScore]={magic adj, spell bonuses, spell failure, spell imm., MAC base, PSP bonus }
    aWisdom[1] = {-6, "None", 80, "None", 10, 0};
    aWisdom[2] = {-4, "None", 60, "None", 10, 0};
    aWisdom[3] = {-3, "None", 50, "None", 10, 0};
    aWisdom[4] = {-2, "None", 45, "None", 10, 0};
    aWisdom[5] = {-1, "None", 40, "None", 10, 0};
    aWisdom[6] = {-1, "None", 35, "None", 10, 0};
    aWisdom[7] = {-1, "None", 30, "None", 10, 0};
    aWisdom[8] = {0, "None", 25, "None", 10, 0};
    aWisdom[9] = {0, "None", 20, "None", 10, 0};
    aWisdom[10] = {0, "None", 15, "None", 10, 0};
    aWisdom[11] = {0, "None", 10, "None", 10, 0};
    aWisdom[12] = {0, "None", 5, "None", 10, 0};
    aWisdom[13] = {0, "1x1st", 0, "None", 10, 0};
    aWisdom[14] = {0, "2x1st", 0, "None", 10, 0};
    aWisdom[15] = {1, "2x1st,1x2nd", 0, "None", 10, 0};
    aWisdom[16] = {2, "2x1st,2x2nd", 0, "None", 9, 1};
    aWisdom[17] = {3, "Various", 0, "None", 8, 2};
    aWisdom[18] = {4, "Various", 0, "None", 7, 3};
    aWisdom[19] = {4, "Various", 0, "Various", 6, 4};
    aWisdom[20] = {4, "Various", 0, "Various", 5, 5};
    aWisdom[21] = {4, "Various", 0, "Various", 4, 6};
    aWisdom[22] = {4, "Various", 0, "Various", 3, 7};
    aWisdom[23] = {4, "Various", 0, "Various", 2, 8};
    aWisdom[24] = {4, "Various", 0, "Various", 1, 9};
    aWisdom[25] = {4, "Various", 0, "Various", 0, 10};
    -- deal with long string bonus for tooltip
    aWisdom[117] = {3, "Bonus Spells: 2x1st, 2x2nd, 1x3rd", 0, "None"};
    aWisdom[118] = {4, "Bonus Spells: 2x1st, 2x2nd, 1x3rd, 1x4th", 0, "None"};
    aWisdom[119] = {4, "Bonus Spells: 3x1st, 2x2nd, 2x3rd, 1x4th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism"};
    aWisdom[120] = {4, "Bonus Spells: 3x1st, 3x2nd, 2x3rd, 2x4th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare"};
    aWisdom[121] = {4, "Bonus Spells: 3x1st, 3x2nd, 3x3rd, 2x4th, 5th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear"};
    aWisdom[122] = {4, "Bonus Spells: 3x1st, 3x2nd, 3x3rd, 3x4th, 2x5th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion"};
    aWisdom[123] = {4, "Bonus Spells: 4x1st, 3x2nd, 3x3rd, 3x4th, 2x5th, 1x6th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion, chaos, feeblemind, hold monster,magic jar,quest"};
    aWisdom[124] = {4, "Bonus Spells: 4x1st, 3x2nd, 3x3rd, 3x4th, 3x5th, 2x6th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion, chaos, feeblemind, hold monster,magic jar,quest, geas, mass suggestion, rod of ruleship"};
    aWisdom[125] = {4, "Bonus Spells: 4x1st, 3x2nd, 3x3rd, 3x4th, 3x5th, 3x6th,1x7th", 0,
                    "Spells: cause fear,charm person, command, friends, hypnotism, forget, hold person, enfeeble, scare, fear, charm monster, confusion, emotion, fumble, suggestion, chaos, feeblemind, hold monster,magic jar,quest, geas, mass suggestion, rod of ruleship, antipathy/sympath, death spell,mass charm"};

    -- aConstitution[abilityScore]={hp, system shock, resurrection survivial, poison save, regeneration, psp bonus}
    aConstitution[1] = {"-5", 25, 30, -2, "None", 0};
    aConstitution[2] = {"-4", 30, 35, -1, "None", 0};
    aConstitution[3] = {"-4", 35, 40, 0, "None", 0};
    aConstitution[4] = {"-3", 40, 45, 0, "None", 0};
    aConstitution[5] = {"-3", 45, 50, 0, "None", 0};
    aConstitution[6] = {"-2", 50, 55, 0, "None", 0};
    aConstitution[7] = {"-2", 55, 60, 0, "None", 0};
    aConstitution[8] = {"-1", 60, 65, 0, "None", 0};
    aConstitution[9] = {"-1", 65, 70, 0, "None", 0};
    aConstitution[10] = {"0", 70, 75, 0, "None", 0};
    aConstitution[11] = {"0", 75, 80, 0, "None", 0};
    aConstitution[12] = {"1", 80, 85, 0, "None", 0};
    aConstitution[13] = {"1", 85, 90, 0, "None", 0};
    aConstitution[14] = {"2", 88, 92, 0, "None", 0};
    aConstitution[15] = {"2", 90, 94, 0, "None", 0};
    aConstitution[16] = {"3", 95, 96, 0, "None", 1};
    aConstitution[17] = {"3", 97, 98, 0, "None", 2};
    aConstitution[18] = {"4", 99, 100, 0, "None", 3};
    aConstitution[19] = {"4", 99, 100, 1, "None", 4};
    aConstitution[20] = {"5", 99, 100, 1, "1/6 turns", 5};
    aConstitution[21] = {"5", 99, 100, 2, "1/5 turns", 6};
    aConstitution[22] = {"6", 99, 100, 2, "1/4 turns", 7};
    aConstitution[23] = {"6", 99, 100, 3, "1/3 turns", 8};
    aConstitution[24] = {"7", 99, 100, 3, "1/2", 9};
    aConstitution[25] = {"7", 100, 100, 4, "1 turn", 10};

    -- aCharisma[abilityScore]={reaction, missile, defensive}
    aCharisma[1] = {0, -8, -7};
    aCharisma[2] = {1, -7, -6};
    aCharisma[3] = {1, -6, -5};
    aCharisma[4] = {1, -5, -4};
    aCharisma[5] = {2, -4, -3};
    aCharisma[6] = {2, -3, -2};
    aCharisma[7] = {3, -2, -1};
    aCharisma[8] = {3, -1, 0};
    aCharisma[9] = {4, 0, 0};
    aCharisma[10] = {4, 0, 0};
    aCharisma[11] = {4, 0, 0};
    aCharisma[12] = {5, 0, 0};
    aCharisma[13] = {5, 0, 1};
    aCharisma[14] = {6, 1, 2};
    aCharisma[15] = {7, 3, 3};
    aCharisma[16] = {8, 4, 5};
    aCharisma[17] = {10, 6, 6};
    aCharisma[18] = {15, 8, 7};
    aCharisma[19] = {20, 10, 8};
    aCharisma[20] = {25, 12, 9};
    aCharisma[21] = {30, 14, 10};
    aCharisma[22] = {35, 16, 1};
    aCharisma[23] = {40, 18, 12};
    aCharisma[24] = {45, 20, 13};
    aCharisma[25] = {50, 20, 14};

    -- aIntelligence[abilityScore]={# languages, spelllevel, learn spell, max spells, illusion immunity, MAC mod, PSP Bonus,MTHACO bonus}
    aIntelligence[1] = {0, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[2] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[3] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[4] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[5] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[6] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[7] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[8] = {1, 0, 0, 0, "None", 0, 0, 0};
    aIntelligence[9] = {2, 4, 35, 6, "None", 0, 0, 0};
    aIntelligence[10] = {2, 5, 40, 7, "None", 0, 0, 0};
    aIntelligence[11] = {2, 5, 45, 7, "None", 0, 0, 0};
    aIntelligence[12] = {3, 6, 50, 7, "None", 0, 0, 0};
    aIntelligence[13] = {3, 6, 55, 9, "None", 0, 0, 0};
    aIntelligence[14] = {4, 7, 60, 9, "None", 0, 0, 0};
    aIntelligence[15] = {4, 7, 65, 11, "None", 0, 0, 0};
    aIntelligence[16] = {5, 8, 70, 11, "None", 1, 1, 1};
    aIntelligence[17] = {6, 8, 75, 14, "None", 1, 2, 1};
    aIntelligence[18] = {7, 9, 85, 18, "None", 2, 3, 2};
    aIntelligence[19] = {8, 9, 95, "All", "1st", 2, 4, 2};
    aIntelligence[20] = {9, 9, 96, "All", "1,2", 3, 5, 3};
    aIntelligence[21] = {10, 9, 97, "All", "1,2,3", 3, 6, 3};
    aIntelligence[22] = {11, 9, 98, "All", "1,2,3,4", 3, 7, 3};
    aIntelligence[23] = {12, 9, 99, "All", "1,2,3,4,5", 4, 8, 4};
    aIntelligence[24] = {15, 9, 100, "All", "1,2,3,4,5,6", 4, 9, 4};
    aIntelligence[25] = {20, 9, 100, "All", "1,2,3,4,5,6,7", 4, 10, 4};
    -- these have such long values we stuff them into tooltips instead
    aIntelligence[119] = {8, 9, 95, "All", "Level: 1st"};
    aIntelligence[120] = {9, 9, 96, "All", "Level: 1st, 2nd"};
    aIntelligence[121] = {10, 9, 97, "All", "Level: 1st, 2nd, 3rd"};
    aIntelligence[122] = {11, 9, 98, "All", "Level: 1st, 2nd, 3rd, 4th"};
    aIntelligence[123] = {12, 9, 99, "All", "Level: 1st, 2nd, 3rd, 4th, 5th"};
    aIntelligence[124] = {15, 9, 100, "All", "Level: 1st, 2nd, 3rd, 4th, 5th, 6th"};
    aIntelligence[125] = {20, 9, 100, "All", "Level: 1st, 2nd, 3rd, 4th, 5th, 6th, 7th"};

    aComeliness[1] = {"You're ugly. Hover for more",
                      "Such an individual is simply ugly. The reaction evidenced will tend toward unease and a desire to get away from such brutishness as quickly as possible. If given the opportunity, the character's Charisma can offset ugliness, but this requires a fair amount of conversation and interaction to take place."};
    aComeliness[2] = {"You're ugly. Hover for more",
                      "Such an individual is simply ugly. The reaction evidenced will tend toward unease and a desire to get away from such brutishness as quickly as possible. If given the opportunity, the character's Charisma can offset ugliness, but this requires a fair amount of conversation and interaction to take place."};
    aComeliness[3] = {"You're ugly. Hover for more",
                      "Such an individual is simply ugly. The reaction evidenced will tend toward unease and a desire to get away from such brutishness as quickly as possible. If given the opportunity, the character's Charisma can offset ugliness, but this requires a fair amount of conversation and interaction to take place."};
    aComeliness[4] = {"You're ugly. Hover for more",
                      "Such an individual is simply ugly. The reaction evidenced will tend toward unease and a desire to get away from such brutishness as quickly as possible. If given the opportunity, the character's Charisma can offset ugliness, but this requires a fair amount of conversation and interaction to take place."};
    aComeliness[5] = {"You're ugly. Hover for more",
                      "Such an individual is simply ugly. The reaction evidenced will tend toward unease and a desire to get away from such brutishness as quickly as possible. If given the opportunity, the character's Charisma can offset ugliness, but this requires a fair amount of conversation and interaction to take place."};
    aComeliness[6] = {"You're ugly. Hover for more",
                      "Such an individual is simply ugly. The reaction evidenced will tend toward unease and a desire to get away from such brutishness as quickly as possible. If given the opportunity, the character's Charisma can offset ugliness, but this requires a fair amount of conversation and interaction to take place."};
    aComeliness[7] = {"You're homely. Hover for more.",
                      "The homeliness of the individual will be such that initial contact will be of a negative sort. This negative feeling will not be strongly evidenced. High Charisma will quickly overcome it if any conversation and interpersonal interaction transpires."};
    aComeliness[8] = {"You're homely. Hover for more.",
                      "The homeliness of the individual will be such that initial contact will be of a negative sort. This negative feeling will not be strongly evidenced. High Charisma will quickly overcome it if any conversation and interpersonal interaction transpires."};
    aComeliness[9] = {"You're homely. Hover for more.",
                      "The homeliness of the individual will be such that initial contact will be of a negative sort. This negative feeling will not be strongly evidenced. High Charisma will quickly overcome it if any conversation and interpersonal interaction transpires."};
    aComeliness[10] = {"You're average. Hover for more", "Plain to Average Comeliness; no effect on the viewer."};
    aComeliness[11] = {"You're average. Hover for more", "Plain to Average Comeliness; no effect on the viewer."};
    aComeliness[12] = {"You're average. Hover for more", "Plain to Average Comeliness; no effect on the viewer."};
    aComeliness[13] = {"You're average. Hover for more", "Plain to Average Comeliness; no effect on the viewer."};
    aComeliness[14] = {"You're attractive. Hover for more.",
                       "Interest in viewing the individual is evidenced by those in contact, as he is good-looking. The reaction adjustment is increased by a percentage equal to the Comeliness score of the character. Individuals of the opposite sex will seek out such characters, and they will be affected as if under a Fascinate spell unless hte Wisdom of such individuals exceeds 50% of the character's Comeliness total."};
    aComeliness[15] = {"You're attractive. Hover for more.",
                       "Interest in viewing the individual is evidenced by those in contact, as he is good-looking. The reaction adjustment is increased by a percentage equal to the Comeliness score of the character. Individuals of the opposite sex will seek out such characters, and they will be affected as if under a Fascinate spell unless hte Wisdom of such individuals exceeds 50% of the character's Comeliness total."};
    aComeliness[16] = {"You're attractive. Hover for more.",
                       "Interest in viewing the individual is evidenced by those in contact, as he is good-looking. The reaction adjustment is increased by a percentage equal to the Comeliness score of the character. Individuals of the opposite sex will seek out such characters, and they will be affected as if under a Fascinate spell unless hte Wisdom of such individuals exceeds 50% of the character's Comeliness total."};
    aComeliness[17] = {"You're attractive. Hover for more.",
                       "Interest in viewing the individual is evidenced by those in contact, as he is good-looking. The reaction adjustment is increased by a percentage equal to the Comeliness score of the character. Individuals of the opposite sex will seek out such characters, and they will be affected as if under a Fascinate spell unless hte Wisdom of such individuals exceeds 50% of the character's Comeliness total."};

    aComeliness[18] = {"You're beautiful. Hover for more.",
                       "The beauty of the character will cause heads to turn and hearts to race. Reaction for initial contact is at a percent equal to 150% of the Comeliness score. Individuals of the opposite sex will be affected as if under a Fascinate spell unless their Wisdom exceeds two-thirds of the character's Comeliness total. Individuals of the same sex will do likewise unless Wisdom totals at least 50% of the other character's Comeliness score. Rejection of harsh nature can cause the individual rejected to have a reaction as if the character had negative Comeliness of half the actual (positive) score."};
    aComeliness[19] = {"You're beautiful. Hover for more.",
                       "The beauty of the character will cause heads to turn and hearts to race. Reaction for initial contact is at a percent equal to 150% of the Comeliness score. Individuals of the opposite sex will be affected as if under a Fascinate spell unless their Wisdom exceeds two-thirds of the character's Comeliness total. Individuals of the same sex will do likewise unless Wisdom totals at least 50% of the other character's Comeliness score. Rejection of harsh nature can cause the individual rejected to have a reaction as if the character had negative Comeliness of half the actual (positive) score."};
    aComeliness[20] = {"You're beautiful. Hover for more.",
                       "The beauty of the character will cause heads to turn and hearts to race. Reaction for initial contact is at a percent equal to 150% of the Comeliness score. Individuals of the opposite sex will be affected as if under a Fascinate spell unless their Wisdom exceeds two-thirds of the character's Comeliness total. Individuals of the same sex will do likewise unless Wisdom totals at least 50% of the other character's Comeliness score. Rejection of harsh nature can cause the individual rejected to have a reaction as if the character had negative Comeliness of half the actual (positive) score."};
    aComeliness[21] = {"You're beautiful. Hover for more.",
                       "The beauty of the character will cause heads to turn and hearts to race. Reaction for initial contact is at a percent equal to 150% of the Comeliness score. Individuals of the opposite sex will be affected as if under a Fascinate spell unless their Wisdom exceeds two-thirds of the character's Comeliness total. Individuals of the same sex will do likewise unless Wisdom totals at least 50% of the other character's Comeliness score. Rejection of harsh nature can cause the individual rejected to have a reaction as if the character had negative Comeliness of half the actual (positive) score."};
    aComeliness[22] = {"You are stunning. Hover for more.",
                       "The stunning beauty and gorgeous looks of a character with so high a Comeliness will be similar to that of those of lesser beauty (18-21). However, individuals will actually flock around the character, follow him, and generally behave foolishly or in some manner so as to attract the attention of the character. The reaction adjustment is double the score of Comeliness. Fascinate-like power will affect all those with Wisdom less than two-thirds the Comeliness score of the character. If an individual of the opposite sex is actually consciously sought by a character with Comeliness of 22-25, that individual will be effectively Fascinated unless his Wisdom is 18 or higher."};
    aComeliness[23] = {"You are stunning. Hover for more.",
                       "The stunning beauty and gorgeous looks of a character with so high a Comeliness will be similar to that of those of lesser beauty (18-21). However, individuals will actually flock around the character, follow him, and generally behave foolishly or in some manner so as to attract the attention of the character. The reaction adjustment is double the score of Comeliness. Fascinate-like power will affect all those with Wisdom less than two-thirds the Comeliness score of the character. If an individual of the opposite sex is actually consciously sought by a character with Comeliness of 22-25, that individual will be effectively Fascinated unless his Wisdom is 18 or higher."};
    aComeliness[24] = {"You are stunning. Hover for more.",
                       "The stunning beauty and gorgeous looks of a character with so high a Comeliness will be similar to that of those of lesser beauty (18-21). However, individuals will actually flock around the character, follow him, and generally behave foolishly or in some manner so as to attract the attention of the character. The reaction adjustment is double the score of Comeliness. Fascinate-like power will affect all those with Wisdom less than two-thirds the Comeliness score of the character. If an individual of the opposite sex is actually consciously sought by a character with Comeliness of 22-25, that individual will be effectively Fascinated unless his Wisdom is 18 or higher."};
    aComeliness[25] = {"You are stunning. Hover for more.",
                       "The stunning beauty and gorgeous looks of a character with so high a Comeliness will be similar to that of those of lesser beauty (18-21). However, individuals will actually flock around the character, follow him, and generally behave foolishly or in some manner so as to attract the attention of the character. The reaction adjustment is double the score of Comeliness. Fascinate-like power will affect all those with Wisdom less than two-thirds the Comeliness score of the character. If an individual of the opposite sex is actually consciously sought by a character with Comeliness of 22-25, that individual will be effectively Fascinated unless his Wisdom is 18 or higher."};
end

function initializeDefaultArmorVsDamageTypeModifiers()
    aDefaultArmorVsDamageTypeModifiers["banded mail"] = {
        ["slashing"] = -2,
        ["piercing"] = 0,
        ["bludgeoning"] = -1
    };
    aDefaultArmorVsDamageTypeModifiers["bandedmail"] = {
        ["slashing"] = -2,
        ["piercing"] = 0,
        ["bludgeoning"] = -1
    };
    aDefaultArmorVsDamageTypeModifiers["brigandine"] = {
        ["slashing"] = -1,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["chain mail"] = {
        ["slashing"] = -2,
        ["piercing"] = 0,
        ["bludgeoning"] = 2
    };
    aDefaultArmorVsDamageTypeModifiers["chainmail"] = {
        ["slashing"] = -2,
        ["piercing"] = 0,
        ["bludgeoning"] = 2
    };
    aDefaultArmorVsDamageTypeModifiers["field plate"] = {
        ["slashing"] = -3,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["full plate"] = {
        ["slashing"] = -4,
        ["piercing"] = -3,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["studded leather"] = {
        ["slashing"] = -2,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["leather armor"] = {
        ["slashing"] = 0,
        ["piercing"] = 2,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["padded armor"] = {
        ["slashing"] = 0,
        ["piercing"] = 2,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["hide armor"] = {
        ["slashing"] = 0,
        ["piercing"] = 2,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["ring mail"] = {
        ["slashing"] = -1,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["ringmail"] = {
        ["slashing"] = -1,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["scale mail"] = {
        ["slashing"] = 0,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["scalemail"] = {
        ["slashing"] = 0,
        ["piercing"] = -1,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["splint mail"] = {
        ["slashing"] = 0,
        ["piercing"] = -1,
        ["bludgeoning"] = -2
    };
    aDefaultArmorVsDamageTypeModifiers["splintmail"] = {
        ["slashing"] = 0,
        ["piercing"] = -1,
        ["bludgeoning"] = -2
    };
    aDefaultArmorVsDamageTypeModifiers["plate mail"] = {
        ["slashing"] = -3,
        ["piercing"] = 0,
        ["bludgeoning"] = 0
    };
    aDefaultArmorVsDamageTypeModifiers["platemail"] = {
        ["slashing"] = -3,
        ["piercing"] = 0,
        ["bludgeoning"] = 0
    };
end

function initializeHitLocations()
    aHitLocations["humanoid"] = {
        [1] = {
            desc = "right leg",
            categoryNames = {"leg"},
            locationCategory = 1
        },
        [2] = {
            desc = "right leg",
            categoryNames = {"leg"},
            locationCategory = 1
        },
        [3] = {
            desc = "left leg",
            categoryNames = {"leg"},
            locationCategory = 1
        },
        [4] = {
            desc = "left leg",
            categoryNames = {"leg"},
            locationCategory = 1
        },
        [5] = {
            desc = "abdomen",
            categoryNames = {"abdomen", "groin"},
            locationCategory = 2
        },
        [6] = {
            desc = "torso",
            categoryNames = {"torso", "chest"},
            locationCategory = 3
        },
        [7] = {
            desc = "torso",
            categoryNames = {"torso", "chest"},
            locationCategory = 3
        },
        [8] = {
            desc = "right arm",
            categoryNames = {"arm", "hand"},
            locationCategory = 4
        },
        [9] = {
            desc = "left arm",
            categoryNames = {"arm", "hand"},
            locationCategory = 4
        },
        [10] = {
            desc = "head",
            categoryNames = {"head", "eye", "neck"},
            locationCategory = 5
        }
    };

    aHitLocations["animal"] = {
        [1] = {
            desc = "right foreleg/wing",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [2] = {
            desc = "left foreleg/wing",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [3] = {
            desc = "right hind leg",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [4] = {
            desc = "left hind leg",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [5] = {
            desc = "tail",
            categoryNames = {"tail"},
            locationCategory = 2
        },
        [6] = {
            desc = "abdomen",
            categoryNames = {"abdomen", "groin"},
            locationCategory = 3
        },
        [7] = {
            desc = "abdomen",
            categoryNames = {"abdomen", "groin"},
            locationCategory = 3
        },
        [8] = {
            desc = "torso",
            categoryNames = {"torso", "chest"},
            locationCategory = 4
        },
        [9] = {
            desc = "torso",
            categoryNames = {"torso", "chest"},
            locationCategory = 4
        },
        [10] = {
            desc = "head",
            categoryNames = {"head", "eye", "neck"},
            locationCategory = 5
        }
    };

    aHitLocations["monster"] = {
        [1] = {
            desc = "right foreleg/claw/wing",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [2] = {
            desc = "left foreleg/claw/wing",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [3] = {
            desc = "right hind leg",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [4] = {
            desc = "left hind leg",
            categoryNames = {"leg", "arm", "hand", "wing", "claw"},
            locationCategory = 1
        },
        [5] = {
            desc = "tail",
            categoryNames = {"tail"},
            locationCategory = 2
        },
        [6] = {
            desc = "abdomen",
            categoryNames = {"abdomen", "groin"},
            locationCategory = 3
        },
        [7] = {
            desc = "abdomen",
            categoryNames = {"abdomen", "groin"},
            ocationCategory = 3
        },
        [8] = {
            desc = "torso",
            categoryNames = {"torso", "chest"},
            locationCategory = 4
        },
        [9] = {
            desc = "torso",
            categoryNames = {"torso", "chest"},
            locationCategory = 4
        },
        [10] = {
            desc = "head",
            categoryNames = {"head", "eye", "neck"},
            locationCategory = 5
        }
    };

end

function initializeDefaultRaceSizes()
    -- Size category: T = 1, S = 2, M = 3, L = 4, H = 5, G = 6
    -- medium is assumed unless specified here
    aDefaultRaceSizes = {
        ["dwarf"] = 3,
        ["elf"] = 3,
        ["gnome"] = 2,
        ["half-elf"] = 3,
        ["halfling"] = 2,
        ["human"] = 3
    };
end

function initializelocationCategorys()
    -- aCritCharts[sCreatureType][sDamageType][nCritLocationGroup][nSeverity]

    -- crit effects:
    -- reduced mvoe
    -- knockdown
    -- armor damage
    -- shield damage
    -- conditional check if armor exists
    -- minor bleeding, major bleeding
    -- attack penalty
    -- no attack
    -- tripled damaged dice
    -- stun
    -- body part "injured" or "broken" or "shattered"
    -- internal bleeding
    -- Drop to 0 HP
    -- weapon/shield/item dropped
    -- permanent stat loss

    -- 1-4 leg
    -- 5 = abdomen (humanoid) or tail(monster/animal)
    -- 6-7 = torso (humanoid) or abdomen(monster/animal)
    -- 8-9 = arm (humanoid) or torso(monster/animal)
    -- 10 = head

    aCritCharts["humanoid"] = {
        ["bludgeoning"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim knocked down."
                },
                [5] = {
                    desc = "Knee struck, knockdown, 1/2 move."
                },
                [6] = {
                    desc = "Foot broken, 1/2 move."
                },
                [7] = {
                    desc = "Armor damaged, leg injured if target has no armor to cover legs, 1/4 move."
                },
                [8] = {
                    desc = "Hip broken, minor bleeding, no move."
                },
                [9] = {
                    desc = "Armor damaged, leg broken if target has no armor to cover legs, no move."
                },
                [10] = {
                    desc = "Knee shattered, no move, -2 penalty to attacks."
                },
                [11] = {
                    desc = "Hip shattered, minor bleeding, no move or attack."
                },
                [12] = {
                    desc = "Leg shattered, no move or attack, major bleeding from compound fractures."
                },
                [13] = {
                    desc = "Leg shattered, no move or attack, major bleeding from compound fractures, tripled damaged dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim stunned 1d6 rounds."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 1/2 move."
                },
                [6] = {
                    desc = "Armor damaged, victim stunned 1d6 rounds, triple damage if no armor."
                },
                [7] = {
                    desc = "Abdomen injured, 1/2 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Abdomen injured, minor internal bleeding, 1/2 move and -2 penalty to attacks."
                },
                [9] = {
                    desc = "Armor damaged, abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks."
                },
                [10] = {
                    desc = "Abdomen injured, no move or attack, minor internal bleeding."
                },
                [11] = {
                    desc = "Abdomen crushed, no move or attack, major internal bleeding."
                },
                [12] = {
                    desc = "Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding."
                },
                [13] = {
                    desc = "Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding, triped damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Knockdown, stunned 1d4 round."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round and reduced to 1/2 move."
                },
                [6] = {
                    desc = "Shield damage, torso struck, 1/2 move."
                },
                [7] = {
                    desc = "Armor damage, torso struck, 1/2 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, minor internal bleeding, no move or attack."
                },
                [9] = {
                    desc = "Ribs broken, minor internal bleeding, 1/2 move, -2 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, major internal bleeding, no move or attack."
                },
                [11] = {
                    desc = "Torso crushed, victim reduced to 0 hit points with severe internal bleeding."
                },
                [12] = {
                    desc = "Torso crushed, victim killed."
                },
                [13] = {
                    desc = "Torso crushed, victim killed, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Hand struck, weapon/shield dropped ."
                },
                [5] = {
                    desc = "Arm struck, shield damage/weapon dropped."
                },
                [6] = {
                    desc = "Hand broken, -2 penalty to attacks/shield dropped ."
                },
                [7] = {
                    desc = "Armor damage, arm broken if victim has no armor to cover limb ."
                },
                [8] = {
                    desc = "Shield damage, arm broken, stunned 1 round."
                },
                [9] = {
                    desc = "Weapon dropped, arm broken, stunned 1d4 rounds."
                },
                [10] = {
                    desc = "Shoulder injured, no attacks, minor bleeding."
                },
                [11] = {
                    desc = "Arm shattered, 1/2 move, no attacks, minor bleeding."
                },
                [12] = {
                    desc = "Shoulder shattered, no move or attacks, major bleeding."
                },
                [13] = {
                    desc = "Shoulder shattered, no move or attacks, major bleeding, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim stunned 1d6 rounds ."
                },
                [5] = {
                    desc = "Head struck, helm removed, victim stunned 1 round; -2 penalty to attack rolls if victim had no helm."
                },
                [6] = {
                    desc = "Head struck, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Helm damaged, face injured, stunned 1d6 rounds, 1/2 move, -4 penalty to attacks ."
                },
                [8] = {
                    desc = "Skull broken, helm damaged, victim reduced to 0 hit points and unconscious 1d4 hours ."
                },
                [9] = {
                    desc = "Face crushed, minor bleeding, no move or attack, Cha drops by 2 points permanently ."
                },
                [10] = {
                    desc = "Head injured, unconscious 1d6 days, lose 1 point each of Int/Wis/Cha permanently ."
                },
                [11] = {
                    desc = "Skull crushed, reduced to 0 hit points, major bleeding, Int, Wis, Cha all drop by 1/2 permanently."
                },
                [12] = {
                    desc = "Skull crushed, immediate death."
                },
                [13] = {
                    desc = "Skull crushed, immediate death, tripled damage dice."
                }
            }
        },
        ["slashing"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Leg struck, minor bleeding."
                },
                [5] = {
                    desc = "Leg struck, minor bleeding; 1/2 move."
                },
                [6] = {
                    desc = "Leg injured, major bleeding, 1/2 move."
                },
                [7] = {
                    desc = "Armor damaged; leg injured if target has no leg armor, 1/2 move, major bleeding."
                },
                [8] = {
                    desc = "Knee shattered, major bleeding, no move, -4 penalty to any attacks."
                },
                [9] = {
                    desc = "Armor damaged, leg struck, minor bleeding, 1/2 move; if target has no leg armor, leg severed at knee, severe bleeding, no move or attack."
                },
                [10] = {
                    desc = "Hip shattered, no move or attack, severe bleeding."
                },
                [11] = {
                    desc = "Leg severed, severe bleeding, no move or attack."
                },
                [12] = {
                    desc = "Leg severed at thigh, no move or attack, victim reduced to 0 hit points with severe bleeding."
                },
                [13] = {
                    desc = "Leg severed at thigh, no move or attack, victim reduced to 0 hit points with severe bleeding, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Abdomen grazed, minor bleeding."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 1/2 move with minor bleeding."
                },
                [6] = {
                    desc = "Armor damaged; victim stunned 1d6 rounds, major bleeding, 1/2 move if no armor."
                },
                [7] = {
                    desc = "Abdomen injured, major bleeding, 1/2 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Abdomen injured, severe bleeding, 1/2 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Armor damage, abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks; if no armor, victim at 0 hit points, major bleeding."
                },
                [10] = {
                    desc = "Abdomen injured, no move or attack, severe bleeding."
                },
                [11] = {
                    desc = "Abdomen injured, victim at 0 hp, severe bleeding."
                },
                [12] = {
                    desc = "Abdomen destroyed, victim killed."
                },
                [13] = {
                    desc = "Abdomen destroyed, victim killed, tripled damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Torso grazed, minor bleeding."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round, reduced to 1/2 move with minor bleeding ."
                },
                [6] = {
                    desc = "Shield damage, torso struck, 1/2 move & minor bleeding."
                },
                [7] = {
                    desc = "Armor damage, torso struck, 1/2 move, -2 penalty to attacks; if no armor, torso injured, no move or attack, severe bleeding."
                },
                [8] = {
                    desc = "Torso injured, major bleeding, 1/2 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Shield damage; torso struck, -2 penalty to attacks; if no shield, torso injured, severe bleeding, no move or attack."
                },
                [10] = {
                    desc = "Torso injured, severe bleeding, no move or attack."
                },
                [11] = {
                    desc = "Torso destroyed, victim reduced to 0 hit points with severe bleeding."
                },
                [12] = {
                    desc = "Torso destroyed, victim killed."
                },
                [13] = {
                    desc = "Torso destroyed, victim killed, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Hand struck, weapon dropped, minor bleeding; no effect on shield arm."
                },
                [5] = {
                    desc = "Arm struck, shield damage/weapon dropped, minor bleeding."
                },
                [6] = {
                    desc = "Hand injured, -2 penalty to attacks/shield dropped."
                },
                [7] = {
                    desc = "Armor damage, arm struck, minor bleeding; if no armor, arm injured, major bleeding."
                },
                [8] = {
                    desc = "Hand severed, stunned 1 round, major bleeding, shield or weapon dropped."
                },
                [9] = {
                    desc = "Armor damage, arm broken; if no armor, arm severed, stunned 1 d6 rounds, major bleeding."
                },
                [10] = {
                    desc = "Shoulder injured, no attacks, major bleeding."
                },
                [11] = {
                    desc = "Shoulder injured, no attacks, major bleeding."
                },
                [12] = {
                    desc = "Arm severed, no move or attacks, severe bleeding."
                },
                [13] = {
                    desc = "Arm severed, no move or attacks, severe bleeding, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Head grazed, stunned 1d3 rounds, minor bleeding."
                },
                [5] = {
                    desc = "Head struck, helm removed, victim stunned 1 round; -2 penalty to attack rolls, minor bleeding if victim had no helm."
                },
                [6] = {
                    desc = "Head struck, minor bleeding, victim blinded for 2d4 rounds by blood in eyes."
                },
                [7] = {
                    desc = "Helm damaged, face injured, stunned 2d6 rounds, minor bleeding, A move, -4 penalty to attacks."
                },
                [8] = {
                    desc = "Skull broken, helm damaged, victim reduced to 0 hit points, major bleeding."
                },
                [9] = {
                    desc = "Throat injured, severe bleeding."
                },
                [10] = {
                    desc = "Skull destroyed, victim reduced to 0 hp, severe bleeding, Int, Wis, Cha all drop by 1/2 permanently."
                },
                [11] = {
                    desc = "Throat destroyed, victim killed."
                },
                [12] = {
                    desc = "Head severed, immediate death."
                },
                [13] = {
                    desc = "Head severed, immediate death, tripled damage dice."
                }
            }
        },
        ["piercing"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Leg grazed, victim knocked down."
                },
                [5] = {
                    desc = "Leg struck, minor bleeding."
                },
                [6] = {
                    desc = "Leg injured, minor bleeding, 2/3 move."
                },
                [7] = {
                    desc = "Armor damaged; leg injured if target has no leg armor, 1/2 move, major bleeding."
                },
                [8] = {
                    desc = "Knee broken, minor bleeding, 1/3 move, -4 penalty to any attacks."
                },
                [9] = {
                    desc = "Armor damaged, leg struck, minor bleeding, 2/3 move; if target has no leg armor, leg broken, major bleeding, 1/3 move, -4 penalty to attacks."
                },
                [10] = {
                    desc = "Hip broken, no move or attack, major bleeding."
                },
                [11] = {
                    desc = "Leg broken, severe bleeding, no move or attack."
                },
                [12] = {
                    desc = "Leg destroyed, no move or attack, severe bleeding."
                },
                [13] = {
                    desc = "Leg destroyed, no move or attack, severe bleeding, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Abdomen grazed, minor bleeding."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 2/3 move with minor bleeding."
                },
                [6] = {
                    desc = "Armor damaged; victim stunned 1d4 rounds, minor bleeding, 2/3 move if no armor."
                },
                [7] = {
                    desc = "Abdomen injured, major bleeding, 1/2 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Abdomen injured, severe bleeding, 1/2 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Armor damage, abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks; if no armor, victim at 0 hit points, major bleeding."
                },
                [10] = {
                    desc = "Abdomen injured, 1/3 move, no attack, severe bleeding."
                },
                [11] = {
                    desc = "Abdomen injured, victim at 0 hp, severe bleeding."
                },
                [12] = {
                    desc = "Abdomen destroyed, victim killed."
                },
                [13] = {
                    desc = "Abdomen destroyed, victim killed, tripled damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Torso grazed, minor bleeding."
                },
                [5] = {
                    desc = "Torso struck, 2/3 move with minor bleeding."
                },
                [6] = {
                    desc = "Shield damage, torso struck, 2/3 move & minor bleeding."
                },
                [7] = {
                    desc = "Armor damage, torso struck, 2/3 move, -2 penalty to attacks; if no armor, torso injured, no move or attack, severe bleeding."
                },
                [8] = {
                    desc = "Torso injured, major bleeding, 1/2 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Shield damage; torso struck, -2 penalty to attacks; if no shield, ribs broken, severe bleeding, no move or attack."
                },
                [10] = {
                    desc = "Ribs broken, severe bleeding, no move or attack."
                },
                [11] = {
                    desc = "Torso destroyed, victim reduced to 0 hit points with severe bleeding."
                },
                [12] = {
                    desc = "Torso destroyed, victim killed."
                },
                [13] = {
                    desc = "Torso destroyed, victim killed, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Hand struck, weapon dropped, minor bleeding; no effect on shield arm."
                },
                [5] = {
                    desc = "Arm struck, shield damage/weapon dropped, minor bleeding."
                },
                [6] = {
                    desc = "Hand injured, -2 penalty to attacks/shield dropped."
                },
                [7] = {
                    desc = "Armor damage, arm struck, minor bleeding; if no armor, arm injured, minor bleeding."
                },
                [8] = {
                    desc = "Arm broken, victim stunned 1 round, minor bleeding, shield or weapon dropped."
                },
                [9] = {
                    desc = "Armor damage, arm injured, -2 penalty to attacks or shield dropped; if no armor, arm broken, stunned 1d6 rounds, major bleeding."
                },
                [10] = {
                    desc = "Shoulder injured, no attacks, major bleeding."
                },
                [11] = {
                    desc = "Arm destroyed, major bleeding, 2/3 move."
                },
                [12] = {
                    desc = "Arm destroyed, no move/attack, major bleeding."
                },
                [13] = {
                    desc = "Arm destroyed, no move/attack, major bleeding, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Head grazed, stunned 1d3 rounds, minor bleeding."
                },
                [5] = {
                    desc = "Head struck, helm removed, victim stunned 1 round; -2 penalty to attack rolls, minor bleeding if victim had no helm."
                },
                [6] = {
                    desc = "Eye injured, -4 penalty to all attacks; if helmed, victim is only stunned 1 round instead."
                },
                [7] = {
                    desc = "Helm damaged, face injured, stunned 1d6 rounds, minor bleeding, 2/3 move, -4 penalty to attack."
                },
                [8] = {
                    desc = "Skull broken, helm damaged, victim reduced to 0 hit points, major bleeding."
                },
                [9] = {
                    desc = "Throat injured, severe bleeding."
                },
                [10] = {
                    desc = "Skull broken, victim reduced to 0 hp, major bleeding, Int, Wis, Cha all drop by 1/2 permanently."
                },
                [11] = {
                    desc = "Throat destroyed, victim killed."
                },
                [12] = {
                    desc = "Head destroyed, immediate death."
                },
                [13] = {
                    desc = "Head destroyed, immediate death, tripled damage dice."
                }
            }
        }
    };
    aCritCharts["animal"] = {
        ["bludgeoning"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim knocked down."
                },
                [5] = {
                    desc = "Knee struck, victim reduced to 2/3 move."
                },
                [6] = {
                    desc = "Foot/wrist broken, 2/3 move."
                },
                [7] = {
                    desc = "Leg injured, 2/3 move, -2 penalty to attack."
                },
                [8] = {
                    desc = "Hip broken, minor bleeding, no movement, -2 penalty to attacks; wing hit forces crash landing."
                },
                [9] = {
                    desc = "Leg broken, 2/3 move, minor bleeding; wing hit forces immediate landing."
                },
                [10] = {
                    desc = "Knee shattered, 1/3 move, -2 penalty to attacks."
                },
                [11] = {
                    desc = "Hip/shoulder shattered, minor bleeding, no move or attack; wing hit forces crash landing."
                },
                [12] = {
                    desc = "Leg/wing shattered, no move or attack, major bleeding from compound fractures."
                },
                [13] = {
                    desc = "Leg/wing shattered, no move or attack, major bleeding from compound fractures, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "No unusual effect."
                },
                [5] = {
                    desc = "No unusual effect."
                },
                [6] = {
                    desc = "Tip of tail struck; if prehensile, any items carried are dropped, -2 penalty to tail attacks due to pain."
                },
                [7] = {
                    desc = "Tail injured, normal animals must save vs. death or retreat in pain; lose any tail attacks."
                },
                [8] = {
                    desc = "Tail injured, normal animals must save vs. death or retreat in pain; lose any tail attacks."
                },
                [9] = {
                    desc = "Tail broken, lose any tail attacks, 1/2 move if animal uses tail for movement."
                },
                [10] = {
                    desc = "Tail broken, lose any tail attacks, 1/2 move if animal uses tail for movement."
                },
                [11] = {
                    desc = "Tail crushed, victim stunned 1-3 rounds, lose any tail attacks, no movement or attacks if animal uses tail for movement."
                },
                [12] = {
                    desc = "Tail crushed, pain reduces creature to 1/2 move and -2 penalty on any attack, minor bleeding; no move or attack if animal uses tail for movement."
                },
                [13] = {
                    desc = "Tail crushed, pain reduces creature to 1/2 move and -2 penalty on any attack, minor bleeding; no move or attack if animal uses tail for movement, tripled damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim stunned 1d6 round."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 1/2 move."
                },
                [6] = {
                    desc = "Abdomen struck, victim stunned 1d6 rounds, reduced to 1/2 move."
                },
                [7] = {
                    desc = "Abdomen injured, 1/2 move, -2 penalty to attack."
                },
                [8] = {
                    desc = "Spine broken, no move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks."
                },
                [10] = {
                    desc = "Abdomen injured, no move or attack, minor internal bleeding."
                },
                [11] = {
                    desc = "Spine crushed, no move or attack, major internal bleeding."
                },
                [12] = {
                    desc = "Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding."
                },
                [13] = {
                    desc = "Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Knockdown, stunned 1d4 rounds."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round and reduced to 1/2 move."
                },
                [6] = {
                    desc = "Torso struck, stunned 1d6 rounds, 1/2 move."
                },
                [7] = {
                    desc = "Spine struck, 1/2 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, minor internal bleeding, no move or attack."
                },
                [9] = {
                    desc = "Ribs broken, minor internal bleeding, 1/2 move, -2 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, major internal bleeding, no move or attack."
                },
                [11] = {
                    desc = "Spine crushed, victim reduced to 0 hit points with severe internal bleeding."
                },
                [12] = {
                    desc = "Torso crushed, victim killed."
                },
                [13] = {
                    desc = "Torso crushed, victim killed, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim stunned 1d6 rounds."
                },
                [5] = {
                    desc = "Snout struck, animal must save vs. death or retreat in pain for 1dl0 rounds."
                },
                [6] = {
                    desc = "Head struck, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Jaw injured, stunned 1d6 rounds, 2/3 move, -4 penalty to all attacks."
                },
                [8] = {
                    desc = "Skull broken, animal reduced to 0 hit points and unconscious 1d4 hours."
                },
                [9] = {
                    desc = "Snout/face crushed, minor bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks."
                },
                [10] = {
                    desc = "Head injured, unconscious 2d4 hours, reduced to 1/2move and -4 penalty to all attacks for 1d3 months."
                },
                [11] = {
                    desc = "Skull crushed, reduced to 0 hit points, major bleeding, Int, Wis, Cha all drop by 1/2 permanently."
                },
                [12] = {
                    desc = "Skull crushed, immediate death."
                },
                [13] = {
                    desc = "Skull crushed, immediate death, tripled damage dice."
                }
            }
        },
        ["slashing"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Leg struck, minor bleeding."
                },
                [5] = {
                    desc = "Knee struck, 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Leg injured, major bleeding, 2/3 move."
                },
                [7] = {
                    desc = "Foot/claw injured, 2/3 move, minor bleeding, -2 penalty to attacks with that limb."
                },
                [8] = {
                    desc = "Hip injured, major bleeding, 1/3 movement, -2 penalty to attacks; wing hit forces crash landing."
                },
                [9] = {
                    desc = "Leg/wing severed at midpoint, 1/3 move, major bleeding; wing hit forces uncontrolled fall."
                },
                [10] = {
                    desc = "Knee destroyed, major bleeding, 1/3 move, -2 penalty to all attacks."
                },
                [11] = {
                    desc = "Hip/shoulder destroyed, severe bleeding, no move or attack; wing hit forces crash landing."
                },
                [12] = {
                    desc = "Leg/wing severed at mid-thigh, no move or attack, severe bleeding."
                },
                [13] = {
                    desc = "Leg/wing severed at mid-thigh, no move or attack, severe bleeding, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "No unusual effect."
                },
                [5] = {
                    desc = "No unusual effect."
                },
                [6] = {
                    desc = "Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks."
                },
                [7] = {
                    desc = "Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks."
                },
                [8] = {
                    desc = "Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks."
                },
                [9] = {
                    desc = "Tail severed near end, major bleeding, lose tail attacks, move reduced by 1/3 if creature uses tail for movement."
                },
                [10] = {
                    desc = "Tail severed near end, major bleeding, lose tail attacks, move reduced by 1/3 if creature uses tail for movement."
                },
                [11] = {
                    desc = "Tail severed, victim stunned 1-3 rounds, lose tail attacks, major bleeding, no movement or attacks if animal uses tail for movement."
                },
                [12] = {
                    desc = "Tail severed, stunned 1-3 rounds, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack."
                },
                [13] = {
                    desc = "Tail severed, stunned 1-3 rounds, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack, tripled damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Abdomen grazed, minor bleeding."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Abdomen struck, victim stunned 1d6 rounds, reduced to 2/3 move, minor bleeding ."
                },
                [7] = {
                    desc = "Abdomen injured, 1/3 move, minor bleeding, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Spine injured, no move, minor bleeding, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Abdomen injured, major bleeding, 1/3 move and -2 penalty to attacks."
                },
                [10] = {
                    desc = "Abdomen injured, no move or attack, major bleeding."
                },
                [11] = {
                    desc = "Spine destroyed, no move or attack, major bleeding, victim paralyzed."
                },
                [12] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with severe bleeding."
                },
                [13] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with severe bleeding, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Torso grazed, minor bleeding."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Torso struck, stunned 1d6 rounds, minor bleeding."
                },
                [7] = {
                    desc = "Spine struck, major bleeding, 2/3 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, severe bleeding, no move or attack."
                },
                [9] = {
                    desc = "Ribs broken, major bleeding, 1/3 move, -4 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, severe bleeding, no move or attack ."
                },
                [11] = {
                    desc = "Spine destroyed, victim reduced to 0 hit points with severe bleeding."
                },
                [12] = {
                    desc = "Torso destroyed, victim killed."
                },
                [13] = {
                    desc = "Torso destroyed, victim killed, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Head grazed, stunned 1 round, minor bleeding."
                },
                [5] = {
                    desc = "Snout struck, minor bleeding, animal must save vs. death or retreat for 1d10 rounds."
                },
                [6] = {
                    desc = "Head struck, minor bleeding, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Throat injured, major bleeding, 2/3 move, -4 penalty to all attacks."
                },
                [8] = {
                    desc = "Skull broken, animal reduced to 0 hit points, major bleeding."
                },
                [9] = {
                    desc = "Snout/face destroyed, major bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks."
                },
                [10] = {
                    desc = "Head injured, reduced to 0 hp, severe bleeding; 1/3 move and -4 penalty to all attacks for 1d3 months."
                },
                [11] = {
                    desc = "Throat destroyed, severe bleeding."
                },
                [12] = {
                    desc = "Head severed, immediate death."
                },
                [13] = {
                    desc = "Head severed, immediate death, tripled damage dice."
                }
            }
        },
        ["piercing"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Leg struck, minor bleeding."
                },
                [5] = {
                    desc = "Knee struck, 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Leg injured, minor bleeding, 2/3 move."
                },
                [7] = {
                    desc = "Foot/claw injured, minor bleeding, -2 penalty to attacks with that limb."
                },
                [8] = {
                    desc = "Hip injured, minor bleeding, 2/3 movement, -2 penalty to all attacks; wing hit forces crash landing."
                },
                [9] = {
                    desc = "Leg/wing broken, 1/3 move, minor bleeding; wing hit forces crash landing."
                },
                [10] = {
                    desc = "Knee broken, minor bleeding, 1/3 move, -2 penalty to all attacks."
                },
                [11] = {
                    desc = "Hip/shoulder destroyed, major bleeding, no move or attack; wing hit forces crash landing."
                },
                [12] = {
                    desc = "Leg/wing destroyed, no move or attack, major bleeding."
                },
                [13] = {
                    desc = "Leg/wing destroyed, no move or attack, major bleeding, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "No unusual effect."
                },
                [5] = {
                    desc = "No unusual effect."
                },
                [6] = {
                    desc = "Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks."
                },
                [7] = {
                    desc = "Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks."
                },
                [8] = {
                    desc = "Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks."
                },
                [9] = {
                    desc = "Tail injured, minor bleeding, lose tail attacks; if creature uses tail for movement, 1/3 move."
                },
                [10] = {
                    desc = "Tail injured, minor bleeding, lose tail attacks; if creature uses tail for movement, 1/3 move."
                },
                [11] = {
                    desc = "Tail destroyed, victim stunned 1-3 rounds, lose tail attacks, major bleeding, no movement or attacks if animal uses tail for movement."
                },
                [12] = {
                    desc = "Tail destroyed, stunned 1d2 rounds, major bleeding, 1/2 move and -2 penalty on attacks; if animal uses tail for movement, no move or attack."
                },
                [13] = {
                    desc = "Tail destroyed, stunned 1d2 rounds, major bleeding, 1/2 move and -2 penalty on attacks; if animal uses tail for movement, no move or attack, tripled damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Abdomen grazed, minor bleeding."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Abdomen struck, victim stunned 1d4 rounds, reduced to 2/3 move, minor bleeding."
                },
                [7] = {
                    desc = "Abdomen injured, 2/3 move, major bleeding, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Spine injured, 1/3 move, minor bleeding, -4 penalty to all attacks."
                },
                [9] = {
                    desc = "Abdomen injured, major bleeding, 1/3 move and -2 penalty to all attacks ."
                },
                [10] = {
                    desc = "Abdomen injured, no move or attack, major bleeding."
                },
                [11] = {
                    desc = "Spine broken, no move or attack, major bleeding, victim paralyzed."
                },
                [12] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with severe bleeding."
                },
                [13] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with severe bleeding, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Torso grazed, minor bleeding."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Torso struck, stunned 1d4 rounds, minor bleeding."
                },
                [7] = {
                    desc = "Spine struck, minor bleeding, 2/3 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, stunned 1 round, major bleeding."
                },
                [9] = {
                    desc = "Ribs broken, minor bleeding, 1/3 move, -4 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, major bleeding, no move or attack."
                },
                [11] = {
                    desc = "Spine destroyed, victim reduced to 0 hit points with major bleeding."
                },
                [12] = {
                    desc = "Torso destroyed, victim killed."
                },
                [13] = {
                    desc = "Torso destroyed, victim killed, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Head grazed, stunned 1 round, minor bleeding ."
                },
                [5] = {
                    desc = "Snout struck, minor bleeding, animal must save vs. death or retreat for 1d10 rounds."
                },
                [6] = {
                    desc = "Eye injured, stunned 1d3 rounds, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Throat injured, major bleeding, 2/3 move, -4 penalty to all attacks."
                },
                [8] = {
                    desc = "Skull broken, animal reduced to 0 hit points, major bleeding."
                },
                [9] = {
                    desc = "Snout/face destroyed, minor bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks."
                },
                [10] = {
                    desc = "Head injured, reduced to 0 hp, major bleeding; 1/3 move and -4 penalty to all attacks for 1d3 months ."
                },
                [11] = {
                    desc = "Throat destroyed, severe bleeding."
                },
                [12] = {
                    desc = "Head severed, immediate death."
                },
                [13] = {
                    desc = "Head severed, immediate death, tripled damage dice."
                }
            }
        }
    };
    aCritCharts["monster"] = {
        ["bludgeoning"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim knocked down."
                },
                [5] = {
                    desc = "Knee struck, victim reduced to 2/3 move, -2 penalty to attacks with that appendage."
                },
                [6] = {
                    desc = "Foot/wrist broken, 2/3 move, -4 penalty to attacks with that appendage."
                },
                [7] = {
                    desc = "Limb injured, 2j/3 move, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Hip broken, minor bleeding, 1/3 move, no attacks with limb; wing hit forces crash landing."
                },
                [9] = {
                    desc = "Limb broken, 2/3 move, minor bleeding; wing hit forces immediate landing."
                },
                [10] = {
                    desc = "Knee shattered, 1/3move, -2 penalty to all attacks."
                },
                [11] = {
                    desc = "Hip/shoulder shattered, minor bleeding, 1/3 move, -4 penalty to all attacks; wing hit forces crash."
                },
                [12] = {
                    desc = "Leg/wing shattered, no move, -4 penalty to all attacks, major bleeding from compound fracture."
                },
                [13] = {
                    desc = "Leg/wing shattered, no move, -4 penalty to all attacks, major bleeding from compound fracture, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "No unusual effect."
                },
                [5] = {
                    desc = "No unusual effect."
                },
                [6] = {
                    desc = "Tip of tail struck; if prehensile, any items carried are dropped, -2 penalty to tail attacks due to pain."
                },
                [7] = {
                    desc = "Tail injured, lose any tail attacks."
                },
                [8] = {
                    desc = "Tail injured, lose any tail attacks."
                },
                [9] = {
                    desc = "Tail broken, lose any tail attacks, if creature uses tail for movement reduced to 1/2 move."
                },
                [10] = {
                    desc = "Tail broken, lose any tail attacks, if creature uses tail for movement reduced to 1/2 move."
                },
                [11] = {
                    desc = "Tail crushed, victim stunned 1-3 rounds, lose any tail attacks, no movement if monster uses tail for movement and -4 penalty to all attacks."
                },
                [12] = {
                    desc = "Tail crushed, pain reduces creature to 1/2 move and -2 penalty on any attack, minor bleeding; if animal uses tail for movement, no move or attack."
                },
                [13] = {
                    desc = "Tail crushed, pain reduces creature to xh move and -2 penalty on any attack, minor bleeding; if animal uses tail for movement, no move or attack, triple damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim stunned 1d4 rounds."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round and reduced to 2/3 move."
                },
                [6] = {
                    desc = "Abdomen struck, victim stunned 1d6 rounds, reduced to 2/3 move ."
                },
                [7] = {
                    desc = "Abdomen injured, 1/2 move, -2 penalty to attacks ."
                },
                [8] = {
                    desc = "Spine injured, 1/3 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Abdomen injured, victim stunned 1d3 rounds, minor bleeding, 1/3 move and -2 penalty to attacks."
                },
                [10] = {
                    desc = "Abdomen injured, no move or attack, minor internal bleeding."
                },
                [11] = {
                    desc = "Spine crushed, no move or attack, major internal bleeding."
                },
                [12] = {
                    desc = "Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding."
                },
                [13] = {
                    desc = "Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Knockdown, stunned 1d4 rounds."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round and reduced to 2/3 move."
                },
                [6] = {
                    desc = "Torso struck, stunned 1d6 rounds, 2/3 move."
                },
                [7] = {
                    desc = "Spine struck, 1/2 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, minor internal bleeding, 1/3 move, -4 penalty to all attacks."
                },
                [9] = {
                    desc = "Ribs broken, minor internal bleeding, 1/2 move, -2 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, major internal bleeding, no move or attack."
                },
                [11] = {
                    desc = "Spine crushed, victim reduced to 0 hit points with severe internal bleeding."
                },
                [12] = {
                    desc = "Torso crushed, victim killed."
                },
                [13] = {
                    desc = "Torso crushed, victim killed, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Victim stunned 1d4 rounds."
                },
                [5] = {
                    desc = "Jaw struck, -2 penalty to any bite attacks."
                },
                [6] = {
                    desc = "Head struck, stunned 1 round, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Jaw injured, stunned 1d4 rounds, 2/3 move, no bite attacks."
                },
                [8] = {
                    desc = "Skull broken, monster reduced to 1/4 normal hit points and unconscious 2dl0 turns."
                },
                [9] = {
                    desc = "Snout/face crushed, minor bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks."
                },
                [10] = {
                    desc = "Head injured, unconscious ldl0 turns, reduced to 1/2 move and -4 penalty to all attacks for 3d6 days."
                },
                [11] = {
                    desc = "Skull crushed, reduced to 0 hit points, major bleeding, Int, Wis, Cha all drop by 1/2 permanently."
                },
                [12] = {
                    desc = "Skull crushed, immediate death."
                },
                [13] = {
                    desc = "Skull crushed, immediate death, tripled damage dice."
                }
            }
        },
        ["slashing"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Leg grazed, minor bleeding."
                },
                [5] = {
                    desc = "Knee struck, 2/3 move, minor bleeding."
                },
                [6] = {
                    desc = "Leg struck, minor bleeding, 2/3 move."
                },
                [7] = {
                    desc = "Foot/claw injured, 2/3 move, minor bleeding, -2 penalty to attacks with that limb."
                },
                [8] = {
                    desc = "Hip injured, major bleeding, 1/3 movement; wing hit forces crash landing."
                },
                [9] = {
                    desc = "Leg/wing severed at midpoint, 1/3 move, major bleeding; wing hit forces uncontrolled fall."
                },
                [10] = {
                    desc = "Knee destroyed, major bleeding, 1/3 move, -2 penalty to attacks with affected limb."
                },
                [11] = {
                    desc = "Hip/shoulder destroyed, major bleeding, no move, -4 penalty to attacks; wing hit forces crash landing."
                },
                [12] = {
                    desc = "Leg/wing severed at mid-thigh, no move or attack, severe bleeding."
                },
                [13] = {
                    desc = "Leg/wing severed at mid-thigh, no move or attack, severe bleeding, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "No unusual effect."
                },
                [5] = {
                    desc = "No unusual effect."
                },
                [6] = {
                    desc = "Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks."
                },
                [7] = {
                    desc = "Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks."
                },
                [8] = {
                    desc = "Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks."
                },
                [9] = {
                    desc = "Tail severed, major bleeding, no tail attacks; if creature uses tail for movement, 1/3 move."
                },
                [10] = {
                    desc = "Tail severed, major bleeding, no tail attacks; if creature uses tail for movement, 1/3 move."
                },
                [11] = {
                    desc = "Tail severed, victim stunned 1 round, lose tail attacks, major bleeding; 1/3 movement, -4 penalty to attacks if monster uses tail for movement."
                },
                [12] = {
                    desc = "Tail severed, stunned 1 round, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack."
                },
                [13] = {
                    desc = "Tail severed, stunned 1 round, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack, tripled damage dice."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Abdomen grazed, minor bleeding."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round, minor bleeding."
                },
                [6] = {
                    desc = "Abdomen struck, victim stunned 1d3 rounds, reduced to 2/3 move, minor bleeding."
                },
                [7] = {
                    desc = "Abdomen injured, 1/2 move, minor bleeding, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Spine injured, 1/3 move, minor bleeding, -4 penalty to all attacks."
                },
                [9] = {
                    desc = "Abdomen injured, major bleeding, 1/3 move and -2 penalty to attacks."
                },
                [10] = {
                    desc = "Abdomen injured, 1/3 move, -4 penalty to attacks, major bleeding."
                },
                [11] = {
                    desc = "Spine injured, no move or attack, major bleeding, victim stunned 1d6 rounds."
                },
                [12] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with severe bleeding."
                },
                [13] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with severe bleeding, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Torso grazed, minor bleeding."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round, minor bleeding."
                },
                [6] = {
                    desc = "Torso struck, stunned 1d3 rounds, minor bleeding."
                },
                [7] = {
                    desc = "Spine struck, minor bleeding, 2/3 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, major bleeding, 1/3 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Ribs injured, major bleeding, 1/3 move, -4 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, severe bleeding, 1/3 move, no attack."
                },
                [11] = {
                    desc = "Spine broken, major bleeding, no move or attack."
                },
                [12] = {
                    desc = "Torso destroyed, victim killed."
                },
                [13] = {
                    desc = "Torso destroyed, victim killed, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Head grazed, minor bleeding."
                },
                [5] = {
                    desc = "Snout struck, minor bleeding, monster must save vs. death or retreat for 1 round."
                },
                [6] = {
                    desc = "Head struck, minor bleeding, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Throat injured, major bleeding, 2/3 move, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Skull injured, monster reduced to 2/3 move, major bleeding, -2 penalty to all attacks."
                },
                [9] = {
                    desc = "Snout/face injured, major bleeding, 1/3 move, no bite attacks, -2 penalty to all other attacks."
                },
                [10] = {
                    desc = "Head injured, reduced to 0 hp, major bleeding; 1/3 move and -4 penalty to all attacks for 1d3 weeks."
                },
                [11] = {
                    desc = "Throat destroyed, severe bleeding."
                },
                [12] = {
                    desc = "Head severed, immediate death."
                },
                [13] = {
                    desc = "Head severed, immediate death, tripled damage dice."
                }
            }
        },
        ["piercing"] = {
            [1] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Leg grazed, minor bleeding."
                },
                [5] = {
                    desc = "Knee struck, 2/3 move."
                },
                [6] = {
                    desc = "Leg struck, minor bleeding, 2/3 move."
                },
                [7] = {
                    desc = "Foot/claw injured, minor bleeding, -2 penalty to attacks with that limb."
                },
                [8] = {
                    desc = "Hip injured, minor bleeding, 1/3 movement; wing hit forces crash landing."
                },
                [9] = {
                    desc = "Leg/wing broken, 1/3 move, minor bleeding; wing hit forces crash landing."
                },
                [10] = {
                    desc = "Knee destroyed, major bleeding, 1/3 move, -2 penalty to attacks with affected limb."
                },
                [11] = {
                    desc = "Hip/shoulder destroyed, major bleeding, no move, -4 penalty to attacks; wing hit forces crash landing."
                },
                [12] = {
                    desc = "Leg/wing destroyed, no move or attack, major bleeding."
                },
                [13] = {
                    desc = "Leg/wing destroyed, no move or attack, major bleeding, tripled damage dice."
                }
            },
            [2] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "No unusual effect."
                },
                [5] = {
                    desc = "No unusual effect."
                },
                [6] = {
                    desc = "Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks."
                },
                [7] = {
                    desc = "Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks."
                },
                [8] = {
                    desc = "Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks."
                },
                [9] = {
                    desc = "Tail broken, minor bleeding, no tail attacks; if creature uses tail for movement, 1/3 move."
                },
                [10] = {
                    desc = "Tail broken, minor bleeding, no tail attacks; if creature uses tail for movement, 1/3 move."
                },
                [11] = {
                    desc = "Tail destroyed, victim stunned 1 round, lose tail attacks, major bleeding; 1/3 movement, -4 penalty to attacks if monster uses tail for movement."
                },
                [12] = {
                    desc = "Tail destroyed, stunned 1d3 rounds, major bleeding, 1/3 move and -2 penalty on any attack; if monster uses tail for movement, no move/attack."
                },
                [13] = {
                    desc = "Tail destroyed, stunned 1d3 rounds, major bleeding, 1/3 move and -2 penalty on any attack; if monster uses tail for movement, no move/attack."
                }
            },
            [3] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Abdomen grazed, minor bleeding."
                },
                [5] = {
                    desc = "Abdomen struck, victim stunned 1 round, minor bleeding."
                },
                [6] = {
                    desc = "Abdomen struck, victim stunned 1d3 rounds, minor bleeding."
                },
                [7] = {
                    desc = "Abdomen injured, 2/3 move, minor bleeding, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Spine injured, 1/2 move, minor bleeding, -4 penalty to all attacks."
                },
                [9] = {
                    desc = "Abdomen injured, major bleeding, 1/3 move and -2 penalty to attacks."
                },
                [10] = {
                    desc = "Abdomen injured, ]A move, -4 penalty to attacks, major bleeding."
                },
                [11] = {
                    desc = "Spine injured, no move or attack, major bleeding, victim stunned 1d6 rounds."
                },
                [12] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with major bleeding."
                },
                [13] = {
                    desc = "Abdomen destroyed, victim reduced to 0 hit points with major bleeding, tripled damage dice."
                }
            },
            [4] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Torso grazed, minor bleeding."
                },
                [5] = {
                    desc = "Torso struck, victim stunned 1 round, minor bleeding."
                },
                [6] = {
                    desc = "Torso struck, stunned 1d3 rounds, minor bleeding."
                },
                [7] = {
                    desc = "Spine struck, minor bleeding, 2/3 move, -2 penalty to attacks."
                },
                [8] = {
                    desc = "Torso injured, minor bleeding, 1/3 move, -4 penalty to attacks."
                },
                [9] = {
                    desc = "Ribs injured, major bleeding, 1/3 move, -4 penalty to attacks."
                },
                [10] = {
                    desc = "Ribs broken, major bleeding, 1/3 move, no attack."
                },
                [11] = {
                    desc = "Spine broken, major bleeding, no move or attack."
                },
                [12] = {
                    desc = "Torso destroyed, victim killed."
                },
                [13] = {
                    desc = "Torso destroyed, victim killed, tripled damage dice."
                }
            },
            [5] = {
                [1] = {
                    desc = "No unusual effect."
                },
                [2] = {
                    desc = "No unusual effect."
                },
                [3] = {
                    desc = "No unusual effect."
                },
                [4] = {
                    desc = "Head grazed, minor bleeding."
                },
                [5] = {
                    desc = "Snout struck, minor bleeding, monster must save vs. death or retreat for 1 round."
                },
                [6] = {
                    desc = "Eye injured, stunned 1 round, -2 penalty to attacks."
                },
                [7] = {
                    desc = "Throat injured, major bleeding, 2/3 move, -2 penalty to all attacks."
                },
                [8] = {
                    desc = "Skull injured, monster reduced to 2/3 move, major bleeding, -2 penalty to all attacks."
                },
                [9] = {
                    desc = "Snout/face injured, major bleeding, 1/3 move, no bite attacks, -2 penalty to all other attacks."
                },
                [10] = {
                    desc = "Head injured, reduced to 0 hp, major bleeding; 1/3 move and -4 penalty to all attacks for 1d3 weeks."
                },
                [11] = {
                    desc = "Throat destroyed, severe bleeding."
                },
                [12] = {
                    desc = "Head destroyed, immediate death."
                },
                [13] = {
                    desc = "Head destroyed, immediate death, tripled ddamage dice."
                }
            }
        }
    };

end

function initializeDefaultWeaponSizes()
    aDefaultWeaponSizes = {
        ["arquebus"] = "M",
        ["battle axe"] = "M",
        ["blowgun"] = "S",
        ["heavy crossbow"] = "L", -- must appear before "bow" entry to be found
        ["heavy xbow"] = "L", -- must appear before "bow" entry to be found
        ["bow"] = "M",
        ["club"] = "M",
        ["dagger"] = "S",
        ["dirk"] = "S",
        ["dart"] = "S",
        ["flail"] = "M",
        ["mace"] = "M",
        ["pick"] = "M",
        ["hand axe"] = "M",
        ["throwing axe"] = "M",
        ["harpoon"] = "L",
        ["javelin"] = "M",
        ["knife"] = "S",
        ["lance"] = "L",
        ["mancatcher"] = "L",
        ["morning star"] = "M",
        ["morningstar"] = "M",
        ["awl pike"] = "L",
        ["bardiche"] = "L",
        ["bec de corbin"] = "L",
        ["bill-guisarme"] = "L",
        ["fauchard"] = "L",
        ["glaive"] = "L",
        ["guisarme"] = "L",
        ["voulge"] = "L",
        ["lucern hammer"] = "L",
        ["military fork"] = "L",
        ["partisan"] = "L",
        ["ranseur"] = "L",
        ["spetum"] = "L",
        ["scourge"] = "S",
        ["sickle"] = "S",
        ["sling"] = "S",
        ["staff"] = "L", -- we want this to come after "sling" so "staff sling" doesn't flag as large
        ["bullet"] = "S",
        ["stone"] = "S",
        ["spear"] = "M",
        ["bastard sword"] = "M",
        ["broad sword"] = "M",
        ["khopesh"] = "M",
        ["long sword"] = "M",
        ["longsword"] = "M",
        ["short sword"] = "S",
        ["shortsword"] = "S",
        ["scimitar"] = "M",
        ["two handed sword"] = "L",
        ["two-handed sword"] = "L",
        ["2 handed sword"] = "L",
        ["2-handed sword"] = "L",
        ["2-h sword"] = "L",
        ["2h sword"] = "L",
        ["trident"] = "L",
        ["warhammer"] = "M",
        ["whip"] = "M"
    };
end

function initializeDefaultCreatureTypes()
    aDefaultCreatureTypesByName = {};

    aDefaultCreatureTypesByType = {
        ["giant"] = "humanoid",
        ["golem"] = "humanoid",
        ["dinosaur"] = "animal",
        ["undead"] = "humanoid"
    };
end

function initializeNaturalWeapons()
    -- [sName] = nSizeCategoryDifference
    aNaturalWeapons["bite"] = 0;
    aNaturalWeapons["butt"] = 0;
    aNaturalWeapons["claw"] = -1;
    aNaturalWeapons["fist"] = -1;
    aNaturalWeapons["horn"] = 0;
    aNaturalWeapons["hoof"] = -1;
    aNaturalWeapons["tail"] = 0;
    aNaturalWeapons["sting"] = -1;
    aNaturalWeapons["wing"] = 0;
    aNaturalWeapons["punch"] = -1;
    aNaturalWeapons["slam"] = -1;
    aNaturalWeapons["kick"] = -1;
end

function initializeDefaultArmorDamageReduction()
    aDefaultArmorDamageReduction["field plate"] = 2;
    aDefaultArmorDamageReduction["full plate"] = 2;
end

function initializeDefaultArmorHp()
    aDefaultArmorHp["robes"] = {1};
    aDefaultArmorHp["garments"] = {1};
    aDefaultArmorHp["studded leather"] = {4, 2, 1};
    aDefaultArmorHp["leather armor"] = {2, 1};
    aDefaultArmorHp["padded armor"] = {2, 1};
    aDefaultArmorHp["ring mail"] = {6, 2, 1};
    aDefaultArmorHp["ringmail"] = {6, 2, 1};
    aDefaultArmorHp["scale mail"] = {7, 4, 2, 1};
    aDefaultArmorHp["scalemail"] = {7, 4, 2, 1};
    aDefaultArmorHp["hide armor"] = {5, 4, 2, 1};
    aDefaultArmorHp["brigandine"] = {6, 4, 2, 1};
    aDefaultArmorHp["chain mail"] = {8, 6, 4, 2, 1};
    aDefaultArmorHp["chainmail"] = {8, 6, 4, 2, 1};
    aDefaultArmorHp["chain"] = {8, 6, 4, 2, 1};
    aDefaultArmorHp["bronze plate mail"] = {12, 8, 6, 4, 2, 1};
    aDefaultArmorHp["banded mail"] = {9, 8, 6, 4, 2, 1};
    aDefaultArmorHp["bandedmail"] = {9, 8, 6, 4, 2, 1};
    aDefaultArmorHp["splint mail"] = {8, 8, 6, 4, 2, 1};
    aDefaultArmorHp["splintmail"] = {8, 8, 6, 4, 2, 1};
    aDefaultArmorHp["splint"] = {8, 8, 6, 4, 2, 1};
    aDefaultArmorHp["field plate"] = {24, 12, 10, 8, 6, 4, 2, 1};
    aDefaultArmorHp["full plate"] = {36, 24, 12, 10, 8, 6, 4, 2, 1};
    aDefaultArmorHp["plate mail"] = {12, 10, 8, 6, 4, 2, 1};
    aDefaultArmorHp["platemail"] = {12, 10, 8, 6, 4, 2, 1};
    aDefaultArmorHp["plate"] = {12, 10, 8, 6, 4, 2, 1};
    aDefaultArmorHp["buckler"] = {3};
    aDefaultArmorHp["small shield"] = {7};
    aDefaultArmorHp["shield, small"] = {7};
    aDefaultArmorHp["medium shield"] = {12};
    aDefaultArmorHp["shield, medium"] = {12};
    aDefaultArmorHp["body shield"] = {18};
    aDefaultArmorHp["shield, body"] = {18};
    aDefaultArmorHp["tower shield"] = {18};
    aDefaultArmorHp["shield, tower"] = {18};
    aDefaultArmorHp["shield"] = {12};

end

function initializeThac0ByHd()
    aThac0ByHd['0'] = 20;
    aThac0ByHd['-1'] = 19;
    aThac0ByHd['1-1'] = 18;
    aThac0ByHd['1'] = 17;
    aThac0ByHd['1+'] = 16;
    aThac0ByHd['2'] = 15;
    aThac0ByHd['3'] = 14;
    aThac0ByHd['4'] = 13;
    aThac0ByHd['5'] = 12;
    aThac0ByHd['6'] = 11;
    aThac0ByHd['7'] = 10;
    aThac0ByHd['8'] = 9;
    aThac0ByHd['9'] = 8;
    aThac0ByHd['10'] = 7;
    aThac0ByHd['11'] = 6;
    aThac0ByHd['12'] = 5;
    aThac0ByHd['13'] = 4;
    aThac0ByHd['14'] = 3;
    aThac0ByHd['15'] = 2;
    aThac0ByHd['16'] = 1;
    aThac0ByHd['17'] = 0;
    aThac0ByHd['18'] = -1;
    aThac0ByHd['19'] = -2;
    aThac0ByHd['20'] = -3;
end

function initializeCalledShots()
    aCalledShotModifiers["abdomen"] = {
        hitModifier = {
            [1] = -6,
            [2] = -5,
            [3] = -4,
            [4] = -4,
            [5] = -4,
            [6] = -4
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["arm"] = {
        hitModifier = {
            [1] = -5,
            [2] = -4,
            [3] = -3,
            [4] = -3,
            [5] = -2,
            [6] = -2
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["eye"] = {
        hitModifier = {
            [1] = -12,
            [2] = -11,
            [3] = -10,
            [4] = -10,
            [5] = -10,
            [6] = -10
        },
        thresholdModifier = 1,
        severityModifier = 2
    };
    aCalledShotModifiers["groin"] = {
        hitModifier = {
            [1] = -6,
            [2] = -5,
            [3] = -4,
            [4] = -4,
            [5] = -4,
            [6] = -4
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["hand"] = {
        hitModifier = {
            [1] = -8,
            [2] = -7,
            [3] = -6,
            [4] = -6,
            [5] = -5,
            [6] = -4
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["head"] = {
        hitModifier = {
            [1] = -10,
            [2] = -8,
            [3] = -6,
            [4] = -6,
            [5] = -5,
            [6] = -4
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["leg"] = {
        hitModifier = {
            [1] = -4,
            [2] = -3,
            [3] = -2,
            [4] = -2,
            [5] = -2,
            [6] = -2
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["neck"] = {
        hitModifier = {
            [1] = -9,
            [2] = -8,
            [3] = -6,
            [4] = -6,
            [5] = -4,
            [6] = -4
        },
        thresholdModifier = 1,
        severityModifier = 1
    };
    aCalledShotModifiers["tail"] = {
        hitModifier = {
            [1] = -7,
            [2] = -6,
            [3] = -5,
            [4] = -5,
            [5] = -4,
            [6] = -3
        },
        thresholdModifier = 1,
        severityModifier = 0
    };
    aCalledShotModifiers["torso"] = {
        hitModifier = {
            [1] = -6,
            [2] = -4,
            [3] = -2,
            [4] = -2,
            [5] = -2,
            [6] = -2
        },
        thresholdModifier = 1,
        severityModifier = 0
    };

    aHackmasterCalledShotsRanges["abdomen"] = {
        low = 2436,
        high = 3155
    };
    aHackmasterCalledShotsRanges["arm"] = {
        low = 3821,
        high = 5836
    };
    aHackmasterCalledShotsRanges["eye"] = {
        low = 9824,
        high = 9903
    };
    aHackmasterCalledShotsRanges["groin"] = {
        low = 2331,
        high = 2435
    };
    aHackmasterCalledShotsRanges["hand"] = {
        low = 5909,
        high = 6220
    };
    aHackmasterCalledShotsRanges["head"] = {
        low = 9374,
        high = 10000
    };
    aHackmasterCalledShotsRanges["leg"] = {
        low = 1,
        high = 2330
    };
    aHackmasterCalledShotsRanges["neck"] = {
        low = 9101,
        high = 9373
    };
    aHackmasterCalledShotsRanges["tail"] = {
        low = 2406,
        high = 2435
    };
    aHackmasterCalledShotsRanges["torso"] = {
        low = 3156,
        high = 3820
    };
end
