local fGetRoll;
local fPerformRoll;
local fHandleApplyInit;
local fNotifyApplyInit;

OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
    fGetRoll = ActionInit.getRoll;
    ActionInit.getRoll = getRollOverride;

    fPerformRoll = ActionInit.performRoll;
    ActionInit.performRoll = performRollOverride;

    fHandleApplyInit = ActionInit.handleApplyInit; -- check update
    ActionInit.handleApplyInit = handleApplyInitOverride;

    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInitOverride);

    fNotifyApplyInit = ActionInit.notifyApplyInit; -- check update
    ActionInit.notifyApplyInit = notifyApplyInitOverride;
end

function notifyApplyInitOverride(rSource, nTotal)
    if not rSource then
        return;
    end

    local msgOOB = {};
    msgOOB.type = OOB_MSGTYPE_APPLYINIT;

    msgOOB.nTotal = nTotal;

    -- msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);

    local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
    msgOOB.sSourceType = sSourceType;
    msgOOB.sSourceNode = sSourceNode;
    local bIsAdditionalAttack = ModifierStack.getModifierKey("ADDITIONAL_ATTACK");
    if bIsAdditionalAttack then
        msgOOB.sIsAdditionalAttack = "1";
    else
        msgOOB.sIsAdditionalAttack = "0";
    end
    DebugPO.log("msgOOB sent", msgOOB);
    Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyInitOverride(msgOOB)
    if PlayerOptionManager.isUsingHackmasterInitiative() then
        local nTotal = tonumber(msgOOB.nTotal) or 1;
        msgOOB.nTotal = math.max(1, nTotal);
    end

    local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
    local nodeCT = ActorManager.getCTNode(rSource);
    local bWasInitRolled = DB.getValue(nodeCT, "initrolled", 0) == 1;
    DebugPO.log("msgOOB received", msgOOB);
    local bIsAdditionalAttack = tonumber(msgOOB.sIsAdditionalAttack) == 1;
    DebugPO.log("bIsAdditionalAttack", bIsAdditionalAttack);

    if bWasInitRolled and bIsAdditionalAttack then
        local nNewInit = tonumber(msgOOB.nTotal) or 1;
        nNewInit = InitManagerPO.addInitToActor(nodeCT, nNewInit);

        if ActorManager.isPC(rSource) then
            ChatManagerPO.deliverInitQueueMessage(nodeCT, nNewInit);
        end

    else
        InitManagerPO.clearActorInitQueue(nodeCT);

        local nSequencedAttacks = ModifierStackPO.getSequencedInitModifierKey();
        if nSequencedAttacks > 0 then
            local nNewInit = tonumber(msgOOB.nTotal) or 1;
            DB.setValue(nodeCT, "initrolled", "number", 1);
            DB.setValue(nodeCT, "initresult", "number", nNewInit);

            if nSequencedAttacks == 2 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 5);
            elseif nSequencedAttacks == 3 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 3);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
            elseif nSequencedAttacks == 4 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 4);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
            elseif nSequencedAttacks == 5 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 4);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 8);
            elseif nSequencedAttacks == 6 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 3);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 5);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 7);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 8);
            elseif nSequencedAttacks == 7 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 3);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 4);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 7);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 8);
            elseif nSequencedAttacks == 8 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 1);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 3);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 5);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 7);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 8);
            elseif nSequencedAttacks == 9 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 1);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 3);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 4);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 5);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 7);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 8);
            elseif nSequencedAttacks == 10 then
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 1);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 2);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 3);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 4);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 5);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 6);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 7);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 8);
                InitManagerPO.addInitToActor(nodeCT, nNewInit + 9);
            end
        else
            InitManagerPO.clearActorInitQueue(nodeCT);
            fHandleApplyInit(msgOOB);
        end
    end
end

