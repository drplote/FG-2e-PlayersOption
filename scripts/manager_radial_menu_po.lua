function onInit()
end

function initAttackMenu(control)
	control.resetMenuItems();

	control.registerMenuItem(Interface.getString("standardAttack"), "standardAttackIcon", 1);
	control.registerMenuItem(Interface.getString("rearAttackModifier"), "rearAttackModifierIcon", 2);
	control.registerMenuItem(Interface.getString("touchAttackModifier"), "touchAttackModifierIcon", 3);

	control.registerMenuItem(Interface.getString("modifier_label_calledshot"), "calledShotIcon", 4);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_torso"), "calledShotTorsoIcon", 4, 1);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_head"), "calledShotHeadIcon", 4, 2);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_arm"), "calledShotArmIcon", 4, 3);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_leg"), "calledShotLegIcon", 4, 4);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_abdomen"), "calledShotAbdomenIcon", 4, 5);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_neck"), "calledShotNeckIcon", 4, 6);

	control.registerMenuItem(Interface.getString("concealment_radial_menuitem"), "concealmentIcon", 5);
	control.registerMenuItem(Interface.getString("conceal_25_radial_menuitem"), "25percentIcon", 5, 3);
	control.registerMenuItem(Interface.getString("conceal_50_radial_menuitem"), "50percentIcon", 5, 4);
	control.registerMenuItem(Interface.getString("conceal_75_radial_menuitem"), "75percentIcon", 5, 5);
	control.registerMenuItem(Interface.getString("conceal_90_radial_menuitem"), "90percentIcon", 5, 6);

	control.registerMenuItem(Interface.getString("cover_radial_menuitem"), "coverIcon", 6);
	control.registerMenuItem(Interface.getString("cover_25_radial_menuitem"), "25percentIcon", 6, 3);
	control.registerMenuItem(Interface.getString("cover_50_radial_menuitem"), "50percentIcon", 6, 4);
	control.registerMenuItem(Interface.getString("cover_75_radial_menuitem"), "75percentIcon", 6, 5);
	control.registerMenuItem(Interface.getString("cover_90_radial_menuitem"), "90percentIcon", 6, 6);

	control.registerMenuItem(Interface.getString("noDexAttackModifier"), "noDexAttackModifierIcon", 7);
	control.registerMenuItem(Interface.getString("noShieldAttackModifier"), "noShieldAttackModifierIcon", 8);
end

function onAttackMenuSelection(control, selection, subselection)

	function attackWithModifier(sModifierKey)
		if sModifierKey then
			ModifierStack.setModifierKey(sModifierKey, true);
		end
		control.window.onAttackAction();
	end

	if selection == 1 then
		attackWithModifier();
	elseif selection == 2 then
		attackWithModifier("ATK_FROMREAR");
	elseif selection == 3 then
		attackWithModifier("ATK_IGNORE_ARMOR");
	elseif selection == 4 and subselection == 1 then
		attackWithModifier("CALLEDSHOT_TORSO");
	elseif selection == 4 and subselection == 2 then
		attackWithModifier("CALLEDSHOT_HEAD");
	elseif selection == 4 and subselection == 3 then
		attackWithModifier("CALLEDSHOT_ARM");
	elseif selection == 4 and subselection == 4 then
		attackWithModifier("CALLEDSHOT_LEG");
	elseif selection == 4 and subselection == 5 then
		attackWithModifier("CALLEDSHOT_ABDOMEN");
	elseif selection == 4 and subselection == 6 then
		attackWithModifier("CALLEDSHOT_HEAD");
	elseif selection == 5 and subselection == 3 then
		attackWithModifier("DEF_CONCEAL_25");
	elseif selection == 5 and subselection == 4 then
		attackWithModifier("DEF_CONCEAL_50");
	elseif selection == 5 and subselection == 5 then
		attackWithModifier("DEF_CONCEAL_75");
	elseif selection == 5 and subselection == 6 then
		attackWithModifier("DEF_CONCEAL_90");
	elseif selection == 6 and subselection == 3 then
		attackWithModifier("DEF_COVER_25");
	elseif selection == 6 and subselection == 4 then
		attackWithModifier("DEF_COVER_50");
	elseif selection == 6 and subselection == 5 then
		attackWithModifier("DEF_COVER_75");
	elseif selection == 6 and subselection == 6 then
		attackWithModifier("DEF_COVER_90");
	elseif selection == 7 then
		attackWithModifier("ATK_SHIELDLESS");
	elseif selection == 8 then
		attackWithModifier("ATK_NODEXTERITY")
	end
end

function initDelayMenu(control)
    control.resetMenuItems();
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		control.registerMenuItem(Interface.getString("delay10_menuitem"), "delayTurn10ButtonIcon", 1);
		control.registerMenuItem(Interface.getString("delay1_menuitem"), "delayTurn1ButtonIcon", 2);
		control.registerMenuItem(Interface.getString("delay2_menuitem"), "delayTurn2ButtonIcon", 3);
		control.registerMenuItem(Interface.getString("delay3_menuitem"), "delayTurn3ButtonIcon", 4);
		control.registerMenuItem(Interface.getString("delay4_menuitem"), "delayTurn4ButtonIcon", 5);
		control.registerMenuItem(Interface.getString("delay5_menuitem"), "delayTurn5ButtonIcon", 6);
		control.registerMenuItem(Interface.getString("delay6_menuitem"), "delayTurn6ButtonIcon", 7);
		control.registerMenuItem(Interface.getString("delay7plus_menuitem"), "delayTurnButtonIcon", 8);
		control.registerMenuItem(Interface.getString("delay7_menuitem"), "delayTurn7ButtonIcon", 8, 1);
		control.registerMenuItem(Interface.getString("delay8_menuitem"), "delayTurn8ButtonIcon", 8, 2);
		control.registerMenuItem(Interface.getString("delay9_menuitem"), "delayTurn9ButtonIcon", 8, 3);
	end
end

function onDelayMenuSelection(control, selection, subselection)
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		local nodeChar = control.window.getDatabaseNode();
		if selection == 1 then
			control.action();
		elseif selection == 2 then
			InitManagerPO.tryDelayActor(nodeChar, 1);
		elseif selection == 3 then
			InitManagerPO.tryDelayActor(nodeChar, 2);
		elseif selection == 4 then
			InitManagerPO.tryDelayActor(nodeChar, 3);
		elseif selection == 5 then
			InitManagerPO.tryDelayActor(nodeChar, 4);
		elseif selection == 6 then
			InitManagerPO.tryDelayActor(nodeChar, 5);
		elseif selection == 7 then
			InitManagerPO.tryDelayActor(nodeChar, 6);
		elseif selection == 8 and subselection == 1 then
			InitManagerPO.tryDelayActor(nodeChar, 7);
		elseif selection == 8 and subselection == 2 then
		 	InitManagerPO.tryDelayActor(nodeChar, 8);
		elseif selection == 8 and subselection == 3 then
			InitManagerPO.tryDelayActor(nodeChar, 9);
		end
	else
		control.super.onMenuSelection(selection, subselection);
	end
end