local fRollNpcHitPoints;
local fCopySourceToNodeCT;
local fAddCTANPC;
local fNotifyEndTurn;

OOB_MSGTYPE_DELAYTURN = "delayturn";

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

    fNotifyEndTurn = CombatManager.notifyEndTurn;
    CombatManager.notifyEndTurn = notifyEndTurnOverride;
    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_DELAYTURN, handleDelayTurn);
end

function handleDelayTurn(msgOOB)
    local nodeCT = CombatManager.getActiveCT()
    local rActor = ActorManager.getActorFromCT(nodeCT);
    local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
    if sActorType == "pc" then
        if nodeActor.getOwner() == msgOOB.user then
            if PlayerOptionManager.isUsingPhasedInitiative() then
                delayThenNextActor(2);
            elseif nodeCT then
                moveActorToEndOfInit(nodeCT);
            end

        end
    end
end

function moveActorToEndOfInit(nodeCT)
    CombatManager.nextActor();

    CombatManagerADND.showCTMessageADND(nodeEntry, DB.getValue(nodeCT, "name", "") .. " " .. Interface.getString("char_initdelay_message"));
    local nNewInit = CombatManagerADND.getLastInitiative() + 1;
    DB.setValue(nodeCT, "initresult", "number", nNewInit);
end

function notifyEndTurnOverride()
    local msgOOB = {};
    msgOOB.type = CombatManager.OOB_MSGTYPE_ENDTURN;
    msgOOB.user = User.getUsername();
    Debug.console("ending turn");

    if (Input.isAltPressed() or Input.isShiftPressed() or Input.isControlPressed()) then
        msgOOB.type = OOB_MSGTYPE_DELAYTURN;
    end

    Comm.deliverOOBMessage(msgOOB, "");
end

function notifyDelayTurn()
    local msgOOB = {};
    msgOOB.type = OOB_MSGTYPE_DELAYTURN;
    msgOOB.user = User.getUsername();

    Comm.deliverOOBMessage(msgOOB, "");
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
    StateManagerPO.setPcInit(0);
    StateManagerPO.setNpcInit(0);
end

function updatePcVsNpcInit()
    if StateManagerPO.getNpcInit() == 0 or StateManagerPO.getPcInit() == 0 then
        while StateManagerPO.getPcInit() == StateManagerPO.getNpcInit() do
            StateManagerPO.setPcInit(math.random(10));
            StateManagerPO.setNpcInit(math.random(10));
        end
        StateManagerPO.clearTurnEffectsState();
        ChatManagerPO.deliverInitRollMessage(StateManagerPO.getPcInit(), StateManagerPO.getNpcInit());
    end
end

function getPhaseShiftForInitMod(nodeActor)
    local aEffectDice, nEffectBonus = EffectManager5E.getEffectsBonus(nodeActor, "INIT");
    local nInitMod = StringManager.evalDice(aEffectDice, nEffectBonus);
    local nStepSize = 3; -- We'll say every 3 points of init mod moves you one step

    local nPhaseShift = 0;
    if nInitMod < 0 then
        nPhaseShift = math.ceil(nInitMod / 3);
    else
        nPhaseShift = math.floor(nInitMod / 3);
    end
    Debug.console("INIT effect of " .. nInitMod .. " shifted init by " .. nPhaseShift .. " phases.");
    return nPhaseShift;
end 

function getFinalInitForActor(nodeActor, nInitPhase, bAllowInitEffects)
    local bIsPc = ActorManager.isPC(nodeActor);

    local nGroupInitRoll;
    local nOtherGroupInitRoll;
    if ActorManager.isPC(nodeActor) then
        nGroupInitRoll = StateManagerPO.getPcInit();
        nOtherGroupInitRoll = StateManagerPO.getNpcInit();
    else
        nGroupInitRoll = StateManagerPO.getNpcInit();
        nOtherGroupInitRoll = StateManagerPO.getPcInit();
    end

    if nGroupInitRoll == 1 then
        Debug.console("Shifted init down for a group roll of 1");
        nInitPhase = nInitPhase - 1;
    elseif nGroupInitRoll == 10 then
        Debug.console("Shifted init up for a group roll of 10");
        nInitPhase = nInitPhase + 1;
    end

    if bAllowInitEffects then
        nInitPhase = nInitPhase + getPhaseShiftForInitMod(nodeActor);
    end

    local nInitResult = nInitPhase * 2;
    if nGroupInitRoll > nOtherGroupInitRoll then
        nInitResult = nInitResult + 1;
    end

    nInitResult = math.max(math.min(nInitResult, 13), 0); -- Force it into bounds.
    return nInitResult;
end

