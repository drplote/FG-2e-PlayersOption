function onInit()
end

function initPlayerInitMenu(control)
	control.resetMenuItems();
	
	control.registerMenuItem(Interface.getString("additional_attack_menuitem"), "attackRateIcon", 2);

	control.registerMenuItem(Interface.getString("rate_of_fire_menuitem"), "rateOfFireIcon", 3);
	control.registerMenuItem(Interface.getString("rate_of_fire_1_menuitem"), "oneIcon", 3, 1);
	control.registerMenuItem(Interface.getString("rate_of_fire_2_menuitem"), "twoIcon", 3, 2);
	control.registerMenuItem(Interface.getString("rate_of_fire_3_menuitem"), "threeIcon", 3, 3);
	control.registerMenuItem(Interface.getString("rate_of_fire_4_menuitem"), "fourIcon", 3, 4);
	control.registerMenuItem(Interface.getString("rate_of_fire_5_menuitem"), "fiveIcon", 3, 5);

end

function onPlayerInitMenuSelection(control, selection, subselection, sub2selection)
	if selection == 2 then
		control.performAdditionalInitAction("ADDITIONAL_ATTACK");
	elseif selection == 3 and subselection == 1 then
		control.performFixedSequenceInitAction(1);
	elseif selection == 3 and subselection == 2 then
		control.performFixedSequenceInitAction(2);
	elseif selection == 3 and subselection == 3 then
		control.performFixedSequenceInitAction(3);
	elseif selection == 3 and subselection == 4 then
		control.performFixedSequenceInitAction(4);
	elseif selection == 3 and subselection == 5 then
		control.performFixedSequenceInitAction(5);
	end
end

function initAttackMenu(control)
	control.resetMenuItems();

	control.registerMenuItem(Interface.getString("standardAttack"), "standardAttackIcon", 1);
	control.registerMenuItem(Interface.getString("defenderModifiers"), "defenderModifiersIcon", 2);
	control.registerMenuItem(Interface.getString("rearAttackModifier"), "rearAttackModifierIcon", 2, 1);
	control.registerMenuItem(Interface.getString("touchAttackModifier"), "touchAttackModifierIcon", 2, 2);
	control.registerMenuItem(Interface.getString("noDexAttackModifier"), "noDexAttackModifierIcon", 2, 3);
	control.registerMenuItem(Interface.getString("noShieldAttackModifier"), "noShieldAttackModifierIcon", 2, 4);
	control.registerMenuItem(Interface.getString("chargeAttackModifier"), "chargeAttackModifierIcon", 2, 8);

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

	if PlayerOptionManager.isAllowingPlayerCheaterDice() then
		control.registerMenuItem(Interface.getString("cheater_dice_menuitem"), "cheaterDiceSubmenuIcon", 8);
		control.registerMenuItem(Interface.getString("roll_20_menuitem"), "nat20Icon", 8, 2);
		control.registerMenuItem(Interface.getString("roll_1_menuitem"), "nat1Icon", 8, 8);
	else
		control.registerMenuItem("", "blankIcon", 8);
	end
	
end

function onAttackMenuSelection(control, selection, subselection)
	if selection == 1 then
		control.performAttackAction();
	elseif selection == 2 and subselection == 1 then
		control.performAttackAction("ATK_FROMREAR");
	elseif selection == 2 and subselection == 2 then
		control.performAttackAction("ATK_IGNORE_ARMOR");
	elseif selection == 2 and subselection == 3 then
		control.performAttackAction("ATK_NODEXTERITY");
	elseif selection == 2 and subselection == 4 then
		control.performAttackAction("ATK_SHIELDLESS")
	elseif selection == 2 and subselection == 8 then
		control.performChargeAction();
	elseif selection == 4 and subselection == 1 then
		control.performAttackAction("CALLEDSHOT_TORSO");
	elseif selection == 4 and subselection == 2 then
		control.performAttackAction("CALLEDSHOT_HEAD");
	elseif selection == 4 and subselection == 3 then
		control.performAttackAction("CALLEDSHOT_ARM");
	elseif selection == 4 and subselection == 4 then
		control.performAttackAction("CALLEDSHOT_LEG");
	elseif selection == 4 and subselection == 5 then
		control.performAttackAction("CALLEDSHOT_ABDOMEN");
	elseif selection == 4 and subselection == 6 then
		control.performAttackAction("CALLEDSHOT_NECK");
	elseif selection == 5 and subselection == 3 then
		control.performAttackAction("DEF_CONCEAL_25");
	elseif selection == 5 and subselection == 4 then
		control.performAttackAction("DEF_CONCEAL_50");
	elseif selection == 5 and subselection == 5 then
		control.performAttackAction("DEF_CONCEAL_75");
	elseif selection == 5 and subselection == 6 then
		control.performAttackAction("DEF_CONCEAL_90");
	elseif selection == 6 and subselection == 3 then
		control.performAttackAction("DEF_COVER_25");
	elseif selection == 6 and subselection == 4 then
		control.performAttackAction("DEF_COVER_50");
	elseif selection == 6 and subselection == 5 then
		control.performAttackAction("DEF_COVER_75");
	elseif selection == 6 and subselection == 6 then
		control.performAttackAction("DEF_COVER_90");
	elseif selection == 8 and subselection == 2 then
		control.performAttackAction("ATK_NAT_20");
	elseif selection == 8 and subselection == 8 then
		control.performAttackAction("ATK_NAT_1");
	end
