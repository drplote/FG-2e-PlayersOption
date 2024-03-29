local fRollNpcHitPoints;
local fCopySourceToNodeCT;
-- local fAddCTANPC;
local fNotifyEndTurn;
local fRollInitOverride;
local fDelayTurn;
-- local fAddBattle;
local fNextActor;
local fRollTypeInit;
local fTurnOffAllInitRolled;
local fRollEntryInit;
local fRollInit;

OOB_MSGTYPE_DELAYTURN = "delayturn";
OOB_MSGTYPE_REQUESTTURN = "requestturn";

function onInit()
    fRollNpcHitPoints = CombatRecordManagerADND.rollNPCHitPoints;
    CombatRecordManagerADND.rollNPCHitPoints = rollNPCHitPointsOverride;

    fRollEntryInit = CombatManagerADND.rollEntryInit;
    CombatManagerADND.rollEntryInit = rollEntryInitOverride;
    CombatManager2.rollEntryInit = rollEntryInitOverride; -- We have to override this because CombatManagerADND overrode this

    fCopySourceToNodeCT = CombatRecordManagerADND.helperCopyCTSourceToNode;
    CombatRecordManagerADND.helperCopyCTSourceToNode = copySourceToNodeCTOverride;

    CombatManager.setCustomRoundStart(onRoundStart);

    -- fAddCTANPC = CombatRecordManagerADND.onNPCAdd;
    -- CombatRecordManagerADND.onNPCAdd = addCTANPCOverride;

    fNotifyEndTurn = CombatManager.notifyEndTurn;
    CombatManager.notifyEndTurn = notifyEndTurnOverride;
    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_DELAYTURN, handleDelayTurn);
    OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_REQUESTTURN, handleRequestTurn);

    -- bugfix - c&t phased init - CombatManager2 no longer held reference to the correct fuction, using CombatManagerADND solves issue
    fRollInit = CombatManagerADND.rollInit;
    CombatManagerADND.rollInit = rollInitOverride;

    fDelayTurn = CombatManagerADND.delayTurn;
    CombatManagerADND.delayTurn = delayTurnOverride;

    -- fAddBattle = CombatRecordManagerADND.helperAddBattleNPC;
    -- CombatRecordManagerADND.helperAddBattleNPC = addBattleOverride;
    -- CombatManager.addBattle = addBattleOverride;

    fNextActor = CombatManager.nextActor;
    CombatManager.nextActor = nextActorOverride;

    fRollTypeInit = CombatManager.rollTypeInit;
    CombatManager.rollTypeInit = rollTypeInitOverride;

    fTurnOffAllInitRolled = CharlistManagerADND.turnOffAllInitRolled;
    CharlistManagerADND.turnOffAllInitRolled = turnOffAllInitRolledOverride;

    CombatManager.setCustomCombatReset(resetInitPo);

    -- override to ensure the new carousel works with the "hide enemies from tracker" option this extension exposes
    CombatManager.isCTHidden = isCTHiddenOverride;
end

-- override
-- core rpg function from CombatManager - add additional logic to handle shouldHideEnemiesFromPlayerCT bit
function isCTHiddenOverride(vEntry)
    local nodeCT = CombatManager.resolveNode(vEntry);
    if not nodeCT then
        return false;
    end

    if CombatManager.getFactionFromCT(nodeCT) == "friend" then
        return false;
    end

    -- extended here
    if PlayerOptionManager.shouldHideEnemiesFromPlayerCT() then
        -- Debug.chat('HIDE FOES FROM COMBAT LIST');
        return true;
    end

    if CombatManager.getTokenVisibilityFromCT(nodeCT) then
        return false;
    end
    return true;
end
 
function resetInitPo()
    if PlayerOptionManager.isUsingHackmasterInitiative() then
        for _, nodeCT in pairs(CombatManager.getCombatantNodes()) do
            DB.setValue(nodeCT, "initresult", "number", 99);
        end
    end
end

