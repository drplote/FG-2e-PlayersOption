function onInit()
end

-- TODO: all this code is incomplete and needs help

function rollSave(rTarget, sSave, sDesc, bSecretRoll)
	if not bSecretRoll then bSecretRoll = false; end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rTarget);
	local nSaveScore = ActorManagerPO.getSaveScore(nodeActor, sSave);
	ActionSave.performRoll(nil, rTarget, sSave, nSaveScore, bSecretRoll, nil, false, sDesc);
end

function rollThresholdOfPain(rTarget)
	rollSave(rTarget, "death", "TOP", false);
	-- todo: automate save vs death with wisdom bonus and apply unconscious effect
end

function getWisdomSaveMod(rSource, sSave)
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rSource);
    return ActorManagerPO.getMagicalDefenseAdjustment(nodeActor);
end