end

function initCombatTrackerActionMenu(control)

	control.registerMenuItem(Interface.getString("additional_attack_menuitem"), "attackRateIcon", 2);

	control.registerMenuItem(Interface.getString("attack_submenu_menuitem"), "attackSubmenuIcon", 3);

	control.registerMenuItem(Interface.getString("standardAttack"), "standardAttackIcon", 3, 1);
	control.registerMenuItem(Interface.getString("defenderModifiers"), "defenderModifiersIcon", 3, 2);
	control.registerMenuItem(Interface.getString("rearAttackModifier"), "rearAttackModifierIcon", 3, 2, 1);
	control.registerMenuItem(Interface.getString("touchAttackModifier"), "touchAttackModifierIcon", 3, 2, 2);
	control.registerMenuItem(Interface.getString("noDexAttackModifier"), "noDexAttackModifierIcon", 3, 2, 3);
	control.registerMenuItem(Interface.getString("noShieldAttackModifier"), "noShieldAttackModifierIcon", 3, 2, 4);
	control.registerMenuItem(Interface.getString("chargeAttackModifier"), "chargeAttackModifierIcon", 3, 2, 8);

	control.registerMenuItem(Interface.getString("modifier_label_calledshot"), "calledShotIcon", 3, 4);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_torso"), "calledShotTorsoIcon", 3, 4, 1);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_head"), "calledShotHeadIcon", 3, 4, 2);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_arm"), "calledShotArmIcon", 3, 4, 3);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_leg"), "calledShotLegIcon", 3, 4, 4);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_abdomen"), "calledShotAbdomenIcon", 3, 4, 5);
	control.registerMenuItem(Interface.getString("modifier_label_calledshot_neck"), "calledShotNeckIcon", 3, 4, 6);

	control.registerMenuItem(Interface.getString("concealment_radial_menuitem"), "concealmentIcon", 3, 5);
	control.registerMenuItem(Interface.getString("conceal_25_radial_menuitem"), "25percentIcon", 3, 5, 3);
	control.registerMenuItem(Interface.getString("conceal_50_radial_menuitem"), "50percentIcon", 3, 5, 4);
	control.registerMenuItem(Interface.getString("conceal_75_radial_menuitem"), "75percentIcon", 3, 5, 5);
	control.registerMenuItem(Interface.getString("conceal_90_radial_menuitem"), "90percentIcon", 3, 5, 6);

	control.registerMenuItem(Interface.getString("cover_radial_menuitem"), "coverIcon", 3, 6);
	control.registerMenuItem(Interface.getString("cover_25_radial_menuitem"), "25percentIcon", 3, 6, 3);
	control.registerMenuItem(Interface.getString("cover_50_radial_menuitem"), "50percentIcon", 3, 6, 4);
	control.registerMenuItem(Interface.getString("cover_75_radial_menuitem"), "75percentIcon", 3, 6, 5);
	control.registerMenuItem(Interface.getString("cover_90_radial_menuitem"), "90percentIcon", 3, 6, 6);

	control.registerMenuItem(Interface.getString("cheater_dice_menuitem"), "cheaterDiceSubmenuIcon", 3, 8);
	control.registerMenuItem(Interface.getString("roll_20_menuitem"), "nat20Icon", 3, 8, 2);
	control.registerMenuItem(Interface.getString("roll_1_menuitem"), "nat1Icon", 3, 8, 8);

	control.registerMenuItem(Interface.getString("rate_of_fire_menuitem"), "rateOfFireIcon", 4);
	control.registerMenuItem(Interface.getString("rate_of_fire_1_menuitem"), "oneIcon", 4, 1);
	control.registerMenuItem(Interface.getString("rate_of_fire_2_menuitem"), "twoIcon", 4, 2);
	control.registerMenuItem(Interface.getString("rate_of_fire_3_menuitem"), "threeIcon", 4, 3);
	control.registerMenuItem(Interface.getString("rate_of_fire_4_menuitem"), "fourIcon", 4, 4);
	control.registerMenuItem(Interface.getString("rate_of_fire_5_menuitem"), "fiveIcon", 4, 5);

	control.registerMenuItem(Interface.getString("attack_rate_menuitem"), "attackRateIcon", 5);
	control.registerMenuItem(Interface.getString("attack_rate_1_menuitem"), "oneIcon", 5, 2);
	control.registerMenuItem(Interface.getString("attack_rate_2_menuitem"), "twoIcon", 5, 3);
	control.registerMenuItem(Interface.getString("attack_rate_3_menuitem"), "threeIcon", 5, 4);
	control.registerMenuItem(Interface.getString("attack_rate_4_menuitem"), "fourIcon", 5, 5);
	control.registerMenuItem(Interface.getString("attack_rate_5_menuitem"), "fiveIcon", 5, 6);

	if not PlayerOptionManager.isUsingPhasedInitiative() then
		control.registerMenuItem(Interface.getString("actor_init_menuitem"), "standardInitIcon", 8);
		control.registerMenuItem(Interface.getString("standard_init_menuitem"), "standardInitIcon", 8, 1);
		control.registerMenuItem(Interface.getString("first_init_menuitem"), "firstInitIcon", 8, 2);
		control.registerMenuItem(Interface.getString("clone_group_init_menuitem"), "cloneIcon", 8, 3);

		control.registerMenuItem(Interface.getString("delay_submenu_menuitem"), "delayTurnButtonIcon", 8, 5);
		control.registerMenuItem(Interface.getString("delay10_menuitem"), "delayTurn10ButtonIcon", 8, 5, 2);
		control.registerMenuItem(Interface.getString("delay1_menuitem"), "delayTurn1ButtonIcon", 8, 5, 3);
		control.registerMenuItem(Interface.getString("delay2_menuitem"), "delayTurn2ButtonIcon", 8, 5, 4);
		control.registerMenuItem(Interface.getString("delay3_menuitem"), "delayTurn3ButtonIcon", 8, 5, 5);
		control.registerMenuItem(Interface.getString("delay4_menuitem"), "delayTurn4ButtonIcon", 8, 5, 6);
		control.registerMenuItem(Interface.getString("delay5_menuitem"), "delayTurn5ButtonIcon", 8, 5, 7);
		control.registerMenuItem(Interface.getString("delay6plus_menuitem"), "delayTurnButtonIcon", 8, 5, 8);
		control.registerMenuItem(Interface.getString("delay6_menuitem"), "delayTurn6ButtonIcon", 8, 5, 8, 8);
		control.registerMenuItem(Interface.getString("delay7_menuitem"), "delayTurn7ButtonIcon", 8, 5, 8, 1);
		control.registerMenuItem(Interface.getString("delay8_menuitem"), "delayTurn8ButtonIcon", 8, 5, 8, 2);
		control.registerMenuItem(Interface.getString("delay9_menuitem"), "delayTurn9ButtonIcon", 8, 5, 8, 3);

		control.registerMenuItem(Interface.getString("roll_group_init_menuitem"), "rollDiceIcon", 8, 7);

		if PlayerOptionManager.isUsingHackmasterInitiative() then
			control.registerMenuItem(Interface.getString("last_init_menuitem"), "lastInitHmIcon", 8, 8);
		else
			control.registerMenuItem(Interface.getString("last_init_menuitem"), "lastInitIcon", 8, 8);
		end
	end

