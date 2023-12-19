function onInit()
	ModifierManager.addModWindowPresets(_tModifierWindowPresets);
end

-- -- Shown in Modifiers window
-- -- NOTE: Set strings for "modifier_category_*" and "modifier_label_*"
_tModifierWindowPresets =
{
	{ 
		sCategory = "calledshot",
		tPresets = 
		{
			"calledshot_abdomen",
			"calledshot_arm",
			"calledshot_head",
			"calledshot_leg",
			"calledshot_tail",
			"calledshot_torso",
			"calledshot_neck",
			"calledshot_eye",
			"calledshot_groin",
			"calledshot_hand"
		}
	}
};