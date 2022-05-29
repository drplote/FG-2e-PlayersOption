function onInit()
	registerDiceMechanic("penDice", processPenetratingDice, processDefaultResults)
	registerDiceMechanic("penDicePlus", processPenetratingDicePlus, processDefaultResults)
	Comm.registerSlashHandler("pdie", onPenetratingDiceSlashCommand)
	Comm.registerSlashHandler("pdiep", onPenetratingDicePlusSlashCommand)
	Comm.registerSlashHandler("pen", onPenetratingDiceSlashCommand)
	Comm.registerSlashHandler("penplus", onPenetratingDicePlusSlashCommand)
end

function processDefaultResults(draginfo)
	local rCustomData = draginfo.getCustomData() or {}
	local aDieResults = decodeDiceResults(rCustomData.rollresults)

	local rMessage = ChatManager.createBaseMessage()
    rMessage.dicedisplay = 1; --  display total
	rMessage.font = "systemfont"
	rMessage.text = draginfo.getDescription()
	rMessage.dice = aDieResults
	rMessage.diemodifier = draginfo.getNumberData()
	Comm.deliverChatMessage(rMessage)

	return true
end

function decodeDiceResults(sSource)
	if not sSource then
		return {}
	end
	local aDieResults = {}
	local nIndex = 0
	while nIndex do
		local nStartIndex, nNextIndex = sSource:find("^d%d+:%d+:%d;", nIndex)
		if nNextIndex then
			local sDieSource = sSource:sub(nStartIndex, nNextIndex-1)
			local sType, sResult, sExploded = sDieSource:match("^(d%d+):(%d+):(%d)")
			table.insert(aDieResults, { type = sType, result = tonumber(sResult), exploded = tonumber(sExploded) })
			nIndex = nNextIndex + 1
		else
			nIndex = nil 
		end
	end
	return aDieResults
end

function onDiceLanded(draginfo)
	local sDragType = draginfo.getType()
	local bProcessed = false
	local bPreventProcess = false

	local rCustomData = draginfo.getCustomData() or {}

	-- dice handling
	for sType, fCallback in pairs(aDiceMechanicHandlers) do
		if sType == sDragType then
			bProcessed, bPreventProcess = fCallback(draginfo)
		end
	end

	-- results
	if not bPreventProcess then
		for sType, fCallback in pairs(aDiceMechanicResultHandlers) do
			if sType == sDragType then
				fCallback(draginfo)
			end
		end
	end

	return bProcessed
end

function multiplyDice(rRoll, nMultiplier)
	local aExtraDice = {};
	for i = 1, nMultiplier - 1 do
		local aNewDice = createExtraDice(rRoll);
		for j = 1, #aNewDice do
			table.insert(aExtraDice, aNewDice[j]);
		end
	end
	for i = 1, #aExtraDice do
		table.insert(rRoll.aDice, aExtraDice[i]);
	end
end

function addDie(rRoll, nDieType)
	local newDie = {};
	newDie.type = "g" .. nDieType;
	newDie.result = math.random(1, nDieType);
	table.insert(rRoll.aDice, newDie);
end

function handlePenetration(rRoll, penPlus)
  checkForPenetration(rRoll, penPlus);  
  createPenetrationDice(rRoll);
end

function rollPenetrateInBothDirection(nNumSides)
	local nValue = math.random(1, nNumSides);
	if nValue == nNumSides then	
		nValue = nValue + (rollPenetrateInBothDirection(nNumSides) - 1);
	elseif nValue == 1 then
		nValue = nValue - (rollPenetrateInBothDirection(nNumSides) - 1);
	end
	return nValue;
end

function createExtraDice(rRoll)
	local aNewDice = {};
	for _, vDie in ipairs(rRoll.aDice) do
		local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
		local newDie = {};
		newDie.type = "g" .. sDieSides;
		local nSides = tonumber(sDieSides) or 0;
		newDie.result = math.random(1, nSides);
		table.insert(aNewDice, newDie);
	end
	return aNewDice;
end

function createPenetrationDice(rRoll)
  for _,vDie in ipairs(rRoll.aDice) do
	local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
	if vDie.penetrationRolls then
		for _, rPenRoll in ipairs(vDie.penetrationRolls) do
			local newDie = {};
			newDie.type = "r" .. sDieSides;
			newDie.result = rPenRoll - 1;
			newDie.isPenetrationRoll = true;
			table.insert(rRoll.aDice, newDie);
		end		
	end
  end
