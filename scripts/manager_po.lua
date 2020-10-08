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
sFumbleOptionKey = "HouseRule_FumbleTable";
sHackmasterAttackMatrixOptionKey = "HouseRule_HackmasterAttackMatrix";
sFatigueOptionKey = "HouseRule_HackmasterFatigueOption";
sRingBellOnRoundStartOptionKey = "AdditionalAutomation_RingBellOnRoundStart";
sPhasedInitiativeOptionKey = "PlayersOption_PhasedInitiative";

function onInit()
    registerOptions();
end 

function registerOptions()
    
    -- Player's Option Rules
	OptionsManager.registerOption2(sCritOptionKey, false, "option_header_po", "option_label_critical_hits", "option_entry_cycler",{ labels = "option_val_nat18AndHitBy5|option_val_nat20AndHitBy5|option_val_anyNat20", values = "nat18OrBetterAndHitBy5|nat20andHitBy5|anyNat20", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2(sPhasedInitiativeOptionKey, false, "option_header_po", "option_label_phased_initiative", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	-- Additional Automation
    OptionsManager.registerOption2(sWeaponTypeVsArmorOptionKey, false, "option_header_automation", "option_label_weapontype_vs_armor_mods", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2(sStricterResistanceOptionKey, false, "option_header_automation", "option_label_stricter_resistance", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2(sGenerateHitLocationsOptionKey, false, "option_header_automation", "option_label_generate_hit_locations", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sDefaultPcInitTo99OptionKey, false, "option_header_automation", "option_label_default_pc_init_to_99", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })

	OptionsManager.registerOption2(sRingBellOnRoundStartOptionKey, false, "option_header_automation", "option_label_ring_bell_on_round_start", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    
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

end

function isUsingPhasedInitiative()
	return OptionsManager.isOption(sPhasedInitiativeOptionKey, "on");
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

function isUsingReactionAdjustmentForInitiative()
	return OptionsManager.isOption(sReactionAdjAffectsInit, "on");
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

function isUsingCombatAndTacticsCritsRAW()
	return OptionsManager.isOption(sCritOptionKey, "nat18OrBetterAndHitBy5");
end

function mustCritHitBy5()
	return OptionsManager.isOption(sCritOptionKey, "nat18OrBetterAndHitBy5") 
		or OptionsManager.isOption(sCritOptionKey, "nat20andHitBy5");
end


function isPOCritEnabled()
	return DataCommonADND.coreVersion == "2e" and not OptionsManager.isOption(sCritOptionKey, "off")
end

function isWeaponTypeVsArmorModsEnabled()
	return OptionsManager.isOption(sWeaponTypeVsArmorOptionKey, "on")
end

function isStricterResistancesEnabled()
	return OptionsManager.isOption(sStricterResistanceOptionKey, "on");
end

function isGenerateHitLocationsEnabled()
	return OptionsManager.isOption(sGenerateHitLocationsOptionKey, "on");
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

