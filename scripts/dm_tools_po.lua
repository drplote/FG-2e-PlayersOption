aHdValues = {
	[1] = 10, [2] = 20,	[3] = 35, [4] = 60, [5] = 90, [6] = 150, [7] = 225, [8] = 375,
	[9] = 600, [10] = 900, [11] = 900, [12] = 1300, [13] = 1300, [14] = 1800, [15] = 1800,
	[16] = 2400, [17] = 2400, [18] = 3000, [19] = 3000, [20] = 4000, [21] = 4000, [22] = 5000
};

aHpValues = {
	[1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 8, [8] = 10, [9] = 12,
	[10] = 14, [11] = 14, [12] = 16, [13] = 16, [14] = 18, [15] = 18, [16] = 20,
	[17] = 20, [18] = 25, [19] = 25, [20] = 30, [21] = 30, [22] = 35;
};

aSpecial = {
	[1] = 4, [2] = 8, [3] = 15, [4] = 25, [5] = 40, [6] = 75, [7] = 125, [8] = 175,
	[9] = 300, [10] = 450, [11] = 450, [12] = 700, [13] = 700, [14] = 950, [15] = 950,
	[16] = 1250, [17] = 1250, [18] = 1550, [19] = 1550, [20] = 2100, [21] = 2100, [22] = 2600
};

aExceptional = {
	[1] = 35, [2] = 45, [3] = 55, [4] = 65, [5] = 75, [6] = 125, [7] = 175, [8] = 275,
	[9] = 400, [10] = 600, [11] = 600, [12] = 850, [13] = 850, [14] = 1200, [15] = 1200,
	[16] = 1600, [17] = 1600, [18] = 2000, [19] = 2000, [20] = 2500, [21] = 2500, [22] = 3000
};

function onInit()
	Comm.registerSlashHandler("oxp", onCalcOsricXp)
end

function onCalcOsricXp(sCmd, sParams)
	local aParams = {};
	if sParams then
		for sParam in sParams:gmatch("%w+") do
			table.insert(aParams, sParam);
		end
	end

	local nHd = 0;
	local nSpecial = 0;
	local nExceptional = 0;
	local nMaxHp = 0;

	if #aParams == 0 then
		ChatManagerPO.deliverChatMessage("Usage: /osricxp #hd #special #exceptional #maxhp")
	else
		nHd = tonumber(aParams[1]);
	end
	if #aParams > 1 then
		nSpecial = tonumber(aParams[2]);
	end
	if #aParams > 2 then
		nExceptional = tonumber(aParams[3])
	end
	if #aParams > 3 then
		nMaxHp = tonumber(aParams[4])
	else
		nMaxHp = 8 * nHd;
	end

	local nXp = calcOsricXp(nHd, nSpecial, nExceptional, nMaxHp);

	local result = string.format("XP Value(%s hd, %s special, %s exceptional, %s max hp): %s", nHd, nSpecial, nExceptional, nMaxHp, nXp);
	ChatManagerPO.deliverChatMessage(result);
end

function calcOsricXp(nHd, nSpecial, nExceptional, nMaxHp)
	if nHd > 21 then
		nHd = 21;
	elseif nHd < 0 then
		nHd = 0;
	end

	local nIndex = nHd + 1;

	local nHdXp = aHdValues[nIndex];
	local nSpecialXp = aSpecial[nIndex] * nSpecial;
	local nExceptionalXp = aExceptional[nIndex] * nExceptional;
	local nHpValue = aHpValues[nIndex] * nMaxHp;

	return nHdXp + nSpecialXp + nExceptionalXp + nHpValue;
end