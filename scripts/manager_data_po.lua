function onInit()
end

function parseArmorHpFromProperties(sProperties)
	local aHpArray = {};
	if not sProperties then
		return aHpArray;
	end
	local sHp = sProperties:match("HP: *%[(.*)%]");
	
	local aHpLevels = UtilityPO.fromCSV(sHp);
	for _, sHpLevel in ipairs(aHpLevels) do
		table.insert(aHpArray, tonumber(sHpLevel));
	end
	return aHpArray;
end

function parseSizeFromProperties(sProperties)
	if not sProperties then
		return nil;
	end

	local sSizeRaw = sProperties:match("[Ss][Ii][Zz][Ee]:? (%a+)");
	return parseSizeString(sSizeRaw);
end


function parseSizeString(sSizeRaw)
	if not sSizeRaw then
		return nil;
	end
	local sSize = sSizeRaw:lower();
	if sSize:find("tiny") then
		return 1;
	elseif sSize:find("small") then
		return 2;
	elseif sSize:find("medium") then
		return 3;
	elseif sSize:find("large") then
		return 4;
	elseif sSize:find("huge") then
		return 5;
	elseif sSize:find("gargantuan") then
		return 6;
	elseif sSizeRaw:find("T") then
		return 1;
	elseif sSizeRaw:find("S") then
		return 2;
	elseif sSizeRaw:find("M") then
		return 3;
	elseif sSizeRaw:find("L") then
		return 4;
	elseif sSizeRaw:find("H") then
		return 5;
	elseif sSizeRaw:find("G") then
		return 6;
	else 
		return nil;
	end
end