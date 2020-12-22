function onInit()
	OptionsManager.registerCallback(PlayerOptionManager.sAddComeliness, onComelinessOptionChanged);
	OptionsManager.registerCallback(PlayerOptionManager.sEnableHonor, onHonorOptionChanged);
	setPlayerOptionControlVisibility();
end

function onClose()
	OptionsManager.registerCallback(PlayerOptionManager.sAddComeliness, onComelinessOptionChanged);
	OptionsManager.registerCallback(PlayerOptionManager.sEnableHonor, onHonorOptionChanged);
end 

function onComelinessOptionChanged()
	setPlayerOptionControlVisibility();
end

function onHonorOptionChanged()
	setPlayerOptionControlVisibility();
end

function setPlayerOptionControlVisibility()
	local bIsComelinessEnabled = PlayerOptionManager.isComelinessEnabled();
	local bIsHonorEnabled = PlayerOptionManager.isHonorEnabled();
	setComelinessVisibility(bIsComelinessEnabled);
	setHonorVisibility(bIsHonorEnabled);

	if bIsComelinessEnabled then
		honor_label.setAnchor("top", "charisma_label", "top", "relative", 100);
	else
		honor_label.setAnchor("top", "charisma_label", "top", "relative", 50);
	end
end

function setComelinessVisibility(bShow)
	comeliness_label.setVisible(bShow);
	comeliness_base.setVisible(bShow);
	comeliness_base_mod.setVisible(bShow);
	com_plus.setVisible(bShow);
	comeliness_mod.setVisible(bShow);
	com_plus2.setVisible(bShow);
	comeliness_temp.setVisible(bShow);
	comeliness_total.setVisible(bShow);

	comeliness_percent_label.setVisible(bShow);
	comeliness_percent_base.setVisible(bShow);
	comeliness_percent_base_mod.setVisible(bShow);
	com_per_plus.setVisible(bShow);
	comeliness_percent_mod.setVisible(bShow);
	com_per_plus2.setVisible(bShow);
	comeliness_percent_temp.setVisible(bShow);
	comeliness_percent_total.setVisible(bShow);
end

function setHonorVisibility(bShow)
	honor_label.setVisible(bShow);
	honor_total.setVisible(bShow);
end