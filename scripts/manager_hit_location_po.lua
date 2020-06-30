function onInit()
end

function getHitLocation(nodeAttacker, nodeDefender)
	local sDefenderType = ActorManagerPO.getTypeForHitLocation(nodeDefender);
	local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender);
	local nHitLocationRoll = getHitLocationDieRoll(nSizeDifference);
	return lookupHitLocation(sDefenderType, nHitLocationRoll);
end

function lookupHitLocation(sDefenderType, nHitLocationRoll)
	return DataCommonPO.aHitLocations[sDefenderType][nHitLocationRoll];
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

