local fModSave;
local fApplySave;

function onInit()
    fModSave = ActionSave.modSave;
    ActionSave.modSave = modSaveOverride;
    ActionsManager.registerModHandler("save", modSaveOverride);

    fApplySave = ActionSave.applySave;
    ActionSave.applySave = applySaveOverride;
end

function applySaveOverride(rSource, rOrigin, rAction, sUser)
    fApplySave(rSource, rOrigin, rAction, sUser);
    if rAction and rAction.sSaveDesc == "TOP" then
        if rAction.nTotal < rAction.nTarget then
            local nodeChar = ActorManager.getCTNode(rSource);
            local nDuration = rAction.nTarget - rAction.nTotal;
            if nodeChar then
                EffectManager.addEffect("", "", ActorManager.getCTNode(rSource), {
                    sName = "Stunned",
                    sLabel = "Stunned",
                    nDuration = nDuration
                }, true);
                EffectManager.addEffect("", "", ActorManager.getCTNode(rSource), {
                    sName = "Prone",
                    sLabel = "Prone",
                    nDuration = nDuration
                }, true);
            end
        end
    end
end

function modSaveOverride(rSource, rTarget, rRoll)
    addMagicalDefenseAdjustment(rSource, rTarget, rRoll);
    HonorManagerPO.addSaveModifier(rSource, rRoll);
    fModSave(rSource, rTarget, rRoll);
    addSpellPenetrationModifier(rSource, rTarget, rRoll);
end

function addSpellPenetrationModifier(rSource, rTarget, rRoll)
    local aSpellPenList = nil;
    if rRoll.sSource then
        local rSaveSource = ActorManager.resolveActor(rRoll.sSource);
        aSpellPenList = EffectManager5E.getEffectsByType(rSaveSource, "SPELLPEN", {}, rSource);
    end

    local aPowerProperties = nil;
    if rRoll.sPowerProperties then
        aPowerProperties = UtilityPO.fromCSV(rRoll.sPowerProperties);
    end

    if aSpellPenList then
        for k, v in pairs(aSpellPenList) do
            if #v.remainder > 0 then
                if aPowerProperties then
                    local aIntersecting = UtilityPO.getIntersecting(aPowerProperties, v.remainder);
                    if aIntersecting and #aIntersecting > 0 then
                        local nSaveMod = StringManager.evalDice(v.dice, v.mod) * -1;
                        rRoll.nMod = rRoll.nMod + nSaveMod;
                        rRoll.sDesc = rRoll.sDesc ..
                                          string.format("[Spell Penetration (%s): %s]", UtilityPO.toCSV(aIntersecting),
                                nSaveMod);
                    end
                end
            else
                local nSaveMod = StringManager.evalDice(v.dice, v.mod) * -1;
                rRoll.nMod = rRoll.nMod + nSaveMod;
                rRoll.sDesc = rRoll.sDesc .. string.format("[Spell Penetration: %s]", nSaveMod);
            end
        end
        if rRoll.sPowerProperties then
            local aProperties = StringManager.split(rRoll.sPowerProperties, ",", true);

        end
    end

end

function addMagicalDefenseAdjustment(rSource, rTarget, rRoll)
    local nMagicalDefenseAdjustment = getMagicalDefenseAdjustment(rSource, rRoll.sSaveDesc);
    rRoll.nMod = rRoll.nMod + nMagicalDefenseAdjustment;

    if nMagicalDefenseAdjustment > 0 then
        rRoll.sDesc = rRoll.sDesc .. " [MAGIC DEF ADJ +" .. nMagicalDefenseAdjustment .. "]";
    elseif nMagicalDefenseAdjustment < 0 then
        rRoll.sDesc = rRoll.sDesc .. " [MAGIC DEF ADJ " .. nMagicalDefenseAdjustment .. "]";
    end
end

function rollSave(rTarget, sSave, sDesc, bSecretRoll)
    if not bSecretRoll then
        bSecretRoll = false;
    end
    local sActorType = ActorManagerPO.getType(rTarget);
    local nodeActor = ActorManagerPO.getCreatureNode(rTarget);
    local nSaveScore = ActorManagerPO.getSaveScore(nodeActor, sSave);
    ActionSave.performRoll(nil, rTarget, sSave, nSaveScore, bSecretRoll, nil, false, sDesc);
end

function rollThresholdOfPain(rTarget)
    rollSave(rTarget, "death", "TOP");
end

function rollCritSave(rTarget)
    rollSave(rTarget, "death", "CRIT");
end

function getMagicalDefenseAdjustment(rSource, sSaveDesc)
    if sSaveDesc == "TOP" then
        local sActorType = ActorManagerPO.getType(rSource);
        local nodeActor = ActorManagerPO.getCreatureNode(rSource);
        return ActorManagerPO.getMagicalDefenseAdjustment(nodeActor);
    end
    return 0;
end
