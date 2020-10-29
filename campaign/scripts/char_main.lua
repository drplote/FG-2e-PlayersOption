function onInit()
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.properties"), "onUpdate", updateArmor);
    OptionsManager.registerCallback(PlayerOptionManager.sArmorDamageOptionKey, onArmorDamageOptionChanged);
    OptionsManager.registerCallback(PlayerOptionManager.sHackmasterStatScaling, updateStatScaling);
    OptionsManager.registerCallback(PlayerOptionManager.sReactionAdjAffectsInit, updateInitiativeScores);	
    OptionsManager.registerCallback(PlayerOptionManager.sFatigueOptionKey, onFatigueOptionChanged);
    DB.addHandler(DB.getPath(node, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
    updateFatigueFactor();
    updateArmor();
    setPlayerOptionControlVisibility();
end

function setPlayerOptionControlVisibility()
	setArmorDamageVisibility(PlayerOptionManager.isUsingArmorDamage());
	setFatigueVisibility(PlayerOptionManager.isUsingHackmasterFatigue());
end

function setArmorDamageVisibility(bShow)
	repair_armor_button.setVisible(bShow);
	current_armor_damage.setVisible(bShow);
	current_armor_damage_label.setVisible(bShow);
	damage_armor_button.setVisible(bShow);
	current_ac_loss.setVisible(bShow);
	current_ac_loss_label.setVisible(bShow);
	armor_description.setVisible(bShow);
	repair_shield_button.setVisible(bShow);
	current_shield_damage.setVisible(bShow);
	damage_shield_button.setVisible(bShow);
	current_shield_loss.setVisible(bShow);
	current_shield_loss_label.setVisible(bShow);
	shield_description.setVisible(bShow);
end

function setFatigueVisibility(bShow)
	fatigue_factor.setVisible(bShow);
	fatigue_factor_label.setVisible(bShow);
	add_fatigue_button.setVisible(bShow);
	current_fatigue.setVisible(bShow);
	current_fatigue_label.setVisible(bShow);
	remove_fatigue_button.setVisible(bShow);
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.properties"), "onUpdate", updateArmor);
	OptionsManager.unregisterCallback(PlayerOptionManager.sArmorDamageOptionKey, onArmorDamageOptionChanged);
	OptionsManager.unregisterCallback(PlayerOptionManager.sHackmasterStatScaling, updateStatScaling);
  	DB.removeHandler(DB.getPath(nodeRecord, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
  	OptionsManager.unregisterCallback(PlayerOptionManager.sFatigueOptionKey, onFatigueOptionChanged);
end

function updateAbilityScores(node)
	super.updateAbilityScores(node);
	FatigueManagerPO.updateFatigueFactor(node);
end

function onFatigueOptionChanged()
	updateAbilityScores(getDatabaseNode());
	setPlayerOptionControlVisibility();
end

function updateFatigueFactor()
	if PlayerOptionManager.isUsingHackmasterFatigue() then
		local nodeChar = getDatabaseNode();
		FatigueManagerPO.updateFatigueFactor(nodeChar);
		onFatigueChanged();
	end
end

function updateStatScaling()
	super.updateAbilityScores(getDatabaseNode());
	updateInitiativeScores();
end

function onArmorDamageOptionChanged()
	updateArmor();
	setPlayerOptionControlVisibility();
end

function updateArmor()
	CharManager.calcItemArmorClass(getDatabaseNode());
	updateArmorDamageDisplay();
	updateShieldDamageDisplay()
end

function updateInitiativeScores()
	super.updateInitiativeScores();
	if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() then
		local nodeChar = getDatabaseNode();
	  	local nInitTotal = DB.getValue(nodeChar, "initiative.total", 0);
	  	local nReactionAdj = 0 - DB.getValue(nodeChar, "abilities.dexterity.reactionadj", 0);
	  	DB.setValue(nodeChar, "initiative.total", "number", nInitTotal + nReactionAdj);
	end
end

function decreaseFatigue()
	FatigueManagerPO.decreaseFatigue(getDatabaseNode());
end

function increaseFatigue()
	FatigueManagerPO.increaseFatigue(getDatabaseNode());
end

function onFatigueChanged()
	local nodeChar = getDatabaseNode();
	local nFatigueFactor = FatigueManagerPO.getFatigueFactor(nodeChar);
	local nCurrentFatigue = FatigueManagerPO.getCurrentFatigue(nodeChar);

	local sColor = ColorManager.COLOR_FULL;
	if nCurrentFatigue > nFatigueFactor then
		sColor = ColorManager.COLOR_TOKEN_HEALTH_HVY_WOUNDS;
	elseif nCurrentFatigue > 0 then
		sColor = ColorManager.COLOR_HEALTH_LT_WOUNDS;
	end

	current_fatigue.setColor(sColor);
end

function updateShieldDamageDisplay()
	if PlayerOptionManager.isUsingArmorDamage() then 
		local nodeItem = getWornShield();
		local sColor = ColorManager.COLOR_FULL;
		if nodeItem then
			local nHpLost = ArmorManagerPO.getHpLost(nodeItem);
			current_shield_damage.setValue(nHpLost);
			current_shield_loss.setValue(ArmorManagerPO.getAcLostFromDamage(nodeItem));
			shield_description.setValue(ItemManagerPO.getItemNameForPlayer(nodeItem));
			if ArmorManagerPO.isBroken(nodeItem) then
				sColor = ColorManager.COLOR_HEALTH_CRIT_WOUNDS;
			elseif nHpLost > 0 then
				sColor = ColorManager.COLOR_HEALTH_LT_WOUNDS;
			end
		else
			current_shield_damage.setValue(0);
			current_shield_loss.setValue(0);
			shield_description.setValue("No Shield Equipped");
		end
		current_shield_damage.setColor(sColor);
	end
end

function updateArmorDamageDisplay()
	if PlayerOptionManager.isUsingArmorDamage() then
		local nodeItem = getWornArmor();
		local sColor = ColorManager.COLOR_FULL;
		if nodeItem then
			local nHpLost = ArmorManagerPO.getHpLost(nodeItem);
			current_armor_damage.setValue(nHpLost);
			current_ac_loss.setValue(ArmorManagerPO.getAcLostFromDamage(nodeItem));
			armor_description.setValue(ItemManagerPO.getItemNameForPlayer(nodeItem));
			if ArmorManagerPO.isBroken(nodeItem) then
				sColor = ColorManager.COLOR_HEALTH_CRIT_WOUNDS;
			elseif nHpLost > 0 then
				sColor = ColorManager.COLOR_HEALTH_LT_WOUNDS;
			end
		else
			current_armor_damage.setValue(0);
			current_ac_loss.setValue(0);
			armor_description.setValue("No Armor Equipped");
		end
		current_armor_damage.setColor(sColor);
	end
end

function getWornShield()
	return ArmorManagerPO.getDamageableShieldWorn(getDatabaseNode());
end

function getWornArmor()
	return ArmorManagerPO.getDamageableArmorWorn(getDatabaseNode());
end

function damageShield()
	ArmorManagerPO.damageArmor(getWornShield(), 1);
end

function repairShield()
	ArmorManagerPO.repairArmor(getWornShield(), 1);
end

function damageArmor()
	ArmorManagerPO.damageArmor(getWornArmor(), 1);
end

function repairArmor()
	ArmorManagerPO.repairArmor(getWornArmor(), 1);
end