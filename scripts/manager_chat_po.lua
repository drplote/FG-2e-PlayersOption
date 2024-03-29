function onInit()
end

function deliverInitQueueMessage(nodeCT, nNewInit)
    local sName = ActorManager.getDisplayName(nodeCT);
    local aQueue = InitManagerPO.getAllActorInits(nodeCT);
    local sMessage = sName .. " rolled an additional intiative of " .. nNewInit .. ". They now have attacks on " ..
                         UtilityPO.toCSV(aQueue) .. ".";
    deliverChatMessage(sMessage);
end

function deliverRateOfFireInitMessage(nodeCT, nNumAttacks)
    local sName = ActorManager.getDisplayName(nodeCT);
    local aQueue = InitManagerPO.getAllActorInits(nodeCT);
    local sMessage = sName .. " has a fixed rate of fire of " .. nNumAttacks .. ". They have attacks on " ..
                         UtilityPO.toCSV(aQueue) .. ".";
    deliverChatMessage(sMessage);
end

function deliverChatMessage(sText, bSecret)
    if bSecret then
        ChatManager.Message(sText, false);
    else
        ChatManager.Message(sText, true);
    end
end

function deliverEndTurnFailedMessage(nodeChar)
    if nodeChar then
        local sName = DB.getValue(nodeChar, "name", "");
        deliverChatMessage(sName .. " tried to end their turn when it wasn't their turn.");
    end
end

function deliverDelayTurnMessage(nodeChar, nDelay, bSecret)
    if nodeChar then
        local sName = DB.getValue(nodeChar, "name", "");
        local sMessage = sName .. " delays their turn";
        if PlayerOptionManager.isUsingPhasedInitiative() then
            sMessage = sMessage .. " one phase";
        else
            if nDelay and nDelay > 0 then
                sMessage = sMessage .. " " .. nDelay .. " segments"
            end
            sMessage = sMessage .. ".";
        end
        deliverChatMessage(sMessage, bSecret);
    end
end

function deliverDelayFailedMessage(nodeChar)
    if nodeChar then
        local sName = DB.getValue(nodeChar, "name", "");
        deliverChatMessage(sName .. " tried to delay when it wasn't their turn.");
    end
end

function deliverTurnRequestMessage(nodeChar, nPreviousInit)
    if nodeChar then
        DebugPO.log(nodeChar);
        local sName = DB.getValue(nodeChar, "name", "");
        deliverChatMessage(sName .. " will now act on the next segment (previous init " .. nPreviousInit .. " ).");
    end
end

function deliverArmorSoakMessage(sCharName, sItemName, nDamageSoaked, nArmorDamageTaken)
    local sDamageMsg = string.format("%s's %s soaks %s and takes %s damage.", sCharName, sItemName, nDamageSoaked,
        nArmorDamageTaken, sDamageType);
    deliverChatMessage(sDamageMsg);
end

function deliverArmorBrokenMessage(sCharName, sItemName)
    deliverChatMessage(sCharName .. "'s " .. sItemName .. " breaks!");
end

function deliverCriticalHitMessage(sMessage)
    local bGmOnlyCritMessage = PlayerOptionManager.isHackmasterCritEnabled() and Session.IsHost;
    deliverChatMessage("[CRITICAL HIT] " .. sMessage, bGmOnlyCritMessage);
end

function deliverInitRollMessage(nPcInit, nNpcInit)
    local sMsg = "";
    if nPcInit < nNpcInit then
        sMsg = "PCs win initiative! (" .. nPcInit .. " vs " .. nNpcInit .. ").";
    else
        sMsg = "NPCs win intiative! (" .. nNpcInit .. " vs " .. nPcInit .. ").";
    end

    if nPcInit == 1 then
        sMsg = sMsg .. " PCs go one phase faster!";
    elseif nPcInit == 10 then
        sMsg = sMsg .. " PCs go one phase slower!";
    end

    if nNpcInit == 1 then
        sMsg = sMsg .. " NPCs go one phase faster!";
    elseif nNpcInit == 10 then
        sMsg = sMsg .. " NPCs go one phase slower!";
    end

    deliverChatMessage(sMsg);

end

function deliverDetectMagicResults(aResults, bSecret)
    local sMsg = "Detect Magic results: ";
    if not aResults or aResults == nil then
        sMsg = sMsg .. "Nothing new detected";
    else
        for _, rResult in pairs(aResults) do
            sMsg = sMsg .. '\r' .. rResult.owner .. ' has ' .. rResult.itemName;
        end
    end
    deliverChatMessage(sMsg, bSecret);
end

function deliverMoraleCheckResults(aResults, bSecret)
    local sMsg = "Morale Check Results:\r-------------------- ";
    if not aResults or aResults == nil then
        sMsg = sMsg .. "No combatants found";
    else
        for _, rStatus in pairs(MoraleManagerPO.MoraleStatus) do
            local aMatches = {};
            for _, rResult in pairs(aResults) do
                if rResult.moraleState.id == rStatus.id then
                    local carryoverPrefix = "";
                    if rResult.usingPreviousState then
                        carryoverPrefix = "*";
                    end

                    table.insert(aMatches, string.format("'%s%s'", carryoverPrefix, rResult.combatantName));
                end
            end
            if #aMatches > 0 then
                sMsg = sMsg .. string.format("\r%s: %s\r--------------------", rStatus.desc, UtilityPO.toCSV(aMatches));
            end
        end
    end
    deliverChatMessage(sMsg, bSecret);
end
