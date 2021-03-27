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

function getHackmasterInitRoll(rActor, bSecretRoll, rItem)
	if ModifierStack.getModifierKey("INIT_START_ROUND") then
		return getFixedInitiativeRoll(1);
	elseif ModifierStack.getModifierKey("INIT_END_ROUND") then
		return getFixedInitiativeRoll(10);
	end
	
	local rRoll = {};
	rRoll.sType = "init";
	rRoll.nMod = 0;
	rRoll.sDesc = "[INIT]";
	rRoll.bSecret = bSecretRoll;

	local bIsFixedInitiative = (rItem and (rItem.nType and rItem.nType ~= 0)) or Input.isShiftPressed();
	local bIsSpell = false;
	if bIsFixedInitiative then -- ranged weapons go on a fixed initiative
		rRoll.aDice = { "d0" }; 
		rRoll.nDieType = 0;
		rRoll.nMod = 1;
		rRoll.sDesc = rRoll.sDesc .. "[Ranged]";
	elseif rItem and rItem.spellPath then -- Spells either go on a fixed initiative, or in +1d4 segments if they have material components  	
		bIsSpell = true;
		rRoll.sDesc = rRoll.sDesc .. "[Spell]";
		if DB.getValue(DB.findNode(rItem.spellPath), "components", ""):match("M") then -- Does it have material componenets?
			rRoll.aDice = { "d4" };
			rRoll.nDieType = 4;
		else
			rRoll.aDice = { "d0" };
			rRoll.nDieType = 0;
			bIsFixedInitiative = true;
		end
		local nSpellSpeed = math.min(rItem.nInit, 10);
		rRoll.nMod = nSpellSpeed; -- Cap spell time at 10.
		rRoll.sDesc = rRoll.sDesc .. " [MOD (" .. rItem.sName .. "): " .. nSpellSpeed .. "]";
	else
		rRoll.aDice = { "d10" };   
		rRoll.nDieType = 10; 
	end  

    -- Determine the modifier and ability to use for this roll
    local sAbility = nil;
    local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
	    if rItem then
	    	if not bIsFixedInitiative and not bIsSpell then
	    		modifyRollForDexterity(rActor, rItem, rRoll);
	    		
	    		if not rItem.isNil then
		    		local nWeaponSpeed = rItem.nInit -5; -- Subtract 5 because all the HM weapons have 5 less speed than 2E Counterparts
	            	rRoll.nMod = rRoll.nMod + nWeaponSpeed ;   		
	        		rRoll.sDesc = rRoll.sDesc .. " [MOD (" .. rItem.sName .. "): " .. nWeaponSpeed .. "]";
	        	end
	    	end
	    elseif sActorType == "pc" then
	        rRoll.nMod = DB.getValue(nodeActor, "initiative.total", 0);
	    else     
	      rRoll.nMod = 0;
	    end
	end
  return rRoll;
end

function getBaseRulesetRoll(rActor, bSecretRoll, rItem)
    if ModifierStack.getModifierKey("INIT_START_ROUND") then
    	return getFixedInitiativeRoll(1);
    elseif ModifierStack.getModifierKey("INIT_END_ROUND") then
		return getFixedInitiativeRoll(99);
    end

	local rRoll = fGetRoll(rActor, bSecretRoll, rItem);

	if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() then
		modifyRollForDexterity(rActor, rItem, rRoll);
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

	return rRoll;
end

function modifyRollForDexterity(rActor, rItem, rRoll)
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

    local rRoll;
    if PlayerOptionManager.isUsingHackmasterInitiative() then
    	rRoll = getHackmasterInitRoll(rActor, bSecretRoll, rItem);
    else
    	rRoll = getBaseRulesetRoll(rActor, bSecretRoll, rItem);
    end


	HonorManagerPO.addInitiativeModifier(rActor, rRoll);
	return rRoll;
end