function rollEntryPhasedInitiative(nodeEntry)
    if not nodeEntry then
        return;
    end

    updatePcVsNpcInit();

    -- Inits: 0-1 top, 2-3 very fast, 4-5 fast, 6-7 average, 8-9 slow, 10-11 very slow, 12-13 bottom

    -- Get any effect modifiers
    local rActor = ActorManager.getActorFromCT(nodeEntry);
    local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
    local nPhaseShift = getPhaseShiftForInitMod(nodeActor);
    
    -- For PCs, we always roll unique initiative
    local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
    if sClass == "charsheet" then
        -- Default PCs to the slowest init for their side. They should roll.
        if StateManagerPO.getPcInit() < StateManagerPO.getNpcInit() then
            DB.setValue(nodeEntry, "initresult", "number", 12);
        else
            DB.setValue(nodeEntry, "initresult", "number", 13);
        end
    else -- it's an npc
        local nInitPhase = InitManagerPO.getWorstPossiblePhaseForActor(nodeActor);
        local nInitResult = getFinalInitForActor(nodeActor, nInitPhase, true);
        DB.setValue(nodeEntry, "initresult", "number", nInitResult);
    end 
end

function rollEntryInitOverride(nodeEntry)
    if PlayerOptionManager.isUsingPhasedInitiative() then
        rollEntryPhasedInitiative(nodeEntry);
        return; 
    end

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
            if CombatManagerADND.PC_LASTINIT == 0 then
                nInitResult = CombatManagerADND.rollRandomInit(0, bADV);
                CombatManagerADND.PC_LASTINIT = nInitResult;
            else
                nInitResult = CombatManagerADND.PC_LASTINIT;
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
            if CombatManagerADND.NPC_LASTINIT == 0 then
            nInitResult = CombatManagerADND.rollRandomInit(0, bADV);
            CombatManagerADND.NPC_LASTINIT = nInitResult;
            else
            nInitResult = CombatManagerADND.NPC_LASTINIT;
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

    return getKickerFromSize(nodeChar);
end

function getKickerFromSize(nodeNpc)
  if DB.getValue(nodeNpc, "hd", 0) == 0 then 
    return 0; -- If it has 0 HD, don't give it a kicker.
  end
  
  local nSizeCategory = ActorManagerPO.getSizeCategory(nodeNpc);  
  local nKicker = 20;
  
  local bUseSizeBasedKicker = PlayerOptionManager.isKickerSizeBased();
  
  if bUseSizeBasedKicker then
    if nSizeCategory == 1 then -- tiny
      nKicker = 0;
    elseif nSizeCategory == 2 then -- small
      nKicker = 10;
    elseif nSizeCategory == 3 then -- medium
      nKicker = 20;
    elseif nSizeCategory == 4 then -- large
      nKicker = 30;
    elseif nSizeCategory == 5 then -- huge
      nKicker = 40;
    elseif nSizeCategory == 6 then -- gargantuan
      nKicker = 50;
    end
  elseif nSizeCategory == 1 then
    nKicker = 10;
  end
  
  return nKicker;
  
end

function nextActor()
    if PlayerOptionManager.isUsingPhasedInitiative() then
        if Input.isShiftPressed() or Input.isAltPressed() or Input.isControlPressed() then
            delayThenNextActor(2);
        else
            CombatManagerADND.nextActor();
        end
    elseif Input.isShiftPressed() or Input.isAltPressed() or Input.isControlPressed() then
        moveActorToEndOfInit(CombatManager.getActiveCT());
    else
        CombatManager.nextActor();
    end
end

function delayThenNextActor(nInitDelay)
    if not User.isHost() then
        return;
    end

    local nodeActive = CombatManager.getActiveCT();
    local nPreviousInit = DB.getValue(nodeActive, "initresult");
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

    local nNewActiveNodeInit = nPreviousInit + nInitDelay;
    -- If next actor available, advance effects, activate and start turn
    if nodeNext then
        local nNextActorInit = DB.getValue(nodeNext, "initresult");

        local bShouldGoToNextActor = nNextActorInit <= nNewActiveNodeInit;


        if bShouldGoToNextActor then 
            Debug.console("trying to go to next actor");
            -- End turn for current actor
            CombatManager.onTurnEndEvent(nodeActive);
        
            -- Process effects in between current and next actors
            if nodeActive then
                CombatManager.onInitChangeEvent(nodeActive, nodeNext);
            else
                CombatManager.onInitChangeEvent(nil, nodeNext);
            end
            
            -- Start turn for next actor
            DB.setValue(nodeActive, "initresult", "number", nNewActiveNodeInit);    
            local bShouldSwitchActor = CombatManagerADND.sortfuncADnD(nodeNext, nodeActive);
            if bShouldSwitchActor then
                CombatManager.requestActivation(nodeNext, bSkipBell);
                CombatManager.onTurnStartEvent(nodeNext);
            end
        end
    end
    DB.setValue(nodeActive, "initresult", "number", nNewActiveNodeInit);    
end
