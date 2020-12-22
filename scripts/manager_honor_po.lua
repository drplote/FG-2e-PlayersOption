function onInit()
end

function getHonorState(rChar)
	if not rChar or not PlayerOptionManager.isHonorEnabled() then
		return 0;
	else
		local nodeChar = ActorManagerPO.getNode(rChar);
		return DB.getValue(nodeChar, "abilities.honor.honorState", 0);
	end
end

function modifyRollForHonor(rRoll, nHonorState, bLowerIsBetter)
	if not PlayerOptionManager.isHonorEnabled() then
		return;
	end

	local nModifier = #rRoll.aDice;
	if bLowerIsBetter then 
		nModifier = nModifier * -1;
	end
	
	if nHonorState == 1 then
		rRoll.sDesc = rRoll.sDesc .. "[Great Honor]";
		rRoll.nMod = rRoll.nMod + nModifier;
	elseif nHonorState == -1 then
		rRoll.sDesc = rRoll.sDesc .. "[Dishonor]";
		rRoll.nMod = rRoll.nMod - nModifier;
	end
end

function addAttackModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar));
end

function addSaveModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar));
end

function addDamageModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar));
end

function addAttributeCheckModiifer(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar), true);
end

function addHealModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar));
end

function addPercentileSkillCheckModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar), true);
end

function addInitiativeModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar), true);
end