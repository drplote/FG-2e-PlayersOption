local fCalcItemArmorClass;
local fGetEncumbranceRank2e;
local fUpdateMoveFromEncumbrance1e;
local fUpdateEncumbrance;
local fRest;

function onInit()
	fCalcItemArmorClass = CharManager.calcItemArmorClass;
	CharManager.calcItemArmorClass = calcItemArmorClassOverride;

  fGetEncumbranceRank2e = CharManager.getEncumbranceRank2e;
  CharManager.getEncumbranceRank2e = getEncumbranceRank2eOverride;

  fUpdateMoveFromEncumbrance1e = CharManager.updateMoveFromEncumbrance1e;
  CharManager.updateMoveFromEncumbrance1e = updateMoveFromEncumbrance1eOverride;

  fUpdateEncumbrance = CharManager.updateEncumbrance;
  CharManager.updateEncumbrance = updateEncumbranceOverride;

  fRest = CharManager.rest;
  CharManager.rest = restOverride;
end

function restOverride(nodeChar, bLong)
  fRest(nodeChar, bLong);
  if PlayerOptionManager.isUsingHackmasterFatigue() then
      FatigueManagerPO.resetFatigue(nodeChar);
  end
end

function updateEncumbranceOverride(nodeChar)
    fUpdateEncumbrance(nodeChar);
    FatigueManagerPO.updateFatigueFactor(nodeChar);
end

function getEncumbranceRank2eOverride(nodeChar)
    if PlayerOptionManager.isUsingHackmasterStats() then
        return getEncumbranceRank2eHackmaster(nodeChar);
    else
        return fGetEncumbranceRank2e(nodeChar);
    end
end

function updateMoveFromEncumbrance1eOverride(nodeChar)
    if PlayerOptionManager.isUsingHackmasterStats() then
        return updateMoveFromEncumbrance1eHackmaster(nodeChar);
    else
        return fUpdateMoveFromEncumbrance1e(nodeChar);
    end
end

function getEncumbranceRank2eHackmaster(nodeChar) 
  local b2e = (DataCommonADND.coreVersion == "2e");
  if not b2e then
    return "", 0, 0;
  end
  local nEncLight = 0.33;   -- 1/3
  local nEncModerate = 0.5; -- 1/2
  local nEncHeavy = 0.67;   -- 2/3
  local nBaseEnc = 0; 
  local sEncRank = "Normal";
  local nBaseMove = DB.getValue(nodeChar, "speed.base", 0);
  local nStrength = DB.getValue(nodeChar, "abilities.strength.score", 0);
  local nPercent = DB.getValue(nodeChar, "abilities.strength.percent", 0);
  local nWeightCarried = DB.getValue(nodeChar, "encumbrance.load", 0);
   
   -- HM4 mod: different strength spread
  nStrength = (nStrength * 2) - 1; 
  if(nPercent > 50) then
    nStrength = nStrength +1
  end
  
  -- determine if wt carried is greater than a encumbrance rank for strength value
  if (nWeightCarried >= DataCommonPO.aStrength[nStrength][11]) then
    nBaseEnc = (nBaseMove - 1); -- greater than max, base is 1
    sEncRank = "MAX";
  elseif (nWeightCarried >= DataCommonPO.aStrength[nStrength][10]) then
    nBaseEnc = (nBaseMove - 1); -- greater than severe, base is 1
    sEncRank = "Severe";
  elseif (nWeightCarried >= DataCommonPO.aStrength[nStrength][9]) then
    nBaseEnc = nBaseMove * nEncHeavy; -- greater than heavy
    sEncRank = "Heavy";
  elseif (nWeightCarried >= DataCommonPO.aStrength[nStrength][8]) then
    nBaseEnc = nBaseMove * nEncModerate; -- greater than moderate
    sEncRank = "Moderate";
  elseif (nWeightCarried >= DataCommonPO.aStrength[nStrength][7]) then
    nBaseEnc = nBaseMove * nEncLight; -- greater than light
    sEncRank = "Light";
  end
  
  nBaseEnc = math.floor(nBaseEnc);
  nBaseEnc = nBaseMove - nBaseEnc;
  
  local nHighestBulk = ArmorManagerPO.getBulkOfWornArmor(nodeChar);
  if nHighestBulk == 2 then
  nBaseEnc = math.floor(nBaseEnc / 6 * 4);
  elseif nHighestBulk == 1 then
  nBaseEnc = math.floor(nBaseEnc / 4 * 3);
  end
  
  if (nBaseEnc < 1) then
      nBaseEnc = 1;
  end
  
  return sEncRank, nBaseEnc, nBaseMove
