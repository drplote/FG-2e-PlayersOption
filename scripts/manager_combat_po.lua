local fRollNpcHitPoints;
local fCopySourceToNodeCT;
local fAddCTANPC;

function onInit()
    fRollNpcHitPoints = CombatManagerADND.rollNPCHitPoints;
    CombatManagerADND.rollNPCHitPoints = rollNPCHitPointsOverride;

    fRollEntryInit = CombatManagerADND.rollEntryInit;
    CombatManagerADND.rollEntryInit = rollEntryInitOverride;
    CombatManager2.rollEntryInit = rollEntryInitOverride; -- We have to override this because CombatManagerADND overrode this

    fCopySourceToNodeCT = CombatManagerADND.copySourceToNodeCT;
    CombatManagerADND.copySourceToNodeCT = copySourceToNodeCTOverride;

    CombatManager.setCustomRoundStart(onRoundStart);

    fAddCTANPC = CombatManagerADND.addCTANPC;
    CombatManagerADND.addCTANPC = addCTANPCOverride;
end

function addCTANPCOverride(sClass, nodeNPC, sNamedInBattle)
    local nodeEntry = fAddCTANPC(sClass, nodeNPC, sNamedInBattle);
    CombatManagerADND.copySourceToNodeCT(nodeNPC, nodeEntry);
    return nodeEntry;
end 

function copySourceToNodeCTOverride(nodeSource, nodeCT)
    fCopySourceToNodeCT(nodeSource, nodeCT);
    if PlayerOptionManager.isUsingArmorDamage() then
        -- Need to recalc item AC after they've loaded items from source or their
        -- AC from armor doesn't work correctly.
        CharManager.calcItemArmorClass(nodeCT);
    end
end

function onRoundStart()
    if PlayerOptionManager.isUsingHackmasterFatigue() then
        FatigueManagerPO.handleFatigueForCombatants();
        FatigueManagerPO.clearFatigueState();
    end
    if PlayerOptionManager.shouldRingBellOnRoundStart() then
        for _, sUserName in pairs(User.getActiveUsers()) do
            User.ringBell(sUserName);
        end       
        User.ringBell();
    end
end

