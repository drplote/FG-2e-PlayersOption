function onInit()
end

function isCriticalHit(rRoll, rAction, nDefenseVal, rSource, rTarget)
	if PlayerOptionManager.isAnyCritEnabled() then
		return isOptionalRulesCriticalHit(rRoll, rAction, nDefenseVal, rSource, rTarget);
	else
		return isCriticalHit2e(rRoll, rAction, rSource, rTarget);
	end
end

function isOptionalRulesCriticalHit(rRoll, rAction, nDefenseVal, rSource, rTarget)
	if EffectManagerPO.isAllowedToCrit(rSource) then
		if nDefenseVal and nDefenseVal ~= 0 then
			local nRequiredCritRoll = getCritThreshold(rRoll, rSource, rTarget);
			local bMustHitBy5 = PlayerOptionManager.mustCritHitBy5();
			local nHitDifference = CombatCalcManagerPO.getAttackVsDefenseDifference(rRoll, rAction, nDefenseVal);
			return rAction.nFirstDie >= nRequiredCritRoll and (not bMustHitBy5 or nHitDifference >= 5);
		end
	end
	return false;
end

function getCritThreshold(rRoll, rSource, rTarget)
	local nBaseThreshold = 20;
	if PlayerOptionManager.isUsingCombatAndTacticsCritsRAW() then
		nBaseThreshold = 18;
	else
		local sCritThreshold = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
		local nCritThreshold = tonumber(sCritThreshold) or 20;
		if nCritThreshold < 2 or nCritThreshold > 20 then
			nCritThreshold = 20;
		end
		nBaseThreshold = nCritThreshold;
	end

	if rSource then
		local nModBonus = EffectManager5E.getEffectsBonus(rSource, {"CRITCHANCE"}, true, {}, rTarget);
		nBaseThreshold = nBaseThreshold - nModBonus;
	end
	
	if rRoll.nCritThresholdMod then
		nBaseThreshold = nBaseThreshold - rRoll.nCritThresholdMod;
	end
	Debug.console("crit threshold", nBaseThreshold);
	return nBaseThreshold;
end


function isCriticalHit2e(rRoll, rAction, rSource, rTarget)
	local nCritThreshold = getCritThreshold(rRoll, rSource, rTarget);
	return rAction.nFirstDie >= nCritThreshold
end


function getWeaponInfo(rSource)
	local rWeaponInfo = {};
	local nodeAttacker = ActorManager.getCreatureNode(rSource);
	if not UtilityPO.isEmpty(rSource.weaponPath) then
		-- First try to determine size from the weapon action, if it exists. Don't allow default values
		local nodeWeapon = DB.findNode(rSource.weaponPath);
		rWeaponInfo.size = WeaponManagerPO.getSizeCategory(nodeWeapon, nodeAttacker, false);
	end
	if not rWeaponInfo.size and not UtilityPO.isEmpty(rSource.itemPath) then
		-- If we don't have a size yet, try to get it from the item, if it exists. Don't allow default avlues
		local nodeWeapon = DB.findNode(rSource.itemPath);
		rWeaponInfo.size = WeaponManagerPO.getSizeCategory(nodeWeapon, nodeAttacker, false);
	end
	if not rWeaponInfo.size and not UtilityPO.isEmpty(rSource.weaponPath) then
		-- If we don't find it, try weapon path info again, but allow defaults
		local nodeWeapon = DB.findNode(rSource.weaponPath);
		rWeaponInfo.size = WeaponManagerPO.getSizeCategory(nodeWeapon, nodeAttacker, true);
	end
	if not rWeaponInfo.size and not UtilityPO.isEmpty(rSource.itemPath) then
		-- If we don't find it, try item path info again, but allow defaults
		local nodeWeapon = DB.findNode(rSource.itemPath);
		rWeaponInfo.size = WeaponManagerPO.getSizeCategory(nodeWeapon, nodeAttacker, true);
	end
	if not rWeaponInfo.size then
		-- If we don't have a size yet, just make it the same as attacker size)
		rWeaponInfo.size = ActorManagerPO.getSizeCategory(nodeAttacker);
	end

	rWeaponInfo.aDamageTypes = rSource.aDamageTypes;
	return rWeaponInfo;
end

function getCritSizeBonus(rSource, rTarget)
	local nModBonus = EffectManager5E.getEffectsBonus(rSource, {"CRITSIZE"}, true, {}, rTarget);
	return nModBonus;
