function onInit()
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.properties"), "onUpdate", updateArmor);
    OptionsManager.registerCallback(PlayerOptionManager.sArmorDamageOptionKey, updateArmor);
    OptionsManager.registerCallback(PlayerOptionManager.sHackmasterStatScaling, updateStatScaling);
    OptionsManager.registerCallback(PlayerOptionManager.sReactionAdjAffectsInit, updateInitiativeScores);
	
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.properties"), "onUpdate", updateArmor);
	OptionsManager.unregisterCallback(PlayerOptionManager.sArmorDamageOptionKey, updateArmor);
	OptionsManager.unregisterCallback(PlayerOptionManager.sHackmasterStatScaling, updateStatScaling);
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