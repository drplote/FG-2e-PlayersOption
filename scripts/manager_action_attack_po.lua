local fModAttack;
local fGetRoll;
local fNotifyApplyAttack;

function onInit()
    fModAttack = ActionAttack.modAttack;
    ActionAttack.modAttack = modAttack;
    ActionsManager.registerModHandler("attack", modAttack); 

    fGetRoll = ActionAttack.getRoll;
    ActionAttack.getRoll = getRoll;
	
	fNotifyApplyAttack = ActionAttack.notifyApplyAttack;
	ActionAttack.notifyApplyAttack = notifyApplyAttack;
end

function notifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, rResults)
	local bGenerateHitLocations = OptionsManager.isOption("AdditionalAutomation_GenerateHitLocations", "on")
	if bGenerateHitLocations then 
		if rResults.sDMResults:find("%[HIT") or rResults.sDMResults:find("%[CRITICAL") then -- TODO: remove crit check once we have crit code, as it'll be handled there.
			if rSource and rTarget then
				local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
				local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
				if nodeAttacker and nodeDefender then
					local sHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
					rResults.sDMResults = rResults.sDMResults .. string.format(" [LOC: %s]", sHitLocation);
				end
			end
		end
	end
	fNotifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, rResults);
end

function modAttack(rSource, rTarget, rRoll)
    fModAttack(rSource, rTarget, rRoll);
    local bAutomateWeaponTypeVsArmorMods = OptionsManager.isOption("AdditionalAutomation_WeaponTypeVsArmorMods", "on");
    if bAutomateWeaponTypeVsArmorMods then
        addWeaponTypeVsArmorMods(rSource, rTarget, rRoll);
    end
end

function getRoll(rActor, rAction)
    local rRoll = fGetRoll(rActor, rAction);
    rRoll.aDamageTypes = rAction.aDamageTypes;
    return rRoll;
end

function addWeaponTypeVsArmorMods(rSource, rTarget, rRoll)  
    local aArmorWorn = getTargetArmor(rTarget);
    local aDamageTypes = rRoll.aDamageTypes;
    local sArmorType, sDamageType, nMod = ArmorManagerPO.getHitModifierForDamageTypeVsArmorList(aArmorWorn, aDamageTypes);
    Debug.console("sArmorType", sArmorType, "sDamageType", sDamageType, "nMod", nMod);
    addModToRoll(rRoll, sDamageType, sArmorType, nMod);
end

function getTargetArmor(rTarget)
    local _, nodeChar = ActorManager.getTypeAndNode(rTarget);
    local _, aArmorWorn = ItemManager2.getArmorWorn(nodeChar);
    return aArmorWorn;
end

function addModToRoll(rRoll, sDamageType, sArmor, nMod)
    if nMod == 0 or nMod == nil then 
        return;
    end
    
    local sMod = tostring(nMod);
    if nMod > 0 then
        sMod = "+" .. sMod;
    end
    
    rRoll.sDesc = rRoll.sDesc .. string.format(" [WvA: %s v %s (%s)]", sDamageType, sArmor, sMod);
    rRoll.nMod = nMod;
end

