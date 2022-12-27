function onInit()
    super.onInit();
    local node = getDatabaseNode();
    OptionsManager.registerCallback(PlayerOptionManager.sPhasedInitiativeOptionKey, update);   
    DB.addHandler(DB.getPath(node, "initresult"), "onUpdate", update);
    DB.addHandler(DB.getPath(node, "initQueue"), "onUpdate", update);
    update();
end


function onClose()
    super.onClose();
    local node = getDatabaseNode();
    DB.removeHandler(DB.getPath(node, "initresult"), "onUpdate", update);
    DB.removeHandler(DB.getPath(node, "initQueue"), "onUpdate", update);
end

function updateInitResult()
    local node = getDatabaseNode();
    if PlayerOptionManager.isUsingPhasedInitiative() then
        local nInitResult = DB.getValue(node, "initresult", 12);
        local sPhaseName = InitManagerPO.getPhaseName(math.floor(nInitResult/2));
        initresultpo.setValue(sPhaseName);
    else
        local sInitQueue = DB.getValue(node, "initQueue");
        initresultpo.setValue(sInitQueue);
    end
end

function update()
    updateInitResult();
    if PlayerOptionManager.isUsingPhasedInitiative() then
        initresult.setVisible(false);
        initresultpo.setVisible(true);
    else
        initresult.setVisible(true);
        
        if InitManagerPO.hasAdditionalInitsInQueue(getDatabaseNode()) then
            initresultpo.setVisible(true);
        else
            initresultpo.setVisible(false);
        end
    end
    RadialMenuManagerPO.initCombatTrackerActorMenu(self);
end

function onMenuSelection(selection, subselection, subsubselection)
  RadialMenuManagerPO.onCombatTrackerActorMenuSelection(self, selection, subselection, subsubselection);
  super.onMenuSelection(selection, subselection);
end

function performSequencedInitAction(nNumAttacks)
    InitManagerPO.rollSequencedAttackInit(getDatabaseNode(), nNumAttacks);
end

function deleteAndAddXp()
    local nodeChar = ActorManager.getCreatureNode(getDatabaseNode());
    PartyManagerPO.addEncounterNPC(nodeChar);
    delete();
end

function performFixedSequenceInitAction(nNumAttacks)
    InitManagerPO.setActorFixedAttackRate(getDatabaseNode(), nNumAttacks);
end

function performCloneGroupInitAction()
    local nodeCT = getDatabaseNode();
    InitManagerPO.cloneInitToSimilarCreatures(nodeCT, true);
end

function performInitAction(sModifierKey)
    if sModifierKey then
        ModifierStack.setModifierKey(sModifierKey, true);
    end
    local nodeCT = getDatabaseNode();
    local rActor = ActorManager.resolveActor(nodeCT);
    ActionInit.performRoll(nil, rActor);
end

function performDelayAction(nDelay)
    local nodeCT = getDatabaseNode();
    if not nDelay then
        InitManagerPO.delayActor(nodeCT);
    else
        InitManagerPO.delayActorForSegments(nodeCT, nDelay);
    end
end

function performEffectAction(sEffectName, isRemoving)
    local nodeCT = getDatabaseNode();

    if isRemoving then
        EffectManager.removeEffect(nodeCT, sEffectName);
    else
        if not EffectManager5E.hasEffect(nodeCT, sEffectName, nil) then
            EffectManager.addEffect("", "", nodeCT, { sName = sEffectName, sLabel = sEffectName, nDuration = 0 }, true);
        end
    end
end

function getCtNodeActor()
    return getDatabaseNode();
end
