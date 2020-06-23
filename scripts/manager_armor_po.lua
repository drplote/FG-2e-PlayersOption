function onInit()
end

function getHitModifierForDamageTypeVsArmorList(aArmor, aDamageTypes)
    local nUsedMod = nil;
    local sUsedArmorType = nil;
    local sUsedDamageType = nil;
    
    -- If for some reason multiple suits of armor are worn, we figure out what which one has the best defense and use that.
    for _, nodeArmor in pairs(aArmor) do
        local sArmorType, sDamageType, nMod = getHitModifierForDamageTypeVsArmor(nodeArmor, aDamageTypes);
        if nUsedMod == nil or nUsedMod > nMod then
            sUsedArmorType = sArmorType;
            sUsedDamageType = sDamageType;
            nUsedMod = nMod;
        end 
    end
    return sUsedArmorType, sUsedDamageType, nUsedMod;
end

function getHitModifierForDamageTypeVsArmor(nodeArmor, aDamageTypes)
    -- For a given piece of armor and damage types coming at it, we use the modifier of the damage type it's worst defending against
    local sArmorName = DB.getValue(nodeArmor, "name", ""):lower();
    local nHighestMod = nil;
    local sHighestDamageType = nil;
    for sArmorType, aModifiers in pairs(DataCommonPO.aArmorVsDamageTypeModifiers) do
        if sArmorName:find(sArmorType) then 
            for _, sDamageType in pairs(aDamageTypes) do
                local nMod = aModifiers[sDamageType];
                if nMod ~= nil and (nHighestMod == nil or nHighestMod < nMod) then
                    nHighestMod = nMod;
                    sHighestDamageType = sDamageType;
                end
            end
        end
    end
    
    return sArmorName, sHighestDamageType, nHighestMod;
end