function onInit()
end

function getHitLocation(nodeAttacker, nodeDefender, sHitLocation)
	local sDefenderType = ActorManagerPO.getTypeForHitLocation(nodeDefender);
	local nHitLocationRoll = nil;

	Debug.console("getHitLocation", sHitLocation);

	if sHitLocation then
		for i,aHitLocationInfo in pairs(DataCommonPO.aHitLocations[sDefenderType]) do
			if UtilityPO.contains(aHitLocationInfo.categoryNames, sHitLocation) then
				nHitLocationRoll = i;
			end
		end
		if not nHitLocationRoll then
			Debug.console("We had a called shot but couldn't figure out what it mapped up to in the hit location list", sHitLocation);
		end
	end

	if not nHitLocationRoll then
		local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender);
		nHitLocationRoll = getHitLocationDieRoll(nSizeDifference);
		return lookupHitLocation(sDefenderType, nHitLocationRoll);
	else
		local rHitLocation = lookupHitLocation(sDefenderType, nHitLocationRoll);
		rHitLocation.desc = sHitLocation;
		return rHitLocation;
	end
end

function lookupHitLocation(sDefenderType, nHitLocationRoll)
	local rCopiedHitLocation = {};
	local rHitLocation = DataCommonPO.aHitLocations[sDefenderType][nHitLocationRoll];
	rCopiedHitLocation.desc = rHitLocation.desc;
	rCopiedHitLocation.locationCategory = rHitLocation.locationCategory;
	return rCopiedHitLocation;
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
	local nAttackerSize = ActorManagerPO.getSizeCategory(nodeAttacker);
	local nDefenderSize = ActorManagerPO.getSizeCategory(nodeDefender);
	
	return nAttackerSize - nDefenderSize;
end

