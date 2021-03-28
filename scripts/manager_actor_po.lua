function onInit()
end

function isPC(nodeCT)
  local rActor = ActorManager.resolveActor(nodeCT);
  return ActorManager.isPC(rActor);
end

function getConstitution(rChar)
  local nodeActor = getNode(rChar);
  local nCon = DB.getValue(nodeActor, "abilities.constitution.total", DB.getValue(nodeActor, "abilities.constitution.score", 0));
  return nCon;
end

function getMaxHp(rChar)
  local sType, nodeActor = ActorManager.getTypeAndNode(rChar);
  local nMaxHp = 0;
  
  if sType == "pc" then
    nMaxHp = DB.getValue(nodeActor, "hp.total", 0);
  else
    nMaxHp = DB.getValue(nodeActor, "hptotal", 0);
  end
  Debug.console("manager_actor_po.getMaxHp", "nMaxHp", nMaxHp);
  return nMaxHp;
end

function getNode(rChar)
  return ActorManager.getCreatureNode(rChar);
end

function getCreatureNode(rChar)
  local rType, rNode = ActorManager.getTypeAndNode(rChar);
  return rNode;
end

function getType(rChar)
  local rType, rNode = ActorManager.getTypeAndNode(rChar);
  return rType;
end

function shouldUseThaco(nodeActor)
  local sSpecialAttacks = DB.getValue(nodeActor, "specialAttacks", ""):lower();
  if sSpecialAttacks:find("usethaco") or sSpecialAttacks:find("usethac0") then
    return true;
  end
end

function getSaveScore(nodeActor, sSave)
	return DB.getValue(nodeActor, "saves." .. sSave .. ".score", 20);
end

function getMagicalDefenseAdjustment(nodeActor)
	return DB.getValue(nodeActor, "abilities.wisdom.magicdefenseadj", 0);
end

