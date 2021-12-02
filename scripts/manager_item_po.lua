function onInit()
end

function getItemNameForPlayer(nodeItem)
	local bIsIdentified = isIdentified(nodeItem);
	local sDisplayName = DB.getValue(nodeItem, "name");
	if not bIsIdentified then
		local sNonIdName = DB.getValue(nodeItem, "nonid_name");
		if sNonIdName and sNonIdName ~= "" then
			sDisplayName = sNonIdName;
		end
	end
	return sDisplayName;
end

function setItemNameForPlayer(nodeItem, sNewName)
	DB.setValue(nodeItem, "nonid_name", "string", sNewName);
end

function tagIfUnidentifiedAndMagical(nodeItem)
	local bIsMagical = isMagical(nodeItem);
	if (not isIdentified(nodeItem)) and bIsMagical then
		tagAsMagical(nodeItem);
	end
	return bIsMagical;
end

function tagAsMagical(nodeItem)
	local sName = getItemNameForPlayer(nodeItem);
	if not sName:lower():find("magic") then
		DB.setValue(nodeItem, "nonid_name", "string", "[Magic]" .. ' ' .. sName);
	end
end

function getItemByName(sItemName)
	return UtilityManagerADND.getItemByName(sItemName);
end

function isIdentified(nodeItem)
	return DB.getValue(nodeItem, "isidentified", 1) == 1
end

function isMagical(nodeItem)
	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
  	local sSubtypeLower = StringManager.trim(DB.getValue(nodeItem, "subtype", "")):lower();

  	return sTypeLower == 'magic' or sSubtypeLower == 'magic';
end