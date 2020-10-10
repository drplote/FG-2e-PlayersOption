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
    else
        initresult.setVisible(true);
        initresultpo.setVisible(false);
    end
end
