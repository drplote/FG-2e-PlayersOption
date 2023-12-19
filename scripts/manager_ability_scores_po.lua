local fGetStrengthProperties;
local fGetDexterityProperties;
local fGetWisdomProperties;
local fGetConstitutionProperties;
local fGetCharismaProperties;
local fGetIntelligenceProperties;
local fUpdateConstitution;
local fDetailsUpdate;
local fDetailsPercentUpdate;

function onInit()
	fGetStrengthProperties = AbilityScoreADND.getStrengthProperties;
	AbilityScoreADND.getStrengthProperties = getStrengthPropertiesOverride;

	fGetDexterityProperties = AbilityScoreADND.getDexterityProperties;
	AbilityScoreADND.getDexterityProperties = getDexterityPropertiesOverride;

	fGetIntelligenceProperties = AbilityScoreADND.getIntelligenceProperties;
	AbilityScoreADND.getIntelligenceProperties = getIntelligencePropertiesOverride;

	fGetWisdomProperties = AbilityScoreADND.getWisdomProperties;
	AbilityScoreADND.getWisdomProperties = getWisdomPropertiesOverride;

	fGetConstitutionProperties = AbilityScoreADND.getConstitutionProperties;
	AbilityScoreADND.getConstitutionProperties = getConstitutionPropertiesOverride;

	fGetCharismaProperties = AbilityScoreADND.getCharismaProperties;
	AbilityScoreADND.getCharismaProperties = getCharismaPropertiesOverride;

    fUpdateConstitution = AbilityScoreADND.updateConstitution;
    AbilityScoreADND.updateConstitution = updateConstitutionOverride;

    fDetailsUpdate = AbilityScoreADND.detailsUpdate;
    AbilityScoreADND.detailsUpdate = detailsUpdateOverride;

    fDetailsPercentUpdate = AbilityScoreADND.detailsPercentUpdate;
    AbilityScoreADND.detailsPercentUpdate = detailsPercentUpdateOverride;    
end

function updateHonor(nodeChar)
    local dbAbility = getHonorProperties(nodeChar);
    
    DB.setValue(nodeChar, "abilities.honor.honorDice", "string", dbAbility.honorDice);
    DB.setValue(nodeChar, "abilities.honor.score", "number", dbAbility.score);
    DB.setValue(nodeChar, "abilities.honor.honorWindow", "string", dbAbility.honorWindow);
    DB.setValue(nodeChar, "abilities.honor.honorState", "number", dbAbility.honorState);
end

function getHonorProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.honor.score", 0);
    local nMaxActiveClassLevel = CharManager.getAbsoluteClassMaxLevel(nodeChar);
    local nActiveClasses = CharManager.getClassCount(nodeChar);
    local nSaneLevel = levelSanityCheck(nMaxActiveClassLevel + nActiveClasses - 1);
    local nChartIndex = math.ceil(honorSanityCheck(nScore) / 5);
    local nHonorState = 0;
    
    local sHonorWindow = "Normal";
    if nScore < DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][1] then
        sHonorWindow = "Dishonor";
        nHonorState = -1;
    elseif nScore >= DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][2] and nScore <= DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][3] then   
        sHonorWindow = "Great Honor";
        nHonorState = 1;
    elseif nScore > DataCommonPO.aHonorThresholdsByLevel[nSaneLevel][3] then
        sHonorWindow = "Too Much Honor";
        nHonorState = 2;
    end
            
    local dbAbility = {};
    dbAbility.score = nScore;
    dbAbility.honorDice = DataCommonPO.aHonorDice[nChartIndex][nSaneLevel];
    dbAbility.honorWindow = sHonorWindow;
    dbAbility.honorState = nHonorState;
    return dbAbility;
end

function levelSanityCheck(nLevel)
    if nLevel > 20 then
        nLevel = 20;
    end
    if nLevel < 1 then
        nLevel = 1;
    end
    return nLevel;
end

function honorSanityCheck(nHonor)
    if nHonor < 1 then  
        nHonor = 1;
    end
    if nHonor > 405 then 
        nHonor = 405;
    end
    return nHonor;
end