end

function onCombatTrackerActionMenuSelection(control, selection, subselection, sub2selection)

	if selection == 2 then
		control.performInitAction("ADDITIONAL_ATTACK");
	elseif selection == 3 then
		if subselection == 1 then
			control.performAttackAction();
		elseif subselection == 2 and sub2selection == 1 then
			control.performAttackAction("ATK_FROMREAR");
		elseif subselection == 2 and sub2selection == 2 then
			control.performAttackAction("ATK_IGNORE_ARMOR");
		elseif subselection == 2 and sub2selection == 3 then
			control.performAttackAction("ATK_NODEXTERITY");
		elseif subselection == 2 and sub2selection == 4 then
			control.performAttackAction("ATK_SHIELDLESS");
		elseif subselection == 2 and sub2selection == 8 then
			control.performChargeAction();
		elseif subselection == 4 and sub2selection == 1 then
			control.performAttackAction("CALLEDSHOT_TORSO");
		elseif subselection == 4 and sub2selection == 2 then
			control.performAttackAction("CALLEDSHOT_HEAD");
		elseif subselection == 4 and sub2selection == 3 then
			control.performAttackAction("CALLEDSHOT_ARM");
		elseif subselection == 4 and sub2selection == 4 then
			control.performAttackAction("CALLEDSHOT_LEG");
		elseif subselection == 4 and sub2selection == 5 then
			control.performAttackAction("CALLEDSHOT_ABDOMEN");
		elseif subselection == 4 and sub2selection == 6 then
			control.performAttackAction("CALLEDSHOT_NECK");
		elseif subselection == 5 and sub2selection == 3 then
			control.performAttackAction("DEF_CONCEAL_25");
		elseif subselection == 5 and sub2selection == 4 then
			control.performAttackAction("DEF_CONCEAL_50");
		elseif subselection == 5 and sub2selection == 5 then
			control.performAttackAction("DEF_CONCEAL_75");
		elseif subselection == 5 and sub2selection == 6 then
			control.performAttackAction("DEF_CONCEAL_90");
		elseif subselection == 6 and sub2selection == 3 then
			control.performAttackAction("DEF_COVER_25");
		elseif subselection == 6 and sub2selection == 4 then
			control.performAttackAction("DEF_COVER_50");
		elseif subselection == 6 and sub2selection == 5 then
			control.performAttackAction("DEF_COVER_75");
		elseif subselection == 6 and sub2selection == 6 then
			control.performAttackAction("DEF_COVER_90");
		elseif subselection == 8 and sub2selection == 2 then
			control.performAttackAction("ATK_NAT_20");
		elseif subselection == 8 and sub2selection == 8 then
			control.performAttackAction("ATK_NAT_1");
		end
	elseif selection == 4 then
		if subselection == 1 then
			control.performFixedSequenceInitAction(1);
		elseif subselection == 2 then
			control.performFixedSequenceInitAction(2);
		elseif subselection == 3 then
			control.performFixedSequenceInitAction(3);
		elseif subselection == 4 then
			control.performFixedSequenceInitAction(4);
		elseif subselection == 5 then
			control.performFixedSequenceInitAction(5);
		end
	elseif selection == 5 then
		if subselection == 2 then
			control.performSequencedInitAction(1);
		elseif subselection == 3 then
			control.performSequencedInitAction(2);
		elseif subselection == 4 then
			control.performSequencedInitAction(3);
		elseif subselection == 5 then
			control.performSequencedInitAction(4);
		elseif subselection == 6 then
			control.performSequencedInitAction(5);
		end
	elseif not PlayerOptionManager.isUsingPhasedInitiative() then
	    if selection == 8 then
	    	if subselection == 1 then
		        control.performInitAction();
		    elseif subselection == 2 then
		        control.performInitAction("INIT_START_ROUND");
		    elseif subselection == 3 then
		    	control.performCloneGroupInitAction();
		    elseif subselection == 7 then
    			control.performRollGroupInitAction();
		    elseif subselection == 8 then
		        control.performInitAction("INIT_END_ROUND");
		    elseif subselection == 5 and sub2selection == 2 then
				control.performDelayAction();
			elseif subselection == 5 and sub2selection == 3 then
				control.performDelayAction(1);
			elseif subselection == 5 and sub2selection == 4 then
				control.performDelayAction(2);
			elseif subselection == 5 and sub2selection == 5 then
				control.performDelayAction(3);
			elseif subselection == 5 and sub2selection == 6 then
				control.performDelayAction(4);
			elseif subselection == 5 and sub2selection == 7 then
				control.performDelayAction(5);
			elseif subselection == 5 and sub2selection == 8 and sub3selection == 8 then
				control.performDelayAction(6);
			elseif subselection == 5 and sub2selection == 8 and sub3selection == 1 then
				control.performDelayAction(7);
			elseif subselection == 5 and sub2selection == 8 and sub3selection == 2 then
			 	control.performDelayAction(8);
			elseif subselection == 5 and sub2selection == 8 and sub3selection == 3 then
				control.performDelayAction(9);
			end
		end
	end
