MoraleStatus = {
	Unknown = {id=-1, desc="unknown"},
	NoCheck = {id=0, desc="did not require check"},
	Success = {id=1, desc="success"},
	FightingRetreat = {id=2, desc="fall back, fighting"},
	DisengageRetreat = {id=3, desc="disengage-retreat"},
	Flee = {id=4, desc="flee in panic"},
	Surrender = {id=5, desc="surrender"}
}

function onInit()
end

function getMoraleNode()
	local nodeMorale = DB.findNode("poMorale");
	if not nodeMorale then
		nodeMorale = DB.createNode("poMorale");
	end
	return nodeMorale;
end

function getBattleReadiness(nodeChar)
	local nStatus = ActorManagerPO.getMoraleStatus(nodeChar);
	if nStatus <= MoraleStatus.Success.id then
		return "Battle ready!";
	else
		return getStatus(nStatus).desc;
	end
end

function getStatus(nStatusId)
	for _,status in pairs(MoraleStatus) do
		if nStatusId == status.id then
			return status;
		end
	end
	return MoraleStatus.Unknown;
end

function rollMoraleDice()
	return DiceManagerPO.getDieResult(10) + DiceManagerPO.getDieResult(10);
end

function resetAllNpcMorale()
	local aCombatants = CombatManager.getCombatantNodes();
	for _, nodeCT in pairs(aCombatants) do
		local nodeChar = CombatManagerADND.getNodeFromCT(nodeCT);
		if not ActorManagerPO.isPC(nodeChar) then
			ActorManagerPO.setMoraleStatus(nodeChar, MoraleStatus.Unknown.id);
		end
	end
	ChatManagerPO.deliverChatMessage("All NPC morale statuses reset.", true)
end

function checkAllNpcMorale(bForceCheck)
	local aResults = {};

	local aCombatants = CombatManager.getCombatantNodes();
	for _, nodeCT in pairs(aCombatants) do
		local nodeChar = CombatManagerADND.getNodeFromCT(nodeCT);
		if not ActorManagerPO.isPC(nodeChar) then
			table.insert(aResults, handleMoraleCheck(nodeChar, bForceCheck));
		end
	end
	ChatManagerPO.deliverMoraleCheckResults(aResults, true);
end

function isMoraleCheckNeeded(nodeChar)
	if ActorManagerPO.isFatigued(nodeChar) then
		return true;
	end

	local nPercentHealthRemaining = ActorManagerPO.getRemainingHealthPercentage(nodeChar);
	if nPercentHealthRemaining <= 75 and nPercentHealthRemaining > 0 then
		return true;
	end

	-- Global Causes
	-- *surprised
	-- *faced by superior force
	-- *ally slain by magic
	-- *25% of group fallen
	-- *50% of group fallen
	-- every companion slain after 50% fallen
	-- *leader deserts or killed
	-- *unable to harm opponent
	-- told to cover retreat
	-- directed to use up magic item
	-- given a chance to surrender
	-- completely surrounded.

	return false;
end

function handleMoraleCheck(nodeChar, bForceCheck)
	local combatantName = ActorManagerPO.getName(nodeChar);
	local rResult = {combatantName = combatantName, moraleState = MoraleStatus.NoCheck, usingPreviousState = false};

	if bForceCheck or isMoraleCheckNeeded(nodeChar) then
		rResult.moraleState = checkMorale(nodeChar);
	end

	local nPreviousMorale = ActorManagerPO.getMoraleStatus(nodeChar);
	if nPreviousMorale > rResult.moraleState.id then
		rResult.moraleState = getStatus(nPreviousMorale);
		rResult.usingPreviousState = true;
	end

	ActorManagerPO.setMoraleStatus(nodeChar, rResult.moraleState.id);
	return rResult;
end

function checkMorale(nodeChar)
	
	local nMoraleAttribute = ActorManagerPO.getMorale(nodeChar);

	local rStatus = MoraleStatus.Unknown;

	if nMoraleRating ~= nil then
		local nModifier = getIndividualMoraleModifier(nodeChar);	
		nModifier = nModifier + getGlobalMoraleModifier();
		local nDieRoll = rollMoraleDice();
		local nCheckScore = nDieRoll + nModifier;
		local nDifference = nCheckScore - nMoraleRating;

		if nDifference > 10 then
			rStatus = MoraleStatus.Surrender;
		elseif nDifference > 6 then
			rStatus = MoraleStatus.Flee;
		elseif nDifference > 3 then
			rStatus = MoraleStatus.DisengageRetreat;
		elseif nDifference > 0 then
			rStatus = MoraleStatus.FightingRetreat;
		else
			rStatus = MoraleStatus.Success;
		end
	end

	return rStatus;
end

function setGlobalMoraleModifier(modifier)
	DB.setValue(getMoraleNode(), "globalModifier", "number", modifier);
end

function getGlobalMoraleModifier()
	--Abandoned by friends –6
	--Creature is fighting hated enemy +4
	--Creature was surprised –2
	--Creatures are fighting wizards or magic-using foes –2
	--Defending home +3
	--Defensive terrain advantage +1
	--Each additional check required in round** –1
	--Leader is of different alignment –1
	--Most powerful ally killed –4
	--NPC has been favored +2
	--NPC has been poorly treated –4
	--No enemy slain –2
	--Outnumbered by 3 or more to 1 –4
	--Outnumber opponent 3 or more to 1 +2
	--Unable to affect opponent*** –8
	--Wizard or magic-using creature on same side +2
	return DB.getValue(getMoraleNode(), "globalModifier", 0);
end

function getIndividualMoraleModifier(nodeChar)
	local nModifier = 0;

	nModifier = nModifier + getAlignmentModifier(nodeChar);
	nModifier = nModifier + getPercentHpMoraleModifier(nodeChar);
	nModifier = nModifier + getFatigueModifier(nodeChar);

	return nModifier;
end

function getAlignmentModifier(nodeChar)
	if ActorManagerPO.isAlignment(nodeChar, "lawful") then
		return -1;
	elseif ActorManagerPO.isAlignment(nodeChar, "chaotic") then
		return 1;
	else
		return 0;
	end
end

function getFatigueModifier(nodeChar)
	local aFatigueEffects = FatigueManagerPO.getFatigueEffectsForChar(nodeChar);
	return #aFatigueEffects;
end

function getPercentHpMoraleModifier(nodeChar)
	local nPercentHpRemaining = ActorManagerPO.getRemainingHealthPercentage(nodeChar);
	if nPercentHpRemaining <= 50 then
		return 4;
	elseif nPercentHpRemaining <= 75 then
		return 2;
	end

	return 0;
end