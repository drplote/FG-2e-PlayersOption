local fModAttack;
local fPerformRoll;

function onInit()
    fModAttack = ActionAttack.modAttack;
    ActionAttack.modAttack = modAttack;
    ActionsManager.registerModHandler("attack", modAttack);   
end


function modAttack(rSource, rTarget, rRoll)
    fModAttack(rSource, rTarget, rRoll);
    local bAutomateWeaponTypeVsArmorMods = OptionsManager.isOption("PlayerOption_WeaponTypeVsArmorMods", "on");
    if bAutomateWeaponTypeVsArmorMods then
        addWeaponTypeVsArmorMods(rSource, rTarget, rRoll);
    end
end

function addWeaponTypeVsArmorMods(rSource, rTarget, rRoll)
    Debug.console("rSource", rSource);  
    Debug.console("rTarget", rTarget);
    Debug.console("rRoll", rRoll);
    --addModToRoll(rRoll, 'sword', 'armor', 2);
end

function getWeaponType(rSource)
end

function getArmorType(rTarget)
end

function getArmorModVsWeaponType(nWeapon, nArmor)
    return 0;
end

function addModToRoll(rRoll, sWeaponType, sArmor, nBonus)
    if nBonus == 0 then 
        return;
    end
    
    local sBonus = tostring(nBonus);
    if nBonus > 0 then
        sBonus = "+" .. sBonus;
    end
    
    rRoll.sDesc = rRoll.sDesc .. string.format(" [WvA: %s v %s (%s)]", sWeaponType, sArmor, sBonus);
    rRoll.nMod = nBonus;
end

