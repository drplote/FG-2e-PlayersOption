function onInit()
end

function getHitLocation(nodeAttacker, nodeDefender, sHitLocation)
    if PlayerOptionManager.isUsingHackmasterHitLocations() then
        return getHackmasterHitLocation(nodeAttacker, nodeDefender, sHitLocation);
    else
        return getPlayersOptionHitLocation(nodeAttacker, nodeDefender, sHitLocation);
    end
end

function getPlayersOptionHitLocation(nodeAttacker, nodeDefender, sCalledShotLocation)
    local sDefenderType = ActorManagerPO.getTypeForHitLocation(nodeDefender);
    local nHitLocationRoll = nil;

    if sCalledShotLocation then
        for i, aHitLocationInfo in pairs(DataCommonPO.aHitLocations[sDefenderType]) do
            if UtilityPO.contains(aHitLocationInfo.categoryNames, sCalledShotLocation) then
                nHitLocationRoll = i;
            end
        end
        if not nHitLocationRoll then
            Debug.console("We had a called shot but couldn't figure out what it mapped up to in the hit location list",
                sCalledShotLocation);
        end
    end

    if not nHitLocationRoll then
        local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender);
        nHitLocationRoll = getPlayersOptionHitLocationDieRoll(nSizeDifference);
        return lookupPlayersOptionHitLocation(sDefenderType, nHitLocationRoll);
    else
        local rHitLocation = lookupPlayersOptionHitLocation(sDefenderType, nHitLocationRoll);
        rHitLocation.desc = sCalledShotLocation;
        return rHitLocation;
    end
end

function lookupPlayersOptionHitLocation(sDefenderType, nHitLocationRoll)
    local rCopiedHitLocation = {};
    local rHitLocation = DataCommonPO.aHitLocations[sDefenderType][nHitLocationRoll];
    rCopiedHitLocation.desc = rHitLocation.desc;
    rCopiedHitLocation.locationCategory = rHitLocation.locationCategory;
    return rCopiedHitLocation;
end

function getPlayersOptionHitLocationDieRoll(nSizeDifference)
    if nSizeDifference > 1 then
        return math.random(1, 6) + 4;
    elseif nSizeDifference < -1 then
        return math.random(1, 6);
    else
        return math.random(1, 10);
    end
end

function getSizeDifference(nodeAttacker, nodeDefender)
    local nAttackerSize = ActorManagerPO.getSizeCategory(nodeAttacker) + getHitSizeBonus(nodeAttacker, nodeDefender);
    local nDefenderSize = ActorManagerPO.getSizeCategory(nodeDefender) + getDefendSizeBonus(nodeAttacker, nodeDefender);

    return nAttackerSize - nDefenderSize;
end

function getHitSizeBonus(rSource, rTarget)
    local nModBonus = EffectManager5E.getEffectsBonus(rSource, {"HITSIZE"}, true, {}, rTarget);
    return nModBonus;
end

function getDefendSizeBonus(rSource, rTarget)
    local nModBonus = EffectManager5E.getEffectsBonus(rTarget, {"DEFENDSIZE"}, true, {}, rSource);
    return nModBonus;
end

