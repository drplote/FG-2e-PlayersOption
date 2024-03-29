local sFatigueEffectPrefix;
local sFatigueEffectPC;
local sFatigueEffectNPC;

function onInit()
    sFatigueEffectPrefix = "Combat Fatigue;";
    sFatigueEffectPC = sFatigueEffectPrefix .. "DEX:-1;STR:-1";
    sFatigueEffectNPC = sFatigueEffectPrefix .. "AC:-1;ATK:-1";
end

function recordCast(rChar)
    StateManagerPO.setFatigueState(rChar, 1);
end

function recordAttack(rChar, rTarget, sRange)
    local nFatigueState = 1;
    if sRange == "M" then
        nFatigueState = 2;
    end

    StateManagerPO.setFatigueState(rChar, nFatigueState);
    if rTarget then
        StateManagerPO.setFatigueState(rTarget, nFatigueState);
    end
end

function clearFatigueState()
    local aCombatants = CombatManager.getCombatantNodes();
    for _, nodeCT in pairs(aCombatants) do
        local nodeChar = ActorManager.getCreatureNode(nodeCT);
        DebugPO.log("clearFatigueState-ForLoop-nodeChar", nodeChar);
        StateManagerPO.clearFatigueState(nodeChar);
    end
end

function resetFatigue(nodeChar)
    setCurrentFatigue(nodeChar, 0);
    StateManagerPO.clearFatigueState(nodeChar);
end

function setCurrentFatigue(nodeChar, nFatigue)
    ActorManagerPO.setCurrentFatigue(nodeChar, nFatigue);
    ChatManagerPO.deliverChatMessage(ActorManager.getDisplayName(nodeChar) .. "'s fatigue is now " .. nFatigue .. ".");
    if nFatigue == 0 then
        removeAllFatigueEffects(nodeChar);
    end
end

function handleFatigueForCombatants()
    local aCombatants = CombatManager.getCombatantNodes();
    for _, nodeCT in pairs(aCombatants) do
        local nodeChar = ActorManager.getCreatureNode(nodeCT);
        local nFatigue = StateManagerPO.getFatigueState(nodeChar);
        if nFatigue == 2 then
            increaseFatigue(nodeChar);
        elseif nFatigue == 0 then
            decreaseFatigue(nodeChar);
        end
    end
end

function updateFatigueFactor(nodeChar)

    local lEnumbranceMultipliersByRank = {};
    lEnumbranceMultipliersByRank["Normal"] = 1.0;
    lEnumbranceMultipliersByRank["Light"] = .75;
    lEnumbranceMultipliersByRank["Moderate"] = .5;
    lEnumbranceMultipliersByRank["Heavy"] = .25;
    lEnumbranceMultipliersByRank["Severe"] = 0;
    lEnumbranceMultipliersByRank["MAX"] = 0;

    -- con / 2 * rank (unc =1, light=.75,mod=.5,heavy=.25, severe=0)
    local nCon = DB.getValue(nodeChar, "abilities.constitution.total",
        DB.getValue(nodeChar, "abilities.constitution.score", 0));

    local sEncRank, nBaseEnc, nBaseMove = CharManager.getEncumbranceRank2e(nodeChar);
    local lEncMultiplier = lEnumbranceMultipliersByRank[sEncRank] or 0;
    local nFatigueFactor = math.floor(nCon / 2 * lEncMultiplier);
    local nMultiplier = DB.getValue(nodeChar, "fatigue.multiplier", 1);
    nFatigueFactor = nFatigueFactor * nMultiplier;

    DB.setValue(nodeChar, "fatigue.factor", "number", nFatigueFactor);
end

function increaseFatigue(nodeChar)
    DebugPO.log("nodeChar before call to canBeAffectedbyFatigue", nodeChar);
    if ActorManagerPO.canBeAffectedByFatigue(nodeChar) then
        local nCurrentFatigue = ActorManagerPO.getCurrentFatigue(nodeChar);
        local nNewFatigue = nCurrentFatigue + 1;
        setCurrentFatigue(nodeChar, nNewFatigue);
        if nNewFatigue > ActorManagerPO.getFatigueFactor(nodeChar) then
            checkForFatiguePenalty(nodeChar);
        end
    end
end

function decreaseFatigue(nodeChar)
    local nCurrentFatigue = ActorManagerPO.getCurrentFatigue(nodeChar);
    if nCurrentFatigue > 0 then
        local nNewFatigue = nCurrentFatigue - 1;
        setCurrentFatigue(nodeChar, nNewFatigue);
        if nNewFatigue > 0 and nNewFatigue <= ActorManagerPO.getFatigueFactor(nodeChar) then
            checkToRemoveFatiguePenalty(nodeChar);
        end
    end

