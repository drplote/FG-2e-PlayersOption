function onInit()
    ActionsManager.registerModHandler("honor", modRoll);
    ActionsManager.registerResultHandler("honor", onRoll);
end

function modRoll(rSource, rTarget, rRoll)
	if rRoll.aDice[1] ~= "d0" then
		modifyRollForHonor(rRoll, getHonorState(rSource));
	end
end

function onRoll(rSource, rTarget, rRoll)  
  local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
  Comm.deliverChatMessage(rMessage);
end

function rollHonorDice(rChar, draginfo)
	local sHonorDice = getHonorDice(rChar);
	local rRoll = getRoll(sHonorDice);
	ActionsManager.performAction(draginfo, rChar, rRoll);
end

function getRoll(sHonorDice)
  local rRoll = {};
  rRoll.sType = "honor";
  rRoll.sDesc = "[HONOR ROLL (" .. sHonorDice .. ")]";

  local sDieType = sHonorDice:match("d%d+");
  if sDieType then 
  	rRoll.aDice = { sDieType };
  	local sBonus = sHonorDice:match("+(%d+)");
  	if sBonus then
  		rRoll.nMod = tonumber(sBonus);
  	else
  		rRoll.nMod = 0;
  	end
  else
  	rRoll.aDice = { "d0" };
  	rRoll.nMod = 1;
  end
  
  return rRoll;
end

function getHonorDice(rChar)
	local nodeChar = ActorManagerPO.getNode(rChar);
	return DB.getValue(nodeChar, "abilities.honor.honorDice", "1");
end

function getHonorState(rChar)
	if not rChar or not PlayerOptionManager.isHonorEnabled() then
		return 0;
	else
		local sNodeType = ActorManager.getType(rChar);
		local nodeChar = ActorManager.getCreatureNode(rChar);
		if sNodeType == "pc" then
			return DB.getValue(nodeChar, "abilities.honor.honorState", 0);
		else
		  local sSpecialAttacks = DB.getValue(nodeChar, "specialAttacks", "");
		  return DataManagerPO.parseHonorStateFromString(sSpecialAttacks);
		end
	end
end

function modifyRollForHonor(rRoll, nHonorState, bLowerIsBetter)
	if not PlayerOptionManager.isHonorEnabled() then
		return;
	end

	if not rRoll.nMod then
		rRoll.nMod = 0;
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

function addCritSeverityModifier(rChar, rRoll)
	modifyRollForHonor(rRoll, getHonorState(rChar));
end