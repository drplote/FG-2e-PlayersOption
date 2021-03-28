OOB_MSGTYPE_REQUEST_FIXED_INIT = "requestFixedInitSequence";


function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_REQUEST_FIXED_INIT, handleRequestFixedInitSequence);
end

-- Speeds: 1 = Very Fast, 2 = Fast, 3 = Average, 4 = Slow, 5 = Very Slow

function getWorstPossiblePhaseForActor(nodeActor)
	local nPhase = getBaseActorSpeedPhase(nodeActor);
	for _,nodeWeapon in pairs(DB.getChildren(nodeActor, "weaponlist")) do
		local nWeaponPhase = getWeaponPhase(nodeWeapon, nodeActor);
		nPhase = math.max(nPhase, nWeaponPhase);
	end
	return nPhase;
end

function getPhaseName(nInitPhase)
	if nInitPhase < 1 then
		return "very fast+";
	elseif nInitPhase == 1 then
		return "very fast";
	elseif nInitPhase == 2 then
		return "fast";
	elseif nInitPhase == 3 then
		return "average";
	elseif nInitPhase == 4 then
		return "slow";
	elseif nInitPhase == 5 then
		return "very slow";
	else 
		return "very slow-";
	end

end

function getBaseActorSpeedPhase(nodeActor)
	if not nodeActor then
		return 3;
	end

	local nBaseSpeed;
	local nSizeCategory = ActorManagerPO.getSizeCategory(nodeActor);
	if nSizeCategory == 1 or nSizeCategory == 2 then
		nBaseSpeed = 1;
	elseif nSizeCategory == 3 then
		nBaseSpeed = 2;
	elseif nSizeCategory == 4 then
		nBaseSpeed = 3;
	elseif nSizeCategory == 5 then
		nBaseSpeed = 4;
	else 
		nBaseSpeed = 5;
	end

	
	local nMovementRateModifierToPhase = getMovementRateModifierToPhase(nodeActor);
	local nEncumbranceModifierToPhase = getEncumbranceModifierToPhase(nodeActor);
	Debug.console("Base Speed Phase", nBaseSpeed, "Movement Rate Modifier", nMovementRateModifierToPhase, "Encumbrance Modifier", nEncumbranceModifierToPhase);
	nBaseSpeed = nBaseSpeed + nMovementRateModifierToPhase + nEncumbranceModifierToPhase;

	nBaseSpeed = math.max(1, math.min(5, nBaseSpeed)); -- bounds check
	return nBaseSpeed;
end

function getMovementRateModifierToPhase(nodeActor)
	local nMovementRate = DB.getValue(nodeActor, "speed.total", 12);
	if nMovementRate >= 18 then
		return -1;
	elseif nMovementRate <= 6 then
		return 1;
	else
		return 0;
	end
end

function getEncumbranceModifierToPhase(nodeActor)
	local sEncumbranceRank = DB.getValue(nodeActor, "speed.encumbrancerank", "");
	if sEncumbranceRank == "Moderate" then
		return 1;
	elseif sEncumranceRank == "Heavy" then
		return 2;
	elseif sEncumbranceRank == "Severe" or sEncumbranceRank == "MAX" then
		return 3;
	else
		return 0;
	end
end

function getSpellPhase(nSpellInitMod)

	local nSpellPhase = 5;
	if nSpellInitMod <= 0 then
		nSpellPhase = 1;
	elseif nSpellInitMod <= 3 then
		nSpellPhase = 2;
	elseif nSpellInitMod <= 6 then
		nSpellPhase = 3;
	elseif nSpellInitMod <= 9 then
		nSpellPhase = 4;
	else
		nSpellPhase = 5;
	end

	Debug.console("Spell Phase", nSpellPhase, "Spell init", nSpellInitMod);
	return nSpellPhase;
end

