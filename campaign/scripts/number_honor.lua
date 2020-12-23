function onInit()
	if super then
        super.onInit();
    end
end

function update(bReadOnly)
  setReadOnly(bReadOnly);
end

function action(draginfo)
  local rActor = ActorManager.getActor("", window.getDatabaseNode());
   HonorManagerPO.rollHonorDice(rActor, draginfo);
  return true;
end

function onDragStart(button, x, y, draginfo)
  if rollable then
    return action(draginfo);
  end
end
  
function onDoubleClick(x, y)
  if rollable then
    return action();
  end
end