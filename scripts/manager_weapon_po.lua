function onInit()
end

function getSizeCategory(nodeWeapon, nodeAttacker)
    local nSizeCategory = nil;
    if not nSizeCategory then
        -- First try to parse size from the weapon node
        nSizeCategory = getSizeCategoryFromNode(nodeWeapon);
    end

    if not nSizeCategory then
        -- Couldn't figure it out from the weapon node, so see if it's named after a natural weapon and base it on attacker size
        nSizeCategory = tryGetNaturalWeaponSizeCategory(nodeWeapon, nodeAttacker);
    end
    return nSizeCategory;
end

function getSizeCategoryFromNode(nodeWeapon)
    local nSizeCategory = nil;
    if nodeWeapon then
        local sProperties = DB.getValue(nodeWeapon, "properties", "");
            nSizeCategory = DataManagerPO.parseSizeFromProperties(sProperties);
        if not nSizeCategory then
            nSizeCategory = getDefaultWeaponSizeCategory(nodeWeapon);
        end
    end
    return nSizeCategory;
end

function tryGetNaturalWeaponSizeCategory(nodeWeapon, nodeAttacker)
    if nodeWeapon and nodeAttacker then
        local sWeaponName = DB.getValue(nodeWeapon, "name", "");
        for _, sNatWeaponName in pairs(DataCommonPO.aNaturalWeaponNames) do
            if sWeaponName:find(sNatWeaponName) then
                return ActorManagerPO.getSizeCategory(nodeAttacker) - 2;
            end
        end
    end
    return nil;
end

function getDefaultWeaponSizeCategory(nodeWeapon)
	local sName = DB.getValue(nodeWeapon, "name", ""):lower();
	for sWeaponName, sSize in pairs(DataCommonPO.aDefaultWeaponSizes) do
		if sName:find(sWeaponName) then
			return DataManagerPO.parseSizeString(sSize);
		end
	end
    Debug.console("couldn't find size for ", sName);
    return nil;
end

function getDamageTypes(nodeWeapon)
    if not nodeWeapon then 
        return nil; 
    end;
    
    return getDamageTypesFromDamageList(nodeWeapon);
end

function getDamageTypesFromDamageList(nodeWeapon)
    local aDamageTypes = {};
    
    for _, nodeDamage in pairs(DB.getChildren(nodeWeapon, "damagelist")) do
        local sDamageType = DB.getValue(nodeDamage, "type", "");
        for _, sExpectedDamageType in pairs(DataCommon.dmgtypes) do
            if sDamageType:find(sExpectedDamageType) then
                UtilityPO.addIfUnique(aDamageTypes, sExpectedDamageType);
            end
        end
    end 
    
    return aDamageTypes;
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