end

function getCritSeverityBonus(rSource, rTarget, rAction)
	-- attacker's crit bonus
	local nModBonus = EffectManager5E.getEffectsBonus(rSource, {"CRITSEVERITY"}, true, {}, rTarget);
	if rAction.nCritSeverityMod then
		nModBonus = nModBonus + rAction.nCritSeverityMod;
	end

	-- Target's crit resist
	local nModPenalty = EffectManager5E.getEffectsBonus(rTarget, {"CRITRESIST"}, true, {}, rSource);
	nModBonus = nModBonus - nModPenalty;
	Debug.console("Crit severity bonus:", nModBonus);
	return nModBonus;
end

function handleCrit(rRoll, rAction, nDefenseVal, rSource, rTarget)
	if rSource and rTarget then
		if EffectManagerPO.hasImmunity(rSource, rTarget, "critical") then
			Debug.console("Target was crit immune, so crit ignored");
			return nil;
		end

		if PlayerOptionManager.isPOCritEnabled() then
			return handlePlayersOptionCrit(rRoll, rAction, nDefenseVal, rSource, rTarget);
		elseif PlayerOptionManager.isHackmasterCritEnabled() then
			return CritManagerHM.handleCrit(rRoll, rAction, nDefenseVal, rSource, rTarget);
		end
	end
	return nil;
end

function handlePlayersOptionCrit(rRoll, rAction, nDefenseVal, rSource, rTarget)
	local rWeaponInfo = getWeaponInfo(rSource);
	local nodeAttacker = ActorManager.getCreatureNode(rSource);
	local nodeDefender = ActorManager.getCreatureNode(rTarget);
	local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender, rAction.sCalledShotLocation);
	local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender, rWeaponInfo) + getCritSizeBonus(rSource, rTarget);
	local nSeverity = getSeverityDieRoll(nSizeDifference) + getCritSeverityBonus(rSource, rTarget, rAction);
	local rCrit = getCritResult(rWeaponInfo, nodeDefender, rHitLocation, nSeverity);
	StateManagerPO.setCritState(rSource, rTarget, rCrit);
	Debug.console("Crit with weapon: ", rWeaponInfo, "hit location:", rHitLocation, "size difference", nSizeDifference, "severity", nSeverity);
	return rCrit;
end

function addCritMessage(rCrit)
    local sLocationMsg = string.format("In the %s", rCrit.sHitLocation or "");
    local sSeverityMsg = string.format(" (severity %s)", rCrit.nSeverity or "");
    local sTypeMsg = string.format("%s vs %s", rCrit.sDamageType or "", rCrit.sDefenderType or "");

	local sDmgMult = "2x";
    if rCrit.dmgMultiplier == 3 then
      sDmgMult = "3x";
    end
    local sDmgMultMsg = string.format("%s damage dice",  sDmgMult);

    rCrit.message = "";
    if not UtilityPO.isEmpty(rCrit.sHitLocation) then
    	rCrit.message = rCrit.message .. sLocationMsg;
    end
    if not UtilityPO.isEmpty(rCrit.sDamageType) and not UtilityPO.isEmpty(rCrit.sDefenderType) then
    	if not UtilityPO.isEmpty(rCrit.message) then
    		sTypeMsg = ", " .. sTypeMsg;
    	end
    	rCrit.message = rCrit.message .. sTypeMsg;
    end
    if rCrit.nSeverity then
    	rCrit.message = rCrit.message .. sSeverityMsg;
    end

    if not rCrit.error then
    	local sDesc = string.format(". %s Save vs death to avoid effects. %s regardless of save result.", rCrit.desc, sDmgMultMsg);
    	rCrit.message = rCrit.message .. sDesc;
    else
    	if not UtilityPO.isEmpty(rCrit.message) then
    		rCrit.message = rCrit.message .. string.format(". %s", sDmgMultMsg)
    	else
    		rCrit.message = sDmgMultMsg;
    	end
    end
end

