function onInit()
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
	elseif nPcInit == 10 then
		sMsg = sMsg .. " NPCs go one phase slower!";
	end

	deliverChatMessage(sMsg);

end