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
	if ActorManager.isPC(nodeActor) then
		local sSizeRaw = DB.getValue(nodeActor, "size");
		if sSizeRaw then
			return DataManagerPO.parseSizeString(sSizeRaw);
		else
			return getDefaultSizeFromRace(nodeActor);
		end
	else
		local sSizeRaw = DB.getValue(nodeActor, "size", "");
		return DataManagerPO.parseSizeString(sSizeRaw);
	end
end

function getDefaultSizeFromRace(nodeActor)
	local sRace = DB.getValue(nodeActor, "race", "");
	local nSize = DataCommonPO.aDefaultRaceSizes[sRace];
	if nSize then	
		return nSize;
	else
		return 3; -- Default to medium if we didn't find it.
	end
end

