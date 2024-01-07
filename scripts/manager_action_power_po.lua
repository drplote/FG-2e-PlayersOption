local fOnPowerCast;

function onInit()
    fOnPowerCast = ActionPower.onPowerCast;
    ActionPower.onPowerCast = onPowerCastOverride;
    ActionsManager.registerResultHandler("cast", onPowerCastOverride);

end

function onPowerCastOverride(rSource, rTarget, rRoll)
    fOnPowerCast(rSource, rTarget, rRoll);
    if PlayerOptionManager.isUsingHackmasterFatigue() then
        FatigueManagerPO.recordCast(rSource);
    end
end

