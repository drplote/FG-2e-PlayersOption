local fOnHealPostRoll;
 
function onInit()
    fOnHealPostRoll = ActionHeal.onHealPostRoll;
    ActionHeal.onHealPostRoll = onHealPostRoll;
    ActionsManager.registerPostRollHandler("heal", onHealPostRoll);
end
 
function onHealPostRoll(rSource, rRoll)
    local bUsePenetration = OptionsManager.isOption("SternoHouseRule_PenetrationDice", "on");
    fOnHealPostRoll(rSource, rRoll);
    if bUsePenetration then 
        PlayerOptionDiceManager.handlePenetration(rRoll, false);
    end
end