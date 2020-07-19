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

function onInit()
    registerOptions();
end 

function registerOptions()
    
    -- Player's Option Rules
	OptionsManager.registerOption2(sCritOptionKey, false, "option_header_po", "option_label_critical_hits", "option_entry_cycler",{ labels = "option_val_nat18AndHitBy5|option_val_nat20AndHitBy5|option_val_anyNat20", values = "nat18OrBetterAndHitBy5|nat20andHitBy5|anyNat20", baselabel = "option_val_off", baseval = "off", default = "off" });

	-- Additional Automation
    OptionsManager.registerOption2(sWeaponTypeVsArmorOptionKey, false, "option_header_automation", "option_label_weapontype_vs_armor_mods", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2(sStricterResistanceOptionKey, false, "option_header_automation", "option_label_stricter_resistance", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2(sGenerateHitLocationsOptionKey, false, "option_header_automation", "option_label_generate_hit_locations", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2(sDefaultPcInitTo99OptionKey, false, "option_header_automation", "option_label_default_pc_init_to_99", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" })
    
    
    -- House rules
    OptionsManager.registerOption2(sHackmasterStatScaling, false, "option_header_house_rule", "option_label_hackmaster_stat_scaling", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sKickerOptionKey, false, "option_header_house_rule", "option_label_hp_kicker", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    OptionsManager.registerOption2(sPenetrationOptionKey, false, "option_header_house_rule", "option_label_penetration_dice", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    OptionsManager.registerOption2(sArmorDamageOptionKey, false, "option_header_house_rule", "option_label_armor_damage", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sThresholdOfPainOptionKey, false, "option_header_house_rule", "option_label_threshold_of_pain", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    

    OptionsManager.registerOption2(sReactionAdjAffectsInit, false, "option_header_house_rule", "option_label_reaction_adj_affects_init", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });    


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
	return OptionsManager.isOption(sKickerOptionKey, "on");
end

function isPenetrationDiceEnabled()
	return OptionsManager.isOption(sPenetrationOptionKey, "on");
end

