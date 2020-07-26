function onInit()
end

function updateFatigueSave(nodeChar)
	local nCon = DB.getValue(nodeChar, "abilities.constitution.total", DB.getValue(nodeChar, "abilities.constitution.score", 0));
	local nWis = DB.getValue(nodeChar, "abilities.wisdom.total", DB.getValue(nodeChar, "abilities.wisdom.score", 0));
	local nFatigueSave = 20 - math.floor((nCon + nWis) / 2);
	
	DB.setValue(nodeChar, "saves.fatigue.base", "number", nFatigueSave);
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

	DB.setValue(nodeChar, "fatigue.factor", "number", nFatigueFactor);
end

function removeFatigue(nodeChar, nAmount)
	local nCurrentFatigue = DB.getValue(nodeChar, "fatigue.score", 0);
	if nCurrentFatigue > 0 then
		local nNewFatigue = 0;
		if nAmount then
			nNewFatigue = math.max(nCurrentFatigue - nAmount, 0);
		end
		DB.setValue(nodeChar, "fatigue.score", nNewFatigue);
	end
end

function tryToRemoveFatiguePenalty(nodeChar, sAttribute)
	local nConScore = DB.getValue(nodeChar, "abilities.constitution.total", DB.getValue(nodeChar, "abilities.constitution.score", 0));
	local nAttrMod = DB.getValue(nodeChar, "abilities." .. sAttribute .. ".fatiguemod", 0);
	if nAttrMod > 0 then
		local sName = DB.getValue(nodeChar, "name", "");
		local nConRoll = math.random(1, 20);
		if  nConRoll <= nConScore then
			nAttrMod = nAttrMod - 1;
			DB.setValue(nodeChar, "abilities." .. sAttribute .. ".fatiguemod", "number", nAttrMod);
			
			local sMessage = sName .. " succeeds at a Constitution check to remove fatigue[" .. nConRoll .. " <= " .. nConScore .. "]. " .. sAttribute .. " penalty drops to " .. nAttrMod .. ".";
			ChatManager.SystemMessage(sMessage);
		else
			local sMessage = sName .. " fails a Constitution check to remove fatigue[" .. nConRoll .. " > " .. nConScore .. "]. " .. sAttribute .. " penalty remains at " .. nAttrMod .. ".";
			ChatManager.SystemMessage(sMessage);
		end
	end
end

function checkForFatiguePenalty(nodeChar)
	local sName = DB.getValue(nodeChar, "name", "");
	local nFatigueSave = DB.getValue(nodeChar, "saves.fatigue.score", 20);
	local nFatigueSaveRoll = math.random(1, 20);
	if nFatigueSaveRoll >= nFatigueSave then
		local sMessage = sName .. " makes a fatigue save[" .. nFatigueSaveRoll .. " >= " .. nFatigueSave .. "]. No fatigue penalty gained." ;
		ChatManager.SystemMessage(sMessage);
	else	
		local nStrengthMod = DB.getValue(nodeChar, "abilities.strength.fatiguemod", 0) + 1;
		local nDexMod = DB.getValue(nodeChar, "abilities.dexterity.fatiguemod", 0) + 1;
		local sMessage = sName .. " fails a fatigue save[" .. nFatigueSaveRoll .. " < " .. nFatigueSave .. "]. Fatigue penalty rises to " .. nDexMod .. " dexterity and " .. nStrengthMod .. " strength.";
		ChatManager.SystemMessage(sMessage);

		DB.setValue(nodeChar, "abilities.strength.fatiguemod", "number", nStrengthMod);
		DB.setValue(nodeChar, "abilities.dexterity.fatiguemod", "number", nDexMod);
		-- report fatigue added
	end
end

function updateFatigue(nodeChar)
	-- get current fatigue
		-- If increasing, get fatigue factor
			-- if past fatigue factor, make fatigue check
			-- if failed, add fatiguemod penalty to str and dexterity
	-- display some messages
	-- set new fatigue
	local nPreviousFatigue = DB.getValue(nodeChar, "fatigue.previous", 0);
	local nCurrentFatigue = DB.getValue(nodeChar, "fatigue.score", 0);
	local nFatigueFactor = DB.getValue(nodeChar, "fatigue.factor", 0);

	if nCurrentFatigue == 0 then
		local sName = DB.getValue(nodeChar, "name", "");
		local nStrMod = DB.getValue(nodeChar, "abilities.strength.fatiguemod", 0);
		local nDexMod = DB.getValue(nodeChar, "abilities.dexterity.fatiguemod", 0);
		DB.setValue(nodeChar, "abilities.strength.fatiguemod", "number", 0);
		DB.setValue(nodeChar, "abilities.dexterity.fatiguemod", "number", 0);
		if nStrMod > 0 or nDexMod > 0 then
			ChatManager.SystemMessage(sName .. "'s fatigue drops to 0. All fatigue penalties cleared.");
		end
	elseif nCurrentFatigue <= nFatigueFactor and nCurrentFatigue < nPreviousFatigue then
		-- House rule: Fatigue is dropping, and is under fatigue factor. Roll checks to lose fatigue penalty
		tryToRemoveFatiguePenalty(nodeChar, "strength");
		tryToRemoveFatiguePenalty(nodeChar, "dexterity");
	elseif nCurrentFatigue > nFatigueFactor and nCurrentFatigue > nPreviousFatigue then
		-- Fatigue is rising and is over fatigue factor. Roll a fatigue save or gain fatigue penalty.
		checkForFatiguePenalty(nodeChar);
	end
	
	DB.setValue(nodeChar, "fatigue.previous", "number", nCurrentFatigue);
end