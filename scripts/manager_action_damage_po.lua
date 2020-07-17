local fOnDamageRoll;
local fCheckReductionType;
local fModDamage;

function onInit()
    fOnDamageRoll = ActionDamage.onDamageRoll;
    ActionDamage.onDamageRoll = onDamageRollOverride;
    ActionsManager.registerPostRollHandler("damage", onDamageRollOverride);
	
	fCheckReductionType = ActionDamage.checkReductionType;
	ActionDamage.checkReductionType = checkReductionTypeOverride;

	fModDamage = ActionDamage.modDamage;
	ActionDamage.modDamage = modDamageOverride;
	ActionsManager.registerModHandler("damage", modDamageOverride);

	fGetDamageAdjust = ActionDamage.getDamageAdjust;
	ActionDamage.getDamageAdjust = getDamageAdjustOverride;
end

function getDamageAdjustOverride(rSource, rTarget, nDamage, rDamageOutput, aDice)

  local nDamageAdjust = 0;
  local bVulnerable = false;
  local bResist = false;
  local bAbsorb = false;
  local nDamageDice = 0; -- less than 0, vuln, more than 1 resist
  local sRangeType = "untypedRange";
  if (rDamageOutput.sRange == "R") then
    sRangeType = "range";
  elseif (rDamageOutput.sRange == "M") then
    sRangeType = "melee";
  elseif (rDamageOutput.sRange == "P") then
    sRangeType = "psionic";
  end
  
  local aImmune = ActionDamage.getReductionType(rSource, rTarget, "IMMUNE");
  local aVuln = ActionDamage.getReductionType(rSource, rTarget, "VULN");
  local aResist = ActionDamage.getReductionType(rSource, rTarget, "RESIST");
  local aDamageDiceResist = ActionDamage.getReductionType(rSource, rTarget, "DDR");
  
  local bIncorporealSource = EffectManager5E.hasEffect(rSource, "Incorporeal", rTarget);
  local bIncorporealTarget = EffectManager5E.hasEffect(rTarget, "Incorporeal", rSource);
  local bApplyIncorporeal = (bIncorporealSource ~= bIncorporealTarget);
  
  -- Handle immune all
  if aImmune["all"] then
    nDamageAdjust = 0 - nDamage;
    bResist = true;
    return nDamageAdjust, bVulnerable, bResist, 0;
  end
  
  -- Iterate through damage type entries for vulnerability, resistance and immunity
  local nVulnApplied = 0;
  local bResistCarry = false;
  for k, v in pairs(rDamageOutput.aDamageTypes) do
    -- Get individual damage types for each damage clause
    local aSrcDmgClauseTypes = {};
    local aTemp = StringManager.split(k, ",", true);
    for _,vType in ipairs(aTemp) do
      if vType ~= "untyped" and vType ~= "" then
        table.insert(aSrcDmgClauseTypes, vType);
      end
    end
       
    -- Handle standard immunity, vulnerability and resistance
    local bLocalDamageDiceResist = (ActionDamage.checkNumericalReductionType(aDamageDiceResist, aSrcDmgClauseTypes) ~= 0);
    local bLocalVulnerable = ActionDamage.checkReductionType(aVuln, aSrcDmgClauseTypes);
    local bLocalResist = ActionDamage.checkReductionType(aResist, aSrcDmgClauseTypes);
    local bLocalImmune = ActionDamage.checkReductionType(aImmune, aSrcDmgClauseTypes);


    -- Handle incorporeal
    if bApplyIncorporeal then
      bLocalResist = true;
    end
    
    -- Calculate adjustment
    -- Vulnerability = double
    -- Resistance = half
    -- Immunity = none
    local nLocalDamageAdjust = 0;
    if bLocalImmune then
      nLocalDamageAdjust = -v;
      bResist = true;
    else

      -- handle damage dice reduction DDR
      if bLocalDamageDiceResist then
        local nLocalDamageDiceResist = ActionDamage.checkDiceReductionType(aDamageDiceResist, aSrcDmgClauseTypes, aDice);
        if nLocalDamageDiceResist ~= 0 then
          nDamageDice = nLocalDamageDiceResist;
          nLocalDamageAdjust = nLocalDamageAdjust - nLocalDamageDiceResist;
        end
      end

      -- Handle numerical resistance
      local nLocalResist = ActionDamage.checkNumericalReductionType(aResist, aSrcDmgClauseTypes, v);
      if nLocalResist ~= 0 then
        nLocalDamageAdjust = nLocalDamageAdjust - nLocalResist;
        bResist = true;
      end
      
      -- Handle numerical vulnerability
      local nLocalVulnerable = ActionDamage.checkNumericalReductionType(aVuln, aSrcDmgClauseTypes);
      if nLocalVulnerable ~= 0 then
        nLocalDamageAdjust = nLocalDamageAdjust + nLocalVulnerable;
        bVulnerable = true;
      end
      
      -- Handle standard resistance
      if bLocalResist then
        local nResistOddCheck = (nLocalDamageAdjust + v) % 2;
        local nAdj = math.ceil((nLocalDamageAdjust + v) / 2);
        nLocalDamageAdjust = nLocalDamageAdjust - nAdj;
        if nResistOddCheck == 1 then
          if bResistCarry then
            nLocalDamageAdjust = nLocalDamageAdjust + 1;
            bResistCarry = false;
          else
            bResistCarry = true;
          end
        end
        bResist = true;
      end
      -- Handle standard vulnerability
      if bLocalVulnerable then
        nLocalDamageAdjust = nLocalDamageAdjust + (nLocalDamageAdjust + v);
        bVulnerable = true;
      end
      
    end

    -- add support for "DA: # type" where damage # is absorbed from type damage and then that value is reduced the amount absorbed. --celestian
    local nAbsorbed = ActionDamage.getAbsorbedByType(rTarget,aSrcDmgClauseTypes,sRangeType,(nDamage-nLocalDamageAdjust));
    nAbsorbed = nAbsorbed + handleArmorDamageAbsorb(rTarget, aDice, aSrcDmgClauseTypes, nDamage - nAbsorbed);
    if nAbsorbed > 0 then
      nLocalDamageAdjust = nLocalDamageAdjust - nAbsorbed;
      bAbsorb = true;
    end
    
    -- Apply adjustment to this damage type clause
    nDamageAdjust = nDamageAdjust + nLocalDamageAdjust;
  end
  
	-- Handle damage threshold
	local nDTMod, nDTCount = EffectManager5E.getEffectsBonus(rTarget, {"DT"}, true);
	if nDTMod > 0 then
		if nDTMod > (nDamage + nDamageAdjust) then 
			nDamageAdjust = 0 - nDamage;
			bResist = true;
		end
	end

  -- Results
  return nDamageAdjust, bVulnerable, bResist, bAbsorb, nDamageDice;
