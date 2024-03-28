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

    local strDesc = rRoll.sDesc;

    -- Debug.chat(strDesc);

    -- DEX based skills/checks only
    if string.find(strDesc, 'Dexterity') or string.find(strDesc, 'DEX') then

        -- Debug.chat('DEX BASED CHECK AND/OR SKILL WAS DETECTED');

        -- get all armor/sheilds
        local _, aArmorWorn = ItemManager2.getArmorWorn(nodeActor);

        -- iterate each armor found and cross check with the armor penalty table
        for _, nodeItem in ipairs(aArmorWorn) do

            local sArmorName = DB.getValue(nodeItem, "name", "");
            local sArmorNameLower = DB.getValue(nodeItem, "name", ""):lower();
            local nIndex = 0;

            -- if fuzzy match found, concat message/modifiers
            for sValue, index in pairs(DataCommonPO.cfhArmorPenalties) do

                if string.find(sArmorNameLower, sValue) then
                    if (index ~= 0) then
                        sArmorNameLower = '';
                        rRoll.nMod = rRoll.nMod + index;
                        rRoll.sDesc = rRoll.sDesc .. " [" .. sArmorName .. " " .. index .. "]";
                    end
                end
            end
        end
    end
end
