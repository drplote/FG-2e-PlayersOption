function onInit()
end

function isSuitOfArmor(nodeArmor)
    return ItemManager2.isArmor(nodeArmor) and not ItemManager2.isShield(nodeArmor);
end

function isBroken(nodeArmor)
    return getHpLost(nodeArmor) >= getMaxHp(nodeArmor);
end

function getArmorHpChart(nodeArmor)
    local sProperties = getProperties(nodeArmor);
    local aHpChart = DataManagerPO.parseArmorHpFromProperties(sProperties);
    
    if not aHpChart or #aHpChart == 0 then 
        aHpChart = getDefaultArmorHpChart(nodeArmor);
    end

    if #aHpChart >= 0 then
        local nBonus = getMagicAcBonus(nodeArmor);
        if nBonus > 0 then
            -- Armor gets a bonus level of HP for each + of it's magic bonus
            local nBonusLevelHp = aHpChart[1];
            for i = 1, nBonus, 1 do
                table.insert(aHpChart, 1, nBonusLevelHp);
            end
        end
    end
    return aHpChart;
end

function getDefaultArmorHpChart(nodeArmor)
    local sNameLower = getName(nodeArmor):lower();
        for sArmorType, aArmorChart in pairs(DataCommonPO.aDefaultArmorHp) do
        if sNameLower:find(sArmorType) then 
            return aArmorChart;
        end
    end
    return {};
end

function canArmorSoakDamageType(aDmgTypes)
    if not aDmgTypes or #aDmgTypes == 0 then
        return true;
    else
        local aUnsoakableDamageTypes = {"psychic", "poison"};        
        return not UtilityPO.intersects(aUnsoakableDamageTypes, aDmgTypes);
    end
end

function getDamageReduction(nodeArmor, aDmgTypes)
    if not canArmorSoakDamageType(aDmgTypes) then
        return 0;
    end
    local sProperties = getProperties(nodeArmor);
    local nDr = DataManagerPO.parseDamageReductionFromProperties(sProperties);
    if not nDr or nDr == 0 then
        nDr = getDefaultDamageReduction(nodeArmor);
    end
    return nDr;
end

function getDefaultDamageReduction(nodeArmor)
    local sNameLower = getName(nodeArmor):lower();
        for sArmorType, nArmorDr in pairs(DataCommonPO.aDefaultArmorDamageReduction) do
        if sNameLower:find(sArmorType) then 
            return nArmorDr;
        end
    end
    return 1;
end

function damageArmor(nodeArmor, nDamage)
    if not nodeArmor then return; end

    local nHpRemaining = getHpRemaining(nodeArmor);
    local nDamageDone = math.min(nDamage, nHpRemaining);
    local nHpLost = getHpLost(nodeArmor) + nDamageDone;
    setHpLost(nodeArmor, nHpLost);
end

function repairArmor(nodeArmor, nDamageToRepair)
    if not nodeArmor then return; end

    local nHpLost = getHpLost(nodeArmor);
    local nDamageRepaired = math.min(nDamageToRepair, nHpLost);
    local nHpLost = nHpLost - nDamageRepaired;
    setHpLost(nodeArmor, nHpLost);
end

function canDamageTypeHurtArmor(aDmgTypes, nodeArmor)
    local nBonus = getPotency(nodeArmor);

    local aImmunities = DataManagerPO.parseArmorDamageImmunitiesFromProperties(getProperties(nodeArmor));
    if nBonus <= 0 then
        local aIgnoredDamageTypes = {"poison", "psychic"};
        for _,sDamageType in pairs(aImmunities) do
            table.insert(aIgnoredDamageTypes, sDamageType);
        end

        return not UtilityPO.intersects(aIgnoredDamageTypes, aDmgTypes);
    elseif not aDmgTypes or #aDmgTypes == 0 then
        return false;
    else
       
        local aDamagingTypes = {"acid","cold","fire","force","lightning","necrotic","radiant","thunder"};

        if PlayerOptionManager.isMagicArmorDamagedByEqualMagic() then 
            if nBonus <= 6 then table.insert(aDamagingTypes, "magic +6"); end
            if nBonus <= 5 then table.insert(aDamagingTypes, "magic +5"); end
            if nBonus <= 4 then table.insert(aDamagingTypes, "magic +4"); end
            if nBonus <= 3 then table.insert(aDamagingTypes, "magic +3"); end
            if nBonus <= 2 then table.insert(aDamagingTypes, "magic +2"); end
            if nBonus <= 1 then table.insert(aDamagingTypes, "magic +1"); table.insert(aDamagingTypes, "magic"); end
        end


        aDamagingTypes = UtilityPO.removeIntersecting(aDamagingTypes, aImmunities); 
        return UtilityPO.intersects(aDamagingTypes, aDmgTypes);
    end
end

function getAcBase(nodeArmor)
    local nBaseAc;
    local nAcGiven = 0;

    local bIsSuitOfArmor = isSuitOfArmor(nodeArmor);
    if bIsSuitOfArmor then
        nBaseAc = DB.getValue(nodeArmor, "ac", 10);
    else
        nBaseAc = DB.getValue(nodeArmor, "ac", 0);
    end

    if PlayerOptionManager.isUsingArmorDamage() then
        local nAcLostFromDamage = getAcLostFromDamage(nodeArmor);
        if bIsSuitOfArmor then
            nBaseAc = nBaseAc + nAcLostFromDamage;
        else
            nBaseAc = nBaseAc - nAcLostFromDamage;
        end
    end;

    local nAcBonusGranted = 0;
    if bIsSuitOfArmor then
        nAcBonusGranted = 10 - nBaseAc;
    else
        nAcBonusGranted = nBaseAc;
    end
    return nBaseAc, nAcBonusGranted;