function getDefenseValue(rAttacker, rDefender, rRoll)
  local nDefense = 10;
  local bPsionic = false;
  local nACShield = 0;
  
  if (rRoll) then -- need to get defense value from psionic power
    bPsionic = rRoll.bPsionic == "true";
    if (bPsionic) then
      nDefense = tonumber(rRoll.Psionic_MAC) or 10;
      nDefense = ActorManagerADND.convertToAscendingAC(nDefense);
    end
  end

  if not rDefender and rRoll and bPsionic then -- no defender but psionic power target
    return nDefense, 0, 0, nACShield;
  elseif not rDefender or not rRoll then
    return nil, 0, 0, nACShield;
  end
  
  -- Base calculations
  local sAttack = rRoll.sDesc;
  
  local sAttackType = string.match(sAttack, "%[ATTACK.*%((%w+)%)%]");
  local bOpportunity = string.match(sAttack, "%[OPPORTUNITY%]");
  local nCover = tonumber(string.match(sAttack, "%[COVER %-(%d)%]")) or 0;
  local bRearAtk = string.match(sAttack, "%[REAR%]");
  
  local bNoDex = ModifierStack.getModifierKey("ATK_NODEXTERITY");
  local bNoShield = ModifierStack.getModifierKey("ATK_SHIELDLESS");
  local bIgnoreArmor = ModifierStack.getModifierKey("ATK_IGNORE_ARMOR");
  
  -- Effects
  local nAttackEffectMod = 0;
  local nDefenseEffectMod = 0;
  local bADV = false;
  local bDIS = false;
  
  local sDefenseStat = "dexterity";

  local sDefenderType = ActorManager.getType(rDefender);
  local nodeDefender = ActorManager.getCreatureNode(rDefender);
  if not nodeDefender then
    return nil, 0, 0, nACShield;
  end

  if bPsionic then -- calculate defenses for psionics
    if rRoll.Psionic_DisciplineType:match("attack") then -- mental attack
      nDefense = DB.getValue(nodeDefender,"combat.mac.score",10);
      -- need to get effects/adjustments for MAC/BMAC/etc.
      -- grab BAC value if exists in effects
      local nBonusMACBase, nBonusMACBaseEffects = EffectManager5E.getEffectsBonus(rDefender, "BMAC",true);
      if (nBonusMACBaseEffects > 0 and nBonusMACBase < nDefense) then
        nDefense = nBonusMACBase;
      end
      local nBonusMAC, nBonusMACEffects = EffectManager5E.getEffectsBonus(rDefender, "MAC",true);
      if (nBonusMACEffects > 0) then
        -- we minus the mod because +1 is good, -1 is bad, but lower MAC is better.
        nDefense = nDefense - nBonusMAC;
      end
    else -- using a power with a MAC
      nDefense = tonumber(rRoll.Psionic_MAC) or 10;
    end
    nDefense = ActorManagerADND.convertToAscendingAC(nDefense);

    -- if psionic attack, check psionic defenses
    if rRoll.Psionic_DisciplineType == "attack" then
      local nodeSpell = DB.findNode(rRoll.sSpellSource);
      if (nodeSpell) then
        local sSpellName = DB.getValue(nodeSpell,"name",""):lower();
        if sSpellName ~= "" then 
          nAttackEffectMod = ActorManagerADND.getPsionicAttackVersusDefenseMode(rDefender,rAttacker,sSpellName,nAttackEffectMod);
        end
      end
    end

  else -- calculate defenses for melee/range attacks
    local nACTemp = 0;
    local nACBase = 10;
    local nACArmor = 0;
    local nACMisc = 0;
    
    local bAttackRanged = (rRoll.range and rRoll.range == "R");
    local bAttackMelee = (rRoll.range and rRoll.range == "M");

    local nBaseRangeAC = 10;
    local nRangeACEffect = 0;
    local nRangeACMod = 0;
    local nRangeACModEffect = 0;

    local nBaseMeleeAC = 10;
    local nMeleeACEffect = 0;
    local nMeleeACMod = 0;
    local nMeleeACModEffect = 0;
    
    -- grab BAC value if exists in effects
    local nBonusACBase, nBonusACEffects = EffectManager5E.getEffectsBonus(rDefender, "BAC",true);

    if (bAttackMelee) then
      nBaseMeleeAC, nMeleeACEffect = EffectManager5E.getEffectsBonus(rDefender, "BMELEEAC",true);
      nMeleeACMod, nMeleeACModEffect = EffectManager5E.getEffectsBonus(rDefender, "MELEEAC",true);
    end
    
    if (bAttackRanged) then
      nBaseRangeAC, nRangeACEffect = EffectManager5E.getEffectsBonus(rDefender, "BRANGEAC",true);
      nRangeACMod, nRangeACModEffect = EffectManager5E.getEffectsBonus(rDefender, "RANGEAC",true);
    end
    
    local bProne = false;
    local bParalyzed = false;
    local bRestrainedStunned = false;
    local bUnconscious = false;
    if EffectManager5E.hasEffect(rDefender, "Paralyzed", rAttacker) then
      bParalyzed = true;
    end
    if EffectManager5E.hasEffect(rDefender, "Prone", rAttacker) then
      bProne = true;
    end
    if EffectManager5E.hasEffect(rDefender, "Restrained", rAttacker) then
      bRestrainedStunned = true;
    end
    if EffectManager5E.hasEffect(rDefender, "Stunned", rAttacker) then
      bRestrainedStunned = true;
    end
    if EffectManager5E.hasEffect(rDefender, "Unconscious", rAttacker) then
      bUnconscious = true;
      bProne = true;
    end
    
    -- if PC
    if sDefenderType == "pc" or PlayerOptionManager.shouldUseDynamicNpcAc() then
      local nodeDefender = DB.findNode(rDefender.sCreatureNode);
      Debug.console("nodeDefender", nodeDefender);
      nACTemp = DB.getValue(nodeDefender, "defenses.ac.temporary",0);
      nACBase = DB.getValue(nodeDefender, "defenses.ac.base",10);
      nACArmor = DB.getValue(nodeDefender, "defenses.ac.armor",0);
      nACShield = DB.getValue(nodeDefender, "defenses.ac.shield",0);
      nACMisc = DB.getValue(nodeDefender, "defenses.ac.misc",0);
      
      if sDefenderType == "pc" then        
        if bIgnoreArmor then
          nDefense = 10;
        else
          nDefense = nACBase;
        end
      else
        local nStatBlockAc = DB.getValue(nodeDefender, "ac", 10);
        nACBase = math.min(nStatBlockAc, nACBase);
        if bIgnoreArmor then
          nDefense = nStatBlockAc;
        else
          nDefense = nACBase;
        end
      end

    else
      -- ELSE NPC
        nDefense = DB.getValue(nodeDefender, "ac", 10);
    end

    -- use BAC style effects if exist
    if nBonusACEffects > 0 then
      if nBonusACBase < nDefense then
        nDefense = nBonusACBase;
      end
    end
    if (bAttackMelee and nMeleeACEffect > 0) then
      if (nBaseMeleeAC < nDefense) then
        nDefense = nBaseMeleeAC;
      end
    end
    if (bAttackRanged and nRangeACEffect > 0) then
      if (nBaseRangeAC < nDefense) then
        nDefense = nBaseRangeAC;
      end
    end
    if (bAttackMelee and nMeleeACModEffect > 0) then
      nACTemp = nACTemp + (nACTemp - nMeleeACMod); -- (minus the mod, +3 is good, so we reduce AC by 3, -3 would be worse)
    end
    if (bAttackRanged and nRangeACModEffect > 0) then
      nACTemp = nACTemp + (nACTemp - nRangeACMod); -- (minus the mod, +3 is good, so we reduce AC by 3, -3 would be worse)
    end
    -- 
    
    if sDefenderType == "pc" or PlayerOptionManager.shouldUseDynamicNpcAc() then
      -- dont get shield bonus if you attacked from rear
      -- or if you are prone
	    if bNoShield or bRearAtk or bUnconscious or bParalyzed or bRestrainedStunned or (bProne and not PlayerOptionManager.isUsingAlternateTargetEffectModifiers()) or
	        EffectManager5E.hasEffect(rDefender, "NOSHIELD", nil) or 
	        EffectManager5E.hasEffect(rDefender, "SHIELDLESS", nil) or 
	        EffectManager5E.hasEffect(rDefender, "Charged", nil) then
	    		 nACShield = 0;
		  end
        nDefense = nDefense + nACTemp + nACArmor + nACShield + nACMisc;
    else -- npc
        nDefense = nDefense + nACTemp; -- nACTemp are "modifiders"
    end
       
    if sDefenderType == "pc" or PlayerOptionManager.shouldUseDynamicNpcAc() then  
      -- check to see if casting or if has NODEX effect, if so dont apply dex AC
      -- if attacking from rear no dex! if prone, they get no dex.
      -- also, make sure modifier
      if bNoDex or bRearAtk or bProne or bParalyzed or bRestrainedStunned or 
          ActionSave.hasConcentrationEffects(rDefender) or 
          EffectManager5E.hasEffect(rDefender, "BLINDED", nil) or 
          EffectManager5E.hasEffect(rDefender, "Charged", nil) or 
          EffectManager5E.hasEffect(rDefender, "NODEX", nil) or 
          EffectManager5E.hasEffect(rDefender, "NO-DEXTERITY", nil) then
      -- dont apply dex in these cases
      else
      -- apply dex
        local nDefenseStatMod = ActorManagerADND.getAbilityBonus(rDefender, sDefenseStat, "defenseadj");
        nDefense = nDefense + nDefenseStatMod;
      end
    end
      
    -- flip ac to ascending since rest of the code uses ascending AC (but we show decending).
    -- this is just to make things easier sharing code with 5E. 
    -- Mathmatically it's the same and display shows what AD&Ders expect.
    nDefense = ActorManagerADND.convertToAscendingAC(nDefense);
    --
    
    if ActorManager.hasCT(rDefender) then
      local nBonusStat = 0;
      local nBonusSituational = 0;
      local nBonusAC = 0;
      
      local aAttackFilter = {};
      if sAttackType == "M" then
        table.insert(aAttackFilter, "melee");
      elseif sAttackType == "R" then
        table.insert(aAttackFilter, "ranged");
      end
      if bOpportunity then
        table.insert(aAttackFilter, "opportunity");
      end

      local aBonusTargetedAttackDice, nBonusTargetedAttack = EffectManager5E.getEffectsBonus(rAttacker, "ATK", false, aAttackFilter, rDefender, true);
      nAttackEffectMod = nAttackEffectMod + StringManager.evalDice(aBonusTargetedAttackDice, nBonusTargetedAttack);
            
      local aACEffects, nACEffectCount = EffectManager5E.getEffectsBonusByType(rDefender, {"AC"}, true, aAttackFilter, rAttacker);
      for _,v in pairs(aACEffects) do
        nBonusAC = nBonusAC + v.mod;
      end
      
      -- minus 1 ac because the charged.
      if EffectManager5E.hasEffect(rDefender, "Charged", nil) then
        nBonusAC = nBonusAC -1;
      end
      if EffectManager5E.hasEffect(rDefender, "Invisible", rAttacker) then
        nBonusAC = nBonusAC + 4;
      end
      
      -- this makes DEX: -3 worsen AC by 3, wtf... 5e code?
      --
      -- nBonusStat = getAbilityEffectsBonus(rDefender, sDefenseStat);
      --
      -- if we ever remove the persistant stat for ability scores 
      -- and go to "effect check" only then we'll need to revisit this.
      
      -- AC is 4 worse when blinded
      if EffectManager5E.hasEffect(rDefender, "BLINDED", nil) then
        nBonusAC = nBonusAC - 4;
      end
 
      -- encumbrance penalties
      --local sRank = CharManager.getEncumbranceRank2e(nodeDefender);
      local sRank = DB.getValue(nodeDefender,"speed.encumbrancerank","");
      if sRank == "Heavy" then
        nBonusAC = nBonusAC -1;
      elseif sRank == "Severe" or sRank == "MAX" then
        nBonusAC = nBonusAC -3;
      end
      
      nDefenseEffectMod = nBonusAC + nBonusStat + nBonusSituational;
    end
    
  end -- end if bPsionic

  -- Results
  return nDefense, nAttackEffectMod, nDefenseEffectMod, nACShield;