end

function checkForPenetration(rRoll, penPlus)
  for _,vDie in ipairs(rRoll.aDice) do
    local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
	local nSides = tonumber(sDieSides) or 0;
	if needsPenetrationRoll(nSides, vDie.result, penPlus) then	
		local lRolls = {};
	  getPenetrationRolls(lRolls, nSides, penPlus);
		vDie.penetrationRolls = lRolls;
    end
  end
end

function getDamageRoll(nNumDice, nNumSides, nBonus) -- Rolls with penetration, minimum of 1
	local nTotal = getDiceResult(nNumDice, nNumSides, 1, nBonus);
	return math.max(nTotal, 1);
end

function getDiceResult(nNumDice, nNumSides, nPenetration, nBonus) -- nPenetration 0 = normal roll, 1 = penetration, 2 = penetration plus
	if not nBonus then nBonus = 0; end
	local nTotal = 0;
	for i = 1, nNumDice, 1 do
		nTotal = nTotal + getDieResult(nNumSides, nPenetration);
	end
	if nBonus then
		nTotal = nTotal + nBonus;
	end
	return nTotal;
end

function getDieResult(nNumSides, nPenetration) -- nPenetration 0 = normal roll, 1 = penetration, 2 = penetration plus
	if not nPenetration or nNumSides <= 3 then nPenetration = 0; end
	
	local nDieResult = math.random(1, nNumSides);
	if (nPenetration ~= 0 and nDieResult == nNumSides) or (nPenetration == 2 and nDieResult == nNumSides - 1) then
		nDieResult = nDieResult + getDiceResult(nNumSides, nPenetration) - 1;
	end
	return nDieResult;
end

function needsPenetrationRoll(rSides, rResult, penPlus)
	if rSides < 3 then
		return false
	elseif rResult == rSides  then
		return true
	elseif penPlus and rResult == rSides - 1 then
		return true
	else
		return false
	end
end

function getPenetrationRolls(rRolls, rSides, penPlus)
	
	local lDamage = math.random(1, rSides);
	table.insert(rRolls, lDamage);
	
	if needsPenetrationRoll(rSides, lDamage, penPlus) then	
		getPenetrationRolls(rRolls, rSides, penPlus)
	end	
end

function toCommaSepartedString(tt)
	local s = "";
	for _, p in ipairs(tt) do
		s = s .. "," .. p
	end
	return string.sub(s, 2);
end

function getPenetrationTotal(aDice)
	local nTotal = 0;
	for _, vDie in pairs(aDice) do
		if vDie.penetrationRolls then
			for _, nRoll in ipairs(vDie.penetrationRolls) do
				nTotal = nTotal + nRoll - 1;
			end
		end
	end

	return nTotal;
end


function onPenetratingDiceSlashCommand(sCmd, sParam)
	if sParam then
		local sDieString = sParam
		local sDescription1 = sParam
		local nSeparationStart, nSeparationEnd = sParam:find("%s+")
		if nSeparationStart then
			sDieString = sParam:sub(1, nSeparationStart-1)
			sDescription1 = sParam:sub(nSeparationEnd+1)
		end
		
		local aDices, nMod = StringManager.convertStringToDice(sDieString)
	
		local rThrow = {}
		rThrow.type = "penDice"
		rThrow.description = sDescription1
		rThrow.secret = false
	
		local rSlot = {}
		rSlot.dice = aDices
		rSlot.number = nMod
		rSlot.custom = {}
		rThrow.slots = { rSlot }
	
		Comm.throwDice(rThrow)
	end
end

function onPenetratingDicePlusSlashCommand(sCmd, sParam)
	if sParam then
		local sDieString = sParam
		local sDescription1 = sParam
		local nSeparationStart, nSeparationEnd = sParam:find("%s+")
		if nSeparationStart then
			sDieString = sParam:sub(1, nSeparationStart-1)
			sDescription1 = sParam:sub(nSeparationEnd+1)
		end
		
		local aDices, nMod = StringManager.convertStringToDice(sDieString)
	
		local rThrow = {}
		rThrow.type = "penDicePlus"
		rThrow.description = sDescription1
		rThrow.secret = false
	
		local rSlot = {}
		rSlot.dice = aDices
		rSlot.number = nMod
		rSlot.custom = {}
		rThrow.slots = { rSlot }
	
		Comm.throwDice(rThrow)
	end