function detailsUpdateOverride(nodeChar)
    fDetailsUpdate(nodeChar);
    local nBase =       DB.getValue(nodeChar, "abilities.comeliness.base",9);
    local nBaseMod =    DB.getValue(nodeChar, "abilities.comeliness.basemod",0);
    local nAdjustment = DB.getValue(nodeChar, "abilities.comeliness.adjustment",0);
    local nTempMod =    DB.getValue(nodeChar, "abilities.comeliness.tempmod",0);
    local nFinalBase = nBase;

    -- if Base Modifier isn't 0 then lets use that instead
    if (nBaseMod ~= 0) then
      nFinalBase = nBaseMod;
    end
    
    local nTotal = (nFinalBase + nAdjustment + nTempMod);
    if (nTotal < 1) then
      nTotal = 1;
    end
    if (nTotal > 25) then
      nTotal = 25;
    end
    local nScoreCurrent = DB.getValue(nodeChar, "abilities.comeliness.score",0);
    
    local nTotalCurrent = DB.getValue(nodeChar, "abilities.comeliness.total",0);
    
    if nTotalCurrent ~= nTotal then
      DB.setValue(nodeChar, "abilities.comeliness.total","number", nTotal);
    end
end

function detailsPercentUpdateOverride(nodeChar)
    fDetailsPercentUpdate(nodeChar);
    local nBase =       DB.getValue(nodeChar, "abilities.comeliness.percentbase",0);
    local nBaseMod =    DB.getValue(nodeChar, "abilities.comeliness.percentbasemod",0);
    local nAdjustment = DB.getValue(nodeChar, "abilities.comeliness.percentadjustment",0);
    local nTempMod =    DB.getValue(nodeChar, "abilities.comeliness.percenttempmod",0);
    local nFinalBase = nBase;

    if (nBaseMod ~= 0) then
        nFinalBase = nBaseMod;
    end
    local nTotal = (nFinalBase + nAdjustment + nTempMod);
    if (nTotal < 1) then
        nTotal = 0;
    end
    if (nTotal > 100) then
        nTotal = 100;
    end
    DB.setValue(nodeChar, "abilities.comeliness.percent","number", nTotal);
    DB.setValue(nodeChar, "abilities.comeliness.percenttotal","number", nTotal);
  end

function updateConstitutionOverride(nodeChar)
    local dbAbility = fUpdateConstitution(nodeChar);
    if PlayerOptionManager.isUsingHackmasterFatigue() and ActorManager.isPC(nodeChar) then
        FatigueManagerPO.updateFatigueFactor(nodeChar);
    end
    return dbAbility;
end

function updateComeliness(nodeChar)
    local dbAbility = getComelinessProperties(nodeChar);
    local nScore = dbAbility.score;
    
    DB.setValue(nodeChar, "abilities.comeliness.score", "number", nScore);
    DB.setValue(nodeChar, "abilities.comeliness.effects", "string", dbAbility.effects);
    return dbAbility;
end

function getStrengthPropertiesOverride(nodeChar)
	if PlayerOptionManager.isUsingHackmasterStats() then
		return getHackmasterStrengthProperties(nodeChar);
	else
		return fGetStrengthProperties(nodeChar);
	end
end

function getDexterityPropertiesOverride(nodeChar)
	if PlayerOptionManager.isUsingHackmasterStats() then
		return getHackmasterDexterityProperties(nodeChar);
	else
		return fGetDexterityProperties(nodeChar);
	end
end

function getConstitutionPropertiesOverride(nodeChar)
	if PlayerOptionManager.isUsingHackmasterStats() then
		return getHackmasterConstitutionProperties(nodeChar);
	else
		return fGetConstitutionProperties(nodeChar);
	end
end

function getIntelligencePropertiesOverride(nodeChar)
	if PlayerOptionManager.isUsingHackmasterStats() then
		return getHackmasterIntelligenceProperties(nodeChar);
	else
		return fGetIntelligenceProperties(nodeChar);
	end
end

function getWisdomPropertiesOverride(nodeChar)
	if PlayerOptionManager.isUsingHackmasterStats() then
		return getHackmasterWisdomProperties(nodeChar);
	else
		return fGetWisdomProperties(nodeChar);
	end
end

function getCharismaPropertiesOverride(nodeChar)
	if PlayerOptionManager.isUsingHackmasterStats() then
		return getHackmasterCharismaProperties(nodeChar);
	else
		return fGetCharismaProperties(nodeChar);
	end
end

function getComelinessProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.comeliness.total", DB.getValue(nodeChar, "abilities.comeliness.score", 0));
    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
      -- adjust ability scores from effects!
      local sAbilityEffect = "BCOM";
      local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      if (nAbilityMod ~= 0) then
       nScore = nAbilityMod;
      end
      
      sAbilityEffect = "COM";
      nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      nScore = nScore + nAbilityMod;
    end
    
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
    dbAbility.effects = DataCommonPO.aComeliness[nScore][1];
    dbAbility.effects_TT = DataCommonPO.aComeliness[nScore][2];
    return dbAbility;
