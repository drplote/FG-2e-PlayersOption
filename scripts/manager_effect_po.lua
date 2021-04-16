local fOnEffectActorStartTurn;

OOB_MSGTYPE_REQUEST_ADD_EFFECT = "requestAddEffect";

function onInit()
	fOnEffectActorStartTurn = EffectManagerADND.onEffectActorStartTurn;
	EffectManagerADND.onEffectActorStartTurn = onEffectActorStartTurnOverride;
    EffectManager.setCustomOnEffectActorStartTurn(onEffectActorStartTurnOverride);

    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_REQUEST_ADD_EFFECT, handleRequestAddEffect);
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

function isAllowedToCrit(rSource)
	if not rSource then
		return true;
	end
	
	return not EffectManager5E.hasEffect(rSource, "NOCRIT", nil);
end

function hasSpellRazor(rSource)
	if not rSource then
		return false;
	end
	
	return EffectManager5E.hasEffect(rSource, "SPELLRAZOR", nil);
end

function isAllowedToPenetrate(rSource)
	if not rSource then
		return true;
	end

	return not EffectManager5E.hasEffect(rSource, "NOPENETRATE", nil);
end

function requestAddEffect(nodeChar, sEffectName, nDuration, bUseActiveInitSegment)
  local msgOOB = {};
  msgOOB.type = OOB_MSGTYPE_REQUEST_ADD_EFFECT;
  msgOOB.sEffectName = sEffectName;
  msgOOB.sCharNodeName = nodeChar.getNodeName();
  msgOOB.sDuration = tostring(nDuration);
  msgOOB.sUseActiveInitSegment = tostring(bUseActiveInitSegment);

  Comm.deliverOOBMessage(msgOOB, "");
end

function handleRequestAddEffect(msgOOB)
	local nodeChar = ActorManager.resolveActor(msgOOB.sCharNodeName);
    local sEffectName = msgOOB.sEffectName;
    local nDuration = tonumber(msgOOB.sDuration);
    local useActiveInitSegment = tonumber(msgOOB.sUseActiveInitSegment);

    local nodeCT = ActorManager.getCTNode(nodeChar);
    Debug.console("nodeCT", nodeCT);

    if nDuration then
	    if msgOOB.sUseActiveInitSegment then
	    	local nCurrentInit = DB.getValue(nodeCT, "initresult", 0);
	    	EffectManager.addEffect("", "", nodeCT, { sName = sEffectName, sLabel = sEffectName, nDuration = nDuration, nInit = nCurrentInit }, true);
	    else
	    	EffectManager.addEffect("", "", nodeCT, { sName = sEffectName, sLabel = sEffectName, nDuration = nDuration }, true);
	    end
	else
		EffectManager.addEffect("", "", nodeCT, { sName = sEffectName, sLabel = sEffectName }, true);
	end
end
