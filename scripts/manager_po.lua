function onInit()
    registerOptions();
end 

function registerOptions()
    
    -- Player's Option Rules
	
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