local fGetRoll;

function onInit()
	fGetRoll = ActionInit.getRoll;
	ActionInit.getRoll = getRollOverride;
end

function getRollOverride(rActor, bSecretRoll, rItem)
	local rRoll = fGetRoll(rActor, bSecretRoll, rItem);
	if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() then
		if rActor and rItem then
			local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
			if nodeActor then
				local nReactionAdj = 0 - DB.getValue(nodeActor, "abilities.dexterity.reactionadj", 0);
				rRoll.sDesc = rRoll.sDesc .. "[Reaction Adj: " .. nReactionAdj .. "]";
				rRoll.nMod = rRoll.nMod + nReactionAdj;
			end
		end
	end
	return rRoll;
end