end



function initDelayMenu(control)
    control.resetMenuItems();
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		control.registerMenuItem(Interface.getString("delay10_menuitem"), "delayTurn10ButtonIcon", 2);
		control.registerMenuItem(Interface.getString("delay1_menuitem"), "delayTurn1ButtonIcon", 3);
		control.registerMenuItem(Interface.getString("delay2_menuitem"), "delayTurn2ButtonIcon", 4);
		control.registerMenuItem(Interface.getString("delay3_menuitem"), "delayTurn3ButtonIcon", 5);
		control.registerMenuItem(Interface.getString("delay4_menuitem"), "delayTurn4ButtonIcon", 6);
		control.registerMenuItem(Interface.getString("delay5_menuitem"), "delayTurn5ButtonIcon", 7);
		control.registerMenuItem(Interface.getString("delay6plus_menuitem"), "delayTurnButtonIcon", 8);
		control.registerMenuItem(Interface.getString("delay6_menuitem"), "delayTurn6ButtonIcon", 8, 8);
		control.registerMenuItem(Interface.getString("delay7_menuitem"), "delayTurn7ButtonIcon", 8, 1);
		control.registerMenuItem(Interface.getString("delay8_menuitem"), "delayTurn8ButtonIcon", 8, 2);
		control.registerMenuItem(Interface.getString("delay9_menuitem"), "delayTurn9ButtonIcon", 8, 3);
	end
