function onInit()
	Comm.registerSlashHandler("detectmagic", onDetectMagic)
end

function onDetectMagic(sCmd, sParam)
	if not Session.IsHost then
		ChatManagerPO.deliverChatMessage("Only the DM can use /detectmagic.");
		return;
	end

	local bDoNotTagItems = sParam == "1";

	local aDetected = {};
	for _,v in pairs(DB.getChildren("partysheet.partyinformation")) do
		local sClass, sRecord = DB.getValue(v, "link");
		if sClass == "charsheet" and sRecord then
			local nodePC = DB.findNode(sRecord);
			if nodePC then
				local sCharacterName = DB.getValue(nodePC, "name", "");
				detectMagicOnItems(aDetected, sCharacterName, DB.getChildren(nodePC, "inventorylist"), bDoNotTagItems);
			end
		end
	end
	detectMagicOnItems(aDetected, "Party Sheet", DB.getChildren("partysheet.treasureparcelitemlist"), bDoNotTagItems);
	ChatManagerPO.deliverDetectMagicResults(aDetected);
end

function detectMagicOnItem(aDetected, sOwner, nodeItem, bDoNotTagItems)
	local bIsMagical = false;
	if bDoNotTagItems then
		bIsMagical = ItemManagerPO.isMagical(nodeItem);
	else
		bIsMagical = ItemManagerPO.tagIfUnidentifiedAndMagical(nodeItem)
	end

	if bIsMagical then
		table.insert(aDetected, {owner = sOwner, itemName = ItemManagerPO.getItemNameForPlayer(nodeItem)});
	end
end

function detectMagicOnItems(aDetected, sOwner, aItems, bDoNotTagItems)
	for _, nodeItem in pairs(aItems) do
		detectMagicOnItem(aDetected, sOwner, nodeItem, bDoNotTagItems)
	end
end