end


function handleArmorDamageAbsorb(rTarget, aDice, aSrcDmgClauseTypes, nDamageToAbsorb)
	local nAbsorbed = 0;
	if not PlayerOptionManager.isUsingArmorDamage() then
		return nAbsorbed;
	end

	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	local nodeArmor = ArmorManagerPO.getDamageableArmorWorn(nodeTarget);
	local nArmorHpRemaining = ArmorManagerPO.getHpRemaining(nodeArmor);
	local nSoakPerDie = ArmorManagerPO.getDamageReduction(nodeArmor);
	local nPointsThatCanBeSoaked = math.min(DiceManagerPO.getNumOriginalDice(aDice) * nSoakPerDie, nDamageToAbsorb);
	local nDamageSoaked = math.min(nPointsThatCanBeSoaked, nArmorHpRemaining);
	nAbsorbed = nDamageSoaked;
	if nDamageSoaked > 0 then
		local sCharName = DB.getValue(nodeTarget, "name");
		local sItemName = ItemManagerPO.getItemNameForPlayer(nodeArmor);

		local nArmorDamageTaken = nDamageSoaked;
		if ArmorManagerPO.canDamageTypeHurtArmor(aSrcDmgClauseTypes, nodeArmor) then
			ArmorManagerPO.damageArmor(nodeArmor, nDamageSoaked);
		else	
			nArmorDamageTaken = 0;
		end
		ChatManagerPO.deliverArmorSoakMessage(sCharName, sItemName, nDamageSoaked, nArmorDamageTaken);
		if ArmorManagerPO.isBroken(nodeArmor) then
			ChatManagerPO.deliverArmorBrokenMessage(sCharName, sItemName);
		end
	end	
	return nAbsorbed;
