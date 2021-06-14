sCritOptionKey = "PlayersOption_CriticalHits";
sWeaponTypeVsArmorOptionKey = "AdditionalAutomation_WeaponTypeVsArmorMods";
sStricterResistanceOptionKey = "AdditionalAutomation_StricterResistance";
sGenerateHitLocationsOptionKey = "AdditionalAutomation_GenerateHitLocations";
sKickerOptionKey = "HouseRule_HpKicker";
sPenetrationOptionKey = "HouseRule_PenetrationDice";
sArmorDamageOptionKey = "HouseRule_ArmorDamage";
sThresholdOfPainOptionKey = "HouseRule_ThresholdOfPain";
sHackmasterStatScaling = "HouseRule_HackmasterStatScaling";
sReactionAdjAffectsInit = "HouseRule_ReactionAdjustmentAffectsInit"
sDefaultPcInitTo99OptionKey = "AdditionalAutomation_DefaultPCInitTo99";
sDefaultNpcInitTo99OptionKey = "AdditionalAutomation_DefaultNPCInitTo99";
sFumbleOptionKey = "HouseRule_FumbleTable";
sHackmasterAttackMatrixOptionKey = "HouseRule_HackmasterAttackMatrix";
sFatigueOptionKey = "HouseRule_HackmasterFatigueOption";
sRingBellOnRoundStartOptionKey = "AdditionalAutomation_RingBellOnRoundStart";
sPhasedInitiativeOptionKey = "PlayersOption_PhasedInitiative";
sAddComeliness = "HouseRule_Comeliness";
sEnableHonor = "HouseRule_HackmasterHonor";
sHackmasterCalledShots = "HouseRule_HackmasterCalledShots";
sHackmasterCritsOptionKey = "HouseRule_HackmasterCrits";
sHackmasterInitKey = "HouseRule_HackmasterInit";
sMagicArmorDamageOptionKey = "HouseRule_MagicArmorDamage";
sAdjustNpcAcLikePc = "AdditionalAutomation_AdjustNpcAcLikePc";
sAllowPlayerCheaterDice = "AdditionalAutomation_AllowPlayerCheaterDice";
sAlternateTargetEffectModifiers = "AdditionalAutomation_AlternateTargetEffectModifiers";
sMoreDurableMagicShields = "HouseRule_MoreDurableMagicShields";
sDebugOptionKey = "AdditionalAutomation_DebugOptions";
sCoinWeightOptionKey = "HouseRule_CoinWeight";

function onInit()
    registerOptions();
    OptionsManager.registerCallback(sCritOptionKey, onPlayersOptionCritOptionChanged);
    OptionsManager.registerCallback(sHackmasterCritsOptionKey, onHackmasterCritOptionChanged);
    OptionsManager.registerCallback(sHackmasterInitKey, onHackmasterInitOptionChanged);
    OptionsManager.registerCallback(sPhasedInitiativeOptionKey, onPlayersOptionInitOptionChanged);
    OptionsManager.registerCallback(sArmorDamageOptionKey, onArmorDamageOptionChanged);
    OptionsManager.registerCallback(sCoinWeightOptionKey, onCoinWeightChanged);
   
   	updateOldOptionsToNewValues();
end 


function updateOldOptionsToNewValues()
	if OptionsManager.isOption(sGenerateHitLocationsOptionKey, "on") then
		OptionsManager.setOption(sGenerateHitLocationsOptionKey, "po");
	end

	if OptionsManager.isOption(sArmorDamageOptionKey, "on") then
		OptionsManager.setOption(sAdjustNpcAcLikePc, "on");
	end
end

function onCoinWeightChanged()
	if isUsing1eCoinWeight() then
		DataCommonADND.nDefaultCoinWeight = 0.1;
	else
		DataCommonADND.nDefaultCoinWeight = 0.02;
	end
end


function onPlayersOptionCritOptionChanged()
	if isPOCritEnabled() then
		OptionsManager.setOption(sHackmasterCritsOptionKey, "off");
	end
end

function onHackmasterCritOptionChanged()
	if isHackmasterCritEnabled() then
		OptionsManager.setOption(sCritOptionKey, "off");
	end
end

function onPlayersOptionInitOptionChanged()
	if isUsingPhasedInitiative() then
		OptionsManager.setOption(sHackmasterInitKey, "off");
	end
end

function onArmorDamageOptionChanged()
	if isUsingArmorDamage() then
		OptionsManager.setOption(sAdjustNpcAcLikePc, "on");
	end
end

function onHackmasterInitOptionChanged()
	if isUsingHackmasterInitiative() then
		OptionsManager.setOption(sPhasedInitiativeOptionKey, "off");
	end
end

