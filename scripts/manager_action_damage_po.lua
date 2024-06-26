local fOnDamageRoll;
local fCheckReductionType;
local fModDamage;
local fApplyDamage;
local fGetDamageAdjust;
local fGetRoll;
local fDecodeDamageText;

function onInit()
    fOnDamageRoll = ActionDamage.onDamageRoll; -- check update
    ActionDamage.onDamageRoll = onDamageRollOverride;
    ActionsManager.registerPostRollHandler("damage", onDamageRollOverride);

    fCheckReductionType = ActionDamage.checkReductionType;
    ActionDamage.checkReductionType = checkReductionTypeOverride;

    fModDamage = ActionDamage.modDamage;
    ActionDamage.modDamage = modDamageOverride;
    ActionsManager.registerModHandler("damage", modDamageOverride);

    fGetDamageAdjust = ActionDamage.getDamageAdjust; -- check update
    ActionDamage.getDamageAdjust = getDamageAdjustOverride;

    fApplyDamage = ActionDamage.applyDamage; -- check update
    ActionDamage.applyDamage = applyDamageOverride;

    fGetRoll = ActionDamage.getRoll;
    ActionDamage.getRoll = getRollOverride;

    fDecodeDamageText = ActionDamage.decodeDamageText;
    ActionDamage.decodeDamageText = decodeDamageTextOverride;
end

function decodeDamageTextOverride(nDamage, sDamageDesc)
    local rDamageOutput = fDecodeDamageText(nDamage, sDamageDesc);
    rDamageOutput.rArmorDamageInfo = {
        nPenetrationsHandled = 0
    };
    for sDamageType, sDamageDice, sDamageSubTotal in string.gmatch(sDamageDesc,
        "%[TYPE: ([^(]*) %(([%d%+%-dD]+)%=(%d+)%)%]") do
        sDamageType = UtilityPO.stripWhitespace(sDamageType);
        local nDamageSubTotal = (tonumber(sDamageSubTotal) or 0);
        local nDamageDice = 0;
        DebugPO.log("sDamageDice", sDamageDice);
        for sNumDiceMatch in string.gmatch(sDamageDice, "(%d+)d") do
            nDamageDice = nDamageDice + (tonumber(sNumDiceMatch) or 1);
        end
        if nDamageDice == 0 then
            nDamageDice = 1
        end
        if rDamageOutput.rArmorDamageInfo[sDamageType] == nil then
            rDamageOutput.rArmorDamageInfo[sDamageType] = {
                unsoakedDamageDice = 0,
                damageSubTotal = 0
            };
        end
        rDamageOutput.rArmorDamageInfo[sDamageType].unsoakedDamageDice =
            rDamageOutput.rArmorDamageInfo[sDamageType].unsoakedDamageDice + nDamageDice;
        rDamageOutput.rArmorDamageInfo[sDamageType].damageSubTotal =
            rDamageOutput.rArmorDamageInfo[sDamageType].damageSubTotal + nDamageSubTotal;
    end

    return rDamageOutput;
end

function getRollOverride(rActor, rAction)
    local rRoll = fGetRoll(rActor, rAction);
    rRoll.sPowerType = rAction.sPowerType;
    rRoll.sPowerSchool = rAction.sPowerSchool;
    return rRoll;
end