function getWeaponPhaseFromSpeed(nSpeedFactor, nodeActor)
	Debug.console("Weapon Speed Factor", nSpeedFactor);
	if PlayerOptionManager.isUsingReactionAdjustmentForInitiative() and nodeActor then
		local nReactionAdj = DB.getValue(nodeActor, "abilities.dexterity.reactionadj", 0);
		nSpeedFactor = nSpeedFactor - nReactionAdj;
		Debug.console("Weapon Speed Factor after Reaction Adjustment", nSpeedFactor);
	end

	local nWeaponPhase = 5;
	if nSpeedFactor <= 0 then
		nWeaponPhase = 1;
	elseif nSpeedFactor <= 4 then
		nWeaponPhase = 2;
	elseif nSpeedFactor <= 7 then
		nWeaponPhase = 3;
	elseif nSpeedFactor <= 13 then
		nWeaponPhase = 4;
	else
		nWeaponPhase = 5;
	end

	Debug.console("Weapon Phase", nWeaponPhase);
	return nWeaponPhase;
end

function getWeaponPhase(nodeWeapon, nodeActor)
	if not nodeWeapon then
		return 0;
	end

	local nSpeedFactor = WeaponManagerPO.getSpeedFactor(nodeWeapon);
	return getWeaponPhaseFromSpeed(nSpeedFactor, nodeActor);
end

function delayActorForSegments(nodeChar, nDelay)
	local nodeCT = CombatManager.getCTFromNode(nodeChar);
	local nodeCTActive = CombatManager.getActiveCT();
	if nodeCT == nodeCTActive then
		CombatManagerPO.notifyDelayTurn(nDelay);
	else
		ChatManagerPO.deliverDelayFailedMessage(nodeChar);
	end
	return true;
end

function delayActor(nodeChar)
	if PlayerOptionManager.isUsingHackmasterInitiative() then
		InitManagerPO.delayActorForSegments(nodeChar, 10);
	else
		local nodeCT = CombatManager.getCTFromNode(nodeChar);
		local nodeCTActive = CombatManager.getActiveCT();
		if nodeCT == nodeCTActive then
		    if PlayerOptionManager.isUsingPhasedInitiative() then
                CombatManagerPO.notifyDelayTurn();
            else
	  			local nLastInit = CombatManagerADND.getLastInitiative();
	  			CombatManagerADND.showCTMessageADND(nodeEntry,DB.getValue(nodeCT,"name","") .. " " .. Interface.getString("char_initdelay_message"));
	  			if Session.IsHost then 
	    			CombatManager.nextActor();
	  			else 
	    			CombatManager.notifyEndTurn();
	  			end
  				CombatManagerADND.notifyInitiativeChange(nodeCT,nLastInit + 1);
  			end
  		else
  			ChatManagerPO.deliverDelayFailedMessage(nodeChar);
		end
	end
end

function getActiveInit()
	local nodeActive = CombatManager.getActiveCT();
	if not nodeActive then
		return 0;
	end

	return DB.getValue(nodeActive, "initresult", 0);
end

function generateDefaultHackmasterInit(nodeCT, nodeWeapon)
	local rItem = WeaponManagerADND.builtInitiativeItem(nodeWeapon);
	local rActor = ActorManager.resolveActor(nodeCT);	
	local rRoll = ActionInitPO.getHackmasterInitRoll(rActor, true, rItem);
	ActionInit.modRoll(rActor, nil, rRoll);

	local nInitResult = 0;
	if rRoll.nDieType and rRoll.nDieType > 0 then
		nInitResult = nInitResult + math.random(rRoll.nDieType);
	end

	nInitResult = nInitResult + rRoll.nMod;
	return nInitResult;
end

function rollInitForSimilarCreatures(nodeCT, nodeAction, bUnrolledOnly)
    local aSimilarActors = CombatManagerPO.getSimilarCreaturesInCT(nodeCT);
    for _,nodeActor in pairs(aSimilarActors) do
    	if not bUnrolledOnly or DB.getValue(nodeActor, "initrolled", 0) == 0 then
        	WeaponManagerADND.onInitiative(nil, nodeActor, nodeAction);
        end
    end
end

