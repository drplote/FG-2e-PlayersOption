function onInit()
end

function getAttackVsDefenseDifference(rRoll, rAction, nDefenseVal)
	return rAction.nTotal + rRoll.nBaseAttack - nDefenseVal;
end

function isHit(rRoll, rAction, nDefenseVal)
	return isAutoHit(rAction) or getAttackVsDefenseDifference(rRoll, rAction, nDefenseVal) >= 0;
end

function isAutoHit(rAction)
	return rAction.nFirstDie == 20;
end