end

function modDamageOverride(rSource, rTarget, rRoll)
	if PlayerOptionManager.isPOCritEnabled() then
		-- TODO: make this visually roll dice
		local bIsCrit, nCritMultiplier = CritManagerPO.hasCritState(rSource, rTarget);
		if bIsCrit and nCritMultiplier > 0 then
			rRoll.nCritMultiplier = nCritMultiplier;
		end
	end
	fModDamage(rSource, rTarget, rRoll);
end

function onDamageRollOverride(rSource, rRoll)
	if PlayerOptionManager.isPOCritEnabled() then
		if rRoll.nCritMultiplier then
			rRoll.sDesc = string.format("%s [CRITICAL HIT (x%s)]", rRoll.sDesc, rRoll.nCritMultiplier);
			DiceManagerPO.multiplyDice(rRoll, rRoll.nCritMultiplier);
		end
	end

    if PlayerOptionManager.isPenetrationDiceEnabled() then
        DiceManagerPO.handlePenetration(rRoll, false);
    end
    
    fOnDamageRoll(rSource, rRoll);
end

function checkReductionTypeOverride(aReduction, aDmgType)
	if not PlayerOptionManager.isStricterResistancesEnabled() then
		return fCheckReductionType(aReduction, aDmgType);
	end
	
	local aReducedDamageTypes = {};

	for _,sDmgType in pairs(aDmgType) do
		if ActionDamage.checkReductionTypeHelper(aReduction[sDmgType], aDmgType) or ActionDamage.checkReductionTypeHelper(aReduction["all"], aDmgType) then
			table.insert(aReducedDamageTypes, sDmgType);
		end
	end  

	if #aReducedDamageTypes == 0 then
		return false;
	else
		-- We're going to treat bludgeoning/piercing/slashing differently, and say that if it contains more than one of these types, it must 
		-- resist ALL of these "base" damage types it contains to be resisted. (i.e., a bludgeoning/piercing morningstar shouldn't be resisted by 
		-- just bludgeoning resist, but should instead require both bludgeoning resist and piercing resist)
		local bIsBludgeoning, bIsPiercing, bIsSlashing = hasBaseDamageTypes(aDmgType);
		local bResistsBludgeoning, bResistsPiercing, bResistsSlashing = hasBaseDamageTypes(aReducedDamageTypes);

		local bResistsAllBaseTypesItContains = true;
		bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bIsBludgeoning or bResistsBludgeoning);
		bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bIsPiercing or bResistsPiercing);
		bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bResistsSlashing or bResistsSlashing);

		return bResistsAllBaseTypesItContains;
	end
end

function hasBaseDamageTypes(aDmgTypes)
	local bBludgeoning = false;
	local bPiercing = false;
	local bSlashing = false;
	
	for _,sDmgType in pairs(aDmgTypes) do
		local sDmgTypeLower = sDmgType:lower();
		if sDmgTypeLower:find("bludgeoning") then
			bBludgeoning = true;
		elseif sDmgTypeLower:find("slashing") then
			bSlashing = true;
		elseif sDmgTypeLower:find("piercing") then
			bPiercing = true;
		end
	end
	
	return bBludgeoning, bPiercing, bSlashing;
end