end

-- update speed.basemodenc due to weight adjustments for AD&D 1e
function updateMoveFromEncumbrance1eHackmaster(nodeChar)
    if ActorManager.isPC(nodeChar) then -- only need this is the node is a PC
        local nEncLight = 0.33;   -- 1/3
        local nEncModerate = 0.5; -- 1/2
        local nEncHeavy = 0.67;   -- 2/3
        
        local nStrength = DB.getValue(nodeChar, "abilities.strength.score", 0);
        local nPercent = DB.getValue(nodeChar, "abilities.strength.percent", 0);
        local nWeightCarried = DB.getValue(nodeChar, "encumbrance.load", 0);
        local nBaseMove = DB.getValue(nodeChar, "speed.base", 0);
        local nBaseEncOriginal = DB.getValue(nodeChar, "speed.basemodenc", 0);
        local sEncRankOriginal = DB.getValue(nodeChar, "speed.encumbrancerank", "");
        local nBaseEnc = 0; 
        local sEncRank = "Normal";
        
    -- HM4 mod: Different strength spread
      nStrength = (nStrength * 2) - 1; 
      if(nPercent > 50) then
          nStrength = nStrength +1
      end
        
        local nWeightAllowance = DataCommonPO.aStrength[nStrength][3];
        nWeightAllowance = math.floor(nWeightAllowance/10); -- convert the coin weight 1e style to actual pounds

        local nHeavyCarry = 105;
        local nModerateCarry = 70;
        local nNormalCarry = 35;
        
        -- determine if wt carried is greater than a encumbrance rank for strength value
        if (nWeightCarried >= (nHeavyCarry+nWeightAllowance)) then
            nBaseEnc = nBaseMove * nEncHeavy; -- greater than heavy
            sEncRank = "Heavy";
        elseif (nWeightCarried >= (nModerateCarry+nWeightAllowance)) then
            nBaseEnc = nBaseMove * nEncModerate; -- greater than moderate
            sEncRank = "Moderate";
        elseif (nWeightCarried >= (nNormalCarry+nWeightAllowance)) then
            nBaseEnc = nBaseMove * nEncLight; -- greater than light
            sEncRank = "Light";
        else
            nBaseEnc = nBaseMove;
        end
        
        if nBaseMove == nBaseEnc then
            DB.setValue(nodeChar,"speed.basemodenc","number",0);
        else
            nBaseEnc = math.floor(nBaseEnc);
            nBaseEnc = nBaseMove - nBaseEnc;
            if (nBaseEnc < 1) then
                nBaseEnc = 1;
            end
            DB.setValue(nodeChar,"speed.basemodenc","number",nBaseEnc);
        end
        DB.setValue(nodeChar,"speed.encumbrancerank","string",sEncRank);
        if (sEncRankOriginal ~= sEncRank ) then
            local sFormat = Interface.getString("message_encumbrance_changed");
            local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", ""),sEncRank,nBaseEnc);
            ChatManager.SystemMessage(sMsg);
        end
        
    end
end