function turnOffAllInitRolledOverride()
    for _, vChild in pairs(CombatManager.getCombatantNodes()) do
        local rActor = ActorManager.resolveActor(vChild);
        if not PlayerOptionManager.isUsingHackmasterInitiative() then
            DB.setValue(vChild, "initrolled", "number", 0);
        end
    end
end

function rollTypeInitOverride(sType, fRollCombatantEntryInit, ...)
    if PlayerOptionManager.isUsingHackmasterInitiative() then
        for _, v in pairs(CombatManager.getCombatantNodes()) do
            DB.setValue(v, "previnitresult", "number", DB.getValue(v, "initresult", 0));
        end
    end

    return fRollTypeInit(sType, fRollCombatantEntryInit, ...);
end

function delayTurnOverride(nodeCT)
    if PlayerOptionManager.isUsingPhasedInitiative() then
        delayThenNextActor(2);
    elseif PlayerOptionManager.isUsingHackmasterInitiative() then
        delayThenNextActor(1);
    else
        fDelayTurn(nodeCT);
    end
end

function rollInitOverride(sType)
    if PlayerOptionManager.isUsingPhasedInitiative() then
        resetGroupInits();
    end

    fRollInit(sType);
end

function handleDelayTurn(msgOOB)
    local nodeCT = CombatManager.getActiveCT();
    local rActor = ActorManagerPO.getActorFromCT(nodeCT);
    local nodeActor = ActorManager.getCreatureNode(rActor);
    if PlayerOptionManager.isUsingPhasedInitiative() then
        delayThenNextActor(2);
    elseif nodeCT then
        local nDelay = nil;
        if msgOOB.nDelay then
            nDelay = tonumber(msgOOB.nDelay);
        end

        if nDelay and nDelay > 0 then
            delayThenNextActor(nDelay);
        elseif PlayerOptionManager.isUsingHackmasterInitiative() then
            delayThenNextActor(1);
        else
            moveActorToEndOfInit(nodeCT);
        end
    end
end

function handleRequestTurn(msgOOB)
    local rChar = ActorManager.resolveActor(msgOOB.sNodeChar);
    local nodeChar = ActorManagerPO.getNode(rChar);
    if nodeChar then
        local nodeActive = CombatManager.getActiveCT();
        local nCurrentInit = DB.getValue(nodeActive, "initresult", 0);

        local nodeCT = CombatManager.getCTFromNode(nodeChar);
        if nodeCT ~= nodeActive then
            local nPreviousInit = DB.getValue(nodeCT, "initresult", 99);
            DB.setValue(nodeCT, "initresult", "number", nCurrentInit + 1);
            ChatManagerPO.deliverTurnRequestMessage(nodeChar, nPreviousInit);
        end
    end
end

function moveActorToEndOfInit(nodeCT)
    fNextActor();

    CombatManagerADND.showCTMessageADND(nodeEntry, DB.getValue(nodeCT, "name", "") .. " " ..
        Interface.getString("char_initdelay_message"));
    local nNewInit = CombatManagerADND.getLastInitiative() + 1;
    DB.setValue(nodeCT, "initresult", "number", nNewInit);
end

function notifyEndTurnOverride()
    local msgOOB = {};
    msgOOB.type = CombatManager.OOB_MSGTYPE_ENDTURN;
    msgOOB.user = User.getUsername();

    if (Input.isAltPressed() or Input.isShiftPressed() or Input.isControlPressed()) then
        msgOOB.type = OOB_MSGTYPE_DELAYTURN;
    end

    Comm.deliverOOBMessage(msgOOB, "");
end

function notifyDelayTurn(nDelay)
    local msgOOB = {};
    msgOOB.type = OOB_MSGTYPE_DELAYTURN;
    msgOOB.user = User.getUsername();

    msgOOB.nDelay = nDelay;

    Comm.deliverOOBMessage(msgOOB, "");
end

