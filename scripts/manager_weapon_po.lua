function onInit()
end

function getSizeCategory(nodeWeapon)
	--TODO: eventually try to read this from properties
	local sSize = getDefaultWeaponSizeCategory(nodeWeapon);
	return DataManagerPO.parseSizeString(sSize);
end

function getDefaultWeaponSizeCategory(nodeWeapon)
	local sName = DB.getValue(nodeWeapon, "name", ""):lower();
	for sWeaponName, sSize in pairs(DataCommonPO.aDefaultWeaponSizes) do
		if sName:find(sWeaponName) then
			return sSize;
		end
	end
    Debug.console("couldn't find size for ", sName);
    return "";
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