function performRollOverride(draginfo, rActor, bSecretRoll, rItem)

    if ModifierStackPO.peekModifierKey("ADDITIONAL_ATTACK") then
        if not ActorManager.isPC(rActor) then
            bSecretRoll = true;
        end

        local rRoll = ActionInit.getRoll(rActor, bSecretRoll, rItem);

        if (draginfo and rActor.itemPath and rActor.itemPath ~= "") then
            draginfo.setMetaData("itemPath", rActor.itemPath);
        end
        if (draginfo and rItem and rItem.spellPath and rItem.spellPath ~= "") then
            draginfo.setMetaData("spellPath", rActor.spellPath);
            rActor.spellPath = rItem.spellPath;
        end
        -- dont like this but I need the spell path to for later and this
        -- is the easiest place to put it. We need to know the spellPath AFTER
        -- the initiative is set so the initiative for the effect is correct
        if (rItem and rItem.spellPath and rItem.spellPath ~= "") then
            rRoll.spellPath = rItem.spellPath;
        end

        -- updated
        local actor = ActorManager.getCTNode(rActor);
        DB.setValue(actor, "inititem", "string", rItem.sName);
        -- Debug.chat('Setting Weapon Name to CT Actor Data');

        ActionsManager.performAction(draginfo, rActor, rRoll);
    else
        fPerformRoll(draginfo, rActor, bSecretRoll, rItem);
    end
end

function getRollForPhasedInit(rActor, bSecretRoll, rItem)
    local rRoll = {};
    rRoll.sType = "init";
    rRoll.aDice = {"d0"};
    rRoll.nMod = 13; -- Default to last
    rRoll.sDesc = "[INIT]";
    rRoll.bSecret = bSecretRoll;

    local sActorType = ActorManagerPO.getType(rActor);
    local nodeActor = ActorManagerPO.getCreatureNode(rActor);
    if nodeActor then
        local nInitPhase = InitManagerPO.getBaseActorSpeedPhase(nodeActor);
        if rItem then
            if rItem.spellPath then
                local nCastInit = DB.getValue(DB.findNode(rItem.spellPath), "castinitiative", 99);
                nInitPhase = InitManagerPO.getSpellPhase(nCastInit);
                rRoll.sDesc = rRoll.sDesc .. " [Spell:" .. InitManagerPO.getPhaseName(nInitPhase) .. "]";
                nInitPhase = CombatManagerPO.getFinalInitForActor(nodeActor, nInitPhase, false);
            else
                rRoll.sDesc = rRoll.sDesc .. " [Base:" .. InitManagerPO.getPhaseName(nInitPhase) .. "]";
                local nWeaponInitPhase = InitManagerPO.getWeaponPhaseFromSpeed(rItem.nInit, nodeActor);
                rRoll.sDesc = rRoll.sDesc .. " [Weapon:" .. InitManagerPO.getPhaseName(nWeaponInitPhase) .. "]";
                nInitPhase = math.max(nWeaponInitPhase, nInitPhase);
                nInitPhase = CombatManagerPO.getFinalInitForActor(nodeActor, nInitPhase, true);
            end
        else
            rRoll.sDesc = rRoll.sDesc .. " [Base: " .. InitManagerPO.getPhaseName(nInitPhase) .. "]";
            nInitPhase = CombatManagerPO.getFinalInitForActor(nodeActor, nInitPhase, true);
        end
        rRoll.nMod = nInitPhase;
    end

    return rRoll;
end