end



function getHackmasterStrengthProperties(nodeChar)

    local nScore = DB.getValue(nodeChar, "abilities.strength.total", DB.getValue(nodeChar, "abilities.strength.score", 0));
    local nPercent = DB.getValue(nodeChar, "abilities.strength.percenttotal", DB.getValue(nodeChar, "abilities.strength.percenttotal", 0));
    
    local rActor = ActorManagerPO.getActor("", nodeChar);

    if rActor then
        -- adjust ability scores from effects!
        local sAbilityEffect = "BSTR";
        local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        if (nAbilityMod ~= 0) then
	        nScore = nAbilityMod;
        end
        
        sAbilityEffect = "BPSTR";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        if (nAbilityMod ~= 0) then
            if (nAbilityMod > 100) then
                nAbilityMod = 100;
            end
            if (nAbilityMod < 1) then
                nAbilityMod = 1;
            end
         nPercent = nAbilityMod;
        end
        
        sAbilityEffect = "STR";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        nScore = nScore + nAbilityMod;
        
        sAbilityEffect = "PSTR";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        nPercent = nPercent + nAbilityMod;
        
        -- adjust ability scores from items!
    end
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local nScoreSaved = nScore;
	
	nScore = (nScore * 2) - 1; 
	if(nPercent > 50) then
	  nScore = nScore +1
	end
       
    local dbAbility = {};
    dbAbility.score = nScoreSaved;
    dbAbility.scorepercent = nPercent;
    dbAbility.hitadj = DataCommonPO.aStrength[nScore][1];
    dbAbility.dmgadj = DataCommonPO.aStrength[nScore][2];
    dbAbility.weightallow = DataCommonPO.aStrength[nScore][3];
    dbAbility.maxpress = DataCommonPO.aStrength[nScore][4];
    dbAbility.opendoors = DataCommonPO.aStrength[nScore][5];
    dbAbility.bendbars = DataCommonPO.aStrength[nScore][6];
    return dbAbility;
end

function getHackmasterDexterityProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.dexterity.total", DB.getValue(nodeChar, "abilities.dexterity.score", 0));
	local nPercent = DB.getValue(nodeChar, "abilities.dexterity.percenttotal", DB.getValue(nodeChar, "abilities.dexterity.percenttotal", 0));

    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
        -- adjust ability scores from effects!
        local sAbilityEffect = "BDEX";
        local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        if (nAbilityMod ~= 0) then
         nScore = nAbilityMod;
        end
        
        sAbilityEffect = "DEX";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        nScore = nScore + nAbilityMod;
    end

    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
	local nScoreSaved = nScore;
	
	nScore = (nScore * 2) - 1; 
	if(nPercent > 50) then
	  nScore = nScore +1
	end
	
    local dbAbility = {};
    dbAbility.score = nScoreSaved;
    dbAbility.reactionadj = DataCommonPO.aDexterity[nScore][1];
    dbAbility.hitadj = DataCommonPO.aDexterity[nScore][2];
    dbAbility.defenseadj = DataCommonPO.aDexterity[nScore][3];
    
    return dbAbility;
end

function getHackmasterWisdomProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.wisdom.total", DB.getValue(nodeChar, "abilities.wisdom.score", 0));
    
    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
        -- adjust ability scores from effects!
        local sAbilityEffect = "BWIS";
        local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        if (nAbilityMod ~= 0) then
         nScore = nAbilityMod;
        end
        
        sAbilityEffect = "WIS";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        nScore = nScore + nAbilityMod;
    end
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
    dbAbility.magicdefenseadj = DataCommonPO.aWisdom[nScore][1];
    dbAbility.spellbonus = DataCommonPO.aWisdom[nScore][2];
    dbAbility.failure = DataCommonPO.aWisdom[nScore][3];
    dbAbility.immunity = DataCommonPO.aWisdom[nScore][4];
    if DataCommonADND.coreVersion == "2e" then
      dbAbility.mac_base = DataCommonPO.aWisdom[nScore][5];
      dbAbility.psp_bonus = DataCommonPO.aWisdom[nScore][6];
    end
    
    local sBonus_TT = Interface.getString("char_abilityscore_wisdombonus_tooltip");
    local sImmunity_TT = Interface.getString("char_abilityscore_intelligencebonus_tooltip");
    if (nScore >= 17) then
        sBonus_TT = sBonus_TT .. DataCommonPO.aWisdom[nScore+100][2];
        sImmunity_TT = sImmunity_TT .. DataCommonPO.aWisdom[nScore+100][4];
    end
    dbAbility.sBonus_TT = sBonus_TT;
    dbAbility.sImmunity_TT = sImmunity_TT;
    
    return dbAbility;
