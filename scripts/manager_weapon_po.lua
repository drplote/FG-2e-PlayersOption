local fBuildAttackAction;
local fBuiltInitiativeItem;

function onInit()
    fBuildAttackAction = WeaponManagerADND.buildAttackAction;
    WeaponManagerADND.buildAttackAction = buildAttackActionOverride;

    fBuiltInitiativeItem = WeaponManagerADND.builtInitiativeItem;
    WeaponManagerADND.builtInitiativeItem = builtInitiativeItemOverride;
end

function builtInitiativeItemOverride(nodeWeapon)
    local rItem = fBuiltInitiativeItem(nodeWeapon);
    rItem.nType = DB.getValue(nodeWeapon, "type", 0);
    rItem.isNil = (not nodeWeapon);
    return rItem;
end

function buildAttackActionOverride(rActor, nodeWeapon)
    local rAction = fBuildAttackAction(rActor, nodeWeapon);

    rAction.weaponPath = nodeWeapon.getPath();
    local aDamageTypes = getDamageTypes(nodeWeapon);
    rAction.aDamageTypes = encodeDamageTypes(aDamageTypes);

    return rAction;
end

function getSizeCategory(nodeWeapon, nodeAttacker, canReturnDefault)
    local nSizeCategory = nil;
    if not nSizeCategory then
        -- First try to parse size from the weapon node
        nSizeCategory = getSizeCategoryFromNode(nodeWeapon, canReturnDefault);
    end

    if not nSizeCategory and canReturnDefault then
        -- Couldn't figure it out from the weapon node, so see if it's named after a natural weapon and base it on attacker size
        nSizeCategory = tryGetNaturalWeaponSizeCategory(nodeWeapon, nodeAttacker);
    end
    return nSizeCategory;
end

function getSizeCategoryFromNode(nodeWeapon, canReturnDefault)
    local nSizeCategory = nil;
    if nodeWeapon then
        local sProperties = DB.getValue(nodeWeapon, "properties", "");
            nSizeCategory = DataManagerPO.parseSizeFromProperties(sProperties);
        if not nSizeCategory and canReturnDefault then
            nSizeCategory = getDefaultWeaponSizeCategory(nodeWeapon);
        end
    end
    return nSizeCategory;
end

function tryGetNaturalWeaponSizeCategory(nodeWeapon, nodeAttacker)
    if nodeWeapon and nodeAttacker then
        local sWeaponName = DB.getValue(nodeWeapon, "name", ""):lower();
        for sNatWeaponName, nSizeCategoryModifier in pairs(DataCommonPO.aNaturalWeapons) do
            if sWeaponName:find(sNatWeaponName) then
                return ActorManagerPO.getSizeCategory(nodeAttacker) + nSizeCategoryModifier;
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

function encodeDamageTypes(aDamageTypes)
    if not aDamageTypes then
        return "";
    end

    return UtilityPO.toCSV(aDamageTypes);
end

function decodeDamageTypes(sDamageTypes)
    if UtilityPO.isEmpty(sDamageTypes) then
        return {};
    end
    return UtilityPO.fromCSV(sDamageTypes);
end

function getSpeedFactor(nodeWeapon)
    if not nodeWeapon then
        return 0;
    end

    return DB.getValue(nodeWeapon, "speedfactor", 0);
end