function rollEntryInitOverride(nodeEntry)
    if not nodeEntry then
        return;
    end

    local sOptPCVNPCINIT = OptionsManager.getOption("PCVNPCINIT");
    -- Start with the base initiative bonus
    local nInit = DB.getValue(nodeEntry, "init", 0);
    -- Get any effect modifiers
    local rActor = ActorManager.getActorFromCT(nodeEntry);
    local aEffectDice, nEffectBonus = EffectManager5E.getEffectsBonus(rActor, "INIT");
    local nInitMOD = StringManager.evalDice(aEffectDice, nEffectBonus);
    
    -- Check for the ADVINIT effect
    local bADV = EffectManager5E.hasEffectCondition(rActor, "ADVINIT");

    -- For PCs, we always roll unique initiative
    local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
    if sClass == "charsheet" then
        local nodeChar = DB.findNode(sRecord);
        local nInitPC = DB.getValue(nodeChar,"initiative.total",0);
        local nInitResult = 0;
        if sOptPCVNPCINIT == "on" then
            if PC_LASTINIT == 0 then
                nInitResult = CombatManagerADND.rollRandomInit(0, bADV);
                PC_LASTINIT = nInitResult;
            else
                nInitResult = PC_LASTINIT;
            end
        else
            if PlayerOptionManager.isDefaultingPcInitTo99() then
                nInitResult = 99;
            else
                nInitResult = CombatManagerADND.rollRandomInit(nInitPC + nInitMOD, bADV);
            end
        end
    
        DB.setValue(nodeEntry, "initresult", "number", nInitResult);
        return;
    else -- it's an npc
        --[[ We're using PC versus NPC initiative. So both sides roll once w/o modifiers ]]
        if sOptPCVNPCINIT == "on" then
            local nInitResult = 0;
            if NPC_LASTINIT == 0 then
            nInitResult = CombatManagerADND.rollRandomInit(0, bADV);
            NPC_LASTINIT = nInitResult;
            else
            nInitResult = NPC_LASTINIT;
            end
            DB.setValue(nodeEntry, "initresult", "number", nInitResult);
            return;
        end

        -- for npcs we allow them to have custom initiative. Check for it 
        -- and set nInit.
        local nTotal = DB.getValue(nodeEntry,"initiative.total",0);
        -- flip through weaponlist, get the largest speedfactor as default
        local nSpeedFactor = 0;

        for _,nodeWeapon in pairs(DB.getChildren(nodeEntry, "weaponlist")) do
            local nSpeed = DB.getValue(nodeWeapon,"speedfactor",0);
            if nSpeed > nSpeedFactor then
                nSpeedFactor = nSpeed;
            end
        end

        if nSpeedFactor ~= 0 then
            nInit = nSpeedFactor + nInitMOD ;
        elseif (nTotal ~= 0) then 
            nInit = nTotal + nInitMOD ;
        end

        --[[ IF we ignore size/mods, clear nInit ]]
        if OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") ~= "on" then
            nInit = 0;
        end
        -- For NPCs, if NPC init option is not group, then roll unique initiative
        local sOptINIT = OptionsManager.getOption("INIT");
        if sOptINIT ~= "group" then
            -- if they have custom init then we use it.
            local nInitResult = CombatManagerADND.rollRandomInit(nInit, bADV);
            DB.setValue(nodeEntry, "initresult", "number", nInitResult);
            return;
        end


        -- For NPCs with group option enabled
        -- Get the entry's database node name and creature name
        local sStripName = CombatManager.stripCreatureNumber(DB.getValue(nodeEntry, "name", ""));
        if sStripName == "" then
            local nInitResult = CombatManagerADND.rollRandomInit(nInit, bADV);
            DB.setValue(nodeEntry, "initresult", "number", nInitResult);
            return;
        end
      
        -- Iterate through list looking for other creature's with same name and faction
        local nLastInit = nil;
        local sEntryFaction = DB.getValue(nodeEntry, "friendfoe", "");
        for _,v in pairs(CombatManager.getCombatantNodes()) do
            if v.getName() ~= nodeEntry.getName() then
                if DB.getValue(v, "friendfoe", "") == sEntryFaction then
                    local sTemp = CombatManager.stripCreatureNumber(DB.getValue(v, "name", ""));
                    if sTemp == sStripName then
                        local nChildInit = DB.getValue(v, "initresult", 0);
                        if nChildInit ~= -10000 then
                            nLastInit = nChildInit;
                        end
                    end
                end
            end
        end

        -- If we found similar creatures, then match the initiative of the last one found
        if nLastInit then
            DB.setValue(nodeEntry, "initresult", "number", nLastInit);
        else
            local nInitResult = CombatManagerADND.rollRandomInit(nInit, bADV);
            DB.setValue(nodeEntry, "initresult", "number", nInitResult);
        end
    end 
end

function rollNPCHitPointsOverride(nodeChar)
    return fRollNpcHitPoints(nodeChar) + getHpKicker(nodeChar);
end


function getHpKicker(nodeChar)
    if not PlayerOptionManager.isHpKickerEnabled() then
        return 0;
    end;
    
    local sHitDice = DB.getValue(nodeChar, "hitDice", "0");
    if not sHitDice or sHitDice == "0" then 
        return 0; -- If it has 0 HD, don't give it a kicker.
    end

    local sSizeRaw = StringManager.trim(DB.getValue(nodeChar, "size", "M"));
    local sSize = sSizeRaw:lower();

    if sSize == "tiny" or string.find(sSizeRaw, "T") then
        return 10;
    end
    return 20;
end

function nextActor()
    if Input.isShiftPressed() then
        delayThenNextActor(5);
    elseif Input.isAltPressed() then
        delayThenNextActor(1);
    elseif Input.isControlPressed() then
        delayThenNextActor(10);
    else
        CombatManager.nextActor();    
    end
end

function delayThenNextActor()
    if not User.isHost() then
        return;
    end

    local nodeActive = CombatManager.getActiveCT();
    local nIndexActive = 0;
    
    -- Check the skip hidden NPC option
    local bSkipHidden = OptionsManager.isOption("CTSH", "on");
    
    -- Determine the next actor
    local nodeNext = nil;
    local aEntries = CombatManager.getSortedCombatantList();
    if #aEntries > 0 then
        if nodeActive then
            for i = 1,#aEntries do
                if aEntries[i] == nodeActive then
                    nIndexActive = i;
                    break;
                end
            end
        end
        if bSkipHidden then
            local nIndexNext = 0;
            for i = nIndexActive + 1, #aEntries do
                if DB.getValue(aEntries[i], "friendfoe", "") == "friend" then
                    nIndexNext = i;
                    break;
                else
                    if not CombatManager.isCTHidden(aEntries[i]) then
                        nIndexNext = i;
                        break;
                    end
                end
            end
            if nIndexNext > nIndexActive then
                nodeNext = aEntries[nIndexNext];
                for i = nIndexActive + 1, nIndexNext - 1 do
                    CombatManager.showTurnMessage(aEntries[i], false);
                end
            end
        else
            nodeNext = aEntries[nIndexActive + 1];
        end
        
    end

    local nInitDelay = 10;

    -- If next actor available, advance effects, activate and start turn
    if nodeNext then
        local nPreviousInit = DB.getValue(nodeActive, "initresult");
        local nNextActorInit = DB.getValue(nodeNext, "initresult");
        if (nPreviousInit + nInitDelay < nNextActorInit) then -- TODO: This might need to be <=
            -- End turn for current actor
            CombatManager.onTurnEndEvent(nodeActive);
        
            -- Process effects in between current and next actors
            if nodeActive then
                CombatManager.onInitChangeEvent(nodeActive, nodeNext);
            else
                CombatManager.onInitChangeEvent(nil, nodeNext);
            end
            
            -- Start turn for next actor
            CombatManager.requestActivation(nodeNext, bSkipBell);
            CombatManager.onTurnStartEvent(nodeNext);
        end
    end
    DB.setValue(nodeActive, "initresult", "number", nPreviousInit + nInitDelay);
end