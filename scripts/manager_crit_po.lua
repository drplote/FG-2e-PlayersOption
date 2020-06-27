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
		local nHitDifference = CombatCalcManagerPO.getAttackVsDefenseDifference(rRoll, rAction, nDefenseVal);
		return rAction.nFirstDie >= 18 and nHitDifference >= 5;
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
	Debug.console("rSource", rSource);
	Debug.console("rTarget", rTarget);
	if rSource and rTarget then
		local nodeWeaon = nil; TODO: get this
		local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
		local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
		local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
		local nSizeDifference = getSizeDifference(nodeWeapon, nodeDefender);
		local nSeverity = getSeverityDieRoll(nSizeDifference);
		local rCrit = getCritResult(nodeWeapon, rHitLocation, nSeverity);

		if isDefenderAffectedByCrit(nodeDefender) then
			-- TODO: report it?
		end
	end
end

function isDefenderAffectedByCrit(nodeDefender)
	-- TODO: make a saving throw
	-- certain creatures immune to certain effects
	return true;
end

function getCritResult(nodeWeapon, rHitLocation, nSeverity)

end

function getSizeDifference(nodeWeapon, nodeDefender)
	local nDefenderSizeCategory = ActorManagerPO.getSizeCategory(nodeDefender);
	local nWeaponSizeCategory = WeaponManagerPO.getSizeCategory(nodeWeapon);
    return nAttackerSize - nDefenderSize;
end

function getSeverityDieRoll(nSizeDifference)
	if nSizeDifference < 0 then
		return DiceManagerPO.getDiceResult(1, 6);
	elseif nSizeDifference == 1 then
		return DiceManagerPO.getDiceResult(2, 6);
	elseif nSizeDifference > 1 then
		return DiceManagerPO.getDiceResult(2, 8);
	else
		return DiceManagerPO.getDiceResult(2, 4);
	end
end
