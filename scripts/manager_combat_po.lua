        local fRollNpcHitPoints;

function onInit()
    fRollNpcHitPoints = CombatManagerADND.rollNPCHitPoints;
    CombatManagerADND.rollNPCHitPoints = rollNPCHitPointsOverride;
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