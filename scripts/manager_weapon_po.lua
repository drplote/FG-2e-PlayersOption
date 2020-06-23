function onInit()
end

function getWeaponType(nodeWeapon)
    if not nodeWeapon then 
        return nil; 
    end;
    
    local sWeaponType = DB.getValue(nodeWeapon, "weaponType", nil);
    if sWeaponType then
        return sWeaponType;
    else
        -- If the weaponType property wasn't set, we'll have to dig through the damages to see if there is a known damage type
        return getWeaponTypeFromDamageList(nodeWeapon);
    end 
end

function getWeaponTypeFromDamageList(nodeWeapon)
    local aDamageTypes = {};
    
    for _, nodeDamage in pairs(DB.getChildren(nodeWeapon, "damagelist")) do
        local sDamageType = DB.getValue(nodeDamage, "type", "");
        for _, sExpectedDamageType in pairs(DataCommon.dmgtypes) do
            if sDamageType:find(sExpectedDamageType) then
                UtilityPO.addIfUnique(aDamageTypes, sExpectedDamageType);
            end
        end
    end 
    
    return UtilityPO.toCSV(aDamageTypes);
end

function isBludgeoning(sDamageType)
    return isDamageType(sDamageType, {"bludgeon", "crushing"});
end

function isSlashing(sDamageType)
    return isDamageType(sDamageType, {"slash", "hack"});
end

function isPiercing(sDamageType)
    return isDamageType(sDamageType, {"piercing", "pierce", "puncturing", "puncture"});
end

function isDamageType(sDamageType, aDamageTypeNames)
    local sLower = sDamageType:lower();
    for _, sDamageTypeName in pairs(aDamageTypeNames) do
        if sLower:find(sDamageTypeName:lower()) then
            return true;
        end
    end
    return false;
end