function cloneInitToSimilarCreatures(nodeCT, bUnrolledOnly)
	local aSimilarActors = CombatManagerPO.getSimilarCreaturesInCT(nodeCT);
	local nSourceInitResult = DB.getValue(nodeCT, "initresult", 99);
	local nSourceInitRolled = DB.getValue(nodeCT, "initrolled", 0);
	local nSourceInitQueue = DB.getValue(nodeCT, "initQueue", nil);

    for _,nodeActor in pairs(aSimilarActors) do
    	if not bUnrolledOnly or DB.getValue(nodeActor, "initrolled", 0) == 0 then
        	DB.setValue(nodeActor, "initresult", "number", nSourceInitResult);
        	DB.setValue(nodeActor, "initrolled", "number", nSourceInitRolled);
        	DB.setValue(nodeActor, "initQueue", "string", nSourceInitQueue);
        end
    end
end

function getNextActorInit(nodeCT)
	local nActiveInit = getActiveInit();
	local aQueue = getAllActorInits();
	if aQueue and #aQueue > 1 then
		for _,nInit in pairs(aQueue) do
			if nInit <= nActiveInit then
				return nInit;
			end
		end
	end

	return nil;
end

function addDelayToActorInitQueue(nodeCT, nDelay)
	local aQueue = getActorInitQueue(nodeCT);
	if aQueue and #aQueue > 0 then
		local aNewQueue = {};
		for _,nInit in pairs(aQueue) do
			table.insert(aNewQueue, nInit + nDelay);
		end
		setActorInitQueue(nodeCT, aNewQueue);
	end
end


function addInitToActor(nodeCT, nNewInit)
	local nActiveInit = InitManagerPO.getActiveInit();
	if nNewInit < nActiveInit then
		nNewInit = nActiveInit + 1;
	end

	local nInitResult = DB.getValue(nodeCT, "initresult", 0);

	if nInitResult < nActiveInit then
		-- initresult is a turn that already happened
		DB.setValue(nodeCT, "initresult", "number", nNewInit);
	elseif nNewInit < nInitResult then
		DB.setValue(nodeCT, "initresult", "number", nNewInit);
		addActorInitToQueue(nodeCT, nInitResult);
	else			
		addActorInitToQueue(nodeCT, nNewInit);
	end

	return nNewInit;
end

function getAllActorInits(nodeCT)
	local aQueue = getActorInitQueue(nodeCT);
	table.insert(aQueue, 1, DB.getValue(nodeCT, "initresult", 0));
	return aQueue;
end

function addActorInitToQueue(nodeCT, nInit)
	local aQueue = getActorInitQueue(nodeCT);
	if nInit == DB.getValue(nodeCT, "initresult", 0) then
		nInit = nInit + 1;
	end

	while UtilityPO.contains(aQueue, nInit) do
		nInit = nInit + 1;
	end
	table.insert(aQueue, nInit);
	setActorInitQueue(nodeCT, aQueue);
	return 
end

function setActorInitQueue(nodeCT, aQueue)
	table.sort(aQueue);
	DB.setValue(nodeCT, "initQueue", "string", UtilityPO.toCSV(aQueue));
end

function getActorInitQueue(nodeCT)
	local aQueue = {};
	local sQueue = DB.getValue(nodeCT, "initQueue", nil);
	if sQueue then
		local aStringQueue = UtilityPO.fromCSV(sQueue);
		for _,s in pairs(aStringQueue) do
			table.insert(aQueue, tonumber(s));
		end
	end
	return aQueue;
end

function hasAdditionalInitsInQueue(nodeCT)
	local sInitQueue = DB.getValue(nodeCT, "initQueue");
	return sInitQueue ~= nil and sInitQueue ~= "";
end

function popActorInitFromQueue(nodeCT)
	local aQueue = getActorInitQueue(nodeCT);
	local nInit = nil;
	if aQueue and #aQueue > 0 then
		nInit = table.remove(aQueue, 1);
		setActorInitQueue(nodeCT, aQueue);
	end
	return nInit;
end

function clearActorInitQueue(nodeCT)
	DB.setValue(nodeCT, "initQueue", "string", nil);
end