end

function onDelayMenuSelection(control, selection, subselection)
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		if selection == 2 then
			control.performDelayAction();
		elseif selection == 3 then
			control.performDelayAction(1);
		elseif selection == 4 then
			control.performDelayAction(2);
		elseif selection == 5 then
			control.performDelayAction(3);
		elseif selection == 6 then
			control.performDelayAction(4);
		elseif selection == 7 then
			control.performDelayAction(5);
		elseif selection == 8 and subselection == 8 then
			control.performDelayAction(6);
		elseif selection == 8 and subselection == 1 then
			control.performDelayAction(7);
		elseif selection == 8 and subselection == 2 then
		 	control.performDelayAction(8);
		elseif selection == 8 and subselection == 3 then
			control.performDelayAction(9);
		end
	end
end

function initInitiativeMenu(control)
	control.resetMenuItems();
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		control.registerMenuItem(Interface.getString("standard_init_menuitem"), "standardInitIcon", 1);
		control.registerMenuItem(Interface.getString("first_init_menuitem"), "firstInitIcon", 2);

		if PlayerOptionManager.isUsingHackmasterInitiative() then
			control.registerMenuItem(Interface.getString("last_init_menuitem"), "lastInitHmIcon", 8);
		else
			control.registerMenuItem(Interface.getString("last_init_menuitem"), "lastInitIcon", 8);
		end
		
	end
end

function onInitiativeMenuSelection(control, selection, subselection)
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		if selection == 1 then
			control.performInitAction();
		elseif selection == 2 then
			control.performInitAction("INIT_START_ROUND");
		elseif selection == 8 then
			control.performInitAction("INIT_END_ROUND");
		end
	end
end

