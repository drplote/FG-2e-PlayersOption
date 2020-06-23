local fOnDamageRoll;

function onInit()
    fOnDamageRoll = ActionDamage.onDamageRoll;
    ActionDamage.onDamageRoll = onDamageRoll;
    ActionsManager.registerPostRollHandler("damage", onDamageRoll);
end

function onDamageRoll(rSource, rRoll)
    local bUsePenetration = OptionsManager.isOption("SternoHouseRule_PenetrationDice", "on");
    if bUsePenetration then
        PlayerOptionDiceManager.handlePenetration(rRoll, false);
    end
    
    fOnDamageRoll(rSource, rRoll);
end