function getHackmasterHitLocationFromNumber(nHitLocationRoll)
    local rHitLocation = {};
    local bIsRightSide = nHitLocationRoll % 2 == 0;
    local sLocation = "";

    if nHitLocationRoll < 101 then
        sLocation = "Foot, top";
    elseif nHitLocationRoll < 105 then
        sLocation = "Heel";
    elseif nHitLocationRoll < 137 then
        sLocation = "Toe(s)";
    elseif nHitLocationRoll < 141 then
        sLocation = "Foot, arch";
    elseif nHitLocationRoll < 171 then
        sLocation = "Ankle, inner";
    elseif nHitLocationRoll < 201 then
        sLocation = "Ankle, outer";
    elseif nHitLocationRoll < 221 then
        sLocation = "Ankle, upper/Achilles";
    elseif nHitLocationRoll < 965 then
        sLocation = "Shin";
    elseif nHitLocationRoll < 1007 then
        sLocation = "Calf";
    elseif nHitLocationRoll < 1119 then
        sLocation = "Knee";
    elseif nHitLocationRoll < 1133 then
        sLocation = "Knee, back";
    elseif nHitLocationRoll < 1217 then
        sLocation = "Hamstring";
    elseif nHitLocationRoll < 2001 then
        sLocation = "Thigh";
    elseif nHitLocationRoll < 2331 then
        sLocation = "Hip";
    elseif nHitLocationRoll < 2406 then
        sLocation = "Groin";
    elseif nHitLocationRoll < 2436 then
        sLocation = "Buttock";
    elseif nHitLocationRoll < 2571 then
        sLocation = "Abdomen, Lower";
    elseif nHitLocationRoll < 3021 then
        sLocation = "Side, lower";
    elseif nHitLocationRoll < 3111 then
        sLocation = "Abdomen, upper";
    elseif nHitLocationRoll < 3126 then
        sLocation = "Back, small of";
    elseif nHitLocationRoll < 3156 then
        sLocation = "Back, lower";
    elseif nHitLocationRoll < 3426 then
        sLocation = "Chest";
    elseif nHitLocationRoll < 3456 then
        sLocation = "Side, upper";
    elseif nHitLocationRoll < 3486 then
        sLocation = "Back, upper";
    elseif nHitLocationRoll < 3501 then
        sLocation = "Back, upper middle";
    elseif nHitLocationRoll < 3821 then
        sLocation = "Armpit";
    elseif nHitLocationRoll < 4301 then
        sLocation = "Arm, upper outer";
    elseif nHitLocationRoll < 4493 then
        sLocation = "Arm, upper inner";
    elseif nHitLocationRoll < 4589 then
        sLocation = "Elbow";
    elseif nHitLocationRoll < 4685 then
        sLocation = "Inner joint";
    elseif nHitLocationRoll < 5309 then
        sLocation = "Forearm, back";
    elseif nHitLocationRoll < 5837 then
        sLocation = "Forearm, inner";
    elseif nHitLocationRoll < 5909 then
        sLocation = "Wrist, back";
    elseif nHitLocationRoll < 5981 then
        sLocation = "Wrist, front";
    elseif nHitLocationRoll < 6053 then
        sLocation = "Hand, back";
    elseif nHitLocationRoll < 6077 then
        sLocation = "Palm";
    elseif nHitLocationRoll < 6221 then
        sLocation = "Finger(s)";
    elseif nHitLocationRoll < 7181 then
        sLocation = "Shoulder, side";
    elseif nHitLocationRoll < 9101 then
        sLocation = "Shoulder, top";
    elseif nHitLocationRoll < 9122 then
        sLocation = "Neck, front";
    elseif nHitLocationRoll < 9143 then
        sLocation = "Neck, back";
    elseif nHitLocationRoll < 9374 then
        sLocation = "Neck, side";
    elseif nHitLocationRoll < 9654 then
        sLocation = "Head, side";
    elseif nHitLocationRoll < 9689 then
        sLocation = "Head, back lower";
    elseif nHitLocationRoll < 9769 then
        sLocation = "Face, lower side";
    elseif nHitLocationRoll < 9789 then
        sLocation = "Face, lower center";
    elseif nHitLocationRoll < 9824 then
        sLocation = "Head, back upper";
    elseif nHitLocationRoll < 9904 then
        sLocation = "Face, upper side";
    elseif nHitLocationRoll < 9924 then
        sLocation = "Face, upper center";
    else
        sLocation = "Head, top";
    end

    local sSide = "";
    if bIsRightSide then
        sSide = "right"
    else
        sSide = "left"
    end

    rHitLocation.desc = sLocation;
    rHitLocation.side = sSide;
    rHitLocation.roll = nHitLocationRoll;
    return rHitLocation;
end

function getHackmasterHitLocation(rSource, rTarget, sCalledShotLocation)
    local nHitLocationRoll;

    if sCalledShotLocation then
        local rHitRange = DataCommonPO.aHackmasterCalledShotsRanges[sCalledShotLocation];
        if rHitRange then
            nHitLocationRoll = math.random(rHitRange.low, rHitRange.high);
        end
    end
    if not nHitLocationRoll then
        local nLocationDieType = 10000;
        local nLocationHitModifier = 0;
        local nSizeDifference = getSizeDifference(ActorManagerPO.getNode(rSource), ActorManagerPO.getNode(rTarget));
        DebugPO.log("Size Difference =", nSizeDifference);
        if nSizeDifference > 0 then
            nLocationHitModifier = nLocationHitModifier + (1000 * nSizeDifference);
        elseif nSizeDifference < 0 then
            nLocationDieType = nLocationDieType - (1000 * nSizeDifference)
        end

        nHitLocationRoll = math.random(1, nLocationDieType) + nLocationHitModifier;
    end

    return getHackmasterHitLocationFromNumber(nHitLocationRoll);
end
