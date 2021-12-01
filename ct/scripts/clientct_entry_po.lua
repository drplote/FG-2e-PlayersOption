function onInit()
  onFactionChanged();
  onHealthChanged();
  
  local node = getDatabaseNode();
  DB.addHandler(node.getPath() .. ".active", "onUpdate", toggleActiveUpdateFeatures);
  -- make sure first time load of map has proper indicator
  toggleActiveUpdateFeatures()
  OptionsManager.registerCallback(PlayerOptionManager.sPhasedInitiativeOptionKey, updateInitDisplay);   
  DB.addHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitDisplay);
  DB.addHandler(DB.getPath(node, "initQueue"), "onUpdate", updateInitDisplay);
  updateInitDisplay();
end

function onClose()
  local node = getDatabaseNode();
  DB.removeHandler(node.getPath() .. ".active", "onUpdate", updateInitDisplay);
  DB.removeHandler(DB.getPath(node, "initresult"), "onUpdate", updateInitDisplay);
end

function onActiveChanged()
  updateDisplay();
end

function onFactionChanged()
  updateDisplay();
  updateHealthDisplay();
end

function onHealthChanged()
  local rActor = ActorManager.resolveActor(getDatabaseNode())
  local sColor = ActorHealthManager.getHealthColor(rActor);
  
  wounds.setColor(sColor);
  status.setColor(sColor);
end

function toggleActiveUpdateFeatures()
  TokenManagerADND.clearAllTargetsWidgets();
  toggleTargetTokenIndicators();
  clearSelectionToken();
end

function clearSelectionToken()
  local nodeCT = getDatabaseNode();
  local tokenMap = CombatManager.getTokenFromCT(nodeCT);
  local imageControl = ImageManager.getImageControl(tokenMap, true);
  if imageControl then
    imageControl.clearSelectedTokens();
    imageControl.selectToken( tokenMap, true ) ;
  end
  TokenManagerADND.resetIndicators(nodeCT, false);
end

function toggleTargetTokenIndicators()
  local nodeCT = getDatabaseNode();
  TokenManagerADND.setTargetsForActive(nodeCT)
end

function updateHealthDisplay()
  local sOption;
  if friendfoe.getStringValue() == "friend" then
    sOption = OptionsManager.getOption("SHPC");
  else
    sOption = OptionsManager.getOption("SHNPC");
  end
  
  if sOption == "detailed" then
    hptotal.setVisible(true);
    hptemp.setVisible(true);
    wounds.setVisible(true);

    status.setVisible(false);
  elseif sOption == "status" then
    hptotal.setVisible(false);
    hptemp.setVisible(false);
    wounds.setVisible(false);

    status.setVisible(true);
  else
    hptotal.setVisible(false);
    hptemp.setVisible(false);
    wounds.setVisible(false);

    status.setVisible(false);
  end
end

function updateDisplay()
  local sFaction = friendfoe.getStringValue();

  local sOptCTSI = OptionsManager.getOption("CTSI");
  local bShowInit = ((sOptCTSI == "friend") and (sFaction == "friend")) or (sOptCTSI == "on");
  initresult.setVisible(bShowInit);
  
  if active.getValue() == 1 then
    name.setFont("sheetlabel");
    nonid_name.setFont("sheetlabel");

    active_spacer_top.setVisible(true);
    active_spacer_bottom.setVisible(true);
    
    if sFaction == "friend" then
      setFrame("ctentrybox_friend_active");
    elseif sFaction == "neutral" then
      setFrame("ctentrybox_neutral_active");
    elseif sFaction == "foe" then
      setFrame("ctentrybox_foe_active");
    else
      setFrame("ctentrybox_active");
    end
    
    windowlist.scrollToWindow(self);
  else
    name.setFont("sheettext");
    nonid_name.setFont("sheettext");

    active_spacer_top.setVisible(false);
    active_spacer_bottom.setVisible(false);
    
    if sFaction == "friend" then
      setFrame("ctentrybox_friend");
    elseif sFaction == "neutral" then
      setFrame("ctentrybox_neutral");
    elseif sFaction == "foe" then
      setFrame("ctentrybox_foe");
    else
      setFrame("ctentrybox");
    end
  end
  updateInitDisplay();
end

function onIDChanged()
  local nodeRecord = getDatabaseNode();
  local sClass = DB.getValue(nodeRecord, "link", "npc", "");
  if sClass == "npc" then
    local bID = LibraryData.getIDState("npc", nodeRecord, true);
    name.setVisible(bID);
    nonid_name.setVisible(not bID);
  else
    name.setVisible(true);
    nonid_name.setVisible(false);
  end
end


function updateInitResult()
  if PlayerOptionManager.isUsingPhasedInitiative() then
      local node = getDatabaseNode();
      local nInitResult = DB.getValue(node, "initresult", 12);
      local sPhaseName = InitManagerPO.getPhaseName(math.floor(nInitResult/2));
      initresultpo.setValue(sPhaseName);
  else
      local aAllInits = InitManagerPO.getAllActorInits(getDatabaseNode());
      local sAllInits = UtilityPO.toCSV(aAllInits);
      initresultpo.setValue(sAllInits);
  end
end

function shouldShowInit()
  local sFaction = friendfoe.getStringValue();
  local sOptCTSI = OptionsManager.getOption("CTSI");
  return ((sOptCTSI == "friend") and (sFaction == "friend")) or (sOptCTSI == "on");
end

function updateInitDisplay()
  updateInitResult();
  if not shouldShowInit() then
      initresult.setVisible(false);
      initresultpo.setVisible(false);
  elseif PlayerOptionManager.isUsingPhasedInitiative() then
      initresult.setVisible(false);
      initresultpo.setVisible(true);  
  else
      if InitManagerPO.hasAdditionalInitsInQueue(getDatabaseNode()) then
          initresultpo.setVisible(true);
          initresult.setVisible(false);
      else
          initresultpo.setVisible(false);
          initresult.setVisible(true);
      end
  end
end
