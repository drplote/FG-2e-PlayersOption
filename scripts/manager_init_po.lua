function onInit()
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