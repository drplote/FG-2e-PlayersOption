local fOnPowerCast;
local fGetPowerRoll;

function onInit()
	fOnPowerCast = ActionPower.onPowerCast;
	ActionPower.onPowerCast = onPowerCastOverride;
	ActionsManager.registerResultHandler("cast", onPowerCastOverride);

	fGetPowerRoll = PowerManager.getPowerRoll;
	PowerManager.getPowerRoll = getPowerRollOverride;
end

function onPowerCastOverride(rSource, rTarget, rRoll)
	fOnPowerCast(rSource, rTarget, rRoll);
	if PlayerOptionManager.isUsingHackmasterFatigue() then
		FatigueManagerPO.recordCast(rSource);
	end
end

function getPowerRollOverride(rActor, nodeAction, sSubRoll)
	local rAction = fGetPowerRoll(rActor, nodeAction, sSubRoll);
	if nodeAction then
		local sType = DB.getValue(nodeAction, "type", "");
		local nodeSpell = nodeAction.getChild("...");
  		rAction.sPowerType = DB.getValue(nodeSpell, "type", ""):lower();
  		rAction.sPowerSchool = DB.getValue(nodeSpell, "school", ""):lower();
	end
	return rAction;
end

