local fGetPowerRoll;
local fGetCasterLevelByType;

function onInit()
    fGetPowerRoll = PowerManager.getPowerRoll;
    PowerManager.getPowerRoll = getPowerRollOverride;

    fGetCasterLevelByType = PowerManager.getCasterLevelByType;
    PowerManager.getCasterLevelByType = getCasterLevelByTypeOverride;

    fGetLevelBasedDiceValues = PowerManager.getLevelBasedDiceValues;
    PowerManager.getLevelBasedDiceValues = getLevelBasedDiceValuesOverride;
end

function getLevelBasedDiceValuesOverride(nodeCaster, isPC, node, nodeAction)
    local nDiceCount = 0;
    local aDice = DB.getValue(nodeAction, "dice", {});
    local nMod = DB.getValue(nodeAction, "bonus", 0);
    local sCasterType = DB.getValue(nodeAction, "castertype", "");
    local nCasterMax = DB.getValue(nodeAction, "castermax", 20);
    local nCustomValue = DB.getValue(nodeAction, "customvalue", 0);
    local aDmgDiceCustom = DB.getValue(nodeAction, "dicecustom", {});
    local nodeSpell = node.getChild("...");
    local sSpellType = DB.getValue(nodeSpell, "type", ""):lower();
    local nCasterLevel = PowerManager.getCasterLevelByType(nodeCaster, sSpellType, isPC, nodeSpell); -- PO Note: The only thing that changed in this whole method was adding nodeSpell as a parameter
    -- local nCasterLevel = 1;
    -- local sSpellType = DB.getValue(nodeSpell, "type", ""):lower();
    -- if (sSpellType:match("arcane")) then
    -- nCasterLevel = DB.getValue(nodeCaster, "arcane.totalLevel",1);
    -- elseif (sSpellType:match("divine")) then
    -- nCasterLevel = DB.getValue(nodeCaster, "divine.totalLevel",1);
    -- elseif (sSpellType:match("psionic")) then
    -- nCasterLevel = DB.getValue(nodeCaster, "psionic.totalLevel",1);
    -- else
    -- if (isPC) then
    -- -- use spelltype name and match it with class and return that level
    -- nCasterLevel = CharManager.getClassLevelByName(nodeCaster,sSpellType);
    -- if (nCasterLevel <= 0) then
    -- nCasterLevel = CharManager.getActiveClassMaxLevel(nodeCaster);
    -- end
    -- else
    -- nCasterLevel = DB.getValue(nodeCaster, "level",1);
    -- end
    -- end
    -- if castertype ~= "" then setup the dice
    if (sCasterType ~= nil) then
        -- make sure nCasterLevel is not larger than max size
        if nCasterMax > 0 and nCasterLevel > nCasterMax then
            nCasterLevel = nCasterMax;
        end
        -- match the caster level number on end of string
        local sCasterLevel = sCasterType:match("casterlevelby(%d+)");
        if sCasterType == "casterlevel" then
            nDiceCount = nCasterLevel;
        elseif sCasterLevel then
            local nDividedBy = tonumber(sCasterLevel) or 1;
            nDiceCount = math.floor(nCasterLevel / nDividedBy);
        else
            nDiceCount = 1;
        end
        if nDiceCount > 0 then
            -- if using customvalue multiply it by CL value and add that to +mod total
            if (nCustomValue > 0) then
                nMod = nMod + (nCustomValue * nDiceCount); -- nDiceCount is CL value
            end
            local aNewDmgDice = {}
            local nDiceIndex = 0;
            -- roll count number of "dice" LEVEL D {DICE}
            for count = 1, nDiceCount do
                for i = 1, #aDice do
                    nDiceIndex = nDiceIndex + 1;
                    aNewDmgDice[nDiceIndex] = aDice[i];
                end
            end
            -- add in custom plain dice now
            for i = 1, #aDmgDiceCustom do
                nDiceIndex = nDiceIndex + 1;
                aNewDmgDice[nDiceIndex] = aDmgDiceCustom[i];
            end

            aDice = aNewDmgDice;
        end
    end
    -- end sort out level for dice count

    -- return adjusted modifier and dice
    return nMod, aDice;
end