function getHackmasterInitRoll(rActor, bSecretRoll, rItem)
    if ModifierStack.getModifierKey("INIT_START_ROUND") then
        return getFixedInitiativeRoll(1);
    elseif ModifierStack.getModifierKey("INIT_END_ROUND") then
        return getFixedInitiativeRoll(10);
    end

    local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
    local rRoll = {};
    rRoll.sType = "init";
    rRoll.nMod = 0;
    rRoll.sDesc = "[INIT]";
    rRoll.bSecret = bSecretRoll;

    local bIsFixedInitiative = (rItem and (rItem.nType and rItem.nType ~= 0)) or Input.isShiftPressed();
    local bIsSpell = false;
    if bIsFixedInitiative then -- ranged weapons go on a fixed initiative
        rRoll.aDice = {"d0"};
        rRoll.nDieType = 0;
        rRoll.nMod = 1;
        rRoll.sDesc = rRoll.sDesc .. "[Ranged]";
    elseif rItem and rItem.spellPath then -- Spells either go on a fixed initiative, or in +1d4 segments if they have material components  	
        bIsSpell = true;
        rRoll.sDesc = rRoll.sDesc .. "[Spell]";
        local nReactionAdj = DB.getValue(nodeActor, "abilities.dexterity.reactionadj", 0);
        local nBaseMaterialComponentDie = 4;
        local nFinalMaterialComponentDie = nBaseMaterialComponentDie - nReactionAdj;
        DebugPO.log("nReactionAdj", nReactionAdj);
        DebugPO.log("nBaseMaterialComponentDie", nBaseMaterialComponentDie);
        DebugPO.log("nFinalMaterialComponentDie", nFinalMaterialComponentDie);
        if nFinalMaterialComponentDie > 0 and DB.getValue(DB.findNode(rItem.spellPath), "components", ""):match("M") then -- Does it have material componenets?
            rRoll.aDice = {"d" .. nFinalMaterialComponentDie};
            rRoll.nDieType = nFinalMaterialComponentDie;
            DebugPO.log("rRoll", rRoll);
        else
            rRoll.aDice = {"d0"};
            rRoll.nDieType = 0;
            bIsFixedInitiative = true;
        end
        local nSpellSpeed = math.min(rItem.nInit, 10);
        rRoll.nMod = nSpellSpeed; -- Cap spell time at 10.
        rRoll.sDesc = rRoll.sDesc .. " [MOD (" .. rItem.sName .. "): " .. nSpellSpeed .. "]";
    else
        local nDieType = InitManagerPO.getMeleeInitDieType();
        local nNumSequencedAttacks = ModifierStackPO.peekSequencedInitModifierKey();
        if nNumSequencedAttacks > 1 then
            rRoll.sDesc = rRoll.sDesc .. "[" .. nNumSequencedAttacks .. " sequenced attacks]";
        end

        rRoll.aDice = {"d" .. nDieType};
        rRoll.nDieType = nDieType;
    end

    -- Determine the modifier and ability to use for this roll
    local sAbility = nil;
    if nodeActor then
        if not bIsFixedInitiative and not bIsSpell then
            modifyRollForDexterity(rActor, rRoll);
        end
        if rItem and not bIsFixedInitiative and not bIsSpell and not rItem.isNil then
            local nWeaponSpeed = rItem.nInit - 5; -- Subtract 5 because all the HM weapons have 5 less speed than 2E Counterparts
            rRoll.nMod = rRoll.nMod + nWeaponSpeed;
            rRoll.sDesc = rRoll.sDesc .. " [MOD (" .. rItem.sName .. "): " .. nWeaponSpeed .. "]";
        end
    end
    return rRoll;
end

function getBaseRulesetRoll(rActor, bSecretRoll, rItem)
    if ModifierStack.getModifierKey("INIT_START_ROUND") then
        return getFixedInitiativeRoll(1);
    elseif ModifierStack.getModifierKey("INIT_END_ROUND") then
        return getFixedInitiativeRoll(99);
    end

    local rRoll = fGetRoll(rActor, bSecretRoll, rItem);

    if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() then
        modifyRollForDexterity(rActor, rRoll);
    end

    return rRoll;
end

function modifyRollForDexterity(rActor, rRoll)
    if rActor then
        local sActorType = ActorManagerPO.getType(rActor);
        local nodeActor = ActorManagerPO.getCreatureNode(rActor);
        if nodeActor then
            local nReactionAdj = 0 - DB.getValue(nodeActor, "abilities.dexterity.reactionadj", 0);
            rRoll.sDesc = rRoll.sDesc .. "[Reaction Adj: " .. nReactionAdj .. "]";
            rRoll.nMod = rRoll.nMod + nReactionAdj;
        end
    end
end

function getFixedInitiativeRoll(nFixedInit, bSecretRoll)
    local rRoll = {};
    rRoll.sType = "init";
    rRoll.aDice = {"d0"};
    rRoll.nMod = nFixedInit; -- Default to last
    rRoll.sDesc = "[INIT][FORCED]";
    rRoll.bSecret = bSecretRoll;
    return rRoll;
end

function getRollOverride(rActor, bSecretRoll, rItem)
    if PlayerOptionManager.isUsingPhasedInitiative() then
        return getRollForPhasedInit(rActor, bSecretRoll, rItem);
    end

    local rRoll;
    if PlayerOptionManager.isUsingHackmasterInitiative() then
        rRoll = getHackmasterInitRoll(rActor, bSecretRoll, rItem);
    else
        rRoll = getBaseRulesetRoll(rActor, bSecretRoll, rItem);
    end

    HonorManagerPO.addInitiativeModifier(rActor, rRoll);
    return rRoll;
end
