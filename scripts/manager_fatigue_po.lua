local sFatigueEffectPrefix;
local sFatigueEffectPC;
local sFatigueEffectNPC;

function onInit()
	sFatigueEffectPrefix = "Combat Fatigue;";
	sFatigueEffectPC = sFatigueEffectPrefix .. "DEX:-1;STR:-1";
	sFatigueEffectNPC = sFatigueEffectPrefix .. "AC:-1;ATK:-1";
end

function recordCast(rChar)
	StateManagerPO.setFatigueState(rChar, 1);
end

function recordAttack(rChar, sRange)
	if sRange == "M" then
		StateManagerPO.setFatigueState(rChar, 2);
	else
		StateManagerPO.setFatigueState(rChar, 1);
	end
end

function clearFatigueState()
	StateManagerPO.clearFatigueState();
end

function resetFatigue(nodeChar)
	setCurrentFatigue(nodeChar, 0);
end

function getNpcFatigueFactor(nodeChar)
	local sSpecialDefense = DB.getValue(nodeChar, "specialDefense", "");
	local sFatigueFactor = DataManagerPO.parseFatigueFactorFromString(sSpecialDefense);
	if not UtilityPO.isEmpty(sFatigueFactor) then
		return tonumber(sFatigueFactor);
	else
		-- Absent any specification, we'll default monsters to slightly higher fatigue factor
		-- because their penalties for failing are going to stack up quicker 
		return 5;
	end
end

function getFatigueFactor(nodeChar)
	if ActorManager.isPC(nodeChar) then
		return DB.getValue(nodeChar, "fatigue.factor", 5);
	else
		return getNpcFatigueFactor(nodeChar);
	end
end

function setCurrentFatigue(nodeChar, nFatigue)
	DB.setValue(nodeChar, "fatigue.score", "number", nFatigue);
	ChatManager.SystemMessage(ActorManager.getDisplayName(nodeChar) .. "'s fatigue is now " .. nFatigue .. ".");
	if nFatigue == 0 then
		removeAllFatigueEffects(nodeChar);
	end
end

function getCurrentFatigue(nodeChar)
	return DB.getValue(nodeChar, "fatigue.score", 0);
end

function handleFatigueForCombatants()
	local aCombatants = CombatManager.getCombatantNodes();
	for _, nodeChar in pairs(aCombatants) do
		local sCreatureNodeName = ActorManager.getCreatureNodeName(nodeChar);
		local nFatigue = StateManagerPO.getFatigueState(sCreatureNodeName);
		if nFatigue == 2 then
			increaseFatigue(sCreatureNodeName);
		elseif nFatigue == 0 then
			decreaseFatigue(sCreatureNodeName);
		end
	end
end

function updateFatigueFactor(nodeChar)
	
	local lEnumbranceMultipliersByRank = {};
	lEnumbranceMultipliersByRank["Normal"] = 1.0;
	lEnumbranceMultipliersByRank["Light"] = .75;
	lEnumbranceMultipliersByRank["Moderate"] = .5;
	lEnumbranceMultipliersByRank["Heavy"] = .25;
	lEnumbranceMultipliersByRank["Severe"] = 0;
	lEnumbranceMultipliersByRank["MAX"] = 0;
	
	-- con / 2 * rank (unc =1, light=.75,mod=.5,heavy=.25, severe=0)
	local nCon = DB.getValue(nodeChar, "abilities.constitution.total", DB.getValue(nodeChar, "abilities.constitution.score", 0));
	
	local sEncRank, nBaseEnc, nBaseMove = CharManager.getEncumbranceRank2e(nodeChar);
	local lEncMultiplier = lEnumbranceMultipliersByRank[sEncRank] or 0;
	local nFatigueFactor = math.floor(nCon / 2 * lEncMultiplier);
	local nMultiplier = DB.getValue(nodeChar, "fatigue.multiplier", 1);
	nFatigueFactor = nFatigueFactor * nMultiplier;

	Debug.console(ActorManager.getDisplayName(nodeChar) .. " now has a fatigue factor of " .. nFatigueFactor);
	DB.setValue(nodeChar, "fatigue.factor", "number", nFatigueFactor);
end

function increaseFatigue(rChar)
	local nodeChar = ActorManagerPO.getNode(rChar);
	local nCurrentFatigue = getCurrentFatigue(nodeChar);
	local nNewFatigue = nCurrentFatigue + 1;
	setCurrentFatigue(nodeChar, nNewFatigue);
	if nNewFatigue > getFatigueFactor(nodeChar) then
		checkForFatiguePenalty(nodeChar);	
	end
end

