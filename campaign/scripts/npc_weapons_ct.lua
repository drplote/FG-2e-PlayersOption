function onInit()
    super.onInit();
end

function onAttackAction(draginfo, nodeCT, rWeapon)
  local rActor = ActorManager.getActor("", nodeCT);

  -- add itemPath to rActor so that when effects are checked we can 
  -- make compare against action only effects
  rActor.itemPath = rWeapon.sRecord;
  
  local rAction = {};
    
  --local rWeaponProps = StringManager.split(DB.getValue(nodeWeapon, "properties", ""):lower(), ",", true);
  
  rAction.label = rWeapon.sName;
  rAction.stat = rWeapon.sAttackStat;
  if rWeapon.nType == 2 then
    rAction.range = "R";
    if rAction.stat == "" then
      rAction.stat = "strength";
    end
  elseif rWeapon.nType == 1 then
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
  rAction.modifier = rWeapon.nAttackBonus + ActorManager2.getAbilityBonus(rActor, rAction.stat, "hitadj");
  
  --rAction.modifier = rAction.modifier + getToHitProfs(nodeWeapon);
    
  rAction.bWeapon = true;
  
  -- Decrement ammo
  local nMaxAmmo = rWeapon.nMaxAmmo;
  if nMaxAmmo > 0 then
    local nUsedAmmo = rWeapon.nAmmo;
    if nUsedAmmo >= nMaxAmmo then
      ChatManager.Message(Interface.getString("char_message_atkwithnoammo"), true, rActor);
    else
      setWeaponRecordValue(nodeCT,rWeapon.sID,"nAmmo",nUsedAmmo +1,"number");
    end
  end
  
  -- Determine crit range
  -- local nCritThreshold = 20;
  -- if rAction.range == "R" then
    -- nCritThreshold = DB.getValue(nodeChar, "weapon.critrange.ranged", 20);
  -- else
    -- nCritThreshold = DB.getValue(nodeChar, "weapon.critrange.melee", 20);
  -- end
  -- for _,vProperty in ipairs(rWeaponProps) do
    -- local nPropCritRange = tonumber(vProperty:match("crit range (%d+)")) or 20;
    -- if nPropCritRange < nCritThreshold then
      -- nCritThreshold = nPropCritRange;
    -- end
  -- end
  -- if nCritThreshold > 1 and nCritThreshold < 20 then
    -- rAction.nCritRange = nCritThreshold;
  -- end
  
  -- NOTE: These lines are the only line different than the base 2E implementation
  
  Debug.console("NPC rAction", rAction);
  
  ActionAttack.performRoll(draginfo, rActor, rAction);
  
  return true;
end

