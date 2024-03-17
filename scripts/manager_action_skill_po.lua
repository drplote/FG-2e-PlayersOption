local fModRoll;
local fOnRoll;
function onInit()

    -- skill roll override
    fModRoll = ActionSkill.modRoll;
    ActionSkill.modRoll = modRollOverride;
    ActionsManager.registerModHandler("skill", modRollOverride);
end

function modRollOverride(rSource, rTarget, rRoll)
    local nodeActor = ActorManagerPO.getNode(rSource);
    ActionCheckPO.setArmorPenaltyAdjustements(nodeActor, rRoll);
    fModRoll(rSource, rTarget, rRoll);
end
