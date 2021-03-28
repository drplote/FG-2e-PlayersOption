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
    DB.removeHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitResult);
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

function performFixedSequenceInitAction(nNumAttacks)
    InitManagerPO.setActorFixedAttackRate(getDatabaseNode(), nNumAttacks);
end

function performCloneGroupInitAction()
    local nodeChar = getDatabaseNode();
    InitManagerPO.cloneInitToSimilarCreatures(nodeChar, true);
end

function performInitAction(sModifierKey)
    if sModifierKey then
        ModifierStack.setModifierKey(sModifierKey, true);
    end
    local nodeChar = getDatabaseNode();
    local rActor = ActorManager.resolveActor(nodeChar);
    ActionInit.performRoll(nil, rActor);
end

function performDelayAction(nDelay)
    local nodeChar = getDatabaseNode();
    if not nDelay then
        InitManagerPO.delayActor(nodeChar);
    else
        InitManagerPO.delayActorForSegments(nodeChar, nDelay);
    end
end

function performEffectAction(sEffectName, isRemoving)
    local nodeChar = getDatabaseNode();

    if isRemoving then
        EffectManager.removeEffect(nodeChar, sEffectName);
    else
        if not EffectManager5E.hasEffect(nodeChar, sEffectName, nil) then
            EffectManager.addEffect("", "", nodeChar, { sName = sEffectName, sLabel = sEffectName, nDuration = 0 }, true);
        end
    end
end