function decreaseFatigue(rChar)
	local nodeChar = ActorManagerPO.getNode(rChar);
	local nCurrentFatigue = getCurrentFatigue(nodeChar);
	if nCurrentFatigue > 0 then
		local nNewFatigue = nCurrentFatigue - 1;
		setCurrentFatigue(nodeChar, nNewFatigue);
		if nNewFatigue > 0 and nNewFatigue <= getFatigueFactor(nodeChar) then
			checkToRemoveFatiguePenalty(nodeChar);
		end
	end

end

function getFatigueEffectsForChar(nodeChar)
	local aFatigueEffects = {};
	local nodeCT = CharManager.getCTNodeByNodeChar(nodeChar);
	for _, nodeEffect in pairs(DB.getChildren(nodeCT, "effects")) do
		local sEffectLabel = DB.getValue(nodeEffect, "label");
		if sEffectLabel:match(sFatigueEffectPrefix) then
			table.insert(aFatigueEffects, nodeEffect);
		end
	end
	return aFatigueEffects;
end

function addFatigueEffect(nodeChar)
	local sFatigueEffect = sFatigueEffectPC;
	if not ActorManager.isPC(nodeChar) then
		sFatigueEffect = sFatigueEffectNPC;
	end

	local nodeCT = CharManager.getCTNodeByNodeChar(nodeChar);
	EffectManager.addEffect("", "", nodeCT, { sName = sFatigueEffect, sLabel = sFatigueEffect, nDuration = 0 }, true);
end

function removeAllFatigueEffects(nodeChar)
	for _, nodeEffect in pairs(getFatigueEffectsForChar(nodeChar)) do
		nodeEffect.delete();
	end
end

function getFatigueCheckTarget(nodeChar)
	if ActorManager.isPC(nodeChar) then
		return getFatigueCheckTargetForPC(nodeChar);
	else
		return getFatigueCheckTargetForNPC(nodeChar);
	end
end

function getFatigueCheckTargetForNPC(nodeChar)
	-- NPCs use morale for their fatigue check
	local sMorale = DB.getValue(nodeChar, "morale", "");
	local nMorale = DataManagerPO.parseMoraleFromString(sMorale);
	if nMorale then
		return nMorale;
	else
		return getFatigueCheckTargetForPC(nodeChar);
	end
end

function getFatigueCheckTargetForPC(nodeChar)
	local nCon = DB.getValue(nodeChar, "abilities.constitution.total", 10);
	local nConPercent = DB.getValue(nodeChar, "abilities.constitution.percenttotal", 0) / 100;
	local nWis = DB.getValue(nodeChar, "abilities.wisdom.total", 10);
	local nWisPercent = DB.getValue(nodeChar, "abilities.wisdom.percenttotal", 0) / 100;
	local nAverage = (nCon + nWis + nWisPercent + nConPercent ) / 2
	return math.floor(nAverage);
end


function checkToRemoveFatiguePenalty(nodeChar)
	local aFatigueEffects = getFatigueEffectsForChar(nodeChar);
	if #aFatigueEffects > 0 then
		local nConScore = DB.getValue(nodeChar, "abilities.constitution.total", DB.getValue(nodeChar, "abilities.constitution.score", 0));
		local sName = ActorManagerPO.getName(nodeChar);
		local nConRoll = math.random(1, 20);
		if  nConRoll <= nConScore then		
			local sMessage = sName .. " succeeds at a Constitution check to remove a level of fatigue [" .. nConRoll .. " <= " .. nConScore .. "]!";
			ChatManager.SystemMessage(sMessage);
			aFatigueEffects[1].delete();
		else
			local sMessage = sName .. " fails a Constitution check to remove a level of fatigue [" .. nConRoll .. " > " .. nConScore .. "]!";
			ChatManager.SystemMessage(sMessage);
		end
	end
end

function checkForFatiguePenalty(nodeChar)
	local sName = ActorManagerPO.getName(nodeChar);
	local nFatigueCheckTarget = getFatigueCheckTarget(nodeChar);
	local nFatigueCheckRoll = math.random(1, 20);
	if nFatigueCheckRoll <= nFatigueCheckTarget  then
		local sMessage = sName .. " makes a fatigue save[" .. nFatigueCheckRoll .. " <= " .. nFatigueCheckTarget .. "]. No fatigue penalty gained.";
		ChatManager.SystemMessage(sMessage);
	else	
		local sMessage = sName .. " fails a fatigue save[" .. nFatigueCheckRoll .. " > " .. nFatigueCheckTarget .. "] and gains a fatigue penalty."; 
		ChatManager.SystemMessage(sMessage);
		addFatigueEffect(nodeChar);
	end
end