end

function getTypeForHitLocation(nodeActor)
	if ActorManager.isPC(nodeActor) then
		return "humanoid";
	else
		local sType = DB.getValue(nodeActor, "type", ""):lower();
		if sType:find("humanoid") then
			return "humanoid";
		elseif sType:find("animal") then
			return "animal";
		elseif sType:find("monster") then
			return "monster";
		else
			return getDefaultActorTypeForCrit(nodeActor);
		end
	end
end

function getDefaultActorTypeForCrit(nodeActor)
	local sType = getDefaultActorTypeForCritByType(nodeActor);
	if UtilityPO.isEmpty(sType) then
		sType = getDefaultActorTypeForCritByName(nodeActor);
	end
	if UtilityPO.isEmpty(sType) then
		-- If we can't find anything, default to monster
		sType = "monster";
	end
	return sType;
end

function getDefaultActorTypeForCritByType(nodeActor)
	local sType = DB.getValue(nodeActor, "type", ""):lower();
	for sKeyedType, sMappedType in pairs(DataCommonPO.aDefaultCreatureTypesByType) do
		if sType:find(sKeyedType) then
			return sMappedType;
		end
	end
	return nil;
end

function getDefaultActorTypeForCritByName(nodeActor)
	local sName = DB.getValue(nodeActor, "name", ""):lower();
	for sKeyedName, sMappedType in pairs(DataCommonPO.aDefaultCreatureTypesByName) do
		if sName:find(sKeyedName) then
			return sMappedType;
		end
	end
	return nil;