function selectRandomCritDamageType(aDamageTypes)
	local aCritDamageTypes = getCritDamageTypes(aDamageTypes);
	if not aCritDamageTypes or #aCritDamageTypes == 0 then
		return nil;
	end
	return aCritDamageTypes[math.random(1, #aCritDamageTypes)];
end

function getCritDamageTypes(aDamageTypes)
	local aCritDamageTypes = {"bludgeoning", "piercing", "slashing"};
	return UtilityPO.getIntersecting(aCritDamageTypes, aDamageTypes);
end

function getCritResult(rWeaponInfo, nodeDefender, rHitLocation, nSeverity)
	local sDamageType = selectRandomCritDamageType(rWeaponInfo.aDamageTypes);
	local sDefenderType = ActorManagerPO.getTypeForHitLocation(nodeDefender);
	local rCrit = nil;
	if not sDamageType or not sDefenderType or not rHitLocation or not rHitLocation.locationCategory or not nSeverity then
		-- Build up what we can of a crit in an error case (usually just hit location and damage multiplier)
		Debug.console("couldn't generate crit", "sDefenderType", sDefenderType, "sDamageType", sDamageType, "rHitLocation", rHitLocation, "nSeverity", nSeverity);
		rCrit = {};
		rCrit.error = true;
	else
		local nSeverityIndex = nSeverity;
		if nSeverityIndex > 13 then nSeverityIndex = 13; end
		if nSeverityIndex < 1 then nSeverityIndex = 1; end
		rCrit = DataCommonPO.aCritCharts[sDefenderType][sDamageType][rHitLocation.locationCategory][nSeverityIndex];		
	end
	
	rCrit.sDefenderType = sDefenderType;
	if rHitLocation then
		rCrit.sHitLocation = rHitLocation.desc;
	end
	rCrit.nSeverity = nSeverity;
	rCrit.sDamageType = sDamageType;
	if nSeverity >= 13 then
		rCrit.dmgMultiplier = 3;
	else
		rCrit.dmgMultiplier = 2;
	end

	addCritMessage(rCrit);
	return rCrit;
end

function getSizeDifference(nodeAttacker, nodeDefender, rWeaponInfo)
	local nDefenderSizeCategory = ActorManagerPO.getSizeCategory(nodeDefender);
	local nAttackerSizeCategory = rWeaponInfo.size or 0;
	return nAttackerSizeCategory - nDefenderSizeCategory;    
end

function getSeverityDieRoll(nSizeDifference)
	local nRollResult = 1;
	if nSizeDifference < 0 then
		nRollResult = DiceManagerPO.getDiceResult(1, 6);
	elseif nSizeDifference == 1 then
		nRollResult = DiceManagerPO.getDiceResult(2, 6);
	elseif nSizeDifference > 1 then
		nRollResult = DiceManagerPO.getDiceResult(2, 8);
	else
		nRollResult = DiceManagerPO.getDiceResult(2, 4);
	end
	if nRollResult > 13 then
		nRollResult = 13;
	end
	return nRollResult;
end

function getCritType(sDamageTypes)
	local sCritType = selectRandomCritDamageType(aDamageTypes);
	if not sCritType or sCritType == "" then
		sCritType = "h"; -- couldn't parse anything, so call it hacking.
	else
		local sFirstChar = string.sub(sCritType, 1, 1);
		if sFirstChar == "s" or sFirstChar == "h" then
			sCritType = "h";
		elseif sFirstChar == "b" or sFirstChar == "c" then
			sCritType = "c";
		elseif sFirstChar == "p" then
			sCritType = "p"
		else
			sCritType = "h"; -- couldn't parse anything, so call it hacking.
		end
	end
	
	return sCritType;
end

function getCritEffects(sLocation, nSeverity, sDamageTypes)
	local sCritType = getCritType(sDamageTypes);
	if sCritType == "p" then
		return getPuncturingCrit(sLocation, nSeverity);
	elseif sCritType == "b" then
		return getCrushingCrit(sLocation, nSeverity);
	else	
		return getHackingCrit(sLocation, nSeverity);
	end
end

function calculateBaseSeverity(nAttackerThaco, nTargetAc, nAttackBonus)
	local nToHitAc15 = nAttackerThaco - 15;
	return nTargetAc - nToHitAc15 + nAttackBonus;
end

function getPuncturingCrit(sLocation, nSeverity)
	return decodeCritEffect(aPuncturingCritMatrix[sLocation][nSeverity], sLocation, nSeverity);
end

function getCrushingCrit(sLocation, nSeverity)
	return decodeCritEffect(aCrushingCritMatrix[sLocation][nSeverity], sLocation, nSeverity);
end

function getHackingCrit(sLocation, nSeverity)
	return decodeCritEffect(aHackingCritMatrix[sLocation][nSeverity], sLocation, nSeverity);
end