function initCombatTrackerActorMenu(control) 
	control.resetMenuItems();

	control.registerMenuItem(Interface.getString("effects_submenu_menuitem"), "effectsSubmenuIcon", 3);
	control.registerMenuItem(Interface.getString("restrained_effect_menuitem"), "restrainedEffectIcon", 3, 1);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("restrained_effect_menuitem"), "addEffectIcon", 3, 1, 2);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("restrained_effect_menuitem"), "removeEffectIcon", 3, 1, 8);
	control.registerMenuItem(Interface.getString("unconscious_effect_menuitem"), "unconsciousEffectIcon", 3, 2);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("unconscious_effect_menuitem"), "addEffectIcon", 3, 2, 2);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("unconscious_effect_menuitem"), "removeEffectIcon", 3, 2, 8);
	control.registerMenuItem(Interface.getString("prone_effect_menuitem"), "proneEffectIcon", 3, 3);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("prone_effect_menuitem"), "addEffectIcon", 3, 3, 2);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("prone_effect_menuitem"), "removeEffectIcon", 3, 3, 8);
	control.registerMenuItem(Interface.getString("stunned_effect_menuitem"), "stunnedEffectIcon", 3, 4);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("stunned_effect_menuitem"), "addEffectIcon", 3, 4, 4);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("stunned_effect_menuitem"), "removeEffectIcon", 3, 4, 6);	
	control.registerMenuItem(Interface.getString("blind_effect_menuitem"), "blindEffectIcon", 3, 5);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("blind_effect_menuitem"), "addEffectIcon", 3, 5, 2);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("blind_effect_menuitem"), "removeEffectIcon", 3, 5, 8);
	control.registerMenuItem(Interface.getString("invisible_effect_menuitem"), "invisibleEffectIcon", 3, 6);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("invisible_effect_menuitem"), "addEffectIcon", 3, 6, 4);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("invisible_effect_menuitem"), "removeEffectIcon", 3, 6, 6);
	control.registerMenuItem(Interface.getString("no_dexterity_effect_menuitem"), "noDexterityEffectIcon", 3, 8);
	control.registerMenuItem(Interface.getString("add_effect_menuitem") .. Interface.getString("no_dexterity_effect_menuitem"), "addEffectIcon", 3, 8, 2);
	control.registerMenuItem(Interface.getString("remove_effect_menuitem") .. Interface.getString("no_dexterity_effect_menuitem"), "removeEffectIcon", 3, 8, 8);

	control.registerMenuItem(Interface.getString("rate_of_fire_menuitem"), "rateOfFireIcon", 4);
	control.registerMenuItem(Interface.getString("rate_of_fire_1_menuitem"), "oneIcon", 4, 1);
	control.registerMenuItem(Interface.getString("rate_of_fire_2_menuitem"), "twoIcon", 4, 2);
	control.registerMenuItem(Interface.getString("rate_of_fire_3_menuitem"), "threeIcon", 4, 3);
	control.registerMenuItem(Interface.getString("rate_of_fire_4_menuitem"), "fourIcon", 4, 4);
	control.registerMenuItem(Interface.getString("rate_of_fire_5_menuitem"), "fiveIcon", 4, 5);

	control.registerMenuItem(Interface.getString("attack_rate_menuitem"), "attackRateIcon", 5);
	control.registerMenuItem(Interface.getString("attack_rate_1_menuitem"), "oneIcon", 5, 2);
	control.registerMenuItem(Interface.getString("attack_rate_2_menuitem"), "twoIcon", 5, 3);
	control.registerMenuItem(Interface.getString("attack_rate_3_menuitem"), "threeIcon", 5, 4);
	control.registerMenuItem(Interface.getString("attack_rate_4_menuitem"), "fourIcon", 5, 5);
	control.registerMenuItem(Interface.getString("attack_rate_5_menuitem"), "fiveIcon", 5, 6);

	control.registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
    control.registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);

    control.registerMenuItem(Interface.getString("lighting_vision_menuitem"), "lightingVisionIcon", 7);
    control.registerMenuItem(Interface.getString("weapon_glow_menuitem"), "weaponGlowMenuIcon", 7, 1);
    control.registerMenuItem(Interface.getString("weapon_glow_blue_menuitem"), "blueColorIcon", 7, 1, 1);
    control.registerMenuItem(Interface.getString("weapon_glow_red_menuitem"), "redColorIcon", 7, 1, 2);
    control.registerMenuItem(Interface.getString("weapon_glow_green_menuitem"), "greenColorIcon", 7, 1, 3);
    control.registerMenuItem(Interface.getString("weapon_glow_orange_menuitem"), "orangeColorIcon", 7, 1, 4);
    control.registerMenuItem(Interface.getString("weapon_glow_yellow_menuitem"), "yellowColorIcon", 7, 1, 6);
    control.registerMenuItem(Interface.getString("weapon_glow_purple_menuitem"), "purpleColorIcon", 7, 1, 7);
    control.registerMenuItem(Interface.getString("weapon_glow_white_menuitem"), "whiteColorIcon", 7, 1, 8);
    control.registerMenuItem(Interface.getString("remove_lights_menuitem"), "removeLightsIcon", 7, 2);
    control.registerMenuItem(Interface.getString("torch_menuitem"), "torchIcon", 7, 4);
    control.registerMenuItem(Interface.getString("hooded_lantern_menuitem"), "lanternIcon", 7, 5);
    control.registerMenuItem(Interface.getString("candle_menuitem"), "candleIcon", 7, 6);
    control.registerMenuItem(Interface.getString("vision_menuitem"), "visionMenuIcon", 7, 7);
    control.registerMenuItem(Interface.getString("infravision_120_menuitem"), "infravision120Icon", 7, 7, 1);
    control.registerMenuItem(Interface.getString("truesight_240_menuitem"), "truesightIcon", 7, 7, 2);
    control.registerMenuItem(Interface.getString("blindsight_60_menuitem"), "blindsight60Icon", 7, 7, 4);
    control.registerMenuItem(Interface.getString("blindsight_120_menuitem"), "blindsight120Icon", 7, 7, 5);
    control.registerMenuItem(Interface.getString("infravision_30_menuitem"), "infravision30Icon", 7, 7, 6);
    control.registerMenuItem(Interface.getString("infravision_60_menuitem"), "infravision60Icon", 7, 7, 7);
    control.registerMenuItem(Interface.getString("infravision_90_menuitem"), "infravision90Icon", 7, 7, 8);
    control.registerMenuItem(Interface.getString("lighting_spells_menuitem"), "lightingSpellsMenuIcon", 7, 8);
    control.registerMenuItem(Interface.getString("light_spell_menuitem"), "light20Icon", 7, 8, 8);
    control.registerMenuItem(Interface.getString("continual_light_spell_menuitem"), "light60Icon", 7, 8, 1);
    control.registerMenuItem(Interface.getString("darkness_15_menuitem"), "darkness15Icon", 7, 8, 2);
    control.registerMenuItem(Interface.getString("darkness_continual_menuitem"), "darkness60Icon", 7, 8, 3);



	if not PlayerOptionManager.isUsingPhasedInitiative() then
		control.registerMenuItem(Interface.getString("actor_init_menuitem"), "standardInitIcon", 8);
		control.registerMenuItem(Interface.getString("standard_init_menuitem"), "standardInitIcon", 8, 1);
		control.registerMenuItem(Interface.getString("first_init_menuitem"), "firstInitIcon", 8, 2);
		control.registerMenuItem(Interface.getString("clone_group_init_menuitem"), "cloneIcon", 8, 3);

		control.registerMenuItem(Interface.getString("delay_submenu_menuitem"), "delayTurnButtonIcon", 8, 5);
		control.registerMenuItem(Interface.getString("delay10_menuitem"), "delayTurn10ButtonIcon", 8, 5, 2);
		control.registerMenuItem(Interface.getString("delay1_menuitem"), "delayTurn1ButtonIcon", 8, 5, 3);
		control.registerMenuItem(Interface.getString("delay2_menuitem"), "delayTurn2ButtonIcon", 8, 5, 4);
		control.registerMenuItem(Interface.getString("delay3_menuitem"), "delayTurn3ButtonIcon", 8, 5, 5);
		control.registerMenuItem(Interface.getString("delay4_menuitem"), "delayTurn4ButtonIcon", 8, 5, 6);
		control.registerMenuItem(Interface.getString("delay5_menuitem"), "delayTurn5ButtonIcon", 8, 5, 7);
		control.registerMenuItem(Interface.getString("delay6plus_menuitem"), "delayTurnButtonIcon", 8, 5, 8);
		control.registerMenuItem(Interface.getString("delay6_menuitem"), "delayTurn6ButtonIcon", 8, 5, 8, 8);
		control.registerMenuItem(Interface.getString("delay7_menuitem"), "delayTurn7ButtonIcon", 8, 5, 8, 1);
		control.registerMenuItem(Interface.getString("delay8_menuitem"), "delayTurn8ButtonIcon", 8, 5, 8, 2);
		control.registerMenuItem(Interface.getString("delay9_menuitem"), "delayTurn9ButtonIcon", 8, 5, 8, 3);

		if PlayerOptionManager.isUsingHackmasterInitiative() then
			control.registerMenuItem(Interface.getString("last_init_menuitem"), "lastInitHmIcon", 8, 8);
		else
			control.registerMenuItem(Interface.getString("last_init_menuitem"), "lastInitIcon", 8, 8);
		end
	end
