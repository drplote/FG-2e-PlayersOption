local fModAttack;

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
    Debug.console("here we be");
end