end

function getHackmasterConstitutionProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.constitution.total", DB.getValue(nodeChar, "abilities.constitution.score", 0));
    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
        -- adjust ability scores from effects!
        local sAbilityEffect = "BCON";
        local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        if (nAbilityMod ~= 0) then
         nScore = nAbilityMod;
        end
        
        sAbilityEffect = "CON";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        nScore = nScore + nAbilityMod;
    end
    
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
    dbAbility.hitpointadj = DataCommonPO.aConstitution[nScore][1];
    dbAbility.systemshock = DataCommonPO.aConstitution[nScore][2];
    dbAbility.resurrectionsurvival = DataCommonPO.aConstitution[nScore][3];
    dbAbility.poisonadj = DataCommonPO.aConstitution[nScore][4];
    dbAbility.regeneration = DataCommonPO.aConstitution[nScore][5];
    if DataCommonADND.coreVersion == "2e" then
      dbAbility.psp_bonus = DataCommonPO.aConstitution[nScore][6];
    end

    return dbAbility;
end

function getHackmasterCharismaProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.charisma.total", DB.getValue(nodeChar, "abilities.charisma.score", 0));
    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
      -- adjust ability scores from effects!
      local sAbilityEffect = "BCHA";
      local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      if (nAbilityMod ~= 0) then
       nScore = nAbilityMod;
      end
      
      sAbilityEffect = "CHA";
      nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      nScore = nScore + nAbilityMod;
    end
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
    dbAbility.maxhench = DataCommonPO.aCharisma[nScore][1];
    dbAbility.loyalty = DataCommonPO.aCharisma[nScore][2];
    dbAbility.reaction = DataCommonPO.aCharisma[nScore][3];

    return dbAbility;
end

function getHackmasterComelinessProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.comeliness.total", DB.getValue(nodeChar, "abilities.comeliness.score", 0));
    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
      -- adjust ability scores from effects!
      local sAbilityEffect = "BCOM";
      local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      if (nAbilityMod ~= 0) then
       nScore = nAbilityMod;
      end
      
      sAbilityEffect = "COM";
      nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
      nScore = nScore + nAbilityMod;
    end
	
	
	
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
	dbAbility.effects = DataCommonPO.aComeliness[nScore][1];
	dbAbility.effects_TT = DataCommonPO.aComeliness[nScore][2];
    return dbAbility;
end

function getHackmasterIntelligenceProperties(nodeChar)
    local nScore = DB.getValue(nodeChar, "abilities.intelligence.total", DB.getValue(nodeChar, "abilities.intelligence.score", 0));
    local rActor = ActorManagerPO.getActor("", nodeChar);
    if rActor then
        -- adjust ability scores from effects!
        local sAbilityEffect = "BINT";
        local nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        if (nAbilityMod ~= 0) then
         nScore = nAbilityMod;
        end
        
        sAbilityEffect = "INT";
        nAbilityMod, nAbilityEffects = EffectManager5E.getEffectsBonus(rActor, sAbilityEffect, true);
        nScore = nScore + nAbilityMod;
    end
    nScore = AbilityScoreADND.abilityScoreSanity(nScore);
    local dbAbility = {};
    dbAbility.score = nScore;
    dbAbility.languages = DataCommonPO.aIntelligence[nScore][1];
    dbAbility.spelllevel = DataCommonPO.aIntelligence[nScore][2];
    dbAbility.learn = DataCommonPO.aIntelligence[nScore][3];
    dbAbility.maxlevel = DataCommonPO.aIntelligence[nScore][4];
    dbAbility.illusion = DataCommonPO.aIntelligence[nScore][5];
    if DataCommonADND.coreVersion == "2e" then
      dbAbility.mac_adjustment = DataCommonPO.aIntelligence[nScore][6];
      dbAbility.psp_bonus = DataCommonPO.aIntelligence[nScore][7];
      dbAbility.mthaco_bonus = DataCommonPO.aIntelligence[nScore][8];
    end
    
    local sImmunity_TT = "Immune to these level of Illusion spells. ";
    if (nScore >= 19) then
        sImmunity_TT = sImmunity_TT .. DataCommonPO.aIntelligence[nScore+100][5];
    end
    dbAbility.sImmunity_TT = sImmunity_TT;

    return dbAbility;
end