end

function getProperties(nodeArmor)
    return DB.getValue(nodeArmor, "properties", "");
end

function setHpLost(nodeArmor, nHpLost)
    DB.setValue(nodeArmor, "hpLost", "number", nHpLost);
end

function getHpLost(nodeArmor)
    return DB.getValue(nodeArmor, "hpLost", 0);
end

function getName(nodeArmor)
    return DB.getValue(nodeArmor, "name", "");
end

function getHpRemaining(nodeArmor)
    return math.max(getMaxHp(nodeArmor) - getHpLost(nodeArmor), 0);
end

function getMaxHp(nodeArmor)
    local aHpChart = getArmorHpChart(nodeArmor);
    return UtilityPO.sum(aHpChart);
end

function getMagicAcBonus(nodeArmor)
    return DB.getValue(nodeArmor, "bonus", 0);
end

function getPotency(nodeArmor)
    local nPotency = DataManagerPO.parsePotencyFromProperties(getProperties(nodeArmor));
    if nPotency then
        return nPotency;
    else
        return getMagicAcBonus(nodeArmor);
    end
end

function getAcLostFromDamage(nodeArmor)
    local aHpChart = getArmorHpChart(nodeArmor);
    local nHpLost = getHpLost(nodeArmor)
    local nAcLost = 0;

    if nHpLost > 0 and #aHpChart > 0 then
        for _, nHpAtLevel in pairs(aHpChart) do 
            nHpLost = nHpLost - nHpAtLevel;
            if nHpLost >= 0 then
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
        if nMod ~= nil and (nUsedMod == nil or nUsedMod > nMod) then
            sUsedArmorType = sArmorType;
            sUsedDamageType = sDamageType;
            nUsedMod = nMod;
        end 
    end
    
    return sUsedArmorType, sUsedDamageType, nUsedMod;
end

function getHitModifierForDamageTypesVsArmor(nodeArmor, aDamageTypes)
    -- For a given piece of armor and damage types coming at it, we use the modifier of the damage type it's worst defending against
    local sArmorName = ItemManagerPO.getItemNameForPlayer(nodeArmor);
    local nHighestMod = nil;
    local sHighestDamageType = nil;
	local aModifiers = getDamageTypeVsArmorModifiers(nodeArmor);
	if aModifiers then
		for _, sDamageType in pairs(aDamageTypes) do
			local nMod = aModifiers[sDamageType];
            if nMod then
                local nBaseAc, nAcBonusGranted = getAcBase(nodeArmor);
                -- Bonus to hit can't be higher than the AC the armor provides
                nMod = math.min(nAcBonusGranted, nMod); 
    	   		if nHighestMod == nil or nHighestMod < nMod then
    		  		nHighestMod = nMod;
    		  		sHighestDamageType = sDamageType;
    			end
            end
		end
	end
    
    return sArmorName, sHighestDamageType, nHighestMod;
end

function getDamageTypeVsArmorModifiers(nodeArmor)
	local sProperties = getProperties(nodeArmor);
    local aModifiers = DataManagerPO.parseArmorVsWeaponTypeModifiersFromProperties(sProperties);
    if not aModifiers then
	   aModifiers = getDefaultDamageTypeVsArmorModifiers(nodeArmor);
    end
    return aModifiers;
end

function getDefaultDamageTypeVsArmorModifiers(nodeArmor)
	local sArmorName = getName(nodeArmor):lower();
	for sArmorType, aModifiers in pairs(DataCommonPO.aDefaultArmorVsDamageTypeModifiers) do
        if sArmorName:find(sArmorType) then 
			return aModifiers;
		end
	end
	return nil;
end


function getCharArmor(rChar)
    local nodeChar = ActorManager.getCreatureNode(rChar);
    local _, aArmorWorn = ItemManager2.getArmorWorn(nodeChar);
    return aArmorWorn;
end

function getDamageableShieldWorn(nodeChar)
    -- Possible problem: If the character has more than one shield worn, this is only going to return the first it finds
    for _,vNode in pairs(CharManagerPO.getEquippedItems(nodeChar)) do
        if ItemManager2.isShield(vNode) then
            local aArmorHpChart = getArmorHpChart(vNode);
            if #aArmorHpChart > 0 then
                return vNode;
            end
        end
    end
    return nil;
end

function getDamageableArmorWorn(nodeChar)
    -- Possible problem: If the character has more than one armor worn, this is only going to return the first it finds
    for _,vNode in pairs(CharManagerPO.getEquippedItems(nodeChar)) do
        if isSuitOfArmor(vNode) then
            local aArmorHpChart = getArmorHpChart(vNode);
            if #aArmorHpChart > 0 then
                return vNode;
            end
        end
    end
    return nil;
end

function getBulkOfWornArmor(nodeChar)
    local nHighestBulk = 0;

    for _,vNode in pairs(CharManagerPO.getEquippedItems(nodeChar)) do
        if isSuitOfArmor(vNode) then
            local sProperties = getProperties(vNode):lower();
            local nThisArmorBulk = 0;
            if string.find(sProperties, "bulky") then
                nThisArmorBulk = 2;
            elseif string.find(sProperties, "fairly") then
                nThisArmorBulk = 1;
            end
            if getMagicAcBonus(vNode) ~= 0 then
                nThisArmorBulk = nThisArmorBulk - 1;
            end
            
            nHighestBulk = math.max(nHighestBulk, nThisArmorBulk);
        end
    end
    return nHighestBulk; -- 0 = non, 1 = fairly, 2 = bulky
end