local fCalcItemArmorClass;

function onInit()
	fCalcItemArmorClass = CharManager.calcItemArmorClass;
	CharManager.calcItemArmorClass = calcItemArmorClassOverride;
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
 
      if bIsArmor or bIsShield or bIsRingOrCloak then
        if bIsShield then
            nMainShieldTotal = nMainShieldTotal + ArmorManagerPO.getAcBase(vNode) + ArmorManagerPO.getMagicAcBonus(vNode);
        elseif bIsRingOrCloak then          
	        -- we only want the "bonus" value for ring/cloaks/robes
            nMainShieldTotal = nMainShieldTotal + ArmorManagerPO.getMagicAcBonus(vNode);
        else
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