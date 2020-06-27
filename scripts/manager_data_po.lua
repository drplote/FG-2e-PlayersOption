function onInit()
end

function parseSizeString(sSizeRaw)
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
			return 3; -- Default to medium if we don't know.
		end
end