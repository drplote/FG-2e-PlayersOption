function onInit()
end

function log(...)
    if PlayerOptionManager.shouldShowDebugInConsole() then
        Debug.console("Extension Debug:", ...);
    elseif PlayerOptionManager.shouldShowDebugInChat() then
        Debug.chat("Extension Debug (" .. User.getUsername() .. "):", ...);
    end
end