function applyDamageOverride(rSource, rTarget, bSecret, sDamage, nTotal, aDice)
    -- Get health fields
    local nodeTarget = ActorManagerPO.getCreatureNode(rTarget);
    local sTargetType = ActorManagerPO.getType(rTarget);

    local nRemainder = 0;

    local nTotalHP, nTempHP, nWounds, nDeathSaveSuccess, nDeathSaveFail, nCurrentHP;
    if sTargetType == "pc" then
        nTotalHP = DB.getValue(nodeTarget, "hp.total", 0);
        nTempHP = DB.getValue(nodeTarget, "hp.temporary", 0);
        nWounds = DB.getValue(nodeTarget, "hp.wounds", 0);
        nDeathSaveSuccess = DB.getValue(nodeTarget, "hp.deathsavesuccess", 0);
        nDeathSaveFail = DB.getValue(nodeTarget, "hp.deathsavefail", 0);
    else
        nTotalHP = DB.getValue(nodeTarget, "hptotal", 0);
        nTempHP = DB.getValue(nodeTarget, "hptemp", 0);
        nWounds = DB.getValue(nodeTarget, "wounds", 0);
        nDeathSaveSuccess = DB.getValue(nodeTarget, "deathsavesuccess", 0);
        nDeathSaveFail = DB.getValue(nodeTarget, "deathsavefail", 0);
    end

    -- Prepare for notifications
    local aNotifications = {};
    local nConcentrationDamage = 0;
    local bRemoveTarget = false;

    -- Remember current health status
    local _, sOriginalStatus = ActorManagerADND.getWoundPercent(rTarget);

    -- Decode damage/heal description
    local rDamageOutput = ActionDamage.decodeDamageText(nTotal, sDamage);

    -- Healing
    if rDamageOutput.sType == "recovery" then
        local sClassNode = string.match(sDamage, "%[NODE:([^]]+)%]");

        if nWounds <= 0 then
            table.insert(aNotifications, "[NOT WOUNDED]");
        else
            -- Determine whether HD available
            local nClassHD = 0;
            local nClassHDMult = 0;
            local nClassHDUsed = 0;
            if sTargetType == "pc" and sClassNode then
                local nodeClass = DB.findNode(sClassNode);
                nClassHD = DB.getValue(nodeClass, "level", 0);
                nClassHDMult = #(DB.getValue(nodeClass, "hddie", {}));
                nClassHDUsed = DB.getValue(nodeClass, "hdused", 0);
            end

            if (nClassHD * nClassHDMult) <= nClassHDUsed then
                table.insert(aNotifications, "[INSUFFICIENT HIT DICE FOR THIS CLASS]");
            else
                -- Calculate heal amounts
                local nHealAmount = rDamageOutput.nVal;

                -- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
                if (nHealAmount > 0) and (nWounds >= nTotalHP) then
                    EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
                    nWounds = nTotalHP;
                end

                local nWoundHealAmount = math.min(nHealAmount, nWounds);
                nWounds = nWounds - nWoundHealAmount;

                -- Display actual heal amount
                rDamageOutput.nVal = nWoundHealAmount;
                rDamageOutput.sVal = string.format("%01d", nWoundHealAmount);

                -- Decrement HD used
                if sTargetType == "pc" and sClassNode then
                    local nodeClass = DB.findNode(sClassNode);
                    DB.setValue(nodeClass, "hdused", "number", nClassHDUsed + 1);
                    rDamageOutput.sVal = rDamageOutput.sVal .. "][HD-1";
                end
            end
        end

        -- Healing
    elseif rDamageOutput.sType == "heal" then
        if nWounds <= 0 then
            table.insert(aNotifications, "[NOT WOUNDED]");
        else
            -- Calculate heal amounts
            local nHealAmount = rDamageOutput.nVal;

            -- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
            if (nHealAmount > 0) and (nWounds >= nTotalHP) then
                if PlayerOptionManager.shouldTreatDeathsDoorHealingSameAsAllOtherHealing() then
                    if (nWounds - nHealAmount <= nTotalHP) then
                        EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
                    end
                else
                    EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
                    nWounds = nTotalHP;
                    nHealAmount = 1; -- heals only restore 1 hp when below 0.
                end
            end

            local nWoundHealAmount = math.min(nHealAmount, nWounds);
            nWounds = nWounds - nWoundHealAmount;

            -- Display actual heal amount
            rDamageOutput.nVal = nWoundHealAmount;
            rDamageOutput.sVal = string.format("%01d", nWoundHealAmount);
        end

        -- Temporary hit points
    elseif rDamageOutput.sType == "temphp" then
        nTempHP = math.max(nTempHP, nTotal);

        -- Damage
    else
        -- Apply any targeted damage effects 
        -- NOTE: Dice determined randomly, instead of rolled
        if rSource and rTarget and rTarget.nOrder then
            local bCritical = string.match(sDamage, "%[CRITICAL%]");
            local aTargetedDamage = EffectManager5E.getEffectsBonusByType(rSource, {"DMG"}, true,
                rDamageOutput.aDamageFilter, rTarget, true);

            local nDamageEffectTotal = 0;
            local nDamageEffectCount = 0;
            for k, v in pairs(aTargetedDamage) do
                local bValid = true;
                local aSplitByDmgType = StringManager.split(k, ",", true);
                for _, vDmgType in ipairs(aSplitByDmgType) do
                    if vDmgType == "critical" and not bCritical then
                        bValid = false;
                    end
                end

                if bValid then
                    local nSubTotal = StringManager.evalDice(v.dice, v.mod);

                    local sDamageType = rDamageOutput.sFirstDamageType;
                    if sDamageType then
                        sDamageType = sDamageType .. "," .. k;
                    else
                        sDamageType = k;
                    end

                    rDamageOutput.aDamageTypes[sDamageType] = (rDamageOutput.aDamageTypes[sDamageType] or 0) + nSubTotal;

                    nDamageEffectTotal = nDamageEffectTotal + nSubTotal;
                    nDamageEffectCount = nDamageEffectCount + 1;
                end
            end
            nTotal = nTotal + nDamageEffectTotal;

            if nDamageEffectCount > 0 then
                if nDamageEffectTotal ~= 0 then
                    local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]";
                    table.insert(aNotifications, string.format(sFormat, nDamageEffectTotal));
                else
                    table.insert(aNotifications, "[" .. Interface.getString("effects_tag") .. "]");
                end
            end
        end

        -- Handle avoidance/evasion and half damage
        local isAvoided = false;
        local isHalf = string.match(sDamage, "%[HALF%]");
        local sAttack = string.match(sDamage, "%[DAMAGE[^]]*%] ([^[]+)");
        if sAttack then
            local sDamageState = ActionDamage.getDamageState(rSource, rTarget, StringManager.trim(sAttack));
            if sDamageState == "none" then
                isAvoided = true;
                bRemoveTarget = true;
            elseif sDamageState == "half_success" then
                isHalf = true;
                bRemoveTarget = true;
            elseif sDamageState == "half_failure" then
                isHalf = true;
            end
        end
        if isAvoided then
            table.insert(aNotifications, "[EVADED]");
            for kType, nType in pairs(rDamageOutput.aDamageTypes) do
                rDamageOutput.aDamageTypes[kType] = 0;
            end
            nTotal = 0;
        elseif isHalf then
            table.insert(aNotifications, "[HALF]");
            local bCarry = false;
            for kType, nType in pairs(rDamageOutput.aDamageTypes) do
                local nOddCheck = nType % 2;
                rDamageOutput.aDamageTypes[kType] = math.floor(nType / 2);
                if nOddCheck == 1 then
                    if bCarry then
                        rDamageOutput.aDamageTypes[kType] = rDamageOutput.aDamageTypes[kType] + 1;
                        bCarry = false;
                    else
                        bCarry = true;
                    end
                end
            end
            nTotal = math.max(math.floor(nTotal / 2), 1);
        end

        nTotal = handleShieldAbsorb(rSource, rTarget, rDamageOutput, nTotal, aDice);

        -- Apply damage type adjustments
        local nDamageAdjust, bVulnerable, bResist, bAbsorb, nDamageDice =
            ActionDamage.getDamageAdjust(rSource, rTarget, nTotal, rDamageOutput, aDice);
        local nAdjustedDamage = nTotal + nDamageAdjust;
        if nAdjustedDamage < 0 then
            nAdjustedDamage = 0;
        end
        if bResist then
            if nAdjustedDamage <= 0 then
                table.insert(aNotifications, "[RESISTED]");
            else
                table.insert(aNotifications, "[PARTIALLY RESISTED]");
            end
        end
        if bVulnerable then
            table.insert(aNotifications, "[VULNERABLE]");
        end
        if bAbsorb then
            if nAdjustedDamage <= 0 then
                table.insert(aNotifications, "[ABSORBED]");
            else
                table.insert(aNotifications, "[PARTIALLY ABSORBED]");
            end
        end
        if nDamageDice ~= 0 then
            -- reduced damage
            if nDamageDice > 0 and nAdjustedDamage <= 0 then
                table.insert(aNotifications, "[RESISTED]");
            elseif nDamageDice > 0 then
                table.insert(aNotifications, "[PARTIALLY RESISTED]");
                -- increased damage
            elseif nDamageDice < 0 then
                table.insert(aNotifications, "[VULNERABLE]");
            end
        end

        -- Prepare for concentration checks if damaged
        nConcentrationDamage = nAdjustedDamage;

        -- Reduce damage by temporary hit points
        if nTempHP > 0 and nAdjustedDamage > 0 then
            if nAdjustedDamage > nTempHP then
                nAdjustedDamage = nAdjustedDamage - nTempHP;
                nTempHP = 0;
                table.insert(aNotifications, "[PARTIALLY ABSORBED]");
            else
                nTempHP = nTempHP - nAdjustedDamage;
                nAdjustedDamage = 0;
                table.insert(aNotifications, "[ABSORBED]");
            end
        end

        -- Apply remaining damage
        if nAdjustedDamage > 0 then
            -- Remember previous wounds
            local nPrevWounds = nWounds;

            -- Apply wounds
            nWounds = math.max(nWounds + nAdjustedDamage, 0);

            checkThresholdOfPain(rTarget, nAdjustedDamage, nTotalHP, aNotifications);

            -- Calculate wounds above HP
            if nWounds > nTotalHP then
                nRemainder = nWounds - nTotalHP;
                nWounds = nTotalHP;
            end

            -- Prepare for calcs
            local nodeTargetCT = ActorManager.getCTNode(rTarget);

            -- Deal with remainder damage
            if nRemainder >= (nTotalHP + 10) then
                table.insert(aNotifications, "[INSTANT DEATH]");
                nDeathSaveFail = 3;
            elseif nRemainder > 0 or nWounds == nTotalHP then
                if nRemainder > 0 then
                    table.insert(aNotifications, "[DAMAGE EXCEEDS HIT POINTS BY " .. nRemainder .. "]");
                else
                    table.insert(aNotifications, "[DAMAGE EXCEEDS HIT POINTS]");
                end
                if nPrevWounds >= nTotalHP then
                    if rDamageOutput.bCritical then
                        nDeathSaveFail = nDeathSaveFail + 2;
                    else
                        nDeathSaveFail = nDeathSaveFail + 1;
                    end
                end
                -- Add check here for nAdjustedDamage > 50 and if so perform system shock check?-- celestian, AD&D
            end

            -- Handle stable situation
            EffectManager.removeEffect(nodeTargetCT, "Stable");

            -- Disable regeneration next round on correct damage type
            if nodeTargetCT then
                -- Calculate which damage types actually did damage
                local aTempDamageTypes = {};
                local aActualDamageTypes = {};
                for k, v in pairs(rDamageOutput.aDamageTypes) do
                    if v > 0 then
                        table.insert(aTempDamageTypes, k);
                    end
                end
                local aActualDamageTypes = StringManager.split(table.concat(aTempDamageTypes, ","), ",", true);

                -- Check target's effects for regeneration effects that match
                -- for _,v in pairs(DB.getChildren(nodeTargetCT, "effects")) do
                for _, v in ipairs(EffectManagerADND.getEffectsList(nodeTargetCT)) do
                    local nActive = DB.getValue(v, "isactive", 0);
                    if (nActive == 1) then
                        local bMatch = false;
                        local sLabel = DB.getValue(v, "label", "");
                        local aEffectComps = EffectManager.parseEffect(sLabel);
                        for i = 1, #aEffectComps do
                            local rEffectComp = EffectManager5E.parseEffectComp(aEffectComps[i]);
                            if rEffectComp.type == "REGEN" then
                                for _, v2 in pairs(rEffectComp.remainder) do
                                    if StringManager.contains(aActualDamageTypes, v2) then
                                        bMatch = true;
                                    end
                                end
                            end

                            if bMatch then
                                EffectManager.disableEffect(nodeTargetCT, v);
                            end
                        end
                    end
                end
            end
        end

        -- Update the damage output variable to reflect adjustments
        rDamageOutput.nVal = nAdjustedDamage;
        rDamageOutput.sVal = string.format("%01d", nAdjustedDamage);
    end

    -- Clear death saves if health greater than zero
    nDeathSaveSuccess = 0;
    nDeathSaveFail = 0;
    if sTargetType == "pc" then
        if nWounds < nTotalHP then
            if EffectManager5E.hasEffect(rTarget, "Stable") then
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
            end
            -- check for optional AD&D deaths door rule (0 to -10) ? --celestian
            if EffectManager5E.hasEffect(rTarget, "Unconscious") then
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious");
            end
            if EffectManager5E.hasEffect(rTarget, "Dead") then
                EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Dead");
            end
        else
            -- check for optional AD&D deaths door rule --celestian
            local bDeathsDoor = OptionsManager.isOption("HouseRule_DeathsDoor", "on"); -- using deaths door aD&D rule
            local nDEAD_AT = -10; -- death at -10
            if not bDeathsDoor then
                nDEAD_AT = 0;
            end
            if bDeathsDoor and not EffectManager5E.hasEffect(rTarget, "Unconscious") and
                ((nTotalHP - nWounds) - nRemainder > nDEAD_AT) then
                EffectManager.addEffect("", "", ActorManager.getCTNode(rTarget), {
                    sName = "Unconscious;DMGO:1",
                    sLabel = "Unconscious;DMGO:1",
                    nDuration = 0
                }, true);
                -- if below nDEAD_AT then mark DEAD and remove unconscious
            elseif not EffectManager5E.hasEffect(rTarget, "Dead") and not ((nTotalHP - nWounds) - nRemainder > nDEAD_AT) then
                -- removing an effect here causes an error because we're going through a loop of effects where DMGO is called and if this one
                -- is removed it causes the for loop to crash
                -- EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious");
                EffectManager.addEffect("", "", ActorManager.getCTNode(rTarget), {
                    sName = "Dead",
                    nDuration = 0
                }, true);
            end
        end

        -- if optional rule from Fighter's Handbook using Armor Damage (DP) then...
        if OptionsManager.getOption("OPTIONAL_ARMORDP") == 'on' then
            -- armor takes 1 damage each time "damaged"
            local nodeCT = DB.findNode(ActorManager.getCTNodeName(rTarget));
            local nodeChar = ActorManager.getCreatureNode(nodeCT);
            ActionDamage.damageArmorWorn(nodeChar, 1);
        end

        -- Set health fields
        DB.setValue(nodeTarget, "hp.deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3));
        DB.setValue(nodeTarget, "hp.deathsavefail", "number", math.min(nDeathSaveFail, 3));
        DB.setValue(nodeTarget, "hp.temporary", "number", nTempHP);
        DB.setValue(nodeTarget, "hp.wounds", "number", (nWounds + nRemainder));
        -- ^^ was PC
    else
        -- was NPC...
        DB.setValue(nodeTarget, "deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3));
        DB.setValue(nodeTarget, "deathsavefail", "number", math.min(nDeathSaveFail, 3));
        DB.setValue(nodeTarget, "hptemp", "number", nTempHP);
        DB.setValue(nodeTarget, "wounds", "number", nWounds);
    end

    -- Check for status change
    local bShowStatus = false;
    if ActorManager.getFaction(rTarget) == "friend" then
        bShowStatus = not OptionsManager.isOption("SHPC", "off");
    else
        bShowStatus = not OptionsManager.isOption("SHNPC", "off");
    end
    if bShowStatus then
        local _, sNewStatus = ActorManagerADND.getWoundPercent(rTarget);
        if sOriginalStatus ~= sNewStatus then
            table.insert(aNotifications, "[" .. Interface.getString("combat_tag_status") .. ": " .. sNewStatus .. "]");
        end
    end

    -- Output results
    ActionDamage.messageDamage(rSource, rTarget, bSecret, rDamageOutput.sTypeOutput, sDamage, rDamageOutput.sVal,
        table.concat(aNotifications, " "), nTotal);

    -- Remove target after applying damage
    if bRemoveTarget and rSource and rTarget then
        TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
    end

    -- Check for required concentration checks
    -- changed, using (C) effect to indicate someone is casting and if they take damage
    -- the casting is interrupted and spell lost. --celestian
    if nConcentrationDamage > 0 and ActionSave.hasConcentrationEffects(rTarget) then
        if nWounds < nTotalHP then
            ActionSave.expireConcentrationEffects(rTarget);
            local sLmsg = {
                font = "msgfont"
            };
            sLmsg.icon = "roll_cast";
            sLmsg.text = string.format(Interface.getString("message_concentration_failed"),
                ActorManager.getDisplayName(rTarget));

            local sSmsg = {
                font = "msgfont"
            };
            sSmsg.text = string.format("%s's spell casting interrupted.", ActorManager.getDisplayName(rTarget));

            ActionsManager.outputResult(bSecret, nil, rTarget, sLmsg, sSmsg);
        end
    end
end

function checkThresholdOfPain(rTarget, nAdjustedDamage, nTotalHP, aNotifications)
    if PlayerOptionManager.isUsingThresholdOfPain() and ActorManagerPO.canBeAffectedByThresholdOfPain(rTarget) then
        local nTraumaDamage = StateManagerPO.addTraumaDamage(rTarget, nAdjustedDamage);
        if nTraumaDamage >= (nTotalHP / 2) then
            table.insert(aNotifications, "[THRESHOLD OF PAIN]");
            ActionSavePO.rollThresholdOfPain(rTarget);
        end
    end
end

function handleShieldAbsorb(rSource, rTarget, rDamageOutput, nTotal, aDice)
    if not PlayerOptionManager.isUsingArmorDamage() then
        return nTotal;
    end

    if StateManagerPO.hasShieldHitState(rSource, rTarget) or Input.isAltPressed() then
        local nShieldAbsorb = 0;
        -- if shield equipped then reduce damage by up to shield hp
        local sTargetType = ActorManagerPO.getType(rTarget);
        local nodeTarget = ActorManagerPO.getCreatureNode(rTarget);
        local nodeShield = ArmorManagerPO.getDamageableShieldWorn(nodeTarget);
        local nArmorHpRemaining = ArmorManagerPO.getHpRemaining(nodeShield);

        local nShieldSpecializationMod, nShieldSpecializationCount =
            EffectManager5E.getEffectsBonus(rTarget, {"SHIELDSPEC"}, true);
        local bHasShieldSpecialization = nShieldSpecializationCount > 0;
        local nDamageSoakedPerPointTaken = 1;
        if bHasShieldSpecialization then
            nDamageSoakedPerPointTaken = nShieldSpecializationMod;
        end

        nArmorHpRemaining = nArmorHpRemaining * nDamageSoakedPerPointTaken;

        local nDamageSoaked = math.min(nTotal, nArmorHpRemaining);
        nTotal = nTotal - nDamageSoaked;
        if nDamageSoaked > 0 then
            local nShieldDamageTaken = math.floor(nDamageSoaked / nDamageSoakedPerPointTaken);

            local aSrcDmgClauseTypes = {};
            for k, v in pairs(rDamageOutput.aDamageTypes) do
                local aTemp = StringManager.split(k, ",", true);
                for _, vType in ipairs(aTemp) do
                    if vType ~= "untyped" and vType ~= "" then
                        table.insert(aSrcDmgClauseTypes, vType);
                    end
                end
            end

            ArmorManagerPO.damageArmor(nodeShield, nShieldDamageTaken);

            if sTargetType ~= 'pc' then
                CharManager.calcItemArmorClass(nodeTarget);
            end

            displayArmorDamageMessages(nodeTarget, nodeShield, nDamageSoaked, nShieldDamageTaken);
        end
    end
    return nTotal;
end

function displayArmorDamageMessages(nodeTarget, nodeArmor, nDamageSoaked, nDamageTaken, sDamageType)
    local sCharName = ActorManagerPO.getName(nodeTarget);
    local sItemName = ItemManagerPO.getItemNameForPlayer(nodeArmor);

    ChatManagerPO.deliverArmorSoakMessage(sCharName, sItemName, nDamageSoaked, nDamageTaken);
    if ArmorManagerPO.isBroken(nodeArmor) then
        ChatManagerPO.deliverArmorBrokenMessage(sCharName, sItemName);
    end
end

function getDamageAdjustOverride(rSource, rTarget, nDamage, rDamageOutput, aDice)

    local nDamageAdjust = 0;
    local bVulnerable = false;
    local bResist = false;
    local bAbsorb = false;
    local nDamageDice = 0; -- less than 0, vuln, more than 1 resist
    local sRangeType = "untypedRange";
    if (rDamageOutput.sRange == "R") then
        sRangeType = "range";
    elseif (rDamageOutput.sRange == "M") then
        sRangeType = "melee";
    elseif (rDamageOutput.sRange == "P") then
        sRangeType = "psionic";
    end

    local aImmune = ActionDamage.getReductionType(rSource, rTarget, "IMMUNE");
    local aVuln = ActionDamage.getReductionType(rSource, rTarget, "VULN");
    local aResist = ActionDamage.getReductionType(rSource, rTarget, "RESIST");
    local aDamageDiceResist = ActionDamage.getReductionType(rSource, rTarget, "DDR");

    local bIncorporealSource = EffectManager5E.hasEffect(rSource, "Incorporeal", rTarget);
    local bIncorporealTarget = EffectManager5E.hasEffect(rTarget, "Incorporeal", rSource);
    local bApplyIncorporeal = (bIncorporealSource ~= bIncorporealTarget);

    -- Handle immune all
    if aImmune["all"] then
        nDamageAdjust = 0 - nDamage;
        bResist = true;
        return nDamageAdjust, bVulnerable, bResist, 0;
    end

    -- Iterate through damage type entries for vulnerability, resistance and immunity
    local nVulnApplied = 0;
    local bResistCarry = false;
    for k, v in pairs(rDamageOutput.aDamageTypes) do
        -- Get individual damage types for each damage clause
        local aSrcDmgClauseTypes = {};
        local aTemp = StringManager.split(k, ",", true);
        for _, vType in ipairs(aTemp) do
            if vType ~= "untyped" and vType ~= "" then
                table.insert(aSrcDmgClauseTypes, vType);
            end
        end

        -- Handle standard immunity, vulnerability and resistance
        local bLocalDamageDiceResist =
            (ActionDamage.checkNumericalReductionType(aDamageDiceResist, aSrcDmgClauseTypes) ~= 0);
        local bLocalVulnerable = ActionDamage.checkReductionType(aVuln, aSrcDmgClauseTypes);
        local bLocalResist = ActionDamage.checkReductionType(aResist, aSrcDmgClauseTypes);
        local bLocalImmune = ActionDamage.checkReductionType(aImmune, aSrcDmgClauseTypes);

        -- Handle incorporeal
        if bApplyIncorporeal then
            bLocalResist = true;
        end

        -- Calculate adjustment
        -- Vulnerability = double
        -- Resistance = half
        -- Immunity = none
        local nLocalDamageAdjust = 0;
        if bLocalImmune then
            nLocalDamageAdjust = -v;
            bResist = true;
        else

            -- handle damage dice reduction DDR
            if bLocalDamageDiceResist then
                local nLocalDamageDiceResist = ActionDamage.checkDiceReductionType(aDamageDiceResist,
                    aSrcDmgClauseTypes, aDice);
                if nLocalDamageDiceResist ~= 0 then
                    nDamageDice = nLocalDamageDiceResist;
                    nLocalDamageAdjust = nLocalDamageAdjust - nLocalDamageDiceResist;
                end
            end

            -- Handle numerical resistance
            local nLocalResist = ActionDamage.checkNumericalReductionType(aResist, aSrcDmgClauseTypes, v);
            if nLocalResist ~= 0 then
                nLocalDamageAdjust = nLocalDamageAdjust - nLocalResist;
                bResist = true;
            end

            -- Handle numerical vulnerability
            local nLocalVulnerable = ActionDamage.checkNumericalReductionType(aVuln, aSrcDmgClauseTypes);
            if nLocalVulnerable ~= 0 then
                nLocalDamageAdjust = nLocalDamageAdjust + nLocalVulnerable;
                bVulnerable = true;
            end

            -- Handle standard resistance
            if bLocalResist then
                local nResistOddCheck = (nLocalDamageAdjust + v) % 2;
                local nAdj = math.ceil((nLocalDamageAdjust + v) / 2);
                nLocalDamageAdjust = nLocalDamageAdjust - nAdj;
                if nResistOddCheck == 1 then
                    if bResistCarry then
                        nLocalDamageAdjust = nLocalDamageAdjust + 1;
                        bResistCarry = false;
                    else
                        bResistCarry = true;
                    end
                end
                bResist = true;
            end
            -- Handle standard vulnerability
            if bLocalVulnerable then
                nLocalDamageAdjust = nLocalDamageAdjust + (nLocalDamageAdjust + v);
                bVulnerable = true;
            end

        end

        -- add support for "DA: # type" where damage # is absorbed from type damage and then that value is reduced the amount absorbed. --celestian
        local nAbsorbed = ActionDamage.getAbsorbedByType(rTarget, aSrcDmgClauseTypes, sRangeType,
            (nDamage - nLocalDamageAdjust));
        nAbsorbed = nAbsorbed +
                        handleArmorDamageAbsorb(rTarget, aDice, aSrcDmgClauseTypes, nDamage - nAbsorbed,
                rDamageOutput.rArmorDamageInfo);
        if nAbsorbed > 0 then
            nLocalDamageAdjust = nLocalDamageAdjust - nAbsorbed;
            bAbsorb = true;
        end

        -- Apply adjustment to this damage type clause
        nDamageAdjust = nDamageAdjust + nLocalDamageAdjust;
    end

    -- Handle damage threshold
    local nDTMod, nDTCount = EffectManager5E.getEffectsBonus(rTarget, {"DT"}, true);
    if nDTMod > 0 then
        if nDTMod > (nDamage + nDamageAdjust) then
            nDamageAdjust = 0 - nDamage;
            bResist = true;
        end
    end

    -- Results
    return nDamageAdjust, bVulnerable, bResist, bAbsorb, nDamageDice;
end

function handleArmorDamageAbsorb(rTarget, aDice, aSrcDmgClauseTypes, nDamageToAbsorb, rArmorDamageInfo)
    local nAbsorbed = 0;
    if not PlayerOptionManager.isUsingArmorDamage() then
        return nAbsorbed;
    end

    local sTargetType = ActorManagerPO.getType(rTarget);
    local nodeTarget = ActorManagerPO.getCreatureNode(rTarget);
    local nodeArmor = ArmorManagerPO.getDamageableArmorWorn(nodeTarget);
    local nArmorHpRemaining = ArmorManagerPO.getHpRemaining(nodeArmor);
    local nSoakPerDie = ArmorManagerPO.getDamageReduction(nodeArmor, aSrcDmgClauseTypes);
    local sDamageType = UtilityPO.stripWhitespace(UtilityPO.toCSV(aSrcDmgClauseTypes));

    local rArmorDamageInfoForType = rArmorDamageInfo[sDamageType];
    local nNumUnsoakedDice = 0;
    if rArmorDamageInfoForType ~= nil then
        nNumUnsoakedDice = rArmorDamageInfo[sDamageType].unsoakedDamageDice;
    else
        DiceManagerPO.getNumOriginalDice(aDice);
        DebugPO.log("had a damage type we couldn't find armor soak information for: ", sDamageType, "rArmorDamageInfo",
            rArmorDamageInfo);
    end

    local nPointsThatCanBeSoaked = math.min(nNumUnsoakedDice * nSoakPerDie, nDamageToAbsorb);
    local nDamageSoaked = math.min(nPointsThatCanBeSoaked, nArmorHpRemaining);
    nAbsorbed = nDamageSoaked;
    if nDamageSoaked > 0 then
        local nArmorDamageTaken = nDamageSoaked;

        if ArmorManagerPO.canDamageTypeHurtArmor(aSrcDmgClauseTypes, nodeArmor) then
            ArmorManagerPO.damageArmor(nodeArmor, nDamageSoaked);
        elseif PlayerOptionManager.isMagicArmorDamagedByPenetration() then

            -- This is a little hacky and doesn't actually check that the penetrations were rolled for this damage type, which could lead to armor 
            -- taking damage when a non-armor-damaging damage type penetrates. However, teasing out which type caused the penetration is pretty
            -- hard to do at this point, so for now I'm settling for this.

            local nPenetration = math.min(nNumUnsoakedDice, DiceManagerPO.getNumOriginalDiceThatPenetrated(aDice) -
                rArmorDamageInfo.nPenetrationsHandled);
            -- nArmorDamageTaken = math.min(nDamageSoaked, DiceManagerPO.getNumOriginalDiceThatPenetrated(aDice));
            nArmorDamageTaken = math.min(nDamageSoaked, nPenetration);
            rArmorDamageInfo.nPenetrationsHandled = rArmorDamageInfo.nPenetrationsHandled + nArmorDamageTaken;

            ArmorManagerPO.damageArmor(nodeArmor, nArmorDamageTaken);
        else
            nArmorDamageTaken = 0;
        end

        if sTargetType ~= 'pc' then
            CharManager.calcItemArmorClass(nodeTarget);
        end

        displayArmorDamageMessages(nodeTarget, nodeArmor, nDamageSoaked, nArmorDamageTaken, sDamageType);
    end
    return nAbsorbed;
end

function modDamageOverride(rSource, rTarget, rRoll)
    if PlayerOptionManager.isAnyCritEnabled() then
        local bIsCrit, nCritMultiplier, nBonusDie = StateManagerPO.hasCritState(rSource, rTarget);
        if bIsCrit then
            if nCritMultiplier and nCritMultiplier > 0 then
                rRoll.nCritMultiplier = nCritMultiplier;
            end
            if nBonusDie and nBonusDie > 0 then
                rRoll.nCritBonusDie = nBonusDie;
            end
        end
    end

    local aAddDice_Multiplier, nAddMod_Multiplier, nEffectCount_Multiplier =
        EffectManager5E.getEffectsBonus(rSource, {"DMGDX"}, false, aAttackFilter, rTarget);
    if nEffectCount_Multiplier > 0 then
        local nSubTotal = StringManager.evalDice(aAddDice_Multiplier, nAddMod_Multiplier);
        rRoll.nDamageDiceMultiplier = nSubTotal;
    end

    fModDamage(rSource, rTarget, rRoll);
end

function onDamageRollOverride(rSource, rRoll)
    if PlayerOptionManager.isAnyCritEnabled() then
        if rRoll.nCritMultiplier then
            rRoll.sDesc = string.format("%s [CRITICAL HIT (x%s)]", rRoll.sDesc, rRoll.nCritMultiplier);
            DiceManagerPO.multiplyDice(rRoll, rRoll.nCritMultiplier);
        end
        if rRoll.nCritBonusDie then
            rRoll.sDesc = string.format("%s [CRITICAL HIT (+d%s)]", rRoll.sDesc, rRoll.nCritBonusDie);
            DiceManagerPO.addDie(rRoll, rRoll.nCritBonusDie);
        end

    end

    if rRoll.nDamageDiceMultiplier then
        rRoll.sDesc = string.format("%s [DAMAGE DICE MULTIPLIER (x%s)]", rRoll.sDesc, rRoll.nDamageDiceMultiplier);
        DiceManagerPO.multiplyDice(rRoll, rRoll.nDamageDiceMultiplier);
    end

    if PlayerOptionManager.isPenetrationDiceEnabled() and EffectManagerPO.isAllowedToPenetrate(rSource) then
        local aDmgTypes = parseDamageTypes(rRoll);
        local bExtraPenetration = UtilityPO.contains(aDmgTypes, "penetrating");
        DiceManagerPO.handlePenetration(rRoll, bExtraPenetration);
    end

    if rRoll.sPowerType and rRoll.sPowerType == "arcane" and EffectManagerPO.hasSpellRazor(rSource) then
        local nNumDiceRolled = #rRoll.aDice;
        if nNumDiceRolled > 0 then
            rRoll.sDesc = string.format("%s [Spell Razor (+%s)]", rRoll.sDesc, nNumDiceRolled);
            rRoll.nMod = rRoll.nMod + nNumDiceRolled;
        end
    end

    HonorManagerPO.addDamageModifier(rSource, rRoll);

    -- Handle max damage
    local bMax = rRoll.sDesc:match("%[MAX%]") or rRoll.sCriticalType:match("max");
    if bMax then
        for _, vDie in ipairs(rRoll.aDice) do
            local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
            if sDieSides then
                local nResult;
                if sDieSides == "F" then
                    nResult = 1;
                else
                    nResult = tonumber(sDieSides) or 0;
                end

                if sSign == "-" then
                    nResult = 0 - nResult;
                end

                vDie.result = nResult;
                vDie.value = nil;
                if sColor == "d" or sColor == "D" then
                    if sSign == "-" then
                        vDie.type = "-b" .. sDieSides;
                    else
                        vDie.type = "b" .. sDieSides;
                    end
                end
            end
        end
        if rRoll.aDice.expr then
            rRoll.aDice.expr = nil;
        end
    end

    local bXTwoDamage = rRoll.sCriticalType:match("timestwo");
    -- crit == x2, so we double the result of all rolls
    if rRoll.bCritical and bXTwoDamage then
        for _, vDie in ipairs(rRoll.aDice) do
            local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
            if sDieSides then
                vDie.result = vDie.result * 2 or 0;
                if sColor == "d" or sColor == "D" then
                    if sSign == "-" then
                        vDie.type = "-b" .. sDieSides;
                    else
                        vDie.type = "b" .. sDieSides;
                    end
                end
            end
        end
        if rRoll.aDice.expr then
            rRoll.aDice.expr = nil;
        end
    end

    -- check for damage multiplier and apply from effect DMGX
    if rRoll.nDamageMultiplier then
        local nMultiplier = tonumber(rRoll.nDamageMultiplier) or 1;
        if nMultiplier < 0 then
            nMultiplier = 1;
        end

        if PlayerOptionManager.shouldUseAlternateDmgx() then
            DiceManagerPO.applyBaseRollMultiplier(rRoll, nMultiplier);
        else
            -- add [x2] to the damage string for visual
            rRoll.sDesc = rRoll.sDesc .. " [x" .. nMultiplier .. "]";
            for _, vDie in ipairs(rRoll.aDice) do
                local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
                if sDieSides then
                    vDie.result = math.floor(vDie.result * nMultiplier);
                    -- without setting this things break now (post FGU)
                    vDie.value = vDie.result;
                    --
                    if sColor == "d" or sColor == "D" then
                        if sSign == "-" then
                            vDie.type = "-b" .. sDieSides;
                        else
                            vDie.type = "b" .. sDieSides;
                        end
                    end
                end
            end
        end
        if rRoll.aDice.expr then
            rRoll.aDice.expr = nil;
        end
    end

    ActionDamage.decodeDamageTypes(rRoll, true);
end

function parseDamageTypes(rRoll)
    local aDmgTypes = {};
    for sDamageType, sDamageDice, sDamageAbility, sDamageAbilityMult, sDamageReroll in string.gmatch(rRoll.sDesc,
        "%[TYPE: ([^(]*) %(([^)]*)%)%((%w*)%)%(([^)]*)%)%(([%w,]*)%)%]") do
        local aTypes = UtilityPO.fromCSV(sDamageType);
        for _, sType in pairs(aTypes) do
            table.insert(aDmgTypes, sType:lower());
        end
    end
    return aDmgTypes;
end

function checkReductionTypeOverride(aReduction, aDmgType)
    if not PlayerOptionManager.isStricterResistancesEnabled() then
        return fCheckReductionType(aReduction, aDmgType);
    end

    local aReducedDamageTypes = {};

    for _, sDmgType in pairs(aDmgType) do
        if ActionDamage.checkReductionTypeHelper(aReduction[sDmgType], aDmgType) or
            ActionDamage.checkReductionTypeHelper(aReduction["all"], aDmgType) then
            table.insert(aReducedDamageTypes, sDmgType);
        end
    end

    if #aReducedDamageTypes == 0 then
        return false;
    else
        -- We're going to treat bludgeoning/piercing/slashing differently, and say that if it contains more than one of these types, it must 
        -- resist ALL of these "base" damage types it contains to be resisted. (i.e., a bludgeoning/piercing morningstar shouldn't be resisted by 
        -- just bludgeoning resist, but should instead require both bludgeoning resist and piercing resist)
        local bIsBludgeoning, bIsPiercing, bIsSlashing = hasBaseDamageTypes(aDmgType);
        local bResistsBludgeoning, bResistsPiercing, bResistsSlashing = hasBaseDamageTypes(aReducedDamageTypes);

        local bResistsAllBaseTypesItContains = true;
        bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bIsBludgeoning or bResistsBludgeoning);
        bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bIsPiercing or bResistsPiercing);
        bResistsAllBaseTypesItContains = bResistsAllBaseTypesItContains and (not bResistsSlashing or bResistsSlashing);

        return bResistsAllBaseTypesItContains;
    end
end

function hasBaseDamageTypes(aDmgTypes)
    local bBludgeoning = false;
    local bPiercing = false;
    local bSlashing = false;

    for _, sDmgType in pairs(aDmgTypes) do
        local sDmgTypeLower = sDmgType:lower();
        if sDmgTypeLower:find("bludgeoning") then
            bBludgeoning = true;
        elseif sDmgTypeLower:find("slashing") then
            bSlashing = true;
        elseif sDmgTypeLower:find("piercing") then
            bPiercing = true;
        end
    end

    return bBludgeoning, bPiercing, bSlashing;
end

