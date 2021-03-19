function onInit()
end

function getItemNameForPlayer(nodeItem)
	local bIsIdentified = DB.getValue(nodeItem, "isidentified", 1) == 1;
	local sDisplayName = DB.getValue(nodeItem, "name");
	if not bIsIdentified then
		local sNonIdName = DB.getValue(nodeItem, "nonid_name");
		if sNonIdName and sNonIdName ~= "" then
			sDisplayName = sNonIdName;
		end
	end
	return sDisplayName;
end

function getItemByName(sItemName)
	return UtilityManagerADND.getItemByName(sItemName);
end