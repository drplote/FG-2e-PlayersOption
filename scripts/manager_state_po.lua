aCritState = {};
aFatigueState = {};

function onInit()
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

function setFatigueState(rChar, nFatigue)
  -- nFatigue = 0 (decrease fatigue at end of turn), = 1 (no recovery, no increase), = 2 (increase)
  local nodeChar = ActorManagerPO.getNode(rChar);
  if not nodeChar then
    return;
  end

  local nCurrentFatigueState = DB.getValue(nodeChar, "fatigue.state");
  if not nCurrentFatigueState or nCurrentFatigueState < nFatigue then
    DB.setValue(nodeChar, "fatigue.state", "number", nFatigue);
  end
end

function clearFatigueState(nodeChar)
    DB.setValue(nodeChar, "fatigue.state", "number", 0);
end

function setCritState(rSource, rTarget, nDmgMult)
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
  table.insert(aCritState[sSourceCT], {["sTargetCT"]=sTargetCT, ["nDmgMult"]=nDmgMult});
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
    return false, 1;
  end
  
  for k,v in ipairs(aCritState[sSourceCT]) do
    if v.sTargetCT == sTargetCT then
      table.remove(aCritState[sSourceCT], k);
      return true, v.nDmgMult;
    end
  end
  
  return false, 1;
end