function notifyRequestTurn(nodeChar)
    local msgOOB = {};
    msgOOB.type = OOB_MSGTYPE_REQUESTTURN;
    msgOOB.user = User.getUsername();
    msgOOB.sNodeChar = ActorManager.getCreatureNodeName(nodeChar);

    Comm.deliverOOBMessage(msgOOB, "");
end

-- function addCTANPCOverride(sClass, nodeNPC, sNamedInBattle)
--    local nodeEntry = fAddCTANPC(sClass, nodeNPC, sNamedInBattle);
--    CombatManagerADND.helperCopyCTSourceToNode(nodeNPC, nodeEntry);
--    return nodeEntry;
-- end 

function copySourceToNodeCTOverride(nodeSource, nodeCT, tChildren)
    fCopySourceToNodeCT(nodeSource, nodeCT, tChildren);
    if PlayerOptionManager.shouldUseDynamicNpcAc() then
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
    StateManagerPO.handleRoundStart();

    if PlayerOptionManager.shouldRingBellOnRoundStart() then
        for _, sUserName in pairs(User.getActiveUsers()) do
            User.ringBell(sUserName);
        end
        User.ringBell();
    end
end

function resetGroupInits()
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
        nInitPhase = nInitPhase - 1;
    elseif nGroupInitRoll == 10 then
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
    local rActor = ActorManagerPO.getActorFromCT(nodeEntry);
    local nodeActor = ActorManager.getCreatureNode(rActor);
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
    local rActor = ActorManager.resolveActor(nodeEntry);
    local aEffectDice, nEffectBonus = EffectManager5E.getEffectsBonus(rActor, "INIT");
    local nInitMOD = StringManager.evalDice(aEffectDice, nEffectBonus);

    -- Check for the ADVINIT effect
    local bADV = EffectManager5E.hasEffectCondition(rActor, "ADVINIT");

    -- For PCs, we always roll unique initiative
    local sClass, sRecord = DB.getValue(nodeEntry, "link", "", "");
    if sClass == "charsheet" then
        local nodeChar = DB.findNode(sRecord);
        local nInitPC = DB.getValue(nodeChar, "initiative.total", 0);
        local nInitResult = 0;
        if sOptPCVNPCINIT == "on" then
            if CombatManagerADND.PC_LASTINIT == 0 then
                nInitResult = CombatManagerADND.rollRandomInit(0, bADV);
                CombatManagerADND.PC_LASTINIT = nInitResult;
            else
                nInitResult = CombatManagerADND.PC_LASTINIT;
            end
        else
            if PlayerOptionManager.isUsingHackmasterInitiative() then
                nInitResult = InitManagerPO.moveHackmasterActorToNextRound(nodeEntry, nInitMOD);
            else
                InitManagerPO.clearActorInitQueue(nodeEntry);
                if PlayerOptionManager.isDefaultingPcInitTo99() then
                    nInitResult = 99;
                else
                    nInitResult = CombatManagerADND.rollRandomInit(nInitPC + nInitMOD, bADV);
                end
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
        local nTotal = DB.getValue(nodeEntry, "initiative.total", 0);
        -- flip through weaponlist, get the largest speedfactor as default
        local nSpeedFactor = nil;

        local nodeSlowestWeapon = nil;
        for _, nodeWeapon in pairs(DB.getChildren(nodeEntry, "weaponlist")) do
            local nSpeed = DB.getValue(nodeWeapon, "speedfactor", 0);
            if not nSpeedFactor or nSpeed > nSpeedFactor then
                nSpeedFactor = nSpeed;
                nodeSlowestWeapon = nodeWeapon;
            end
        end

        if nSpeedFactor then
            nInit = nSpeedFactor + nInitMOD;
            if PlayerOptionManager.isUsingHackmasterInitiative() then
                nInit = nInit - 5;
            end
        elseif (nTotal ~= 0) then
            nInit = nTotal + nInitMOD;
        end

        --[[ IF we ignore size/mods, clear nInit ]]
        if OptionsManager.getOption("OPTIONAL_INIT_SIZEMODS") ~= "on" and
            not PlayerOptionManager.isUsingHackmasterInitiative() then
            nInit = 0;
        end
        -- For NPCs, if NPC init option is not group, then roll unique initiative
        local sOptINIT = OptionsManager.getOption("INIT");
        if sOptINIT ~= "group" then
            -- if they have custom init then we use it.
            local nPreviousInit = DB.getValue(nodeEntry, "previnitresult", 0);
            if PlayerOptionManager.isUsingHackmasterInitiative() then
                local nInitResult = InitManagerPO.moveHackmasterActorToNextRound(nodeEntry, nInit);
                DB.setValue(nodeEntry, "initresult", "number", nInitResult);
            else
                InitManagerPO.clearActorInitQueue(nodeEntry);
                if PlayerOptionManager.isDefaultingNpcInitTo99() then
                    DB.setValue(nodeEntry, "initresult", "number", 99);
                else
                    local nInitResult = CombatManagerADND.rollRandomInit(nInit, bADV);
                    DB.setValue(nodeEntry, "initresult", "number", nInitResult);
                end
            end
            return;
        end

        -- For NPCs with group option enabled
        -- Get the entry's database node name and creature name
        local sStripName = CombatManager.stripCreatureNumber(DB.getValue(nodeEntry, "name", ""));
        -- Iterate through list looking for other creature's with same name and faction
        local nLastInit = nil;
        if sStripName ~= "" then
            local sEntryFaction = DB.getValue(nodeEntry, "friendfoe", "");
            for _, v in pairs(CombatManager.getCombatantNodes()) do
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
        end

        -- If we found similar creatures, then match the initiative of the last one found
        if nLastInit then
            DB.setValue(nodeEntry, "initresult", "number", nLastInit);
        else
            InitManagerPO.clearActorInitQueue(nodeEntry);
            if PlayerOptionManager.isDefaultingNpcInitTo99() then
                DB.setValue(nodeEntry, "initresult", "number", 99);
            else
                local nInitResult = CombatManagerADND.rollRandomInit(nInit, bADV);
                DB.setValue(nodeEntry, "initresult", "number", nInitResult);
            end
        end
    end
