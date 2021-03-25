-- Most of this file was copy and pasted from the 2E ruleset. Couldn't just extend the control's script because the control wasn't named.

-- list of entries and their locations
aHyperEntries = {}

dragging = false;
local hoverOnEntry = nil;
local clickOnEntry = nil;
local nodeAction = nil;
local rAttackRecord = nil;

function onInit()
	createRadialMenu(); -- NOTE: This is one of the few changes to this file

    nodeAction = window.getDatabaseNode();
    DB.addHandler(DB.getPath(nodeAction), "onChildUpdate", refreshText);
    refreshText();
end

function onClose()
    DB.removeHandler(DB.getPath(nodeAction), "onChildUpdate", refreshText);
end

function createRadialMenu()
	RadialMenuManagerPO.initCombatTrackerActionMenu(self);

    registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
    registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
end

--[[

]]
function onMenuSelection(selection, subselection, subsubselection)
	Debug.console("onMenuSelection", selection, subselection, subsubselection);
    if selection == 6 and subselection == 7 then
        nodeAction.delete();
	else -- NOTE: This is one of the few changes to this file
		RadialMenuManagerPO.onCombatTrackerActionMenuSelection(self, selection, subselection, subsubselection);
	end
end

function performAttackAction()
	actionAbility(nil, rAttackRecord);
end

local powerUsePeriodPretty = {
    ["once"] = "charges",
    ["enc"]  = "rest",
}
--[[

    Rebuild text list

]]--
function refreshText()
    local nodeEntry = nodeAction;
    -- determine if we're using weapons or powers
    local bWeaponEntry = nodeAction.getPath():match("(%.weaponlist%.)") == '.weaponlist.';
    local bPowerEntry = not bWeaponEntry;
    local sText = "";
    --Debug.console("cta_action_item.lua","refreshText","nodeEntry",nodeEntry);            

    -- action name
    local rRecordName = {};
    rRecordName.type = 'name'
    rRecordName.name = DB.getValue(nodeEntry,"name","no-name-set");
    -- special tweaks for powers
    if bPowerEntry then
        local nMemorized = DB.getValue(nodeEntry,"memorized",0);
        local nLevel = DB.getValue(nodeEntry,"level",0);
        local nPrepared = DB.getValue(nodeEntry,"prepared",0);
        local nHasCast  = DB.getValue(nodeEntry,"cast",0);
        local sUsesperiod = DB.getValue(nodeEntry,"usesperiod","");
        local sUsesPeriodPretty = powerUsePeriodPretty[sUsesperiod];
        if nMemorized > 0 then
            rRecordName.name = rRecordName.name .. " x" .. nMemorized;
            rRecordName.name = rRecordName.name .. " (lvl " .. nLevel .. ")"
        elseif nPrepared and sUsesperiod:len() > 0 then
            rRecordName.name = rRecordName.name .. " [" .. StringManager.capitalize(sUsesPeriodPretty) .. " x" .. (nPrepared-nHasCast) .. "]" ;
        elseif nPrepared > 1 then
            rRecordName.name = rRecordName.name .. " x" .. (nPrepared-nHasCast);
        elseif sUsesperiod:len() > 0 then            
            rRecordName.name = rRecordName.name .. " [" .. StringManager.capitalize(sUsesPeriodPretty) .. "]" ;
        elseif nLevel > 0 then
            rRecordName.name = rRecordName.name .. " (lvl " .. nLevel .. ")"
        end
    end
    sText = addHyperTextRecord(sText,rRecordName,nodeEntry,true,true);

    if bWeaponEntry then
        sText = addWeaponEntry(sText,nodeEntry)
    elseif bPowerEntry then
        sText = addPowerEntry(sText,nodeEntry)
    else
        -- unknown action type
    end

    -- -- action edit
    -- local rRecordEDIT = {};
    -- rRecordEDIT.type = 'edit'
    -- rRecordEDIT.class = '';
    -- rRecordEDIT.name = 'EDIT';
    -- sText = addHyperTextRecord(sText,rRecordEDIT,nodeEntry);

    -- -- action details
    -- local rRecordDETAILS = {};
    -- rRecordDETAILS.type = 'details'
    -- rRecordDETAILS.class = '';
    -- rRecordDETAILS.name = 'DETAILS';
    -- sText = addHyperTextRecord(sText,rRecordDETAILS,nodeEntry);

    if sText == "" then
        sText = "Empty";
    end

    --Debug.console("cta_action_item.lua","refreshText","sText",sText);           
    setValue(sText);
