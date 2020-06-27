function onInit()
    registerOptions();
end 

function registerOptions()
    
    -- Player's Option Rules
	OptionsManager.registerOption2("PlayersOption_CriticalHits", false, "option_header_po", "option_label_critical_hits", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	-- Additional Automation
    OptionsManager.registerOption2("AdditionalAutomation_WeaponTypeVsArmorMods", false, "option_header_automation", "option_label_weapontype_vs_armor_mods", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2("AdditionalAutomation_StricterResistance", false, "option_header_automation", "option_label_stricter_resistance", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	
	OptionsManager.registerOption2("AdditionalAutomation_GenerateHitLocations", false, "option_header_automation", "option_label_generate_hit_locations", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    
    -- House rules
    OptionsManager.registerOption2("SternoHouseRule_HpKicker", false, "option_header_sterno_house_rule", "option_label_hp_kicker", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    OptionsManager.registerOption2("SternoHouseRule_PenetrationDice", false, "option_header_sterno_house_rule", "option_label_penetration_dice", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    --OptionsManager.registerOption2("SternoHouseRule_ArmorDamage", false, "option_header_sterno_house_rule", "option_label_armor_damage", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
    --OptionsManager.registerOption2("SternoHouseRule_ShieldDamage", false, "option_header_sterno_house_rule", "option_label_shield_damage", "option_entry_cycler",{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
    
end

function isPOCritEnabled()
	return DataCommonADND.coreVersion == "2e" and OptionsManager.isOption("PlayersOption_CriticalHits", "on")
end

function isWeaponTypeVsArmorModsEnabled()
	return OptionsManager.isOption("AdditionalAutomation_WeaponTypeVsArmorMods", "on")
end

function isStricterResistancesEnabled()
	return OptionsManager.isOption("AdditionalAutomation_StricterResistance", "on");
end

function isGenerateHitLocationsEnabled()
	return OptionsManager.isOption("AdditionalAutomation_GenerateHitLocations", "on");
end

function isHpKickerEnabled()
	return OptionsManager.isOption("SternoHouseRule_HpKicker", "on");
end

function isPenetrationDiceEnabled()
	return OptionsManager.isOption("SternoHouseRule_HpKicker", "on");
end