function registerOptions()
    
    -- Player's Option Rules
	OptionsManager.registerOption2(sCritOptionKey, false, "option_header_po", "option_label_critical_hits", "option_entry_cycler",{ labels = "option_val_nat18AndHitBy5|option_val_nat20AndHitBy5|option_val_anyNat20", values = "nat18OrBetterAndHitBy5|nat20andHitBy5|anyNat20", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2(sPhasedInitiativeOptionKey, false, "option_header_po", "option_label_phased_initiative", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	-- Additional Automation
    OptionsManager.registerOption2(sWeaponTypeVsArmorOptionKey, false, "option_header_automation", "option_label_weapontype_vs_armor_mods", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2(sStricterResistanceOptionKey, false, "option_header_automation", "option_label_stricter_resistance", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2(sGenerateHitLocationsOptionKey, false, "option_header_automation", "option_label_generate_hit_locations", "option_entry_cycler",{ labels = "option_val_po|option_val_hm", values = "hm|po", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sDefaultPcInitTo99OptionKey, false, "option_header_automation", "option_label_default_pc_init_to_99", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })

	OptionsManager.registerOption2(sDefaultNpcInitTo99OptionKey, false, "option_header_automation", "option_label_default_npc_init_to_99", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })

	OptionsManager.registerOption2(sRingBellOnRoundStartOptionKey, false, "option_header_automation", "option_label_ring_bell_on_round_start", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sAdjustNpcAcLikePc, false, "option_header_automation", "option_label_npc_ac_like_pc", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sAllowPlayerCheaterDice, false, "option_header_automation", "option_label_allow_player_cheater_dice", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sAlternateTargetEffectModifiers, false, "option_header_automation", "option_label_alternate_target_effect_modifiers", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sDebugOptionKey, false, "option_header_automation", "open_label_show_debug_messages", "option_entry_cycler",{ labels = "option_val_chat|option_val_console", values = "chat|console", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    
    -- House rules
    OptionsManager.registerOption2(sHackmasterStatScaling, false, "option_header_house_rule", "option_label_hackmaster_stat_scaling", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sHackmasterAttackMatrixOptionKey, false, "option_header_house_rule", "option_label_hackmaster_attack_matrix", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

	OptionsManager.registerOption2(sKickerOptionKey, false, "option_header_house_rule", "option_label_hp_kicker", "option_entry_cycler",{ labels = "option_val_off|option_val_on|option_val_size_based", values = "off|on|sizedBasedKicker", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    OptionsManager.registerOption2(sPenetrationOptionKey, false, "option_header_house_rule", "option_label_penetration_dice", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    OptionsManager.registerOption2(sArmorDamageOptionKey, false, "option_header_house_rule", "option_label_armor_damage", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sThresholdOfPainOptionKey, false, "option_header_house_rule", "option_label_threshold_of_pain", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sReactionAdjAffectsInit, false, "option_header_house_rule", "option_label_reaction_adj_affects_init", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

	OptionsManager.registerOption2(sFumbleOptionKey, false, "option_header_house_rule", "option_label_fumble_table", "option_entry_cycler",{ labels = "option_val_hm_fumbles|option_val_ct_fumbles", values = "hmFumbles|ctFumbles", baselabel = "option_val_off", baseval = "off", default = "off" });

    OptionsManager.registerOption2(sFatigueOptionKey, false, "option_header_house_rule", "option_label_hackmaster_fatigue", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sAddComeliness, false, "option_header_house_rule", "option_label_comeliness", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sEnableHonor, false, "option_header_house_rule", "option_label_honor", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

	OptionsManager.registerOption2(sHackmasterCalledShots, false, "option_header_house_rule", "option_label_hackmaster_called_shots", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });        

	OptionsManager.registerOption2(sHackmasterCritsOptionKey, false, "option_header_house_rule", "option_label_hm_critical_hits", "option_entry_cycler",{ labels = "option_val_nat20AndHitBy5|option_val_anyNat20", values = "nat20andHitBy5|anyNat20", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sHackmasterInitKey, false, "option_header_house_rule", "option_label_hm_init", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sMagicArmorDamageOptionKey, false, "option_header_house_rule", "option_label_magic_armor_damage", "option_entry_cycler",{ labels = "option_val_equal_magic|option_val_penetration|option_val_both", values = "magic|penetration|both", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sMoreDurableMagicShields, false, "option_header_house_rule", "option_label_more_durable_magic_shields", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

	OptionsManager.registerOption2(sCoinWeightOptionKey, false, "option_header_house_rule", "option_label_coin_weight", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

end

function isUsing1eCoinWeight()
	return OptionsManager.isOption(sCoinWeightOptionKey, "on");
end

function shouldShowDebugInConsole()
	return OptionsManager.isOption(sDebugOptionKey, "console");
end

function shouldShowDebugInChat()
	return OptionsManager.isOption(sDebugOptionKey, "chat");
end

function isUsingMoreDurableMagicShields()
	return OptionsManager.isOption(sMoreDurableMagicShields, "on");
end

function isUsingAlternateTargetEffectModifiers()
	return OptionsManager.isOption(sAlternateTargetEffectModifiers, "on");
end

function shouldUseDynamicNpcAc()
	return OptionsManager.isOption(sAdjustNpcAcLikePc, "on") or isUsingArmorDamage();
end

function isMagicArmorDamagedByPenetration()
	return OptionsManager.isOption(sMagicArmorDamageOptionKey, "penetration")
		or OptionsManager.isOption(sMagicArmorDamageOptionKey, "both");
end

function isMagicArmorDamagedByEqualMagic()
	return OptionsManager.isOption(sMagicArmorDamageOptionKey, "magic")
		or OptionsManager.isOption(sMagicArmorDamageOptionKey, "both");
end

function isHackmasterCalledShotsEnabled()
	return OptionsManager.isOption(sHackmasterCalledShots, "on");
end

function isHonorEnabled()
	return OptionsManager.isOption(sEnableHonor, "on");
end

function isComelinessEnabled()
	return OptionsManager.isOption(sAddComeliness, "on");
end

function isUsingPhasedInitiative()
	return OptionsManager.isOption(sPhasedInitiativeOptionKey, "on");
end

function isUsingHackmasterInitiative()
	return OptionsManager.isOption(sHackmasterInitKey, "on");
end

function isAllowingPlayerCheaterDice()
	return OptionsManager.isOption(sAllowPlayerCheaterDice, "on");
end

function shouldRingBellOnRoundStart()
	return OptionsManager.isOption(sRingBellOnRoundStartOptionKey, "on");
end

function isUsingHackmasterFatigue()
	return OptionsManager.isOption(sFatigueOptionKey, "on");
end

function isUsingHackmasterThac0()
	return OptionsManager.isOption(sHackmasterAttackMatrixOptionKey, "on");
end

function isUsingFumbleTables()
	return not OptionsManager.isOption(sFumbleOptionKey, "off");
end

function isUsingSternoFumbles()
	return OptionsManager.isOption(sFumbleOptionKey, "ctFumbles");
end

function isUsingHackmasterFumbles()
	return OptionsManager.isOption(sFumbleOptionKey, "hmFumbles");
end

function isDefaultingPcInitTo99()
	return OptionsManager.isOption(sDefaultPcInitTo99OptionKey, "on");
end

function isDefaultingNpcInitTo99()
	return OptionsManager.isOption(sDefaultNpcInitTo99OptionKey, "on");
end

function isUsingReactionAdjustmentForInitiative()
	return OptionsManager.isOption(sReactionAdjAffectsInit, "on") or isUsingHackmasterInitiative();
end

function isUsingHackmasterStats()
	return OptionsManager.isOption(sHackmasterStatScaling, "on");
end

function isUsingThresholdOfPain()
	return OptionsManager.isOption(sThresholdOfPainOptionKey, "on");
end

function isUsingArmorDamage()
	return OptionsManager.isOption(sArmorDamageOptionKey, "on");
end

function isUsingHackmasterCritsRAW()
	return OptionsManager.isOption(sCritOptionKey, "anyNat20");
end

function isUsingCombatAndTacticsCritsRAW()
	return OptionsManager.isOption(sCritOptionKey, "nat18OrBetterAndHitBy5");
end

function mustCritHitBy5()
	return OptionsManager.isOption(sCritOptionKey, "nat18OrBetterAndHitBy5") 
		or OptionsManager.isOption(sCritOptionKey, "nat20andHitBy5")
		or OptionsManager.isOption(sHackmasterCritsOptionKey, "nat20andHitBy5");
end

function isAnyCritEnabled()
	return isPOCritEnabled() or isHackmasterCritEnabled();
end

function isPOCritEnabled()
	return DataCommonADND.coreVersion == "2e" and not OptionsManager.isOption(sCritOptionKey, "off")
end

function isHackmasterCritEnabled()
	return not OptionsManager.isOption(sHackmasterCritsOptionKey, "off");
end

function isWeaponTypeVsArmorModsEnabled()
	return OptionsManager.isOption(sWeaponTypeVsArmorOptionKey, "on")
end

function isStricterResistancesEnabled()
	return OptionsManager.isOption(sStricterResistanceOptionKey, "on");
end

function isUsingPlayersOptionHitLocations()
	if isAnyCritEnabled() then
		return isPOCritEnabled();
	else
		return OptionsManager.isOption(sGenerateHitLocationsOptionKey, "po");
	end
end

function isUsingHackmasterHitLocations()
	if isAnyCritEnabled() then
		return isHackmasterCritEnabled();
	else
		return OptionsManager.isOption(sGenerateHitLocationsOptionKey, "hm");
	end
end

function isGenerateHitLocationsEnabled()
	return not OptionsManager.isOption(sGenerateHitLocationsOptionKey, "off");
end

function isHpKickerEnabled()
	return OptionsManager.isOption(sKickerOptionKey, "on") or OptionsManager.isOption(sKickerOptionKey, "sizedBasedKicker");
end

function isKickerSizeBased()
	return OptionsManager.isOption(sKickerOptionKey, "sizedBasedKicker");
end

function isPenetrationDiceEnabled()
	return OptionsManager.isOption(sPenetrationOptionKey, "on");
end
