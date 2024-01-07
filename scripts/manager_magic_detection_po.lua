function onInit()
    Comm.registerSlashHandler("detectmagic", onDetectMagic)
end

function onDetectMagic(sCmd, sParams)
    if not Session.IsHost then
        ChatManagerPO.deliverChatMessage("Only the DM can use /detectmagic.");
        return;
    end

    local aParams = {};
    if sParams then
        for sParam in sParams:gmatch("%w+") do
            table.insert(aParams, sParam);
        end
    end

    local bDmOnlyOutput = false;
    local bMarkItems = true;
    local bValidParams = false;
    if #aParams == 2 then
        bValidParams = true;
        DebugPO.log(aParams);
        bMarkItems = aParams[1] ~= "0"; -- Did it this way so any value other than 0 is treated as wanting to mark.
        bDmOnlyOutput = aParams[2] ~= "0"; -- Did it this way so any value other than 0 is treated as DM only
    end

    if not bValidParams then
        ChatManagerPO.deliverChatMessage(
            "Usage: /detectmagic [#markItemsAsMagical (0 or 1)] [#dmonly (0 or 1)]\rExample: /detectmagic 1 0 would mark items as magical and show the output to everyone.");
        return;
    end

    local aDetected = {};
    for _, v in pairs(DB.getChildren("partysheet.partyinformation")) do
        local sClass, sRecord = DB.getValue(v, "link");
        if sClass == "charsheet" and sRecord then
            local nodePC = DB.findNode(sRecord);
            if nodePC then
                local sCharacterName = DB.getValue(nodePC, "name", "");
                detectMagicOnItems(aDetected, sCharacterName, DB.getChildren(nodePC, "inventorylist"), bMarkItems);
            end
        end
    end
    detectMagicOnItems(aDetected, "Party Sheet", DB.getChildren("partysheet.treasureparcelitemlist"), bMarkItems);
    ChatManagerPO.deliverDetectMagicResults(aDetected, bDmOnlyOutput);
end

function detectMagicOnItem(aDetected, sOwner, nodeItem, bMarkItems)
    local bIsMagical = false;
    if bMarkItems then
        bIsMagical = ItemManagerPO.tagIfUnidentifiedAndMagical(nodeItem)
    else
        bIsMagical = ItemManagerPO.isMagical(nodeItem);
    end

    if bIsMagical then
        table.insert(aDetected, {
            owner = sOwner,
            itemName = ItemManagerPO.getItemNameForPlayer(nodeItem)
        });
    end
end

function detectMagicOnItems(aDetected, sOwner, aItems, bMarkItems)
    for _, nodeItem in pairs(aItems) do
        detectMagicOnItem(aDetected, sOwner, nodeItem, bMarkItems)
    end
end
