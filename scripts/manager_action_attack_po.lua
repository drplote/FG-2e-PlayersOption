local fModAttack;
local fOnAttack;
local fIsCrit;
local fClearCritState;
local fGetRoll;



function onInit()
  fModAttack = ActionAttack.modAttack;
  ActionAttack.modAttack = modAttackOverride;
  ActionsManager.registerModHandler("attack", modAttackOverride); 
	
	fOnAttack = ActionAttack.onAttack;
	ActionAttack.onAttack = onAttackOverride;
	ActionsManager.registerResultHandler("attack", onAttackOverride);

  fIsCrit = ActionAttack.isCrit;
  ActionAttack.isCrit = isCritOverride;

  fClearCritState = ActionAttack.clearCritState;
  ActionAttack.clearCritState = clearCritStateOverride

  fGetRoll = ActionAttack.getRoll;
  ActionAttack.getRoll = getRollOverride;
end

function getRollOverride(rActor, rAction)
  local rRoll = fGetRoll(rActor, rAction);
  rRoll.weaponPath = rAction.weaponPath;
  rRoll.aDamageTypes = rAction.aDamageTypes;
  return rRoll;
end

function onAttackOverride(rSource, rTarget, rRoll)
  if not rSource.weaponPath then
    rSource.weaponPath = rRoll.weaponPath;
  end
  if not rSource.aDamageTypes then
    rSource.aDamageTypes = WeaponManagerPO.decodeDamageTypes(rRoll.aDamageTypes);
  end
  local bOptAscendingAC = (OptionsManager.getOption("HouseRule_ASCENDING_AC"):match("on") ~= nil);
  local bOptSHRR = (OptionsManager.getOption("SHRR") ~= "off");
  local bOptREVL = (OptionsManager.getOption("REVL") == "on");
  local is2e = (DataCommonADND.coreVersion == "2e");
  local bHitTarget = false;
  local sExtendedText = "";
  
  ActionsManager2.decodeAdvantage(rRoll);
  local nAttackMatrixRoll = ActionsManager.total(rRoll);
  

  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");

  local bIsSourcePC = (rSource and rSource.sType == "pc");
  local bPsionic = rRoll.bPsionic == "true";
  local rAction = {};
  rAction.nTotal = ActionsManager.total(rRoll);

    -- add base attack bonus here(converted THACO to BaB remember?) so it doesn't confuse players and show up as a +tohit --celestian]
  -- if is2e then
    -- rAction.nTotal = rAction.nTotal + rRoll.nBaseAttack;
  -- end
    
  rAction.aMessages = {};
  
  local nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus = ActorManager2.getDefenseValue(rSource, rTarget, rRoll);
  
  --table.insert(rAction.aMessages, string.format(sFormat, nAtkEffectsBonus));
  
  if nAtkEffectsBonus ~= 0 then
    rAction.nTotal = rAction.nTotal + nAtkEffectsBonus;
    nAttackMatrixRoll = nAttackMatrixRoll + nAtkEffectsBonus;
    local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]"
    table.insert(rAction.aMessages, string.format(sFormat, nAtkEffectsBonus));
  end

  if nDefEffectsBonus ~= 0 then
    nDefenseVal = nDefenseVal + nDefEffectsBonus;
    local sFormat = "[" .. Interface.getString("effects_def_tag") .. " %+d]"
    table.insert(rAction.aMessages, string.format(sFormat, nDefEffectsBonus));
  end
  --  local bCanCrit = true;
  -- insert AC hit
--Debug.console("manager_action_attack.lua","onAttack","nDefenseVal",nDefenseVal);
  local nACHit = (20 - (rAction.nTotal + rRoll.nBaseAttack));
  if DataCommonADND.coreVersion == "1e" or DataCommonADND.coreVersion == "becmi" then
    local nodeForMatrix = DB.findNode(rSource.sCreatureNode);
    nACHit = CombatManagerADND.getACHitFromMatrix(nodeForMatrix,nAttackMatrixRoll);