end

function rollNPCHitPointsOverride(nodeChar)
    return fRollNpcHitPoints(nodeChar) + getHpKicker(nodeChar);
end

function getHpKicker(nodeChar)
    if not PlayerOptionManager.isHpKickerEnabled() then
        return 0;
    end

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

function nextActorOverride()
    if PlayerOptionManager.isUsingPhasedInitiative() then
        if Input.isShiftPressed() or Input.isAltPressed() or Input.isControlPressed() then
            delayThenNextActor(2);
        else
            fNextActor();
        end
    else
        delayThenNextActor(0);
    end
end

function delayThenNextActor(nInitDelay)
    if not Session.IsHost then
        return;
    end

    local nodeActive = CombatManager.getActiveCT();
    local nPreviousInit = DB.getValue(nodeActive, "initresult");
    local nIndexActive = 0;

    -- Check the skip hidden NPC option
    local bSkipHidden = OptionsManager.isOption("CTSH", "on");
    local bSkipDeadNPC = OptionsManager.isOption("CT_SKIP_DEAD_NPC", "on");

    -- Determine the next actor
    local nodeNext = nil;
    local aEntries = CombatManager.getSortedCombatantList();
    if #aEntries > 0 then
        if nodeActive then
            for i = 1, #aEntries do
                if aEntries[i] == nodeActive then
                    nIndexActive = i;
                    break
                end
            end
        end
        if bSkipHidden or bSkipDeadNPC then
            local nIndexNext = 0;
            for i = nIndexActive + 1, #aEntries do
                if DB.getValue(aEntries[i], "friendfoe", "") == "friend" then
                    nIndexNext = i;
                    break
                else
                    local nPercentWounded, _ = ActorHealthManager.getWoundPercent(aEntries[i]);
                    local bisNPC = (not ActorManager.isPC(aEntries[i]));
                    -- is the actor dead?
                    local bSkipDead = (bSkipDeadNPC and bisNPC and nPercentWounded >= 1);
                    -- is the actor hidden?
                    local bSkipHiddenActor = (bSkipHidden and CombatManager.isCTHidden(aEntries[i]));

                    if (not bSkipDead and not bSkipHiddenActor) then
                        nIndexNext = i;
                        break
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

    local nNewActiveNodeInit = nPreviousInit;

    if nInitDelay > 0 then
        InitManagerPO.addDelayToActorInitQueue(nodeActive, nInitDelay);
        nNewActiveNodeInit = nNewActiveNodeInit + nInitDelay;
    elseif InitManagerPO.hasAdditionalInitsInQueue(nodeActive) then
        nNewActiveNodeInit = InitManagerPO.popActorInitFromQueue(nodeActive);
    end

    if nInitDelay > 0 then
        ChatManagerPO.deliverDelayTurnMessage(nodeActive, nInitDelay, not ActorManager.isPC(nodeActive));
    end

    local bHasLaterInit = nNewActiveNodeInit ~= nPreviousInit;

    -- If next actor available, advance effects, activate and start turn
    if nodeNext then
        local nNextActorInit = DB.getValue(nodeNext, "initresult");
        local bShouldGoToNextActor = not bHasLaterInit or (nNextActorInit <= nNewActiveNodeInit);

        if bShouldGoToNextActor then
            -- End turn for current actor
            CombatManager.onTurnEndEvent(nodeActive);

            -- Process effects in between current and next actors
            if nodeActive then
                CombatManager.onInitChangeEvent(nodeActive, nodeNext);
            else
                CombatManager.onInitChangeEvent(nil, nodeNext);
            end

            DB.setValue(nodeActive, "initresult", "number", nNewActiveNodeInit);
            -- Start turn for next actor
            local bShouldSwitchActor = (not bHasLaterInit) or CombatManagerADND.sortfuncADnD(nodeNext, nodeActive);

            if bShouldSwitchActor then
                CombatManager.requestActivation(nodeNext, bSkipBell);
                CombatManager.onTurnStartEvent(nodeNext);
            end

            if PlayerOptionManager.isUsingHackmasterInitiative() and nNextActorInit > 10 then
                CombatManager.nextRound(1);
            end
        else
            DB.setValue(nodeActive, "initresult", "number", nNewActiveNodeInit);
            if PlayerOptionManager.isUsingHackmasterInitiative() and nNewActiveNodeInit > 10 then
                CombatManager.nextRound(1);
            end
        end
    else
        DB.setValue(nodeActive, "initresult", "number", nNewActiveNodeInit);

        if bSkipHidden or bSkipDeadNPC then
            for i = nIndexActive + 1, #aEntries do
                CombatManager.showTurnMessage(aEntries[i], false);
            end
        end
        CombatManager.nextRound(1);
    end
