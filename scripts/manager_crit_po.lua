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
		local nRequiredCritRoll = PlayerOptionManager.getRequiredCritRoll();
		local bMustHitBy5 = PlayerOptionManager.mustCritHitBy5();

		return rAction.nFirstDie >= PlayerOptionManager.getRequiredCritRoll() and (not bMustHitBy5 or nHitDifference >= 5);
	end
	return false;
end

function isCriticalHit2e(rRoll, rAction)
	local sCritThreshold = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
	local nCritThreshold = tonumber(sCritThreshold) or 20;
	if nCritThreshold < 2 or nCritThreshold > 20 then
		nCritThreshold = 20;
	end

	return rAction.nFirstDie >= nCritThreshold
end

function getWeaponInfo(rSource)
	local rWeaponInfo = {};
	if rSource.itemPath then
		rWeaponInfo.nodeWeapon = DB.findNode(rSource.itemPath);
		if rWeaponInfo.nodeWeapon then
			rWeaponInfo.size = WeaponManagerPO.getSizeCategory(rWeaponInfo.nodeWeapon);
		else
			local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
			rWeaponInfo.size = ActorManagerPO.getSizeCategory(nodeAttacker) - 2;
		end
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
		return rCrit;
	end
end

function buildCritMessage(rCrit)
	-- TODO: remove save message once it's automated
	local sCritMsg = string.format("Severity %s critical hit to the %s. %s", 
		rCrit.nSeverity, rCrit.sHitLocation, rCrit.desc);
	sCritMsg = sCritMsg .. " Save vs death to avoid effects.";
	return sCritMsg;
end


function isDefenderAffectedByCrit(nodeDefender)
	-- TODO: make a saving throw
	-- certain creatures immune to certain effects
	return true;
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
	local sDefenderType = ActorManagerPO.getType(nodeDefender);
	if not sDamageType or not sDefenderType or not rHitLocation or not rHitLocation.locationCategory or not nSeverity then
		Debug.console("couldn't generate crit", "sDefenderType", sDefenderType, "sDamageType", sDamageType, "rHitLocation", rHitLocation, "nSeverity", nSeverity);
	end
	
	local rCrit = DataCommonPO.aCritCharts[sDefenderType][sDamageType][rHitLocation.locationCategory][nSeverity];
	rCrit.sHitLocation = rHitLocation.desc;
	rCrit.nSeverity = nSeverity;
	if nSeverity >= 13 then
		rCrit.dmgMultiplier = 3;
	else
		rCrit.dmgMultiplier = 2;
	end

	rCrit.message = buildCritMessage(rCrit);
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
