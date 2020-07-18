function onInit()
end

function isCriticalHit(rRoll, rAction, nDefenseVal)
	if PlayerOptionManager.isPOCritEnabled() then
		return isCriticalHitCombatAndTactics(rRoll, rAction, nDefenseVal);
	else
		return isCriticalHit2e(rRoll, rAction);
	end
end

function isCriticalHitCombatAndTactics(rRoll, rAction, nDefenseVal)
	if nDefenseVal and nDefenseVal ~= 0 then
		local nRequiredCritRoll = getCritThreshold(rRoll);
		local bMustHitBy5 = PlayerOptionManager.mustCritHitBy5();
		local nHitDifference = CombatCalcManagerPO.getAttackVsDefenseDifference(rRoll, rAction, nDefenseVal);
		return rAction.nFirstDie >= nRequiredCritRoll and (not bMustHitBy5 or nHitDifference >= 5);
	end
	return false;
end

function getCritThreshold(rRoll)
	if PlayerOptionManager.isUsingCombatAndTacticsCritsRAW() then
		return 18;
	else
		local sCritThreshold = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
		local nCritThreshold = tonumber(sCritThreshold) or 20;
		if nCritThreshold < 2 or nCritThreshold > 20 then
			nCritThreshold = 20;
		end
		return nCritThreshold;
	end
end


function isCriticalHit2e(rRoll, rAction)
	local nCritThreshold = getCritThreshold(rRoll);
	return rAction.nFirstDie >= nCritThreshold
end


function getWeaponInfo(rSource)
	local rWeaponInfo = {};
	local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
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

function handleCrit(rSource, rTarget)
	if rSource and rTarget then
		local rWeaponInfo = getWeaponInfo(rSource);
		local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
		local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
		local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
		local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender, rWeaponInfo);
		local nSeverity = getSeverityDieRoll(nSizeDifference);
		local rCrit = getCritResult(rWeaponInfo, nodeDefender, rHitLocation, nSeverity);
		StateManagerPO.setCritState(rSource, rTarget, rCrit.dmgMultiplier);
		return rCrit;
	end
	return nil;
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
		rCrit = DataCommonPO.aCritCharts[sDefenderType][sDamageType][rHitLocation.locationCategory][nSeverity];		
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
