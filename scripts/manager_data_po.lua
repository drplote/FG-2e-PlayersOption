function onInit()
end

function parseMoraleFromString(sString)
	if UtilityPO.isEmpty(sString) then
		return nil;
	end
	local aNumbersInString = {};
	for sMatch in sString:gmatch("%d+") do
    	table.insert(aNumbersInString, tonumber(sMatch));
	end

	if #aNumbersInString == 0 then
		return nil;
	elseif #aNumbersInString == 1 then
		return aNumbersInString[1];
	else
		return math.floor(UtilityPO.average(aNumbersInString));
	end
end

function parseFatigueFactorFromString(sString)
	if not sString then
		return nil;
	end

	local sLower = sString:lower();

	local sFF = sLower:match("ff: *(%d*)");
	return sFF;
end

function parseDamageReductionFromProperties(sProperties)
	if not sProperties then
		return nil;
	end
	local sLower = sProperties:lower();

	local sDR = sLower:match("dr: *(%d*)");
	if not sDR then return 0; end
	return tonumber(sDR);
end

function parseArmorHpFromProperties(sProperties)
	local aHpArray = {};
	if not sProperties then
		return aHpArray;
	end

	local sLower = sProperties:lower();
	local sHp = sLower:match("hp: *%[(.*)%]");
	
	local aHpLevels = UtilityPO.fromCSV(sHp);
	for _, sHpLevel in ipairs(aHpLevels) do
		table.insert(aHpArray, tonumber(sHpLevel));
	end
	return aHpArray;
end

function parseArmorDamageImmunitiesFromProperties(sProperties)
	if not sProperties then
		return aImmunities;
	end
	local sLower = sProperties:lower();
	local sImmune = sLower:match("immune: *(.*)");

	return UtilityPO.fromCSV(sImmune);
end

function parseSizeFromProperties(sProperties)
	if not sProperties then
		return nil;
	end

	local sSizeRaw = sProperties:match("[Ss][Ii][Zz][Ee]:? (%a+)");
	return parseSizeString(sSizeRaw);
end

function parsePotencyFromProperties(sProperties)
	if not sProperties then
		return nil;
	end

	local sLower = sProperties:lower();

	local sPotency = sLower:match("potency: *(%d*)");
	if not sPotency then
		return nil;
	end
	return tonumber(sPotency);
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
	elseif sSize:find("medium") or sSize:find("man-sized") then
		return 3;
	elseif sSize:find("large") then
		return 4;
	elseif sSize:find("huge") then
		return 5;
	elseif sSize:find("gargantuan") then
		return 6;
	elseif sSizeRaw:find("^T") then
		return 1;
	elseif sSizeRaw:find("^S") then
		return 2;
	elseif sSizeRaw:find("^M") then
		return 3;
	elseif sSizeRaw:find("^L") then
		return 4;
	elseif sSizeRaw:find("^H") then
		return 5;
	elseif sSizeRaw:find("^G") then
		return 6;
	else 
		return nil;
	end
end

function parseHonorStateFromString(sString)
	if not sString then
		return 0;
	end

	local sLower = sString:lower();

	if sLower:find("greathonor") or sLower:find("great honor") then
		return 1;
	elseif sLower:find("dishonor") then
		return -1;
	else
		return 0;
	end
end

function parseArmorVsWeaponTypeModifiersFromProperties(sProperties)
	if not sProperties then
		return nil;
	end

	local sLower = sProperties:lower();

	local sSlashing = sLower:match("slashing: *(%-?%d+)");
	local sBludgeoning = sLower:match("bludgeoning: *(%-?%d+)");
	local sPiercing = sLower:match("piercing: *(%-?%d+)");

	if not sSlashing and not sBludgeoning and not sPiercing then
		return nil;
	end

	local aModifiers = {["slashing"] = 0, ["piercing"] = 0,  ["bludgeoning"] = 0};
	if sSlashing then aModifiers["slashing"] = tonumber(sSlashing); end
	if sBludgeoning then aModifiers["bludgeoning"] = tonumber(sBludgeoning); end
	if sPiercing then aModifiers["piercing"] = tonumber(sPiercing); end
	
	return aModifiers;
end
