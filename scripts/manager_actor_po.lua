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
	local sType = getDefaultActorTypeForCritByType(nodeActor);
	if UtilityPO.isEmpty(sType) then
		sType = getDefaultActorTypeForCritByName(nodeActor);
	end
	if UtilityPO.isEmpty(sType) then
		-- If we can't find anything, default to monster
		sType = "monster";
	end
	return sType;
end

function getDefaultActorTypeForCritByType(nodeActor)
	local sType = DB.getValue(nodeActor, "type", ""):lower();
	for sKeyedType, sMappedType in pairs(DataCommonPO.aDefaultCreatureTypesByType) do
		if sType:find(sKeyedType) then
			return sMappedType;
		end
	end
	return nil;
end

function getDefaultActorTypeForCritByName(nodeActor)
	local sName = DB.getValue(nodeActor, "name", ""):lower();
	for sKeyedName, sMappedType in pairs(DataCommonPO.aDefaultCreatureTypesByName) do
		if sName:find(sKeyedName) then
			return sMappedType;
		end
	end
	return nil;
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

