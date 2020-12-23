local fModRoll;

function onInit()
	fModRoll = ActionCheck.modRoll;
	ActionCheck.modRoll = modRollOverride;
	ActionsManager.registerModHandler("check", modRollOverride);
end

function modRollOverride(rSource, rTarget, rRoll)
	fModRoll(rSource, rTarget, rRoll);
	HonorManagerPO.addAttributeCheckModiifer(rSource, rRoll);
end