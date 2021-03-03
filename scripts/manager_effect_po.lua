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

function hasImmunity(rSource, rTarget, sImmunity)
	local aImmune = EffectManager5E.getEffectsByType(rTarget, "IMMUNE", {}, rSource);
	
	local aImmuneConditions = {};
	for _,v in pairs(aImmune) do
		for _,vType in pairs(v.remainder) do
			if vType:lower() == sImmunity:lower() then
				return true;
			end
		end
	end
	return false;
end

function isNotAllowedToCrit(rSource)
	return EffectManager5E.hasEffect(rTarget, "NOCRIT", nil);
end

