function onInit()
    update();
end

function update()
    super.update();

    local nodeRecord = getDatabaseNode();
    local bShouldShowArmorDamage = ItemManager2.isArmor(nodeRecord) and PlayerOptionManager.isUsingArmorDamage();
    local bArmor = ItemManager2.isArmor(nodeRecord);
    local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
    local bID = LibraryData.getIDState("item", nodeRecord);

    updateControl("hpLost", bReadOnly, bID and bShouldShowArmorDamage);
    label_hp_lost.setVisible(bShouldShowArmorDamage);
    hpLost.setVisible(bShouldShowArmorDamage);

end
