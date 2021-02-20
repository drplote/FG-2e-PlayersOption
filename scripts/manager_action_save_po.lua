local fModSave;
local fApplySave;


function onInit()
	fModSave = ActionSave.modSave;
	ActionSave.modSave = modSaveOverride;
	ActionsManager.registerModHandler("save", modSaveOverride);

	fApplySave = ActionSave.applySave;
	ActionSave.applySave = applySaveOverride;
end

function applySaveOverride(rSource, rOrigin, rAction, sUser)
	fApplySave(rSource, rOrigin, rAction, sUser);
	if rAction and rAction.sSaveDesc == "TOP" then
		if rAction.nTotal < rAction.nTarget then
			local nodeChar = ActorManager.getCTNode(rSource);
			if nodeChar then 
				EffectManager.addEffect("", "", ActorManager.getCTNode(rSource), 
					{ sName = "Stunned", sLabel = "Stunned", nDuration = rAction.nTarget - rAction.nTotal }, true);
			end
			
		end
	end
end


function modSaveOverride(rSource, rTarget, rRoll)
	local nMagicalDefenseAdjustment = getMagicalDefenseAdjustment(rSource, rRoll.sSaveDesc);
    rRoll.nMod = rRoll.nMod + nMagicalDefenseAdjustment;
    if nMagicalDefenseAdjustment > 0 then
      rRoll.sDesc = rRoll.sDesc .. " [MAGIC DEF ADJ +" .. nMagicalDefenseAdjustment .. "]";
    elseif nMagicalDefenseAdjustment < 0 then
      rRoll.sDesc = rRoll.sDesc .. " [MAGIC DEF ADJ " .. nMagicalDefenseAdjustment .. "]";
    end
    HonorManagerPO.addSaveModifier(rSource, rRoll);
	fModSave(rSource, rTarget, rRoll);
end

function rollSave(rTarget, sSave, sDesc, bSecretRoll)
	if not bSecretRoll then bSecretRoll = false; end
	local sActorType = ActorManagerPO.getType(rTarget);
	local nodeActor = ActorManagerPO.getCreatureNode(rTarget);
	local nSaveScore = ActorManagerPO.getSaveScore(nodeActor, sSave);
	ActionSave.performRoll(nil, rTarget, sSave, nSaveScore, bSecretRoll, nil, false, sDesc);
end

function rollThresholdOfPain(rTarget)
	rollSave(rTarget, "death", "TOP");
end

function rollCritSave(rTarget)
	rollSave(rTarget, "death", "CRIT");
end

function getMagicalDefenseAdjustment(rSource, sSaveDesc)
	if sSaveDesc == "TOP" then
		local sActorType = ActorManagerPO.getType(rSource);
		local nodeActor = ActorManagerPO.getCreatureNode(rSource);
    	return ActorManagerPO.getMagicalDefenseAdjustment(nodeActor);
    end
    return 0;
end