end

function getSizeCategory(nodeActor)
	-- Size Categories: 1 = T, 2 = S, 3 = M, 4 = L, 5 = H, 6 = G
	local nSizeCategory;
	if ActorManager.isPC(nodeActor) then
		local sSizeRaw = DB.getValue(nodeActor, "size", "");
		nSizeCategory = DataManagerPO.parseSizeString(sSizeRaw);
		if not nSizeCategory then
			nSizeCategory = getDefaultSizeFromRace(nodeActor);
		end
	else
		local sSizeRaw = DB.getValue(nodeActor, "size", "");
		nSizeCategory = DataManagerPO.parseSizeString(sSizeRaw);
	end
	
	if not nSizeCategory then
		nSizeCategory = 3; -- If we couldn't figure it out, default to medium
	end
	return nSizeCategory;
end

function getDefaultSizeFromRace(nodeActor)
	local sRace = DB.getValue(nodeActor, "race", "");
	local nSize = DataCommonPO.aDefaultRaceSizes[sRace];
	return nSize;
end

function getName(nodeActor)
  return ActorManager.getDisplayName(nodeActor);
end

function canBeAffectedByFatigue(nodeActor)
  if not nodeActor then return false; end

  local sSpecialDefenses = DB.getValue(nodeActor, "specialDefense", ""):lower();
  if sSpecialDefenses:find("nofatigue")  then
    return false;
  end

  local sType = DB.getValue(nodeActor, "type", ""):lower();
  if sType:find("undead") then
    return false;
  end

  return true;
end

function canBeAffectedByThresholdOfPain(rActor)
  if not rActor then return false; end

  local nodeActor = getNode(rActor);
  if not nodeActor then return false; end

  local sSpecialDefenses = DB.getValue(nodeActor, "specialDefense", ""):lower();
  if sSpecialDefenses:find("notop") or sSpecialDefenses:find("nothreshold") then
    return false;
  end

  local sType = DB.getValue(nodeActor, "type", ""):lower();
  if sType:find("undead") then
    return false;
  end

  return true;
end

function hasItemNamed(nodeActor, sItem)
  if not sItem then
    return false;
  end

  local bHasItem = false;
  for _, nodeItem in pairs(DB.getChildren(nodeActor, "inventorylist")) do
    local sName = DB.getValue(nodeItem, "name"):lower();
    if sItem:lower() == sName then
      bHasItem = true;
      return bHasItem;
    end
  end
  
  return bHasItem;
end

function addItem(nodeActor, nodeItem)
  local nodeInventory = DB.createChild(nodeActor, "inventorylist");
  local nodeNewItem = nodeInventory.createChild();
  DB.copyNode(nodeItem, nodeNewItem);
  DB.setValue(nodeNewItem, "carried", "number", 2);
end