end

function onCombatTrackerActorMenuSelection(control, selection, subselection, sub2selection, sub3selection)

	if selection == 3 then -- effects submenu
		if subselection == 1 and sub2selection == 2 then
			control.performEffectAction("Restrained");
		elseif subselection == 1 and sub2selection == 8 then
			control.performEffectAction("Restrained", true);
		elseif subselection == 2 and sub2selection == 2 then
			control.performEffectAction("Unconscious");
		elseif subselection == 2 and sub2selection == 8 then
			control.performEffectAction("Unconscious", true);
		elseif subselection == 3 and sub2selection == 2 then
			control.performEffectAction("Prone");
		elseif subselection == 3 and sub2selection == 8 then
			control.performEffectAction("Prone", true);
		elseif subselection == 4 and sub2selection == 4 then
			control.performEffectAction("Stunned");
		elseif subselection == 4 and sub2selection == 6 then			
			control.performEffectAction("Stunned", true);
		elseif subselection == 5 and sub2selection == 2 then			
			control.performEffectAction("Blinded");
		elseif subselection == 5 and sub2selection == 8 then						
			control.performEffectAction("Blinded", true);
		elseif subselection == 6 and sub2selection == 4 then			
			control.performEffectAction("Invisible");
		elseif subselection == 6 and sub2selection == 6 then						
			control.performEffectAction("Invisible", true);
		elseif subselection == 8 and sub2selection == 2 then			
			control.performEffectAction("NO-DEXTERITY");
		elseif subselection == 8 and sub2selection == 8 then			
			control.performEffectAction("DEXTERITY", true); -- Need to do this because NO-DEXTERITY fails matching, probably due to the hyphen
		end
	elseif selection == 4 then -- ranged attack sequence submenu
		if subselection == 1 then
			control.performFixedSequenceInitAction(1);
		elseif subselection == 2 then
			control.performFixedSequenceInitAction(2);
		elseif subselection == 3 then
			control.performFixedSequenceInitAction(3);
		elseif subselection == 4 then
			control.performFixedSequenceInitAction(4);
		elseif subselection == 5 then
			control.performFixedSequenceInitAction(5);
		end
	elseif selection == 5 then -- melee attack sequence submenu
		if subselection == 2 then
			control.performSequencedInitAction(1);
		elseif subselection == 3 then
			control.performSequencedInitAction(2);
		elseif subselection == 4 then
			control.performSequencedInitAction(3);
		elseif subselection == 5 then
			control.performSequencedInitAction(4);
		elseif subselection == 6 then
			control.performSequencedInitAction(5);
		end
	end

	if selection == 7 then -- vision and lighting submen u
		local nodeActor = control.getCtNodeActor();
		if subselection == 1 then -- weapon glow submenu
			if sub2selection == 1 then 
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.Blue);
			elseif sub2selection == 2 then
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.Red);
			elseif sub2selection == 3 then
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.Green);
			elseif sub2selection == 4 then				
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.Orange);
			elseif sub2selection == 6 then
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.Yellow);
			elseif sub2selection == 7 then
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.Purple);
			elseif sub2selection == 8 then
				LightingManagerPO.addWeaponGlow(nodeActor, LightingManagerPO.White);
			end
		elseif subselection == 2 then
			LightingManagerPO.removeAllLights(nodeActor);
		elseif subselection == 4 then
			LightingManagerPO.addLight(nodeActor, LightingManagerPO.Torch);
		elseif subselection == 5 then
			LightingManagerPO.addLight(nodeActor, LightingManagerPO.HoodedLantern);
		elseif subselection == 6 then
			LightingManagerPO.addLight(nodeActor, LightingManagerPO.Candle);
		elseif subselection == 7 then -- vision submenu
			if sub2selection == 1 then
				LightingManagerPO.addInfravision(nodeActor, 120);
			elseif sub2selection == 2 then
				LightingManagerPO.addTruesight(nodeActor, 240);
			elseif sub2selection == 4 then
				LightingManagerPO.addBlindsight(nodeActor, 60);
			elseif sub2selection == 5 then
				LightingManagerPO.addBlindsight(nodeActor, 120);
			elseif sub2selection == 6 then
				LightingManagerPO.addInfravision(nodeActor, 30);
			elseif sub2selection == 7 then
				LightingManagerPO.addInfravision(nodeActor, 60);
			elseif sub2selection == 8 then
				LightingManagerPO.addInfravision(nodeActor, 90);
			end
		elseif subselection == 8 then -- spell submenu
			if sub2selection == 1 then
				LightingManagerPO.addLight(nodeActor, LightingManagerPO.ContinualLightSpell);
			elseif sub2selection == 2 then
				LightingManagerPO.addLight(nodeActor, LightingManagerPO.DarknessSpell);
			elseif sub2selection == 3 then
				LightingManagerPO.addLight(nodeActor, LightingManagerPO.ContinualDarknessSpell);
			elseif sub2selection == 8 then
				LightingManagerPO.addLight(nodeActor, LightingManagerPO.LightSpell);
			end	
		end
	end

	if not PlayerOptionManager.isUsingPhasedInitiative() then
	    if selection == 8 then -- initiative submenu
		    if subselection == 1 then
		        control.performInitAction();
		    elseif subselection == 2 then
		        control.performInitAction("INIT_START_ROUND");
		    elseif subselection == 3 then
    			control.performCloneGroupInitAction();
		    elseif subselection == 8 then
		        control.performInitAction("INIT_END_ROUND");
		    elseif subselection == 5 and sub2selection == 2 then
				control.performDelayAction();
			elseif subselection == 5 and sub2selection == 3 then
				control.performDelayAction(1);
			elseif subselection == 5 and sub2selection == 4 then
				control.performDelayAction(2);
			elseif subselection == 5 and sub2selection == 5 then
				control.performDelayAction(3);
			elseif subselection == 5 and sub2selection == 6 then
				control.performDelayAction(4);
			elseif subselection == 5 and sub2selection == 7 then
				control.performDelayAction(5);
			elseif  subselection == 5 and sub2selection == 8 and sub3selection == 8 then
				control.performDelayAction(6);
			elseif  subselection == 5 and sub2selection == 8 and sub3selection == 1 then
				control.performDelayAction(7);
			elseif subselection == 5 and sub2selection == 8 and sub3selection == 2 then
			 	control.performDelayAction(8);
			elseif subselection == 5 and sub2selection == 8 and sub3selection == 3 then
				control.performDelayAction(9);
			end
		end
	end
    
end