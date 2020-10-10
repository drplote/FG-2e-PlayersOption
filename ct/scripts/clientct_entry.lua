function onInit()
  super.onInit();
  local node = getDatabaseNode();
  OptionsManager.registerCallback(PlayerOptionManager.sPhasedInitiativeOptionKey, updateInitDisplay);   
  DB.addHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitResult);
  updateInitDisplay();
end

function onClose()
  super.onClose();
  local node = getDatabaseNode();
  DB.removeHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitResult);
end

function onActiveChanged()
  updateDisplay();
end

function onFactionChanged()
  updateDisplay();
end

function updateDisplay()
  super.updateDisplay();
  Debug.console("update display called");
  updateInitDisplay();
end

function updateInitResult()
  if PlayerOptionManager.isUsingPhasedInitiative() then
      local node = getDatabaseNode();
      local nInitResult = DB.getValue(node, "initresult", 12);
      local sPhaseName = InitManagerPO.getPhaseName(math.floor(nInitResult/2));
      initresultpo.setValue(sPhaseName);
  end
end

function shouldShowInit()
  local sFaction = friendfoe.getStringValue();
  local sOptCTSI = OptionsManager.getOption("CTSI");
  return ((sOptCTSI == "friend") and (sFaction == "friend")) or (sOptCTSI == "on");
end

function updateInitDisplay()
  if not shouldShowInit then
    initresult.setVisible(false);
    initresultpo.setVisible(false);
    Debug.console("hiding all");
  elseif PlayerOptionManager.isUsingPhasedInitiative() then
      initresult.setVisible(false);
      initresultpo.setVisible(true);
      Debug.console("hiding number");
      updateInitResult();

  else
      initresult.setVisible(true);
      initresultpo.setVisible(false);
      Debug.console("hiding string");
  end
end