end

function getFatigueEffectsForChar(nodeChar)
    local aFatigueEffects = {};
    local nodeCT = ActorManager.getCTNode(nodeChar);
    for _, nodeEffect in pairs(DB.getChildren(nodeCT, "effects")) do
        local sEffectLabel = DB.getValue(nodeEffect, "label");
        if sEffectLabel:match(sFatigueEffectPrefix) then
            table.insert(aFatigueEffects, nodeEffect);
        end
    end
    return aFatigueEffects;
end

function addFatigueEffect(nodeChar)
    local sFatigueEffect = sFatigueEffectPC;
    if not ActorManager.isPC(nodeChar) then
        sFatigueEffect = sFatigueEffectNPC;
    end

    local nodeCT = ActorManager.getCTNode(nodeChar);
    EffectManager.addEffect("", "", nodeCT, {
        sName = sFatigueEffect,
        sLabel = sFatigueEffect,
        nDuration = 0
    }, true);
end

function removeAllFatigueEffects(nodeChar)
    for _, nodeEffect in pairs(getFatigueEffectsForChar(nodeChar)) do
        nodeEffect.delete();
    end
end

function getFatigueCheckTarget(nodeChar)
    if ActorManager.isPC(nodeChar) then
        return getFatigueCheckTargetForPC(nodeChar);
    else
        return getFatigueCheckTargetForNPC(nodeChar);
    end
end

function getFatigueCheckTargetForNPC(nodeChar)
    -- NPCs use morale for their fatigue check
    local sMorale = DB.getValue(nodeChar, "morale", "");
    local nMorale = DataManagerPO.parseMoraleFromString(sMorale);
    if nMorale then
        return nMorale;
    else
        return getFatigueCheckTargetForPC(nodeChar);
    end
end

function getFatigueCheckTargetForPC(nodeChar)
    local nCon = DB.getValue(nodeChar, "abilities.constitution.total", 10);
    local nConPercent = DB.getValue(nodeChar, "abilities.constitution.percenttotal", 0) / 100;
    local nWis = DB.getValue(nodeChar, "abilities.wisdom.total", 10);
    local nWisPercent = DB.getValue(nodeChar, "abilities.wisdom.percenttotal", 0) / 100;
    local nAverage = (nCon + nWis + nWisPercent + nConPercent) / 2
    return math.floor(nAverage);
end

function checkToRemoveFatiguePenalty(nodeChar)
    local aFatigueEffects = getFatigueEffectsForChar(nodeChar);
    if #aFatigueEffects > 0 then
        local nConScore = DB.getValue(nodeChar, "abilities.constitution.total",
            DB.getValue(nodeChar, "abilities.constitution.score", 0));
        local sName = ActorManagerPO.getName(nodeChar);
        local nConRoll = math.random(1, 20);
        if nConRoll <= nConScore then
            local sMessage = sName .. " succeeds at a Constitution check to remove a level of fatigue [" .. nConRoll ..
                                 " <= " .. nConScore .. "]!";
            ChatManagerPO.deliverChatMessage(sMessage);
            aFatigueEffects[1].delete();
        else
            local sMessage =
                sName .. " fails a Constitution check to remove a level of fatigue [" .. nConRoll .. " > " .. nConScore ..
                    "]!";
            ChatManagerPO.deliverChatMessage(sMessage);
        end
    end
end

function checkForFatiguePenalty(nodeChar)
    local sName = ActorManagerPO.getName(nodeChar);
    local nFatigueCheckTarget = getFatigueCheckTarget(nodeChar);
    local nFatigueCheckRoll = math.random(1, 20);
    if nFatigueCheckRoll ~= 20 and nFatigueCheckRoll <= nFatigueCheckTarget then -- 20 is auto-failure
        local sMessage = sName .. " makes a fatigue save[" .. nFatigueCheckRoll .. " <= " .. nFatigueCheckTarget ..
                             "]. No fatigue penalty gained.";
        ChatManagerPO.deliverChatMessage(sMessage);
    else
        local sMessage = sName .. " fails a fatigue save[" .. nFatigueCheckRoll .. " > " .. nFatigueCheckTarget ..
                             "] and gains a fatigue penalty.";
        ChatManagerPO.deliverChatMessage(sMessage);
        addFatigueEffect(nodeChar);
    end
end
