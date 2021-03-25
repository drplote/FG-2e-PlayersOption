function onInit()
    super.onInit();
    local node = getDatabaseNode();
    OptionsManager.registerCallback(PlayerOptionManager.sPhasedInitiativeOptionKey, update);   
    DB.addHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitResult);
    update();
end


function onClose()
    super.onClose();
    local node = getDatabaseNode();
    DB.removeHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitResult);
end

function updateInitResult()
    if PlayerOptionManager.isUsingPhasedInitiative() then
        local node = getDatabaseNode();
        local nInitResult = DB.getValue(node, "initresult", 12);
        local sPhaseName = InitManagerPO.getPhaseName(math.floor(nInitResult/2));
        initresultpo.setValue(sPhaseName);
    end
end

function update()
    if PlayerOptionManager.isUsingPhasedInitiative() then
        initresult.setVisible(false);
        initresultpo.setVisible(true);
        updateInitResult();
    else
        initresult.setVisible(true);
        initresultpo.setVisible(false);
    end
    RadialMenuManagerPO.initCombatTrackerActorMenu(self);
end

function onMenuSelection(selection, subselection, subsubselection)
  RadialMenuManagerPO.onCombatTrackerActorMenuSelection(rollInitWithModifier, delayActor, selection, subselection, subsubselection);
  super.onMenuSelection(selection, subselection);
end

function rollInitWithModifier(sModifierKey)
    if sModifierKey then
        ModifierStack.setModifierKey(sModifierKey, true);
    end
    local nodeChar = getDatabaseNode();
    local rActor = ActorManager.resolveActor(nodeChar);
    ActionInit.performRoll(nil, rActor);
end

function delayActor(nDelay)
    local nodeChar = getDatabaseNode();
    if not nDelay then
        InitManagerPO.delayActor(nodeChar);
    else
        InitManagerPO.delayActorForSegments(nodeChar, nDelay);
    end
end