end
--[[
    Add a power entry
]]
function addPowerEntry(sText,nodeEntry)
    -- action init
    local rRecordInit = {};
    rRecordInit.type = 'powerinitiative'
    rRecordInit.name = 'INIT'
    local nCastInit = DB.getValue(nodeEntry,"castinitiative",1);
    if nCastInit ~= 0 then
        rRecordInit.tooltiptext = 'Initiative ' .. UtilityManagerADND.getNumberSign(nCastInit);
    end

    sText = addHyperTextRecord(sText,rRecordInit,nodeEntry);

    -- mini-action button(s)
    local aSortedActions = sortByOrders(DB.getChildren(nodeEntry,"actions"));
    local bCastFound = false;
    if #aSortedActions > 0 then
        for _,nodeMiniAction in pairs(aSortedActions) do
            local rRecord = {};
            sText, bCastFound = addMiniAction(sText, nodeMiniAction,rRecord,bCastFound);
        end
    end

    return sText;
end

-- used to replace certain types with differet name
local miniActionTypeToShortName = {
    ["effect"] = "eff",
    ["damage"] = "dmg",
    ["powerdamage"] = "dmg",
  };
-- used to replace certain 
  local miniActionPowerTypeConversion = {
      ["damage"] = "powerdamage",
  }
--[[
    Add a mini power action (save,dmg,effect/etc)
]]
function addMiniAction(sText, nodeMiniAction, rRecordACTION, bCastFound, sNailedType)
    local sType = DB.getValue(nodeMiniAction,'type');
    -- sanity checking 
    if not sType and not sNailedType then
        return sText, bCastFound;
    end
    if sNailedType then
        sType = sNailedType;
    end

    local sTooltipText = '';

    -- set spell damage type to "powerdamage"
    if miniActionPowerTypeConversion[sType] then
        sType = miniActionPowerTypeConversion[sType];
    end
    rRecordACTION.type = sType;
    -- check for name replacement, if powerdamage set to short name
    if miniActionTypeToShortName[sType] then
        rRecordACTION.name = StringManager.capitalize(miniActionTypeToShortName[sType]);
    else
        rRecordACTION.name = StringManager.capitalize(sType);
    end
    -- we add CR/LF to next line it when we have more than 1 cast per spell
    if bCastFound and sType == 'cast' then
        if UtilityManager.isClientFGU() then
            sText = sText .. '\r';
        else
            sText = sText .. '\n\r';
        end
    end
    if sType == 'cast' and not bCastFound then
        bCastFound = true;
    end
    local sSaveType = DB.getValue(nodeMiniAction,"savetype");
    local nSaveMod = DB.getValue(nodeMiniAction,"savedcmod",0);
    local sOnMissSave = DB.getValue(nodeMiniAction,"onmissdamage");
    local sMod = UtilityManagerADND.getNumberSign(nSaveMod);
    -- if spell is save, include save type in command
    if sType == 'cast' and sSaveType then
        sTooltipText = rRecordACTION.name .. " vs " .. StringManager.capitalize(sSaveType);
        if nSaveMod ~= 0 then
            sTooltipText = sTooltipText .. ' ' .. sMod;
        end
        if sOnMissSave then
            sTooltipText = sTooltipText .. ' for ' .. StringManager.capitalize(sOnMissSave)
        end
    elseif sType == 'save' then
        rRecordACTION.name = rRecordACTION.name .. " vs " .. StringManager.capitalize(sSaveType);
        if nSaveMod ~= 0 then
            rRecordACTION.name = rRecordACTION.name .. ' ' .. sMod;
        end
        if sOnMissSave then
            sTooltipText = rRecordACTION.name .. ' for ' .. StringManager.capitalize(sOnMissSave)
            rRecordACTION.name = rRecordACTION.name .. " (" .. StringManager.capitalize(sOnMissSave) .. ")";
        end
    elseif sType == 'effect' then
        local sLabel = DB.getValue(nodeMiniAction,"label","");
        local sAddendum = DB.getValue(nodeMiniAction,"label",""):match("^[%w]+");
        if sLabel ~= sAddendum then
            sTooltipText =  sLabel;
        end
        if not sAddendum or sAddendum:len() < 1 then
            sAddendum = sLabel;
        end
        if sAddendum and sAddendum:len() > 0 then
            rRecordACTION.name = rRecordACTION.name .. ": " .. sAddendum;
        end
    elseif sType == miniActionPowerTypeConversion['damage'] then
        local sDMG   = PowerManager.getActionDamageText(nodeMiniAction);
        rRecordACTION.name = rRecordACTION.name .. " " .. sDMG;
    elseif sType == 'heal' then
        local sHeal   = PowerManager.getActionHealText(nodeMiniAction);
        rRecordACTION.name = rRecordACTION.name .. " " .. sHeal;
    end

    if sTooltipText:len() > 0 then
        rRecordACTION.tooltiptext = sTooltipText;
    end

    sText = addHyperTextRecord(sText,rRecordACTION,nodeMiniAction);

    -- since "save" is not a action type we insert one here
    if sType == 'cast' and sSaveType then
        local rRecordSave = {}
        sText, bCastFound = addMiniAction(sText, nodeMiniAction,rRecordSave,bCastFound,'save');
    end
    
    return sText, bCastFound;
