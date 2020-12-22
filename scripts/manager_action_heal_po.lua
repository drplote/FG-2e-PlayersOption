local fOnHealPostRoll;
 
function onInit()
    fOnHealPostRoll = ActionHeal.onHealPostRoll;
    ActionHeal.onHealPostRoll = onHealPostRollOverride;
    ActionsManager.registerPostRollHandler("heal", onHealPostRollOverride);
end
 
function onHealPostRollOverride(rSource, rRoll)
    fOnHealPostRoll(rSource, rRoll);
    if PlayerOptionManager.isPenetrationDiceEnabled() then 
        DiceManagerPO.handlePenetration(rRoll, false);
    end
    HonorManagerPO.addHealModifier(rSource, rRoll);
end