function getCasterLevelByTypeOverride(nodeCaster, sSpellType, bIsPC, nodeSpell)
    local rActor = ActorManager.resolveActor(nodeCaster);
    -- Debug.console("manager_power.lua","getCasterLevelByType","nodeCaster",nodeCaster);  
    -- Debug.console("manager_power.lua","getCasterLevelByType","sSpellType",sSpellType);  
    -- Debug.console("manager_power.lua","getCasterLevelByType","bIsPC",bIsPC);  
    local nCasterLevel = 1;
    sSpellType = sSpellType:lower();
    -- if spelltype set to a number we use that as the "caster level"
    if sSpellType:match("^%d+$") then
        nCasterLevel = tonumber(sSpellType) or 1;
    else
        if (sSpellType:match("arcane")) then
            -- local aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rActor, {"ARCANELEVEL"}, false);
            nCasterLevel = DB.getValue(nodeCaster, "arcane.totalLevel", 1);
        elseif (sSpellType:match("divine")) then
            -- local aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rActor, {"DIVINELEVEL"}, false);
            nCasterLevel = DB.getValue(nodeCaster, "divine.totalLevel", 1);
        elseif (sSpellType:match("psionic")) then
            -- local aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rActor, {"PSIONICLEVEL"}, false);
            nCasterLevel = DB.getValue(nodeCaster, "psionic.totalLevel", 1);
        elseif (bIsPC) then
            -- use spelltype name and match it with class and return that level
            nCasterLevel = CharManager.getClassLevelByName(nodeCaster, sSpellType);
            if (nCasterLevel <= 0) then
                nCasterLevel = 1;
            end
            -- if (nCasterLevel <= 0) then
            -- nCasterLevel = CharManager.getActiveClassMaxLevel(nodeCaster);
            -- end
        elseif (not bIsPC) then -- npcs default to their HD/level
            nCasterLevel = DB.getValue(nodeCaster, "level", 1);
        end

        local aSpellSchools = nil;
        if nodeSpell then
            local sSpellSchools = LibraryData5E.sanitizevNodeText(DB.getValue(nodeSpell, "school", ""):lower());
            if sSpellSchools ~= "" then
                aSpellSchools = UtilityPO.fromCSV(sSpellSchools);
            end
        end

        -- get sSpellType "ARCANE: X" effect modifier?
        local aSpellTypesList = EffectManager5E.getEffectsByType(rActor, sSpellType:upper(), {}, {});
        for k, v in pairs(aSpellTypesList) do
            if #v.remainder > 0 then
                if aSpellSchools and #aSpellSchools > 0 then
                    if UtilityPO.intersects(aSpellSchools, v.remainder) then
                        local nAddTotal = StringManager.evalDice(v.dice, v.mod)
                        nCasterLevel = nCasterLevel + nAddTotal;
                    end
                end
            else
                local nAddTotal = StringManager.evalDice(v.dice, v.mod);
                nCasterLevel = nCasterLevel + nAddTotal;
            end

        end

        -- local aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rActor, {sSpellType:upper()}, false);
        -- if nEffectCount > 0 then
        --   local nAddTotal = StringManager.evalDice(aAddDice, nAddMod);
        --  nCasterLevel = nCasterLevel + nAddTotal;
        -- end
    end -- sSpellType == Number

    -- Debug.console("manager_power.lua","getCasterLevelByType","nCasterLevel",nCasterLevel);  
    return nCasterLevel;
end

function getPowerRollOverride(rActor, nodeAction, sSubRoll)
    local rAction = fGetPowerRoll(rActor, nodeAction, sSubRoll);

    -- Add power type and school type
    if nodeAction then

        -- Add Power Type to action so we can check effects like SPELLRAZOR
        local sType = DB.getValue(nodeAction, "type", "");
        local nodeSpell = nodeAction.getChild("...");
        rAction.sPowerType = DB.getValue(nodeSpell, "type", ""):lower();

        local sPowerSchools = LibraryData5E.sanitizevNodeText(DB.getValue(nodeSpell, "school", ""):lower());
        rAction.sPowerSchool = sPowerSchools;

        -- Add schools of magic to the power properties so we can modify saves based on it.
        if sPowerSchools then
            if not rAction.properties then
                rAction.properties = "";
            end

            if #rAction.properties > 0 then
                rAction.properties = rAction.properties .. ", "
            end

            rAction.properties = rAction.properties .. sPowerSchools;
        end
    end

    return rAction;
end
