local fGetRoll;

function onInit()
	fGetRoll = ActionInit.getRoll;
	ActionInit.getRoll = getRollOverride;
end

function getRollForPhasedInit(rActor, bSecretRoll, rItem)
  local rRoll = {};
  rRoll.sType = "init";
  rRoll.aDice = { "d0" };
  rRoll.nMod = 13; -- Default to last
  rRoll.sDesc = "[INIT]";
  rRoll.bSecret = bSecretRoll;

  local sActorType = ActorManagerPO.getType(rActor);
  local nodeActor = ActorManagerPO.getCreatureNode(rActor);
  if nodeActor then
	local nInitPhase = InitManagerPO.getBaseActorSpeedPhase(nodeActor);
  	if rItem then
		if rItem.spellPath then
			local nCastInit = DB.getValue(DB.findNode(rItem.spellPath), "castinitiative", 99);
			nInitPhase = InitManagerPO.getSpellPhase(nCastInit);
			rRoll.sDesc = rRoll.sDesc .. " [Spell:" .. InitManagerPO.getPhaseName(nInitPhase) .. "]";
			nInitPhase = CombatManagerPO.getFinalInitForActor(nodeActor, nInitPhase, false);
		else
			rRoll.sDesc = rRoll.sDesc .. " [Base:" .. InitManagerPO.getPhaseName(nInitPhase) .. "]";
			local nWeaponInitPhase = InitManagerPO.getWeaponPhaseFromSpeed(rItem.nInit, nodeActor);
			rRoll.sDesc = rRoll.sDesc .. " [Weapon:" .. InitManagerPO.getPhaseName(nWeaponInitPhase) .. "]";
			nInitPhase = math.max(nWeaponInitPhase, nInitPhase);			
			nInitPhase = CombatManagerPO.getFinalInitForActor(nodeActor, nInitPhase, true);
		end
	else
		rRoll.sDesc = rRoll.sDesc .. " [Base: " .. InitManagerPO.getPhaseName(nInitPhase) .. "]";
		nInitPhase = CombatManagerPO.getFinalInitForActor(nodeActor, nInitPhase, true);
	end
	rRoll.nMod = nInitPhase;
  end
    
  return rRoll;
end

function getFixedInitiativeRoll(nFixedInit, bSecretRoll)
  local rRoll = {};
  rRoll.sType = "init";
  rRoll.aDice = { "d0" };
  rRoll.nMod = nFixedInit; -- Default to last
  rRoll.sDesc = "[INIT][FORCED]";
  rRoll.bSecret = bSecretRoll;
  return rRoll;
end

function getRollOverride(rActor, bSecretRoll, rItem)
    if PlayerOptionManager.isUsingPhasedInitiative() then
        return getRollForPhasedInit(rActor, bSecretRoll, rItem);
    end

    if ModifierStack.getModifierKey("INIT_START_ROUND") then
    	return getFixedInitiativeRoll(1);
    elseif ModifierStack.getModifierKey("INIT_END_ROUND") then
    	if PlayerOptionManager.isUsingHackmasterInitiative() then
			return getFixedInitiativeRoll(10);
		else
			return getFixedInitiativeRoll(99);
		end
    end

	local rRoll = fGetRoll(rActor, bSecretRoll, rItem);
	if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() then
		if rActor and rItem then
			local sActorType = ActorManagerPO.getType(rActor);
			local nodeActor = ActorManagerPO.getCreatureNode(rActor);
			if nodeActor then
				local nReactionAdj = 0 - DB.getValue(nodeActor, "abilities.dexterity.reactionadj", 0);
				rRoll.sDesc = rRoll.sDesc .. "[Reaction Adj: " .. nReactionAdj .. "]";
				rRoll.nMod = rRoll.nMod + nReactionAdj;
			end
		end
	end
	HonorManagerPO.addInitiativeModifier(rActor, rRoll);
	return rRoll;
end
