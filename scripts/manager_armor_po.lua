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

function getDamageReduction(nodeArmor)
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
            return nDr;
        end
    end
    return 1;
end

function damageArmor(nodeArmor, nDamage)
    local nHpRemaining = getHpRemaining(nodeArmor);
    local nDamageDone = math.min(nDamage, nHpRemaining);
    local nHpLost = getHpLost(nodeArmor) + nDamageDone;
    setHpLost(nodeArmor, nHpLost);
end

function canDamageTypeHurtArmor(aDmgTypes, nodeArmor)
    local nBonus = getMagicAcBonus(nodeArmor);
    if nBonus <= 0 then
        return true;
    elseif not aDmgTypes or #aDmgTypes == 0 then
        return false;
    else
       
        local aDamagingTypes = {"acid","cold","fire","force","lightning","necrotic","poison","psychic","radiant","thunder"};
        if nBonus <= 6 then table.insert(aDamagingTypes, "magic +6"); end
        if nBonus <= 5 then table.insert(aDamagingTypes, "magic +5"); end
        if nBonus <= 4 then table.insert(aDamagingTypes, "magic +4"); end
        if nBonus <= 3 then table.insert(aDamagingTypes, "magic +3"); end
        if nBonus <= 2 then table.insert(aDamagingTypes, "magic +2"); end
        if nBonus <= 1 then table.insert(aDamagingTypes, "magic +1"); table.insert(aDamagingTypes, "magic"); end
        
        return UtilityPO.intersects(aDamagingTypes, aDmgTypes);
    end
end

function getAcBase(nodeArmor)
    local nBaseAc;

    local bIsSuitOfArmor = isSuitOfArmor(nodeArmor);
    if bIsSuitOfArmor then
        nBaseAc = DB.getValue(nodeArmor, "ac", 10);
    else
        nBaseAc = DB.getValue(nodeArmor, "ac", 0);
    end

    if PlayerOptionManager.isUsingArmorDamage() then
        -- Cap how bad it can get (in case someone had more damage levels than AC levels).
        -- Cursed items are handled via their "bonus" so cap won't affect them.
        -- Shields and magic items can't be worse than base 0, armor can't be worse than base 10.
        local nAcLostFromDamage = getAcLostFromDamage(nodeArmor);
        if bIsSuitOfArmor then
            nBaseAc = math.min(10 + getMagicAcBonus(nodeArmor), nBaseAc + nAcLostFromDamage);
        else
            nBaseAc = math.max(0 - getMagicAcBonus(nodeArmor), nBaseAc - nAcLostFromDamage);
        end
    end;

    return nBaseAc;
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
    local sArmorName = getName(nodeArmor):lower();
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
	local sArmorName = getName(nodeArmor):lower();
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