function onInit()
end

-- Speeds: 1 = Very Fast, 2 = Fast, 3 = Average, 4 = Slow, 5 = Very Slow

function getActionPhase(nodeActor)
	-- TODO: If they're casting a spell, use spell init
	-- TODO: else if they're using a weapon, use max of base init or weapon init
	-- TODO: else use base init
	local nBaseActorPhase = getBaseActorSpeedPhase(nodeActor);
	return nBaseActorPhase;
end

function getWorstPossiblePhaseForActor(nodeActor)
	local nPhase = getBaseActorSpeedPhase(nodeActor);
	for _,nodeWeapon in pairs(DB.getChildren(nodeEntry, "weaponlist")) do
		local nWeaponPhase = getWeaponPhase(nodeWeapon, nodeActor);
		nPhase = math.max(nPhase, nWeaponPhase);
	end
	return nPhase;
end

function getBaseActorSpeedPhase(nodeActor)
	if not nodeActor then
		return 3;
	end

	local nSizeCategory = ActorManagerPO.getSizeCategory(nodeActor);
	if nSizeCategory == 1 or nSizeCategory == 2 then
		return 1;
	elseif nSizeCategory == 3 then
		return 2;
	elseif nSizeCategory == 4 then
		return 3;
	elseif nSizeCategory == 5 then
		return 4;
	else 
		return 5;
	end

	-- TODO: speed >= 18, -1   If speed <= 6, +1
	-- TODO: enumbrance: moderate +1, heavy +2, severe +3
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

function getWeaponPhase(nodeWeapon, nodeActor)
	-- TODO: if magic +2 or +3, one phase less
	-- TODO: if magic > +3, two phases less
	-- TODO: add dex reaction adjustment into this?
	if not nodeWeapon then
		return 0;
	end

	local nSpeedFactor = WeaponManagerPO.getSpeedFactor(nodeWeapon);

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