end

local aDiceMechanicHandlers = {}
local aDiceMechanicResultHandlers = {}
function registerDiceMechanic(sDiceMechanicType, callback, callbackResults)
	aDiceMechanicHandlers[sDiceMechanicType] = callback
	if callbackResults then
		aDiceMechanicResultHandlers[sDiceMechanicType] = callbackResults
	end
end
function unregisterDiceMechanic(sDiceMechanicType)
	if aDiceMechanicHandlers then
		aDiceMechanicHandlers[sDiceMechanicType] = nil
		aDiceMechanicResultHandlers[sDiceMechanicType] = nil
	end
end

function onDiceLanded(draginfo)
	local sDragType = draginfo.getType()
	local bProcessed = false
	local bPreventProcess = false
	
	local rCustomData = draginfo.getCustomData() or {}
	
	-- dice handling
	for sType, fCallback in pairs(aDiceMechanicHandlers) do
		if sType == sDragType then
			bProcessed, bPreventProcess = fCallback(draginfo)
		end
	end
	
	-- results
	if not bPreventProcess then
		for sType, fCallback in pairs(aDiceMechanicResultHandlers) do
			if sType == sDragType then
				fCallback(draginfo)
			end
		end
	end
	
	return bProcessed
end

-- penetrate on max
function processPenetratingDice(draginfo)
	return processPenetration(draginfo, false)
end

-- Penetrate on max and max -1
function processPenetratingDicePlus(draginfo)
	return processPenetration(draginfo, true)
end

function getNumOriginalDice(aDice)
	if not aDice then
		return 0;
	end
	local nNumDice = 0;
	for _, vDie in pairs(aDice) do
		if vDie.result then
			nNumDice = nNumDice + 1;
		end
	end
	for _, vDie in pairs(aDice) do
		if vDie.penetrationRolls then
			nNumDice = nNumDice - #vDie.penetrationRolls;
		end
	end
	return nNumDice;
end

function getNumPenetrationDice(aDice)
	if not aDice then return 0; end

	return #aDice - getNumOriginalDice(aDice);
end

function getNumOriginalDiceThatPenetrated(aDice)
	if not aDice then
		return 0;
	end

	local nNumOriginalPenetrations = 0;
	for _, vDie in pairs(aDice) do
		if type(vDie) == 'table' then
			if vDie.penetrationRolls and not vDie.isPenetrationRoll then
				nNumOriginalPenetrations = nNumOriginalPenetrations + 1;
			end
		end
	end
	return nNumOriginalPenetrations;
end

-- penetration means if you roll max on the die (or also max -1 for penPlus), you roll again and subtract 1
function processPenetration(draginfo, penPlus)

	local rSource, rRolls, aTargets = ActionsManager.decodeActionFromDrag(draginfo, true);
	
	for _,vRoll in ipairs(rRolls) do
		if (#(vRoll.aDice) > 0) or ((vRoll.aDice.expr or "") ~= "") then
			handlePenetration(vRoll, penPlus);
			ActionsManager.resolveAction(rSource, nil, vRoll);
		end
	end
end

function getDiceTotal(rRoll)
	local nTotal = 0;
	
	for _,v in ipairs(rRoll.aDice) do
		if not v.dropped then
			if v.value then
				nTotal = nTotal + v.value;
			else
				nTotal = nTotal + v.result;
			end
		end
	end

	return nTotal;
end

function applyBaseRollMultiplier(rRoll, nMultiplier)
	if nMultiplier < 0 or nMultiplier == 1 then
		return;
	end

	local nDiceTotal = getDiceTotal(rRoll);
	local nNewResult = nDiceTotal * nMultiplier;
	
	if nMultiplier > 1 then
		nNewResult = math.floor(nNewResult);
	else
		nNewResult = math.min(math.ceil(nNewResult), 1);
	end

	local nChange = nNewResult - nDiceTotal;
	local sPlusMinus = "+";
	if nMultiplier < 1 then
		sPlusMinus = "-";
	end

	rRoll.nMod = rRoll.nMod + nChange;
	rRoll.sDesc = rRoll.sDesc .. " [x" .. nMultiplier .. " = " .. sPlusMinus .. " " .. math.abs(nChange) .. "]"; 
end