end

--[[function addBattleOverride(nodeBattle)
    local aModulesToLoad = {};
    local sTargetNPCList = LibraryData.getCustomData("battle", "npclist") or "npclist";
    for _, vNPCItem in pairs(DB.getChildren(nodeBattle, sTargetNPCList)) do
        local sClass, sRecord = DB.getValue(vNPCItem, "link", "", "");
        if sRecord ~= "" then
            local nodeNPC = DB.findNode(sRecord);
            if not nodeNPC then
                local sModule = sRecord:match("@(.*)$");
                if sModule and sModule ~= "" and sModule ~= "*" then
                    if not StringManager.contains(aModulesToLoad, sModule) then
                        table.insert(aModulesToLoad, sModule);
                    end
                end
            end
        end
        for _,vPlacement in pairs(DB.getChildren(vNPCItem, "maplink")) do
            local sClass, sRecord = DB.getValue(vPlacement, "imageref", "", "");
            if sRecord ~= "" then
                local nodeImage = DB.findNode(sRecord);
                if not nodeImage then
                    local sModule = sRecord:match("@(.*)$");
                    if sModule and sModule ~= "" and sModule ~= "*" then
                        if not StringManager.contains(aModulesToLoad, sModule) then
                            table.insert(aModulesToLoad, sModule);
                        end
                    end
                end
            end
        end
    end
    if #aModulesToLoad > 0 then
        local wSelect = Interface.openWindow("module_dialog_missinglink", "");
        wSelect.initialize(aModulesToLoad, onBattleNPCLoadCallback, { nodeBattle = nodeBattle });
        return;
    end
    
    if CombatManager.fCustomAddBattle then
        return CombatManager.fCustomAddBattle(nodeBattle);
    end
    
    -- Cycle through the NPC list, and add them to the tracker
    for _, vNPCItem in pairs(DB.getChildren(nodeBattle, sTargetNPCList)) do
        -- Get link database node
        local nodeNPC = nil;
        local sClass, sRecord = DB.getValue(vNPCItem, "link", "", "");
        if sRecord ~= "" then
            nodeNPC = DB.findNode(sRecord);
        end
        local sName = DB.getValue(vNPCItem, "name", "");


        if nodeNPC then
            local aPlacement = {};
            for _,vPlacement in pairs(DB.getChildren(vNPCItem, "maplink")) do
                local rPlacement = {};
                local _, sRecord = DB.getValue(vPlacement, "imageref", "", "");
                rPlacement.imagelink = sRecord;
                rPlacement.imagex = DB.getValue(vPlacement, "imagex", 0);
                rPlacement.imagey = DB.getValue(vPlacement, "imagey", 0);
                table.insert(aPlacement, rPlacement);
            end
            
            local nCount = DB.getValue(vNPCItem, "count", 0);
            for i = 1, nCount do
                --local nodeEntry = CombatManager.addNPC(sClass, nodeNPC, sName);
                local nodeEntry = CombatManagerADND.addCTANPC(sClass, nodeNPC, sName);
                if nodeEntry then
                    local sFaction = DB.getValue(vNPCItem, "faction", "");
                    if sFaction ~= "" then
                        DB.setValue(nodeEntry, "friendfoe", "string", sFaction);
                    end
                    local sToken = DB.getValue(vNPCItem, "token", "");
                    if sToken == "" or not Interface.isToken(sToken) then
                        local sLetter = StringManager.trim(sName):match("^([a-zA-Z])");
                        if sLetter then
                            sToken = "tokens/Medium/" .. sLetter:lower() .. ".png@Letter Tokens";
                        else
                            sToken = "tokens/Medium/z.png@Letter Tokens";
                        end
                    end
                    if sToken ~= "" then
                        DB.setValue(nodeEntry, "token", "token", sToken);
                        
                        if aPlacement[i] and aPlacement[i].imagelink ~= "" then
                            TokenManager.setDragTokenUnits(DB.getValue(nodeEntry, "space"));
                            local tokenAdded = Token.addToken(aPlacement[i].imagelink, sToken, aPlacement[i].imagex, aPlacement[i].imagey);
                            TokenManager.endDragTokenWithUnits(nodeEntry);
                            if tokenAdded then
                                TokenManager.linkToken(nodeEntry, tokenAdded);
                            end
                        end
                    end
                    
                    -- Set identification state from encounter record, and disable source link to prevent overriding ID for existing CT entries when identification state changes
                    local sSourceClass,sSourceRecord = DB.getValue(nodeEntry, "sourcelink", "", "");
                    DB.setValue(nodeEntry, "sourcelink", "windowreference", "", "");
                    DB.setValue(nodeEntry, "isidentified", "number", DB.getValue(vNPCItem, "isidentified", 1));
                    DB.setValue(nodeEntry, "sourcelink", "windowreference", sSourceClass, sSourceRecord);
                else
                    ChatManager.SystemMessage(Interface.getString("ct_error_addnpcfail") .. " (" .. sName .. ")");
                end
        
        -- add custom features for 2E ruleset hp/ac/weapon
        local nHP = DB.getValue(vNPCItem,"hp",0);
        local nAC = DB.getValue(vNPCItem,"ac",11);
        local sWeaponList = DB.getValue(vNPCItem,"weapons","");
        local sItemList = DB.getValue(vNPCItem, "items", "");
        if (nHP ~= 0) then
          DB.setValue(nodeEntry, "hp", "number", nHP);
          DB.setValue(nodeEntry, "hpbase", "number", nHP);
          DB.setValue(nodeEntry, "hptotal", "number", nHP);
        end
        if (nAC <= 10) then
          DB.setValue(nodeEntry, "ac", "number", nAC);
        end
        if (sWeaponList ~= "") then
          for _,sWeapon in ipairs(StringManager.split(sWeaponList, ";", true)) do
            if not UtilityManagerADND.hasWeaponNamed(nodeEntry,sWeapon) then 
              local nodeSourceWeapon = UtilityManagerADND.getWeaponNodeByName(sWeapon);
              if nodeSourceWeapon then
                local nodeWeapons = nodeEntry.createChild("weaponlist");
                for _,v in pairs(DB.getChildren(nodeSourceWeapon, "weaponlist")) do
                  local nodeWeapon = nodeWeapons.createChild();
                  DB.copyNode(v,nodeWeapon);
                  local sName = DB.getValue(v,"name","");
                  local sText = DB.getValue(v,"text","");
                  DB.setValue(nodeWeapon,"itemnote.name","string",sName);
                  DB.setValue(nodeWeapon,"itemnote.text","formattedtext",sText);
                  DB.setValue(nodeWeapon,"itemnote.locked","number",1);
                end
              else
                ChatManager.SystemMessage("Encounter [" .. DB.getValue(nodeBattle,"name","") .. "], unable to find weapon [" .. sWeapon .. "] for NPC [" .. DB.getValue(nodeEntry,"name","") .."].");
              end
            end
          end -- for weapons
        end -- end weaponlist

        if (sItemList ~= "") then
          for _,sItem in ipairs(StringManager.split(sItemList, ";", true)) do
            if not ActorManagerPO.hasItemNamed(nodeEntry, sItem) then 
                -- First see if it's a weapon
                local nodeSourceWeapon = UtilityManagerADND.getWeaponNodeByName(sItem);
                if nodeSourceWeapon then
                    ActorManagerPO.addWeapon(nodeEntry, nodeSourceWeapon);
                else
                    local nodeSourceItem = ItemManagerPO.getItemByName(sItem);
                    if nodeSourceItem then
                      ActorManagerPO.addItem(nodeEntry, nodeSourceItem);
                    else
                      DebugPO.log("Encounter [" .. DB.getValue(nodeBattle,"name","") .. "], unable to find item [" .. sItem .. "] for NPC [" .. DB.getValue(nodeEntry,"name","") .."].");   
                    end
                end
            end
          end -- for items
          CharManager.calcItemArmorClass(nodeEntry);
        end -- end itemlist

        ---- end custom stuff for 2E ruleset encounter spawns
        
      end -- end for
        
      else
          ChatManager.SystemMessage(Interface.getString("ct_error_addnpcfail2") .. " (" .. sName .. ")");
      end
    end
    
    Interface.openWindow("combattracker_host", "combattracker");
end --]]

function getSimilarCreaturesInCT(nodeEntry)
    local aCreatures = {};
    local sStripName = CombatManager.stripCreatureNumber(DB.getValue(nodeEntry, "name", ""));
    if sStripName ~= "" then
        local sEntryFaction = DB.getValue(nodeEntry, "friendfoe", "");
        for _, v in pairs(CombatManager.getCombatantNodes()) do
            if v.getName() ~= nodeEntry.getName() then
                if DB.getValue(v, "friendfoe", "") == sEntryFaction then
                    local sTemp = CombatManager.stripCreatureNumber(DB.getValue(v, "name", ""));
                    if sTemp == sStripName then
                        table.insert(aCreatures, v);
                    end
                end
            end
        end
    end

    return aCreatures;
end
