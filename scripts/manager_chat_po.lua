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