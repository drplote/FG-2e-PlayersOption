local fModRoll;

function onInit()

    -- checks override
    fModRoll = ActionCheck.modRoll;
    ActionCheck.modRoll = modRollOverride;
    ActionsManager.registerModHandler("check", modRollOverride);

end

function modRollOverride(rSource, rTarget, rRoll)
    local nodeActor = ActorManagerPO.getNode(rSource);
    setArmorPenaltyAdjustements(nodeActor, rRoll);
    fModRoll(rSource, rTarget, rRoll);
    HonorManagerPO.addAttributeCheckModiifer(rSource, rRoll);
end

-- Implements the armor penalties (DEX) from the complete fighters handbook - chapter 5 - effects of armor
function setArmorPenaltyAdjustements(nodeActor, rRoll)

    if not PlayerOptionManager.isCfhDexPenaltyArmorOptionsEnabled() then
        return;
    end

    -- get roll data and remove all whitespace/lowercase to check if dex based
    local strDesc = rRoll.sDesc:gsub("%s+", ""):lower();
    local arArmorPenaltyList = {};
    local isDexBased = string.find(strDesc, '%[check%]dexterity') or string.find(strDesc, '%[mod:dex%]');

    -- Debug.chat(strDesc);

    if isDexBased then

        -- Debug.chat('DEX BASED CHECK AND/OR SKILL WAS DETECTED');

        -- get all armor/sheilds
        local _, aArmorWorn = ItemManager2.getArmorWorn(nodeActor);

        -- iterate each armor found and cross check with the armor penalty table
        for _, nodeItem in ipairs(aArmorWorn) do

            local sArmorName = DB.getValue(nodeItem, "name", "");
            local sArmorNameLower = DB.getValue(nodeItem, "name", ""):lower();
            local nIndex = 0;

            -- if fuzzy match found, concat message/modifiers
            for sValue, penalty in pairs(DataCommonPO.cfhArmorPenalties) do
                if string.find(sArmorNameLower, sValue) then
                    if (penalty ~= 0) then
                        sArmorNameLower = '';
                        rRoll.nMod = rRoll.nMod + penalty;
                        rRoll.sDesc = rRoll.sDesc .. " [" .. sArmorName .. " " .. penalty .. "]";
                    end
                end
            end
        end

        -- if next(arArmorPenaltyList) ~= nil then

        -- end

    end
end
