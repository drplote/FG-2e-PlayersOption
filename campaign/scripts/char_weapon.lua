function onInit()
    super.onInit();
end

function onAttackAction(draginfo)
    local nodeWeapon = getDatabaseNode();
    local nodeChar = nodeWeapon.getChild("...")
    local rActor = ActorManager.getActor("", nodeChar);

    -- add itemPath to rActor so that when effects are checked we can 
    -- make compare against action only effects
    local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
    rActor.itemPath = sRecord;
    --Debug.console("char_Weapon.lua","onAttackAction","rActor",rActor);    
    --

    local rAction = {};

    local aWeaponProps = StringManager.split(DB.getValue(nodeWeapon, "properties", ""):lower(), ",", true);

    rAction.label = super.name.getValue();
    rAction.stat = DB.getValue(nodeWeapon, "attackstat", "");
    if type.getValue() == 2 then
    rAction.range = "R";
    if rAction.stat == "" then
      rAction.stat = "strength";
    end
    elseif type.getValue() == 1 then
    rAction.range = "R";
    if rAction.stat == "" then
      rAction.stat = "dexterity";
    end
    else
    rAction.range = "M";
    if rAction.stat == "" then
      rAction.stat = "strength";
    end
    end
    rAction.modifier = DB.getValue(nodeWeapon, "attackbonus", 0) + ActorManager2.getAbilityBonus(rActor, rAction.stat, "hitadj");

    rAction.modifier = rAction.modifier + getToHitProfs(nodeWeapon);

    rAction.bWeapon = true;

    -- Decrement ammo
    local nMaxAmmo = DB.getValue(nodeWeapon, "maxammo", 0);
    if nMaxAmmo > 0 then
    local nUsedAmmo = DB.getValue(nodeWeapon, "ammo", 0);
    if nUsedAmmo >= nMaxAmmo then
      ChatManager.Message(Interface.getString("char_message_atkwithnoammo"), true, rActor);
    else
      DB.setValue(nodeWeapon, "ammo", "number", nUsedAmmo + 1);
    end
    end

    -- Determine crit range
    local nCritThreshold = 20;
    if rAction.range == "R" then
    nCritThreshold = DB.getValue(nodeChar, "weapon.critrange.ranged", 20);
    else
    nCritThreshold = DB.getValue(nodeChar, "weapon.critrange.melee", 20);
    end
    for _,vProperty in ipairs(aWeaponProps) do
    local nPropCritRange = tonumber(vProperty:match("crit range (%d+)")) or 20;
    if nPropCritRange < nCritThreshold then
      nCritThreshold = nPropCritRange;
    end
    end
    if nCritThreshold > 1 and nCritThreshold < 20 then
    rAction.nCritRange = nCritThreshold;
    end

    -- NOTE: this is the only modified line in this method. the rest is the 2e implementation
    addDamageTypesToAction(nodeWeapon, rActor); 

    ActionAttack.performRoll(draginfo, rActor, rAction);

    return true;
end

function addDamageTypesToAction(nodeWeapon, rActor)
    rActor.aDamageTypes = WeaponManagerPO.getDamageTypes(nodeWeapon);
end