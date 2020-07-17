function onInit()
end

function getArmorHpChart(nodeArmor)
    local sProperties = DB.getValue(nodeArmor, "properties", "");
    local aHpChart = DataManagerPO.parseArmorHpFromProperties(sProperties);
    local nBonus = getArmorBonus(nodeArmor);
    if nBonus > 0 then
        local nBonusLevelHp = aHpChart[1];
        for i = 1, nBonus, 1 do
            table.insert(aHpChart, 1, nBonusLevelHp);
        end
    end
    return aHpChart;
end

function getArmorDamage(nodeArmor)
    return DB.getValue(nodeArmor, "armorDamage", 0); -- TODO: check for correct property name
end

function getArmorBonus(nodeArmor)
    return DB.getValue(nodeArmor, "bonus", 0);
end

function getAcLostFromDamage(nodeArmor)
    local aHpChart = getArmorHpChart(nodeArmor);
    local nDamage = getArmorDamage(nodeArmor)
    local nAcLost = 0;

    if nDamage > 0 and #aHpChart > 0 then
        for _, nHpAtLevel in ipairs(aHpChart) do 
            nDamage = nDamage - nHpAtlevel;
            if nDamage >= 0 then
                nAcLost = nAcLost + 1;
            end
        end
    end

    return nAcLost;
end

function getHitModifiersForSourceVsCharacter(rSource, rChar)
    return getHitModifierForDamageTypesVsCharacter(rChar, rSource.aDamageTypes);
end

function getHitModifierForDamageTypesVsCharacter(rChar, aDamageTypes)
	local aArmorWorn = getCharArmor(rChar);
	return getHitModifierForDamageTypesVsArmorList(aArmorWorn, aDamageTypes);
end

function getHitModifierForDamageTypesVsArmorList(aArmor, aDamageTypes)
    local nUsedMod = nil;
    local sUsedArmorType = nil;
    local sUsedDamageType = nil;
    
    -- If for some reason multiple suits of armor are worn, we figure out what which one has the best defense and use that.
    for _, nodeArmor in pairs(aArmor) do
        local sArmorType, sDamageType, nMod = getHitModifierForDamageTypesVsArmor(nodeArmor, aDamageTypes);
        if nUsedMod == nil or nUsedMod > nMod then
            sUsedArmorType = sArmorType;
            sUsedDamageType = sDamageType;
            nUsedMod = nMod;
        end 
    end
    return sUsedArmorType, sUsedDamageType, nUsedMod;
end

function getHitModifierForDamageTypesVsArmor(nodeArmor, aDamageTypes)
    -- For a given piece of armor and damage types coming at it, we use the modifier of the damage type it's worst defending against
    local sArmorName = DB.getValue(nodeArmor, "name", ""):lower();
    local nHighestMod = nil;
    local sHighestDamageType = nil;
	local aModifiers = getDamageTypeVsArmorModifiers(nodeArmor);
	if aModifiers then
		for _, sDamageType in pairs(aDamageTypes) do
			local nMod = aModifiers[sDamageType] or 0;
			if nHighestMod == nil or nHighestMod < nMod then
				nHighestMod = nMod;
				sHighestDamageType = sDamageType;
			end
		end
	end
    
    return sArmorName, sHighestDamageType, nHighestMod;
end

function getDamageTypeVsArmorModifiers(nodeArmor)
	-- TODO: Eventually want to try to read these from properties
	return getDefaultDamageTypeVsArmorModifiers(nodeArmor);
end

function getDefaultDamageTypeVsArmorModifiers(nodeArmor)
	local sArmorName = DB.getValue(nodeArmor, "name", ""):lower();
	for sArmorType, aModifiers in pairs(DataCommonPO.aDefaultArmorVsDamageTypeModifiers) do
        if sArmorName:find(sArmorType) then 
			return aModifiers;
		end
	end
	return nil;
end


function getCharArmor(rChar)
    local _, nodeChar = ActorManager.getTypeAndNode(rChar);
    local _, aArmorWorn = ItemManager2.getArmorWorn(nodeChar);
    return aArmorWorn;
end