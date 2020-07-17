function onInit()
	super.onInit();
	
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.addHandler(DB.getPath(node, "inventorylist.*.properties"), "onUpdate", updateArmor);
    OptionsManager.registerCallback(PlayerOptionManager.sArmorDamageOptionKey, updateArmor);
	
end

function update()
	super.update();
	local nodeRecord = getDatabaseNode();
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.carried"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
	DB.removeHandler(DB.getPath(nodeRecord, "inventorylist.*.properties"), "onUpdate", updateArmor);
	OptionsManager.unregisterCallback(PlayerOptionManager.sArmorDamageOptionKey, updateArmor);
end

function updateArmor()
	CharManager.calcItemArmorClass(getDatabaseNode());
end