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
		local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
		local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
		local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
		local nSeverity = getSeverity(nodeAttacker, nodeDefender);
		-- determine severity
		-- Target needs to save vs death
		-- if they fail, determine extra effects
		-- determine damage bonus
	end
end

function getSeverity(nodeAttacker, nodeDefender)
	local nDefenderSizeCategory = ActorManagerPO.getSizeCategory(nodeDefender);
	return nil;
	--local nodeWeapon = nil; -- TODO
	--local nWeaponSizeCategory = WeaponManagerPO.getSizeCategory(nodeWeapon);
end
