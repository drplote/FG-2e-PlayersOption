function onInit()

end

function addEncounterNPC(nodeNPC)
	DebugPO.log("test", nodeNPC);
  if not nodeNPC then
    return;
  end


  -- capture XP and to set it in the current default usage 
  -- for partysheet.encounters
  local nXP = DB.getValue(nodeNPC,"xp",0);
    
  local nodePSEnc = DB.createChild("partysheet.encounters");
  -- store xp in "exp" also so we don't have to manipulate 
  -- other code to deal with "xp" also.
  DB.setValue(nodePSEnc,"exp","number",nXP);
  DB.setValue(nodePSEnc,"name","string",DB.getValue(nodeNPC,"name"));
  DB.copyNode(nodeNPC, nodePSEnc); 
end