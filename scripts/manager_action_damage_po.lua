local fOnDamageRoll;
local fCheckReductionType;

function onInit()
    fOnDamageRoll = ActionDamage.onDamageRoll;
    ActionDamage.onDamageRoll = onDamageRollOverride;
    ActionsManager.registerPostRollHandler("damage", onDamageRollOverride);
	
	fCheckReductionType = ActionDamage.checkReductionType;
	ActionDamage.checkReductionType = checkReductionTypeOverride;
end

function onDamageRollOverride(rSource, rRoll)
    if PlayerOptionManager.isPenetrationDiceEnabled() then
        DiceManagerPO.handlePenetration(rRoll, false);
    end
    
    fOnDamageRoll(rSource, rRoll);
end

function checkReductionTypeOverride(aReduction, aDmgType)
	if not PlayerOptionManager.isStricterResistancesEnabled() then
		return fCheckReductionType(aReduction, aDmgType);
	end
	
	local aReducedDamageTypes = {};

	for _,sDmgType in pairs(aDmgType) do
		if ActionDamage.checkReductionTypeHelper(aReduction[sDmgType], aDmgType) or ActionDamage.checkReductionTypeHelper(aReduction["all"], aDmgType) then
			table.insert(aReducedDamageTypes, sDmgType);
		end
	end  

	if #aReducedDamageTypes == 0 then
		return false;
	else
		-- We're going to treat bludgeoning/piercing/slashing differently, and say that if it contains more than one of these types, it must 
		-- resist ALL of these "base" damage types it contains to be resisted. (i.e., a bludgeoning/piercing morningstar shouldn't be resisted by 
		-- just bludgeoning resist, but should instead require both bludgeoning resist and piercing resist)
		local bIsBludgeoning, bIsPiercing, bIsSlashing = hasBaseDamageTypes(aDmgType);
		local bResistsBludgeoning, bResistsPiercing, bResistsSlashing = hasBaseDamageTypes(aReducedDamageTypes);

		local bResistsAllBaseTypesItContains = true;
		bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bIsBludgeoning or bResistsBludgeoning);
		bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bIsPiercing or bResistsPiercing);
		bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bResistsSlashing or bResistsSlashing);

		return bResistsAllBaseTypesItContains;
	end
end

function hasBaseDamageTypes(aDmgTypes)
	local bBludgeoning = false;
	local bPiercing = false;
	local bSlashing = false;
	
	for _,sDmgType in pairs(aDmgTypes) do
		local sDmgTypeLower = sDmgType:lower();
		if sDmgTypeLower:find("bludgeoning") then
			bBludgeoning = true;
		elseif sDmgTypeLower:find("slashing") then
			bSlashing = true;
		elseif sDmgTypeLower:find("piercing") then
			bPiercing = true;
		end
	end
	
	return bBludgeoning, bPiercing, bSlashing;
end