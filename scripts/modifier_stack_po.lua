function onInit()
end

function peekModifierKey(sModifierKey)
	return ModifierStack.modifierkeys[sModifierKey];
end

function hasSequencedInitModifierKey()
	local nNumAttacks = peekSequencedInitModifierKey();
	return nNumAttacks > 0;
end

function peekSequencedInitModifierKey()
	if ModifierStack.modifierkeys["SEQUENCED_ATTACK_2"] then
		return 2;
	elseif ModifierStack.modifierkeys["SEQUENCED_ATTACK_3"] then
		return 3;
	elseif ModifierStack.modifierkeys["SEQUENCED_ATTACK_4"] then
		return 4;
	elseif ModifierStack.modifierkeys["SEQUENCED_ATTACK_5"] then
		return 5;
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
	end

	return 0;
end