function moveActorToNextInit(nodeCT)
	local nInitResult = DB.getValue(nodeCT, "initresult", 0);
	local nNextInit = popActorInitFromQueue(nodeCT);
	if nNextInit ~= nil then
		DB.setValue(nodeCT, "initresult", "number", nNextInit);
		return nNextInit;
	end
	return nil;
end

function requestSetActorFixedAttackRate(nodeChar, nNumAttacks)
  local msgOOB = {};
  msgOOB.type = OOB_MSGTYPE_REQUEST_FIXED_INIT;
  msgOOB.sNumAttacks = tostring(nNumAttacks);
  msgOOB.sCharNodeName = nodeChar.getNodeName();
  Comm.deliverOOBMessage(msgOOB, "");
end

function handleRequestFixedInitSequence(msgOOB)
	local nodeChar = ActorManager.resolveActor(msgOOB.sCharNodeName);
	setActorFixedAttackRate(nodeChar, tonumber(msgOOB.sNumAttacks));
end

function setActorFixedAttackRate(nodeChar, nNumAttacks)
	local nodeCT = ActorManager.getCTNode(nodeChar);

	if not nNumAttacks or nNumAttacks < 1 or nNumAttacks > 5 then
		Debug.console("nNumAttacks", nNumAttacks, "Only support a value of 1-5");
		return;
	end

	DB.setValue(nodeCT, "initrolled", "number", 1);
	DB.setValue(nodeCT, "initresult", "number", 1);

	local aInits = {};
	if nNumAttacks == 1 then
		setActorInitQueue(nodeCT, {});
	elseif nNumAttacks == 2 then
		setActorInitQueue(nodeCT, {6});
	elseif nNumAttacks == 3 then
		setActorInitQueue(nodeCT, {5, 9});
	elseif nNumAttacks == 4 then
		setActorInitQueue(nodeCT, {4, 7, 10});
	elseif nNumAttacks == 5 then
		setActorInitQueue(nodeCT, {3, 5, 7, 9});
	end

	if ActorManagerPO.isPC(nodeCT) then
		ChatManagerPO.deliverRateOfFireInitMessage(nodeCT, nNumAttacks);
	end
end

function clearActorInitQueueBelowThreshold(nodeCT, nThreshold)
	local aQueue = getActorInitQueue(nodeCT);
	if aQueue and #aQueue > 0 then
		local aNewQueue = {};
		for _,nInit in pairs(aQueue) do
			if nInit >= nThreshold then
				table.insert(aNewQueue, nInit);
			end
		end
		setActorInitQueue(nodeCT, aNewQueue);
	end
end

function moveHackmasterActorToNextRound(nodeCT, nInitMOD)
	local nInitResult = 0;
	local nPreviousInitResult = DB.getValue(nodeCT, "previnitresult", 0);

	InitManagerPO.addDelayToActorInitQueue(nodeCT, -10);
	clearActorInitQueueBelowThreshold(nodeCT, 1);

	if nPreviousInitResult > 10 then
        nInitResult = nPreviousInitResult - 10;
    elseif InitManagerPO.hasAdditionalInitsInQueue(nodeCT) then 
        nInitResult = InitManagerPO.popActorInitFromQueue(nodeCT);
    else 
	    if PlayerOptionManager.isDefaultingPcInitTo99() then
	        nInitResult = 99;
	    else
	        nInitResult = CombatManagerADND.rollRandomInit(nInitPC + nInitMOD);
	    end
	end
	return nInitResult;
end


function rollSequencedAttackInit(nodeChar, nNumAttacks)
	ModifierStackPO.setSequencedInitModifierKey(nNumAttacks);
    local rActor = ActorManager.resolveActor(nodeChar);
    ActionInit.performRoll(nil, rActor);
end

function getMeleeInitDieType()
	if not PlayerOptionManager.isUsingHackmasterInitiative() then
		return 10;
	end

	local nSequencedAttacks = ModifierStackPO.peekSequencedInitModifierKey();

	if nSequencedAttacks == 2 then
		return 5;
	elseif nSequencedAttacks == 3 then
		return 3;
	elseif nSequencedAttacks == 4 then
		return 3;
	elseif nSequencedAttacks == 5 then
		return 2;
	else
		return 10;
	end

end