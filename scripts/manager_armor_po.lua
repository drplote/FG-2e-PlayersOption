function onInit()
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
	local sArmorName = DB.getValue(nodeArmor, "name", "");
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