--Debug.console("manager_action_attack.lua","onAttack","Matrix ACHit--------->",nACHit);  
  elseif bOptAscendingAC then   -- you can't have AscendingAC and 1e Matrix (right now)
    nACHit = (rAction.nTotal + rRoll.nBaseAttack);
  end
  
  if rTarget ~= nil then
    if (nDefenseVal and nDefenseVal ~= 0) then
      
      -- target has encumbrance penalties
      local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
      local sRank = DB.getValue(nodeDefender,"speed.encumbrancerank","");
      if sRank == "Heavy" then
        table.insert(rAction.aMessages, "[ENC: " .. sRank .. "]" );
      elseif sRank == "Severe" or sRank == "MAX" then
        table.insert(rAction.aMessages, "[ENC: " .. sRank .. "]" );
      end
      
      -- adjust bCanCrit based on target AC, if they need roll+bab 20 to hit target ac then they cant crit
      -- bCanCrit = (not bPsionic and canCrit(rRoll.nBaseAttack,nDefenseVal));
      local nTargetAC = (20 - nDefenseVal);
      if bOptAscendingAC then
        nTargetAC = nDefenseVal;
      end
      if (bPsionic) then
        --rMessage.text = rMessage.text .. "[Hit-MAC: " .. nACHit .. " vs. ".. nTargetAC .." ]" .. table.concat(rAction.aMessages, " ");
        --rMessage.text = rMessage.text .. table.concat(rAction.aMessages, " ");
        table.insert(rAction.aMessages, "[Hit-MAC: " .. nACHit .. " vs. ".. nTargetAC .." ]" );
      else
        --rMessage.text = rMessage.text .. "[Hit-AC: " .. nACHit .. " vs. ".. nTargetAC .." ]" .. table.concat(rAction.aMessages, " ");
        --rMessage.text = rMessage.text .. table.concat(rAction.aMessages, " ");
        table.insert(rAction.aMessages, "[Hit-AC: " .. nACHit .. " vs. ".. nTargetAC .." ]" );
      end
    end
  elseif nDefenseVal and bPsionic and not rRoll.Psionic_DisciplineType:match("attack") then -- no source but nDefenseVal and not a psionic attack (it's a power)
    --bCanCrit = false;
    local nTargetAC = (20 - nDefenseVal);
      if bOptAscendingAC then
        nTargetAC = nDefenseVal;
      end
    --rMessage.text = rMessage.text .. "[Hit-MAC: " .. nACHit .. " vs. ".. nTargetAC .." ]" .. table.concat(rAction.aMessages, " ");
    --rMessage.text = rMessage.text .. table.concat(rAction.aMessages, " ");
  end
  
  if (bPsionic) then
    -- bCanCrit = false;
    table.insert(rAction.aMessages, string.format("[MAC: %d ]" , nACHit) );
    sExtendedText = sExtendedText .. string.format("[MAC: %d ]" , nACHit);
  else
    --"[Hit-AC: " .. nACHit .. " vs. ".. nTargetAC .." ]"
    --table.insert(rAction.aMessages, "[Hit-AC: " .. nACHit .. " vs. ".. nTargetAC .." ]" );
    table.insert(rAction.aMessages, string.format("[AC: %d ]" , nACHit) );
    sExtendedText = sExtendedText .. string.format("[AC: %d ]" , nACHit);
  end
  
  rAction.nFirstDie = 0;
  if #(rRoll.aDice) > 0 then
	rAction.nFirstDie = rRoll.aDice[1].result or 0;
  end
  
  if CritManagerPO.isCriticalHit(rRoll, rAction, nDefenseVal) then
    rAction.bSpecial = true;
    bHitTarget = true;
    rAction.sResult = "crit";
  	if PlayerOptionManager.isPOCritEnabled() then
      Debug.console("rSource", rSource);
  		  local rCrit = CritManagerPO.handleCrit(rSource, rTarget);
        if PlayerOptionManager.isGenerateHitLocationsEnabled() then
          addHitLocationToAction(rAction, rCrit.sHitLocation);
        end
        addCritInfoToAction(rAction, rCrit);
  	else
        if PlayerOptionManager.isGenerateHitLocationsEnabled() then
          addHitLocation(rSource, rTarget, rAction);
        end
        table.insert(rAction.aMessages, "[CRITICAL HIT]");
    end
  elseif rAction.nFirstDie == 1 then
    rAction.sResult = "fumble";
    if bPsionic then
      local sAdjustPSPText = adjustPSPs(rSource,tonumber(rRoll.Psionic_PSPOnFail));
      rMessage.icon = "roll_psionic_hit";
      rMessage.text = rMessage.text .. sAdjustPSPText;
    end
    table.insert(rAction.aMessages, "[MISS-AUTOMATIC]");
    sExtendedText = sExtendedText .. "[MISS-AUTOMATIC]";
  elseif nDefenseVal and nDefenseVal ~= 0 then 
    local nTargetDecendingAC = (20 - nDefenseVal);
    local bMatrixHit = ( nTargetDecendingAC >= nACHit );
    local bHit = CombatCalcManagerPO.isHit(rRoll, rAction, nDefenseVal);
    if (rTarget == nil and rRoll.Psionic_DisciplineType:match("attack")) then
      -- psionic attacks only work with a target, powers however have target MACs so... this lovely confusing mess.
    else if (is2e and bHit) or (not is2e and not bOptAscendingAC and bMatrixHit) then
    --Debug.console("manager_action_attack.lua","onAttack","nDefenseVal",nDefenseVal);
    -- nFirstDie = natural roll, nat 20 == auto-hit, if you can't crit you can still hit on a 20
    -- if rAction.nTotal >= nDefenseVal or rAction.nFirstDie == 20 then
-------------------------------------
      bHitTarget = true;
      rMessage.font = "hitfont";
      rMessage.icon = "chat_hit";
      rAction.sResult = "hit";
      local sHitText = "[HIT]";
      if (rAction.nFirstDie == 20) then
        sHitText = "[HIT-AUTOMATIC]";
      end
      if bPsionic then
        rMessage.icon = "roll_psionic_hit";
      end
	  
	  if PlayerOptionManager.isGenerateHitLocationsEnabled() then
	    addHitLocation(rSource, rTarget, rAction);
	  end
	    
      -- if bPsionic then 
        -- table.insert(rAction.aMessages,adjustPSPs(rSource,tonumber(rRoll.Psionic_PSP)));
      -- end
      table.insert(rAction.aMessages, sHitText);
      sExtendedText = sExtendedText .. sHitText;
-------------------------------------
    else
      rMessage.font = "missfont";
      rMessage.icon = "chat_miss";
      rAction.sResult = "miss";
      if bPsionic then
        local sAdjustPSPText = adjustPSPs(rSource,tonumber(rRoll.Psionic_PSPOnFail));
        rMessage.icon = "roll_psionic_miss";
        rMessage.text = rMessage.text .. sAdjustPSPText;
      end
      sExtendedText = sExtendedText .. "[MISS]";
      table.insert(rAction.aMessages, "[MISS]");
    end
    
    end
  end

  if not rTarget then
    rMessage.text = rMessage.text .. " " .. table.concat(rAction.aMessages, " ");
  end
  
  Comm.deliverChatMessage(rMessage);
  
  if rTarget then
    --notifyApplyAttack(rSource, rTarget, rMessage.secret, rRoll.sType, rRoll.sDesc, rAction.nTotal, table.concat(rAction.aMessages, " "),rRoll.sAttackLabel);
    local rResults = {};
    rResults.sDMResults = table.concat(rAction.aMessages, " ");
    rResults.sWeaponName = rRoll.sAttackLabel;
    rResults.sWeaponType = rRoll.range;
    rResults.sPCExtendedText = sExtendedText;
    
    ActionAttack.notifyApplyAttack(rSource, rTarget, rMessage.secret, rRoll.sType, rRoll.sDesc, rAction.nTotal, rResults);
  end
  
  -- TRACK CRITICAL STATE
  if rAction.sResult == "crit" and not PlayerOptionManager.isPOCritEnabled() then
    ActionAttack.setCritState(rSource, rTarget);
  end
  
  -- REMOVE TARGET ON MISS OPTION
  if rTarget then
    if (rAction.sResult == "miss" or rAction.sResult == "fumble") then
      if rRoll.bRemoveOnMiss then
        TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
      end
    end
  end
  
  -- HANDLE FUMBLE/CRIT HOUSE RULES
  local sOptionHRFC = OptionsManager.getOption("HRFC");
  if rAction.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
    ActionAttack.notifyApplyHRFC("Fumble");
  end
  if rAction.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
    ActionAttack.notifyApplyHRFC("Critical Hit");
  end
  
  -- check for MIRRORIMAGE and STONESKIN /etc...
  if rTarget and bHitTarget and not bPsionic then
    local _, nStoneSkinCount, _ = EffectManager5E.getEffectsBonus(rTarget, {"STONESKIN"}, false, nil);
    local _, nMirrorCount, nEffectCount = EffectManager5E.getEffectsBonus(rTarget, {"MIRRORIMAGE"}, false, nil);
    if (nStoneSkinCount > 0) then
      -- remove a stoneskin from count
      local nodeCT = ActorManager.getCTNode(rTarget);
      EffectManagerADND.removeEffectCount(nodeCT, "STONESKIN", 1);
      local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
      rMessage.text = "[STONESKIN HIT] " .. Interface.getString("chat_combat_hit_stoneskin");
      Comm.deliverChatMessage(rMessage);
    elseif nMirrorCount > 0 then
      local aMirrorDice = { "d100" };
      if Interface.getVersion() < 4 then
        table.insert(aMirrorDice, "d10");
      end
      local rMirrorRoll = { sType = "roll_against_mirrorimages", sDesc = "[MIRROR-IMAGE]", aDice = aMirrorDice, nMod = 0 ,bSecret = false, sUser = User.getUsername()};
      ActionsManager.roll(rSource, rTarget, rMirrorRoll,false);
    else
      -- check to see if displaced
      local bDisplacedTarget = (EffectManager5E.hasEffect(rTarget, "DISPLACED", nil));
      -- local _, nodeCharTarget = ActorManager.getTypeAndNode(rTarget);
      -- local aEquipmentList = ItemManager2.getItemsEquipped(nodeCharTarget);
      local sDisplacementTag = "DISPLACEMENT_" .. UtilityManagerADND.alphaOnly(ActorManager.getDisplayName(rTarget));
      --if UtilityManagerADND.containsAny(aEquipmentList, "displacement" ) and not EffectManager5E.hasEffect(rSource, sDisplacementTag) then
      if bDisplacedTarget and not EffectManager5E.hasEffect(rSource, sDisplacementTag) then
        EffectManager.addEffect("", "", ActorManager.getCTNode(rSource), { sName = sDisplacementTag, sLabel = sDisplacementTag, nDuration = 1, sUnits = "minute", nGMOnly = 1, }, false);
        local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
        rMessage.text = "[DISPLACEMENT] " .. string.format(Interface.getString("chat_combat_hit_displacement"));  
        Comm.deliverChatMessage(rMessage);
      end
    end
  end
end

function modAttackOverride(rSource, rTarget, rRoll)
    fModAttack(rSource, rTarget, rRoll);
	
    if PlayerOptionManager.isWeaponTypeVsArmorModsEnabled() then
        addWeaponTypeVsArmorMods(rSource, rTarget, rRoll);
    end
end

function addHitLocationToAction(rAction, sHitLocation)
    table.insert(rAction.aMessages, string.format("[Location: %s]", sHitLocation));
end

function addCritInfoToAction(rAction, rCrit)
    table.insert(rAction.aMessages, string.format("[CRITICAL HIT: %s]", rCrit.message));
end


function addHitLocation(rSource, rTarget, rAction)
	if rSource and rTarget then
		local _, nodeAttacker = ActorManager.getTypeAndNode(rSource);
		local _, nodeDefender = ActorManager.getTypeAndNode(rTarget);
		if nodeAttacker and nodeDefender then
			local rHitLocation = HitLocationManagerPO.getHitLocation(nodeAttacker, nodeDefender);
      addHitLocationToAction(rAction, rHitLocation.desc);
		end
	end
end

function addWeaponTypeVsArmorMods(rSource, rTarget, rRoll)  
    local sArmorType, sDamageType, nMod = ArmorManagerPO.getHitModifiersForSourceVsCharacter(rSource, rTarget);
    addWeaponTypeVsArmorModToRoll(rRoll, sDamageType, sArmorType, nMod);
end

function addWeaponTypeVsArmorModToRoll(rRoll, sDamageType, sArmor, nMod)
    if nMod == 0 or nMod == nil then 
        return;
    end
    
    local sMod = tostring(nMod);
    if nMod > 0 then
        sMod = "+" .. sMod;
    end
    
    rRoll.sDesc = rRoll.sDesc .. string.format(" [WvA: %s v %s (%s)]", sDamageType, sArmor, sMod);
    rRoll.nMod = nMod;
end

function clearCritStateOverride(rSource)
  if PlayerOptionManager.isPOCritEnabled() then
    CritManagerPO.clearCritState(rSource)
  else
    fClearCritState(rSource);
  end
end

function isCritOverride(rSource, rTarget)
  if PlayerOptionManager.isPOCritEnabled() then
    CritManagerPO.hasCritState(rSource, rTarget);
  else
    fIsCrit(rSource, rTarget);
  end
end