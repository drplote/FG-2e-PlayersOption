function onInit()
end

function deliverInitQueueMessage(nodeCT, nNewInit)
	local sName = ActorManager.getDisplayName(nodeCT);
	local aQueue = InitManagerPO.getAllActorInits(nodeCT);
	local sMessage = sName .. " rolled an additional intiative of " .. nNewInit .. ". They now have attacks on " .. UtilityPO.toCSV(aQueue) .. ".";
	deliverChatMessage(sMessage);	
end

function deliverRateOfFireInitMessage(nodeCT, nNumAttacks)
	local sName = ActorManager.getDisplayName(nodeCT);
	local aQueue = InitManagerPO.getAllActorInits(nodeCT);
	local sMessage = sName .. " has a fixed rate of fire of " .. nNumAttacks .. ". They have attacks on " .. UtilityPO.toCSV(aQueue) .. ".";
	deliverChatMessage(sMessage);	
end

function deliverChatMessage(sText, sType)
	--local rMessage = ChatManager.createBaseMessage();
	--if sType then
	--	rMessage.type = sType;
	--end
	--rMessage.text = sText;
	ChatManager.Message(sText, true);
	--ChatManager.SystemMessage(sText);
end

function deliverEndTurnFailedMessage(nodeChar)
	if nodeChar then
		local sName = DB.getValue(nodeChar, "name", "");
		deliverChatMessage(sName .. " tried to end their turn when it wasn't their turn.");
	end
end

function deliverDelayTurnMessage(nodeChar, nDelay)
	if nodeChar then
		local sName = DB.getValue(nodeChar, "name", "");
		local sMessage = sName .. " delays their turn";
		if PlayerOptionManager.isUsingPhasedInitiative() then
			sMessage = sMessage .. " one phase";
		else
			if nDelay and nDelay > 0 then
				sMessage = sMessage .. " " .. nDelay .. " segments"
			end
			sMessage = sMessage .. ".";
		end
		deliverChatMessage(sMessage);
	end
end

function deliverDelayFailedMessage(nodeChar)
	if nodeChar then
		local sName = DB.getValue(nodeChar, "name", "");
		deliverChatMessage(sName .. " tried to delay when it wasn't their turn.");
	end
end

function deliverTurnRequestMessage(nodeChar, nPreviousInit)
	if nodeChar then
		Debug.console(nodeChar);
		local sName = DB.getValue(nodeChar, "name", "");
		deliverChatMessage(sName .. " will now act on the next segment (previous init " .. nPreviousInit .. " ).");
	end
end

function deliverArmorSoakMessage(sCharName, sItemName, nDamageSoaked, nArmorDamageTaken)
	local sDamageMsg = sCharName .. "'s " .. sItemName .. " soaks " .. nDamageSoaked .. " and takes " .. nArmorDamageTaken .. " damage.";
	deliverChatMessage(sDamageMsg);
end

function deliverArmorBrokenMessage(sCharName, sItemName)
	deliverChatMessage(sCharName .. "'s " .. sItemName .. " breaks!");
end

function deliverCriticalHitMessage(sMessage)
	deliverChatMessage("[CRITICAL HIT] " .. sMessage);
end

function deliverInitRollMessage(nPcInit, nNpcInit)
	local sMsg = "";
	if nPcInit < nNpcInit then
		sMsg = "PCs win initiative! (" .. nPcInit .. " vs " .. nNpcInit .. ").";
	else
		sMsg = "NPCs win intiative! (" .. nNpcInit .. " vs " .. nPcInit .. ").";
	end

	if nPcInit == 1 then
		sMsg = sMsg .. " PCs go one phase faster!";
	elseif nPcInit == 10 then
		sMsg = sMsg .. " PCs go one phase slower!";
	end

	if nNpcInit == 1 then
		sMsg = sMsg .. " NPCs go one phase faster!";
	elseif nNpcInit == 10 then
		sMsg = sMsg .. " NPCs go one phase slower!";
	end

	deliverChatMessage(sMsg);

end