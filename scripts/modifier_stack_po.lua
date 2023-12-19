function onInit()
    Comm.registerSlashHandler("clearmodifiers", onClearModifiers)
end

function onClearModifiers(sCmd, sParams)
    ChatManagerPO.deliverChatMessage("Clearing all temporary combat modifiers (such as rear attack, no dexterity, etc");
    ModifierStackPO.clearModifiers();
end

function clearModifiers()
    for k, v in pairs(ModifierManager._tKeysActive) do
        DebugPO.log("k", k, "v", v);
        ModifierManager.setKey(k, false, true);
    end
end

function peekModifierKey(sModifierKey)
    return ModifierManager.getRawKey(sModifierKey);
end

function hasSequencedInitModifierKey()
    local nNumAttacks = peekSequencedInitModifierKey();
    return nNumAttacks > 0;
end

function peekSequencedInitModifierKey()
    if ModifierManager.getRawKey("SEQUENCED_ATTACK_2") then
        return 2;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_3") then
        return 3;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_4") then
        return 4;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_5") then
        return 5;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_6") then
        return 6;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_7") then
        return 7;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_8") then
        return 8;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_9") then
        return 9;
    elseif ModifierManager.getRawKey("SEQUENCED_ATTACK_10") then
        return 10;
    end

    return 0;
end

function getSequencedInitModifierKey()
    if ModifierStack.getModifierKey("SEQUENCED_ATTACK_2") then
        return 2;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_3") then
        return 3;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_4") then
        return 4;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_5") then
        return 5;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_6") then
        return 6;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_7") then
        return 7;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_8") then
        return 8;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_9") then
        return 9;
    elseif ModifierStack.getModifierKey("SEQUENCED_ATTACK_10") then
        return 10;
    end

    return 0;
end

function setSequencedInitModifierKey(nNumAttacks)
    ModifierStack.setModifierKey("SEQUENCED_ATTACK_" .. nNumAttacks, true);
end
