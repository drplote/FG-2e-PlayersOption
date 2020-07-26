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
    DB.addHandler(DB.getPath(nodeChar, "abilities.*.fatiguemod"), "onUpdate", super.updateAbilityScores);
    DB.addHandler(DB.getPath(nodeChar, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
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
	DB.removeHandler(DB.getPath(nodeChar, "abilities.*.fatiguemod"), "onUpdate", super.updateAbilityScores);
  	DB.removeHandler(DB.getPath(nodeChar, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
  	OptionsManager.unregisterCallback(PlayerOptionManager.sFatigueOptionKey, onFatigueOptionChanged);
end

function onFatigueOptionChanged()
	AbilityScoreADND.detailsUpdate(getDatabaseNode());
end

function onFatigueChanged()
	local node = getDatabaseNode();
	updateFatigueScore(node);
end

function updateFatigueFactor()
	if PlayerOptionManager.isUsingHackmasterFatigue() then
		local nodeChar = getDatabaseNode();
		FatigueManagerPO.updateFatigueFactor(nodeChar);
	end
end

function updateFatigueScore(node)
  local nodeChar = node.getChild("....");
  if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
    nodeChar = node;
  end
  FatigueManagerPO.updateFatigue(nodeChar);
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