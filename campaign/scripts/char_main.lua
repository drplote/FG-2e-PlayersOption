function onInit()
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.properties"), "onUpdate", updateArmor);
    OptionsManager.registerCallback(PlayerOptionManager.sArmorDamageOptionKey, updateArmor);
    OptionsManager.registerCallback(PlayerOptionManager.sHackmasterStatScaling, updateStatScaling);
    OptionsManager.registerCallback(PlayerOptionManager.sReactionAdjAffectsInit, updateInitiativeScores);	
    OptionsManager.registerCallback(PlayerOptionManager.sFatigueOptionKey, onFatigueOptionChanged);
    DB.addHandler(DB.getPath(node, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
    updateFatigueFactor();
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.properties"), "onUpdate", updateArmor);
	OptionsManager.unregisterCallback(PlayerOptionManager.sArmorDamageOptionKey, updateArmor);
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
end

function updateFatigueFactor()
	Debug.console("updatte fatigue factor called");
	if PlayerOptionManager.isUsingHackmasterFatigue() then
		local nodeChar = getDatabaseNode();
		FatigueManagerPO.updateFatigueFactor(nodeChar);
	end
end

function updateStatScaling()
	super.updateAbilityScores(getDatabaseNode());
	updateInitiativeScores();
end

function updateArmor()
	CharManager.calcItemArmorClass(getDatabaseNode());
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