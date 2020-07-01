function onInit()
end

function getTypeForHitLocation(nodeActor)
	if ActorManager.isPC(nodeActor) then
		return "humanoid";
	else
		local sType = DB.getValue(nodeActor, "type", ""):lower();
		if sType:find("humanoid") then
			return "humanoid";
		elseif sType:find("animal") then
			return "animal";
		elseif sType:find("monster") then
			return "monster";
		else
			return getDefaultActorTypeForCrit(nodeActor);
		end
	end
end

function getDefaultActorTypeForCrit(nodeActor)
	local sName = DB.getValue(nodeActor, "name", ""):lower();
	for sCreatureName, sCreatureType in pairs(DataCommonPO.aDefaultCreatureTypes) do
		if sName:find(sCreatureName) then
			return sCreatureType;
		end
	end
	return "monster"; -- Default to monster if we can't find anything else.
end

function getSizeCategory(nodeActor)
	-- Size Categories: 1 = T, 2 = S, 3 = M, 4 = L, 5 = H, 6 = G
	local nSizeCategory;
	if ActorManager.isPC(nodeActor) then
		local sSizeRaw = DB.getValue(nodeActor, "size", "");
		nSizeCategory = DataManagerPO.parseSizeString(sSizeRaw);
		if not nSizeCategory then
			nSizeCategory = getDefaultSizeFromRace(nodeActor);
		end
	else
		local sSizeRaw = DB.getValue(nodeActor, "size", "");
		nSizeCategory = DataManagerPO.parseSizeString(sSizeRaw);
	end
	
	if not nSizeCategory then
		nSizeCategory = 3; -- If we couldn't figure it out, default to medium
	end
	return nSizeCategory;
end

function getDefaultSizeFromRace(nodeActor)
	local sRace = DB.getValue(nodeActor, "race", "");
	local nSize = DataCommonPO.aDefaultRaceSizes[sRace];
	return nSize;
end

