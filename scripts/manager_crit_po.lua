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

		return rAction.nFirstDie >= getRequiredCritRoll and (not bMustHitBy5 or nHitDifference >= 5);
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

function handleCrit(rSource, rTarget)
	if rSource and rTarget then
		local nodeWeapon = nil; --TODO: get this
		local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
		local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
		local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
		local nSizeDifference = getSizeDifference(nodeWeapon, nodeDefender);
		local nSeverity = getSeverityDieRoll(nSizeDifference);
		local rCrit = getCritResult(nodeWeapon, nodeDefender, rHitLocation, nSeverity);

		if rCrit and isDefenderAffectedByCrit(nodeDefender) then
			Comm.deliverChatMessage(buildCritMessage(rCrit));
		end
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
	return math.random(1, #aCritDamageTypes);
end

function getCritDamageTypes(aDamageTypes)
	local aCritDamageTypes = {"bludgeoning", "piercing", "slashing"};
	return UtilityPO.getIntersecting(aCritDamageTypes, aDamageTypes);
end

function getCritResult(nodeWeapon, nodeDefender, rHitLocation, nSeverity)
	local aDamageTypes = WeaponManagerPO.getDamageTypes(nodeWeapon);
	local sDamageType = selectRandomCritDamageType(aDamageTypes);
	local sDefenderType = ActorManagerPO.getType(nodeDefender);
	local rCrit = DataCommonPO.aCritCharts[sDefenderType][sDamageType][rHitLocation.locationCategory][nSeverity];
	rCrit.sHitLocation = rHitLocation.desc;
	rCrit.nSeverity = nSeverity;
	if nSeverity >= 13 then
		rCrit.dmgMultiplier = 3;
	else
		rCrit.dmgMultiplier = 2;
	end
end

function getSizeDifference(nodeWeapon, nodeDefender)
	local nDefenderSizeCategory = ActorManagerPO.getSizeCategory(nodeDefender);
	local nWeaponSizeCategory = WeaponManagerPO.getSizeCategory(nodeWeapon);
    return nAttackerSize - nDefenderSize;
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