end

--[[
    Add a weapon entry 
]]
function addWeaponEntry(sText,nodeEntry)

    -- action init
    local rRecordInit = {};
    rRecordInit.type = 'initiative'
    rRecordInit.name = 'INIT'

    sText = addHyperTextRecord(sText,rRecordInit,nodeEntry);

    -- action atk
    local rRecordATK = {};
    rRecordATK.type = 'attack'
    rRecordATK.name = 'ATK'  .. "(" .. WeaponManagerADND.getRange(nodeEntry) .. ")" .. WeaponManagerADND.onAttackChanged(nodeEntry);
    sText = addHyperTextRecord(sText,rRecordATK,nodeEntry);
    rAttackRecord = rRecordATK;

    -- action dmg(s)
    for _,nodeDamage in pairs(UtilityManager.getSortedTable(DB.getChildren(nodeEntry,"damagelist"))) do
        local rRecordDMG = {};
        local sDMG, sTooltipText = WeaponManagerADND.onDamageChanged(nodeDamage);
        rRecordDMG.type = 'damage'
        rRecordDMG.name = 'DMG ' .. sDMG;
        if sTooltipText:len() > 0 then
            rRecordDMG.tooltiptext = sTooltipText;
        end
        sText = addHyperTextRecord(sText,rRecordDMG,nodeDamage);
    end
    return sText;
end

--[[
    Add record to text, set values, particularly the nStart/nEnd
]]
function addHyperTextRecord(sText,rRecord,nodeEntry,bNoBrackets,bNoHighlight)
    rRecord.recordpath = nodeEntry.getPath();
    if not bNoBrackets then
        sText = sText .. "[";
    end
    
    if bNoHighlight then
        rRecord.nStart = 0;
    else
        rRecord.nStart = sText:len() + 1;
    end
    if rRecord.name:len() < 1 then
        Debug.console("cta_action_item.lua","addHyperTextRecord","Name empty: rRecord",rRecord); 
    end
    sText = sText .. rRecord.name;

    if bNoHighlight then
        rRecord.nEnd = 0;
    else
        rRecord.nEnd = sText:len() + 1;
    end

    if not bNoBrackets then
        sText = sText .. "] ";
    else
        sText = sText .. " ";
    end

    table.insert(aHyperEntries,rRecord);

    return sText;
end

--[[
    When hovering over the template control
]]
function onHover(oncontrol)
--Debug.console("cta_action_item.lua","onHover","oncontrol",oncontrol);                
    if dragging then
        return;
    end

    -- Clear selection when no longer hovering over us
    if not oncontrol then
        -- Clear hover tracking
        hoverOnEntry = nil;
        
        -- Clear any selections
        setSelectionPosition(0);
        setTooltipText('');
    end
end

--[[
    When hovering over the control and mouse moves
]]
function onHoverUpdate(x, y)
    -- we do not mess about when we are dragging a record
    if dragging then
        return;
    end

    -- store the index of the mouse position
    local nMouseIndex = getIndexAt(x, y);
    -- Clear any memory of the last hover update
    hoverOnEntry = nil;
    
    -- Find the entry they have hovered over
    if #aHyperEntries > 0 then
        for _, v in pairs(aHyperEntries) do
            if (nMouseIndex >= v.nStart) and (nMouseIndex <= v.nEnd) then
                hoverOnEntry = v;
                -- dont need tooltip if the name and tooltip are the same
                if v.tooltiptext and vtooltiptext ~= v.name then
                    setTooltipText(UtilityManagerADND.stripFormattedText(v.tooltiptext));
                else
                    setTooltipText('');
                end
                setCursorPosition(v.nStart);
                setSelectionPosition(v.nEnd);
                break;
            end
        end
    end

    -- Reset the cursor
    setHoverCursor("arrow");
