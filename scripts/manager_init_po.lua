function onInit()
end

-- Speeds: 1 = Very Fast, 2 = Fast, 3 = Average, 4 = Slow, 5 = Very Slow

function getWorstPossiblePhaseForActor(nodeActor)
	local nPhase = getBaseActorSpeedPhase(nodeActor);
	for _,nodeWeapon in pairs(DB.getChildren(nodeActor, "weaponlist")) do
		local nWeaponPhase = getWeaponPhase(nodeWeapon, nodeActor);
		nPhase = math.max(nPhase, nWeaponPhase);
	end
	return nPhase;
end

function getPhaseName(nInitPhase)
	if nInitPhase < 1 then
		return "very fast+";
	elseif nInitPhase == 1 then
		return "very fast";
	elseif nInitPhase == 2 then
		return "fast";
	elseif nInitPhase == 3 then
		return "average";
	elseif nInitPhase == 4 then
		return "slow";
	elseif nInitPhase == 5 then
		return "very slow";
	else 
		return "very slow-";
	end

end

function getBaseActorSpeedPhase(nodeActor)
	if not nodeActor then
		return 3;
	end

	local nBaseSpeed;
	local nSizeCategory = ActorManagerPO.getSizeCategory(nodeActor);
	if nSizeCategory == 1 or nSizeCategory == 2 then
		nBaseSpeed = 1;
	elseif nSizeCategory == 3 then
		nBaseSpeed = 2;
	elseif nSizeCategory == 4 then
		nBaseSpeed = 3;
	elseif nSizeCategory == 5 then
		nBaseSpeed = 4;
	else 
		nBaseSpeed = 5;
	end

	nBaseSpeed = nBaseSpeed + getMovementRateModifierToPhase(nodeActor);
	nBaseSpeed = nBaseSpeed + getEncumbranceModifierToPhase(nodeActor);

	nBaseSpeed = math.max(1, math.min(5, nBaseSpeed)); -- bounds check
	return nBaseSpeed;
end

function getMovementRateModifierToPhase(nodeActor)
	local nMovementRate = DB.getValue(nodeActor, "speed.total", 12);
	if nMovementRate >= 18 then
		return -1;
	elseif nMovementRate <= 6 then
		return 1;
	else
		return 0;
	end
end

function getEncumbranceModifierToPhase(nodeActor)
	local sEncumbranceRank = DB.getValue(nodeActor, "speed.encumbrancerank", "");
	if sEncumbranceRank == "Moderate" then
		return 1;
	elseif sEncumranceRank == "Heavy" then
		return 2;
	elseif sEncumbranceRank == "Severe" or sEncumbranceRank == "MAX" then
		return 3;
	else
		return 0;
	end
end

function getSpellPhase(nSpellInitMod)
	if nSpellInitMod <= 0 then
		return 1;
	elseif nSpellInitMod <= 3 then
		return 2;
	elseif nSpellInitMod <= 6 then
		return 3;
	elseif nSpellInitMod <= 9 then
		return 4;
	else
		return 5;
	end
end

function getWeaponPhaseFromSpeed(nSpeedFactor, nodeActor)
	if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() and nodeActor then
		local nReactionAdj = 0 - DB.getValue(nodeActor, "abilities.dexterity.reactionadj", 0);
		nSpeedFactor = nSpeedFactor - nReactionAdj;
	end

	if nSpeedFactor <= 0 then
		return 1;
	elseif nSpeedFactor <= 4 then
		return 2;
	elseif nSpeedFactor <= 7 then
		return 3;
	elseif nSpeedFactor <= 13 then
		return 4;
	else
		return 5;
	end
end

function getWeaponPhase(nodeWeapon, nodeActor)
	if not nodeWeapon then
		return 0;
	end

	local nSpeedFactor = WeaponManagerPO.getSpeedFactor(nodeWeapon);
	return getWeaponPhaseFromSpeed(nSpeedFactor, nodeActor);
end