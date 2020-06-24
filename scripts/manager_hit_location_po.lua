function onInit()
end

function getHitLocation(nodeAttacker, nodeDefender)
	local sDefenderType = getCharacterType(nodeDefender);
	local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender);
	local nHitLocationRoll = getHitLocationDieRoll(nSizeDifference);
	return lookupHitLocation(sDefenderType, nHitLocationRoll);
end

function lookupHitLocation(sDefenderType, nHitLocationRoll)
	return DataCommonPO.aHitLocations[sDefenderType][nHitLocationRoll].desc;
end

function getHitLocationDieRoll(nSizeDifference)
	if nSizeDifference > 1 then	
		return math.random(1, 6) + 4;
	elseif nSizeDifference < -1 then
		return math.random(1, 6);
	else
		return math.random(1, 10);
	end
end

function getSizeDifference(nodeAttacker, nodeDefender)
	local nAttackerSize = getCharacterSizeCategory(nodeAttacker);
	local nDefenderSize = getCharacterSizeCategory(nodeDefender);
	
	return nAttackerSize - nDefenderSize;
end

function getCharacterSizeCategory(nodeChar)
	-- Size Categories: 1 = T, 2 = S, 3 = M, 4 = L, 5 = H, 6 = G
	if ActorManager.isPC(nodeChar) then
		local sSizeRaw = DB.getValue(nodeChar, "size");
		if sSizeRaw then
			return parseSizeString(sSizeRaw);
		else
			return getSizeFromRace(nodeChar);
		end
	else
		local sSizeRaw = DB.getValue(nodeChar, "size", "");
		return parseSizeString(sSizeRaw);
	end
end

function getSizeFromRace(nodeChar)
	local sRace = DB.getValue(nodeChar, "race", "");
	local nSize = DataCommonPO.aRaceSizes[sRace];
	if nSize then	
		return nSize;
	else
		return 3; -- Default to medium if we didn't find it.
	end
end

function parseSizeString(sSizeRaw)
		local sSize = sSizeRaw:lower();
		if sSize:find("tiny") then
			return 1;
		elseif sSize:find("small") then
			return 2;
		elseif sSize:find("medium") then
			return 3;
		elseif sSize:find("large") then
			return 4;
		elseif sSize:find("huge") then
			return 5;
		elseif sSize:find("gargantuan") then
			return 6;
		elseif sSizeRaw:find("T") then
			return 1;
		elseif sSizeRaw:find("S") then
			return 2;
		elseif sSizeRaw:find("M") then
			return 3;
		elseif sSizeRaw:find("L") then
			return 4;
		elseif sSizeRaw:find("H") then
			return 5;
		elseif sSizeRaw:find("G") then
			return 6;
		else	
			return 3; -- Default to medium if we don't know.
		end
end

function getCharacterType(nodeChar)
	if ActorManager.isPC(nodeChar) then
		return "humanoid";
	else
		local sType = DB.getValue(nodeChar, "type", ""):lower();
		if sType:find("humanoid") then
			return "humanoid";
		elseif sType:find("animal") then
			return "animal";
		else	
			return "monster";
		end
	end
end