end
    
    --[[
    When clicking on the highlighted text run this
]]
function onClickDown(button, x, y)
    --Debug.console("cta_action_item.lua","onClickDown","button",button);       
    if hoverOnEntry then
        clickOnEntry = hoverOnEntry;
    end
    return true;
end

--[[

]]
function onClickRelease(button, x, y)
    return true;
end
--[[

]]
function onDoubleClick(x, y)
    --Debug.console("cta_action_item.lua","onDoubleClick","x",x);          
    actionAbility(nil, clickOnEntry);
    return true;
end


--[[
    Not implemented yet
]]
function onDragStart(button, x, y, draginfo)
--Debug.console("cta_action_item.lua","onDragStart","draginfo",draginfo);        
    dragging = false;
    if clickOnEntry then
        dragging = actionAbility(draginfo, clickOnEntry);
        clickOnEntry = nil;
    end

    return dragging;
end
--[[

    At the end of a drag, cleanup

]]
function onDragEnd(dragdata)
    setCursorPosition(0);
    setSelectionPosition(0);
    setTooltipText('');
	dragging = false;
end        

--[[
    Run action
]]
function actionAbility(draginfo, rRecord)
	Debug.console("cta_action_item.lua", "rAttackRecord", rAttackRecord);
Debug.console("cta_action_item.lua","actionAbility","rRecord",rRecord);       
Debug.console("cta_action_item.lua","actionAbility","rRecord.type",rRecord.type);            
	local bResult = true;
    if not rRecord then
        return false;
    end
	-- USAGE
	if rRecord.type == "usage" then
		if draginfo then
			bResult = false;
		elseif rPower.sUsage == "USED" then
			rechargePower(rPower);
		else
			usePower(rPower);
		end
	-- ATTACK
    elseif rRecord.type == "attack" then
        WeaponManagerADND.onAttackAction(draginfo, getActor(),nodeAction);
	-- SAVE VS
	elseif rRecord.type == "save" then
        PowerManagerADND.onCastAction(draginfo, getActor(), DB.findNode(rRecord.recordpath),'save');
	-- DAMAGE
    elseif rRecord.type == "damage" then
        WeaponManagerADND.onDamageActionSingle(draginfo, getActor(),DB.findNode(rRecord.recordpath));
	-- HEAL
	elseif rRecord.type == "heal" then
        --ActionHeal.performRoll(draginfo, getActor(), rAction);
        PowerManagerADND.onHealAction(draginfo, getActor(), DB.findNode(rRecord.recordpath))
	-- EFFECT
    elseif rRecord.type == "effect" then
        PowerManagerADND.onEffectAction(draginfo, getActor(), DB.findNode(rRecord.recordpath))
    elseif rRecord.type == "initiative" then
        WeaponManagerADND.onInitiative(draginfo, getActor(), nodeAction)
    elseif rRecord.type == "powerinitiative" then
        PowerManagerADND.onCastInitiative(draginfo, getActor(), nodeAction);
    elseif rRecord.type == 'cast' then
        PowerManagerADND.onCastAction(draginfo, getActor(), DB.findNode(rRecord.recordpath));
    elseif rRecord.type == 'powerdamage' then
        PowerManager.performAction(draginfo, DB.findNode(rRecord.recordpath));
    end

    return bResult;
end

--[[

]]
function getActor()
	local nodeActor = nil;
	local node = nodeAction;
	if node then
		nodeActor = node.getChild(actorpath[1]);
    end
    
    --return ActorManager.getActor(actortype[1], nodeActor);
    return ActorManager.resolveActor( nodeActor);
end

--[[
    Convenience function to sort by order
]]
function sortByOrders(aTable)
    local function sortByOrder(a,b)
        return DB.getValue(a,"order") < DB.getValue(b,"order");
    end
    local aSorted = {};
    for _,v in pairs(aTable) do
        table.insert(aSorted,v);
    end
    table.sort(aSorted,sortByOrder);
    return aSorted;
end

--[[
    Convenience function to sort by level
]]
function sortByLevels(aTable)
    local function sortByLevel(a,b)
        return DB.getValue(a,"level") < DB.getValue(b,"level");
    end
    local aSorted = {};
    for _,v in pairs(aTable) do
        table.insert(aSorted,v);
    end
    table.sort(aSorted,sortByLevel);
    return aSorted;
end