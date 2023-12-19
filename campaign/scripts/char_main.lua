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
    OptionsManager.registerCallback(PlayerOptionManager.sAddComeliness, onComelinessOptionChanged);
    OptionsManager.registerCallback(PlayerOptionManager.sEnableHonor, onHonorOptionChanged);
    DB.addHandler(DB.getPath(node, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.percentbase"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.percentbasemod"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.percentadjustment"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.percenttempmod"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.base"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.basemod"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.adjustment"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.comeliness.tempmod"), "onUpdate", updateComeliness);
    DB.addHandler(DB.getPath(node, "abilities.honor.score"), "onUpdate", updateHonor);
    DB.addHandler(DB.getPath(node, "classes.*.level"), "onUpdate", updateHonor);
    updateComeliness(node);
    updateFatigueFactor();
    updateArmor();
    setPlayerOptionControlVisibility();
end

function onClose()
    local nodeChar = getDatabaseNode();
    DB.removeHandler(DB.getPath(nodeChar, "abilities.honor.score"), "onUpdate", updateHonor);
    DB.removeHandler(DB.getPath(nodeChar, "classes.*.level"), "onUpdate", updateHonor);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentbase"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentbasemod"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percentadjustment"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.percenttempmod"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.base"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.basemod"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.adjustment"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.comeliness.tempmod"), "onUpdate", updateComeliness);
    DB.removeHandler(DB.getPath(nodeChar, "abilities.honor.score"), "onUpdate", updateHonor);
    DB.removeHandler(DB.getPath(nodeChar, "fatigue.multiplier"), "onUpdate", updateFatigueFactor);
    DB.removeHandler(DB.getPath(nodeChar, "inventorylist.*.carried"), "onUpdate", updateArmor);
    DB.removeHandler(DB.getPath(nodeChar, "inventorylist.*.hpLost"), "onUpdate", updateArmor);
    DB.removeHandler(DB.getPath(nodeChar, "inventorylist.*.properties"), "onUpdate", updateArmor);
    OptionsManager.unregisterCallback(PlayerOptionManager.sArmorDamageOptionKey, onArmorDamageOptionChanged);
    OptionsManager.unregisterCallback(PlayerOptionManager.sHackmasterStatScaling, updateStatScaling);
    OptionsManager.unregisterCallback(PlayerOptionManager.sFatigueOptionKey, onFatigueOptionChanged);
    OptionsManager.unregisterCallback(PlayerOptionManager.sAddComeliness, onComelinessOptionChanged);
    OptionsManager.unregisterCallback(PlayerOptionManager.sEnableHonor, onHonorOptionChanged);
    super.onClose();
end

function updateHonor(node)
    local nodeChar = node.getChild("....");
    if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
        nodeChar = node;
    end
    AbilityScorePO.updateHonor(nodeChar);
end

function setPlayerOptionControlVisibility()
    local bIsUsingArmorDamage = PlayerOptionManager.isUsingArmorDamage();
    local bIsUsingFatigue = PlayerOptionManager.isUsingHackmasterFatigue();
    local bIsComelinessEnabled = PlayerOptionManager.isComelinessEnabled();
    local bIsHonorEnabled = PlayerOptionManager.isHonorEnabled();
    setArmorDamageVisibility(bIsUsingArmorDamage);
    setFatigueVisibility(bIsUsingFatigue);
    setComelinessVisibility(bIsComelinessEnabled);
    setHonorVisibility(bIsHonorEnabled);

    local nOffsetAmount = 0;
    if bIsComelinessEnabled then
        nOffsetAmount = nOffsetAmount + 36;
    end
    if bIsHonorEnabled then
        nOffsetAmount = nOffsetAmount + 45;
    end
    combattitle.setAnchor("top", "charisma", "bottom", "relative", 15 + nOffsetAmount);
    combatanchor.setAnchor("top", "combattitle", "bottom", "relative", 15);
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

function setComelinessVisibility(bShow)
    comeliness.setVisible(bShow);
    com_label.setVisible(bShow);
    com_label_actual.setVisible(bShow);
    comdetailframe.setVisible(bShow);
    comeliness_percent.setVisible(bShow);
    com_percent_label.setVisible(bShow);
    comeliness_effects.setVisible(bShow);
    comeliness_effects_label.setVisible(bShow);
end

function setHonorVisibility(bShow)
    honor.setVisible(bShow);
    hon_label.setVisible(bShow);
    honor_label_actual.setVisible(bShow);
    hondetailframe.setVisible(bShow);
    honor_temp.setVisible(bShow);
    hon_temp_label.setVisible(bShow);
    honor_dice.setVisible(bShow);
    honor_dice_label.setVisible(bShow);
    honor_window.setVisible(bShow);
    honor_window_label.setVisible(bShow);
end

function updateAbilityScores(node)
    super.updateAbilityScores(node);

    FatigueManagerPO.updateFatigueFactor(node);
end

function updateComeliness(node)
    local nodeChar = node.getChild("....");
    -- onInit doesn't have the same path for node, so we check here so first time
    -- load works.
    if (nodeChar == nil and node.getPath():match("^charsheet%.id%-%d+$")) then
        nodeChar = node;
    end
    local dbAbility = AbilityScorePO.updateComeliness(nodeChar);
    -- set tooltip for this because it's just to big for the abilities pane
    comeliness_effects.setTooltipText(dbAbility.effects_TT);
end

function onFatigueOptionChanged()
    updateAbilityScores(getDatabaseNode());
    setPlayerOptionControlVisibility();
end

function onComelinessOptionChanged()
    setPlayerOptionControlVisibility();
end

function onHonorOptionChanged()
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
    local nodeChar = getDatabaseNode();
    FatigueManagerPO.increaseFatigue(nodeChar);
    local nFatigue = StateManagerPO.getFatigueState(nodeChar);
    if nFatigue == 0 then
        StateManagerPO.setFatigueState(nodeChar, 1);
    end
end

function onFatigueChanged()
    local nodeChar = getDatabaseNode();
    local nFatigueFactor = ActorManagerPO.getFatigueFactor(nodeChar);
    local nCurrentFatigue = ActorManagerPO.getCurrentFatigue(nodeChar);

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
