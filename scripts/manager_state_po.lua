aCritState = {};
aFatigueState = {};
aRanStartEffects = {};

OOB_MSGTYPE_SET_FATIGUE_STATE = "requestSetFatigueState";

function onInit()
  OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_SET_FATIGUE_STATE, handleSetFatigueState);
end

function handleRoundStart()
  if PlayerOptionManager.isUsingThresholdOfPain() then
    local aCombatants = CombatManager.getCombatantNodes();
    for _, ctNode in pairs(aCombatants) do
        local nodeChar = CombatManagerADND.getNodeFromCT(ctNode);
        StateManagerPO.clearTraumaDamage(nodeChar);
    end
  end
end

function getStateNode()
  local nodeState = DB.findNode("poState");
  if not nodeState then
    nodeState = DB.createNode("poState");
  end
  return nodeState;
end

function getPcInit()
  return DB.getValue(getStateNode(), "pc_init", 0);
end

function setPcInit(nInit)
    return DB.setValue(getStateNode(), "pc_init", "number", nInit);
end

function getNpcInit()
  return DB.getValue(getStateNode(), "npc_init", 0);
end

function setNpcInit(nInit)
    return DB.setValue(getStateNode(), "npc_init", "number", nInit);
end

function setRanStartEffect(nodeActor, nodeEffect)
  if not nodeActor or not nodeEffect then return; end
  
  local sSourceCT = ActorManager.getCTNodeName(nodeActor);
  if sSourceCT == "" then
    return;
  end
  
  if not aRanStartEffects[sSourceCT] then
    aRanStartEffects[sSourceCT] = {};
  end
  table.insert(aRanStartEffects[sSourceCT], {["effectId"]=nodeEffect});
end


function clearTurnEffectsState()
  aRanStartEffects = {};
end

function hasRunStartEffect(nodeActor, nodeEffect)
  if not nodeActor or not nodeEffect then return false; end

  local sSourceCT = ActorManager.getCTNodeName(nodeActor);
  if sSourceCT == "" then
    return false;
  end

  if not aRanStartEffects[sSourceCT] then
    return false;
  end
  
  for k,v in ipairs(aRanStartEffects[sSourceCT]) do
    if v.effectId == nodeEffect then
      return true;
    end
  end
  
  return false;
end



function hasShieldHitState(rSource, rTarget)
  local nodeChar = ActorManagerPO.getNode(rSource);
  if not nodeChar then
    return;
  end

  local sTargetCT = "";
  if rTarget then
    sTargetCT = ActorManager.getCTNodeName(rTarget);
  end

  local sShieldHitTarget = DB.getValue(nodeChar, "shieldhit.state", "");
  return sShieldHitTarget == ActorManager.getCTNodeName(rTarget);
end

function clearShieldHitState(rSource)
  local nodeChar = ActorManagerPO.getNode(rSource);
  DB.setValue(nodeChar, "shieldhit.state", "string", "");
end

function setShieldHitState(rSource, rTarget)
    local nodeChar = ActorManagerPO.getNode(rSource);
    if not nodeChar then
      return;
    end

    DB.setValue(nodeChar, "shieldhit.state", "string", ActorManager.getCTNodeName(rTarget));
end

function getFatigueState(nodeChar)
    return DB.getValue(nodeChar, "fatigue.state", 0);
end

function handleSetFatigueState(msgOOB)
  local rActor = ActorManager.resolveActor(msgOOB.sCharNodeName);
  if not rActor then
    return;
  end

  local nodeChar = ActorManagerPO.getNode(rActor);

  DebugPO.log("nodeChar", nodeChar);
  local nFatigue = tonumber(msgOOB.sFatigue);
  local nCurrentFatigueState = DB.getValue(nodeChar, "fatigue.state");
  if not nCurrentFatigueState or nCurrentFatigueState < nFatigue then
    DB.setValue(nodeChar, "fatigue.state", "number", nFatigue);
  end
end


function setFatigueState(rChar, nFatigue)
  local msgOOB = {};
  msgOOB.type = OOB_MSGTYPE_SET_FATIGUE_STATE;
  msgOOB.sFatigue = tostring(nFatigue);
  
  local nodeChar = ActorManagerPO.getNode(rChar);
  if nodeChar then
    msgOOB.sCharNodeName = nodeChar.getNodeName();
    Comm.deliverOOBMessage(msgOOB, "");
  end
end

function clearFatigueState(nodeChar)
    DB.setValue(nodeChar, "fatigue.state", "number", 0);
end

function getTraumaDamage(nodeChar)
  return DB.getValue(nodeChar, "traumadamage", 0);
end

function addTraumaDamage(rChar, nTraumaDamage)
  local nodeChar = ActorManagerPO.getNode(rChar);
  if not nodeChar then
    return 0;
  end

  local nCurrentTraumaDamage = getTraumaDamage(nodeChar);
  local nTotal = nCurrentTraumaDamage + nTraumaDamage;
  DB.setValue(nodeChar, "traumadamage", "number", nTotal);
  return nTotal;
end

function clearTraumaDamage(nodeChar)
  DB.setValue(nodeChar, "traumadamage", "number", 0);
end

function setCritState(rSource, rTarget, rCrit)

  local sSourceCT = ActorManager.getCreatureNodeName(rSource);
  if sSourceCT == "" then
    return;
  end
  local sTargetCT = "";
  if rTarget then
    sTargetCT = ActorManager.getCTNodeName(rTarget);
  end
  
  if not aCritState[sSourceCT] then
    aCritState[sSourceCT] = {};
  end
  table.insert(aCritState[sSourceCT], {["sTargetCT"]=sTargetCT, ["nDmgMult"]=rCrit.dmgMultiplier, ["nDmgBonusDie"]=rCrit.dmgBonusDie});
end

function clearCritState(rSource)
  local sSourceCT = ActorManager.getCreatureNodeName(rSource);
  if sSourceCT ~= "" then
    aCritState[sSourceCT] = nil;
  end
end

function hasCritState(rSource, rTarget)
  local sSourceCT = ActorManager.getCreatureNodeName(rSource);
  if sSourceCT == "" then
    return;
  end
  local sTargetCT = "";
  if rTarget then
    sTargetCT = ActorManager.getCTNodeName(rTarget);
  end

  if not aCritState[sSourceCT] then
    return false, 1, 0;
  end
  
  for k,v in ipairs(aCritState[sSourceCT]) do
    if v.sTargetCT == sTargetCT then
      table.remove(aCritState[sSourceCT], k);
      return true, v.nDmgMult, v.nDmgBonusDie;
    end
  end
  
  return false, 1, 0;
end