local fOnEffectActorStartTurn;

function onInit()
	fOnEffectActorStartTurn = EffectManagerADND.onEffectActorStartTurn;
	EffectManagerADND.onEffectActorStartTurn = onEffectActorStartTurnOverride;
    EffectManager.setCustomOnEffectActorStartTurn(onEffectActorStartTurnOverride);
end

function onEffectActorStartTurnOverride(nodeActor, nodeEffect)
	if not PlayerOptionManager.isUsingPhasedInitiative() then
		fOnEffectActorStartTurn(nodeActor, nodeEffect);
		return;
	end

	if not StateManagerPO.hasRunStartEffect(nodeActor, nodeEffect) then
		fOnEffectActorStartTurn(nodeActor, nodeEffect);
		StateManagerPO.setRanStartEffect(nodeActor, nodeEffect);
	end
end


