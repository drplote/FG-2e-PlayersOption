aCritState = {};

function onInit()
end

function isCriticalHit(rRoll, rAction, nDefenseVal)
	if PlayerOptionManager.isPOCritEnabled() then
		return isCriticalHitCombatAndTactics(rRoll, rAction, nDefenseVal);
	else
		return isCriticalHit2e(rRoll, rAction);
	end
end

function isCriticalHitCombatAndTactics(rRoll, rAction, nDefenseVal)
	if nDefenseVal and nDefenseVal ~= 0 then
		local nRequiredCritRoll = PlayerOptionManager.getRequiredCritRoll();
		local bMustHitBy5 = PlayerOptionManager.mustCritHitBy5();

		return rAction.nFirstDie >= PlayerOptionManager.getRequiredCritRoll() and (not bMustHitBy5 or nHitDifference >= 5);
	end
	return false;
end

function isCriticalHit2e(rRoll, rAction)
	local sCritThreshold = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
	local nCritThreshold = tonumber(sCritThreshold) or 20;
	if nCritThreshold < 2 or nCritThreshold > 20 then
		nCritThreshold = 20;
	end

	return rAction.nFirstDie >= nCritThreshold
end


function getWeaponInfo(rSource)
	local rWeaponInfo = {};
	local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
	if rSource.weaponPath then
		-- First try to determine size from the weapon action, if it exists
		local nodeWeapon = DB.findNode(rSource.weaponPath);
		rWeaponInfo.size = WeaponManagerPO.getSizeCategory(nodeWeapon, nodeAttacker);
	end
	if not rWeaponInfo.size and rSource.itemPath then
		-- If we don't have a size yet, try to get it from the item, if it exists
		local nodeWeapon = DB.findNode(rSource.itemPath);
		rWeaponInfo.size = WeaponManagerPO.getSizeCategory(nodeWeapon, nodeAttacker);
	end
	if not rWeaponInfo.size then
		-- If we don't have a size yet, just make it the same as attacker size it on attacker size)
		rWeaponInfo.size = ActorManagerPO.getSizeCategory(nodeAttacker);
	end

	rWeaponInfo.aDamageTypes = rSource.aDamageTypes;
	return rWeaponInfo;
end

function handleCrit(rSource, rTarget)
	if rSource and rTarget then
		local rWeaponInfo = getWeaponInfo(rSource);
		local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
		local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
		local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
		local nSizeDifference = getSizeDifference(nodeAttacker, nodeDefender, rWeaponInfo);
		local nSeverity = getSeverityDieRoll(nSizeDifference);
		local rCrit = getCritResult(rWeaponInfo, nodeDefender, rHitLocation, nSeverity);
		setCritState(rSource, rTarget, rCrit.dmgMultiplier);
		return rCrit;
	end
end

function addCritMessage(rCrit)
	-- TODO: remove save message once it's automated
	local sCritMsg = string.format("In the %s, %s vs %s (severity %s). %s", 
		rCrit.sHitLocation,
		rCrit.sDamageType,
		rCrit.sDefenderType,
		rCrit.nSeverity, 
		rCrit.desc);

    local sDmgMult = "2x";
    if rCrit.dmgMultiplier == 3 then
      sDmgMult = "3x";
    end

	rCrit.message = string.format("%s Save vs death to avoid effects. %s damage dice regardless of save result.", sCritMsg, sDmgMult);
end

function selectRandomCritDamageType(aDamageTypes)
	local aCritDamageTypes = getCritDamageTypes(aDamageTypes);
	if not aCritDamageTypes or #aCritDamageTypes == 0 then
		return nil;
	end
	return aCritDamageTypes[math.random(1, #aCritDamageTypes)];
end

function getCritDamageTypes(aDamageTypes)
	local aCritDamageTypes = {"bludgeoning", "piercing", "slashing"};
	return UtilityPO.getIntersecting(aCritDamageTypes, aDamageTypes);
end

function getCritResult(rWeaponInfo, nodeDefender, rHitLocation, nSeverity)
	local sDamageType = selectRandomCritDamageType(rWeaponInfo.aDamageTypes);
	local sDefenderType = ActorManagerPO.getTypeForHitLocation(nodeDefender);
	if not sDamageType or not sDefenderType or not rHitLocation or not rHitLocation.locationCategory or not nSeverity then
		Debug.console("couldn't generate crit", "sDefenderType", sDefenderType, "sDamageType", sDamageType, "rHitLocation", rHitLocation, "nSeverity", nSeverity);
	end
	
	local rCrit = DataCommonPO.aCritCharts[sDefenderType][sDamageType][rHitLocation.locationCategory][nSeverity];
	rCrit.sDefenderType = sDefenderType;
	rCrit.sHitLocation = rHitLocation.desc;
	rCrit.nSeverity = nSeverity;
	rCrit.sDamageType = sDamageType;
	if nSeverity >= 13 then
		rCrit.dmgMultiplier = 3;
	else
		rCrit.dmgMultiplier = 2;
	end

	addCritMessage(rCrit);
	return rCrit;
end

function getSizeDifference(nodeAttacker, nodeDefender, rWeaponInfo)
	local nDefenderSizeCategory = ActorManagerPO.getSizeCategory(nodeDefender);
	local nAttackerSizeCategory = rWeaponInfo.size or 0;
	return nAttackerSizeCategory - nDefenderSizeCategory;    
end

function getSeverityDieRoll(nSizeDifference)
	local nRollResult = 1;
	if nSizeDifference < 0 then
		nRollResult = DiceManagerPO.getDiceResult(1, 6);
	elseif nSizeDifference == 1 then
		nRollResult = DiceManagerPO.getDiceResult(2, 6);
	elseif nSizeDifference > 1 then
		nRollResult = DiceManagerPO.getDiceResult(2, 8);
	else
		nRollResult = DiceManagerPO.getDiceResult(2, 4);
	end
	if nRollResult > 13 then
		nRollResult = 13;
	end
	return nRollResult;
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