function calcItemArmorClassOverride(nodeChar)
  local nMainArmorBase = 10;
  local nMainArmorTotal = 0;
  local nMainShieldTotal = 0;
  local bNonCloakArmorWorn  = ItemManager2.isWearingArmorNamed(nodeChar, DataCommonADND.itemArmorNonCloak);
  local bMagicArmorWorn     = ItemManager2.isWearingMagicArmor(nodeChar);
  local bUsingShield        = ItemManager2.isWearingShield(nodeChar);  
  
  for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
    if DB.getValue(vNode, "carried", 0) == 2 then
      local sTypeLower = StringManager.trim(DB.getValue(vNode, "type", "")):lower();
      local sSubtypeLower = StringManager.trim(DB.getValue(vNode, "subtype", "")):lower();
      local bIsArmor, _, _ = ItemManager2.isArmor(vNode);
      local bIsWarding ,_,_ = ItemManager2.isWarding(vNode);
      local bIsShield = (StringManager.contains(DataCommonADND.itemShieldArmorTypes, sSubtypeLower));
      if (not bIsShield) then
        bIsShield = ItemManager2.isShield(vNode);
      end
      local bIsRingOrCloak = (StringManager.contains(DataCommonADND.itemOtherArmorTypes, sSubtypeLower));
      if (not bIsRingOrCloak) then
        bIsRingOrCloak = ItemManager2.isProtectionOther(vNode);
      end
      -- cloaks of protection dont work with magic armor, shields or any armor other than leather.
      if ItemManager2.isItemAnyType("cloak",sTypeLower,sSubtypeLower) and (bNonCloakArmorWorn or bMagicArmorWorn or bUsingShield) then
        bIsRingOrCloak = false;
        bIsArmor = false;
        bIsShield = false;
      end
      -- robe of protection dont work with magic armor, shields or any armor other than leather.
      if ItemManager2.isItemAnyType("robe",sTypeLower,sSubtypeLower) and (bNonCloakArmorWorn or bMagicArmorWorn or bUsingShield) then
        bIsRingOrCloak = false;
        bIsArmor = false;
        bIsShield = false;
      end
      -- rings of protection dont work with any magic armor
      if ItemManager2.isItemAnyType("ring",sTypeLower,sSubtypeLower) and (bMagicArmorWorn) then
        bIsRingOrCloak = false;
        bIsArmor = false;
        bIsShield = false;
      end      
 
      if bIsArmor or bIsWarding or bIsShield or bIsRingOrCloak then
        if bIsShield then
            nMainShieldTotal = nMainShieldTotal + ArmorManagerPO.getAcBase(vNode) + ArmorManagerPO.getMagicAcBonus(vNode);
        elseif bIsRingOrCloak then          
	        -- we only want the "bonus" value for ring/cloaks/robes
            nMainShieldTotal = nMainShieldTotal + ArmorManagerPO.getMagicAcBonus(vNode);
        elseif bIsWarding then
          if bID then
            nMainArmorBase = DB.getValue(vNode, "ac", 0);
          else
            nMainArmorBase = DB.getValue(vNode, "ac", 0);
          end

          if bID then
            nMainArmorTotal = nMainArmorTotal -(DB.getValue(vNode, "bonus", 0));
          else
            nMainArmorTotal = nMainArmorTotal -(DB.getValue(vNode, "bonus", 0));
          end
        elseif bIsArmor then
            nMainArmorBase = ArmorManagerPO.getAcBase(vNode);
          -- convert bonus from +bonus to -bonus to adjust AC down for decending AC
            nMainArmorTotal = nMainArmorTotal - ArmorManagerPO.getMagicAcBonus(vNode);  
        end
      end
    end
  end
  
  -- flip value for decending ac in nMainShieldTotal -celestian
  nMainShieldTotal = -(nMainShieldTotal);
    
  DB.setValue(nodeChar, "defenses.ac.base", "number", nMainArmorBase);
  DB.setValue(nodeChar, "defenses.ac.armor", "number", nMainArmorTotal);
  DB.setValue(nodeChar, "defenses.ac.shield", "number", nMainShieldTotal);
end

function getInventory(nodeChar)
  return DB.getChildren(nodeChar, "inventorylist", {});
end

function getItemsByCarriedState(nodeChar, nCarriedState)
  local aMatchedItems = {};
  for _, nodeItem in pairs(getInventory(nodeChar)) do
      if DB.getValue(nodeItem, "carried", 0) == nCarriedState then
          table.insert(aMatchedItems, nodeItem);
      end
  end
  return aMatchedItems;
end

function getEquippedItems(nodeChar)
  return getItemsByCarriedState(nodeChar, 2);
end