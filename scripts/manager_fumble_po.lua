function onInit()
	Comm.registerSlashHandler("fumble", onFumbleSlashCommand);
	Comm.registerSlashHandler("mishap", onMishapSlashCommand);
end

function onMishapSlashCommand(sCmd)
	local nRollValue = DiceManagerPO.getDieResult(10000);
	local sRollName = "Spell Mishap";
	
	local sResult = getMishapResult(nRollValue);
	local sText = "[" .. sRollName .. "(d10000=" .. nRollValue .. ")] " .. sResult;
	ChatManagerPO.deliverChatMessage(sText);
end

function onFumbleSlashCommand(sCmd, sParam)
	local sUpperParam = string.upper(sParam);
	local isUnarmed = sUpperParam == "UNARMED" or sUpperParam == "U" ;
	handleFumble(isUnarmed);	
end

function handleFumble(bIsUnarmed, rAction, nDefenseVal)
	if PlayerOptionManager.isUsingHackmasterFumbles() then
		handleHackmasterFumble(bIsUnarmed);
	elseif PlayerOptionManager.isUsingSternoFumbles() then
		if not rAction or not nDefenseVal then
			handleHackmasterFumble(bIsUnarmed);
		else
			local nNewRollValue = math.random(1, 20);
			DebugPO.log("Roll to confirm fumble(" .. nNewRollValue .. ") + attack bonus (" .. rAction.nTotal .. ") vs defense value (" .. nDefenseVal .. ").");
			local bHit = (rAction.nTotal + nNewRollValue) >= nDefenseVal;
			if not bHit then
				handleHackmasterFumble(bIsUnarmed);
			else
				ChatManagerPO.deliverChatMessage("Fumble averted!");
			end
		end
	end
end

-- CURRENTLY UNUSED
function handleSeverityBasedFumble(bIsUnarmed, rRoll, rAction, nDefenseVal, rSource, rTarget)
	local rFumble = getSternoFumbleResult(bIsUnarmed, rRoll, rAction, nDefenseVal, rSource, rTarget);
	if rFumble then
		local sText = "[Fumble] [Severity " .. rFumble.nSeverity .. "] " .. rFumble.sResult;
		ChatManagerPO.deliverChatMessage(sText);
	end
end

-- CURRENTLY UNUSED
function getSeverityBasedFumbleResult(bIsUnarmed, rRoll, rAction, nDefenseVal, rSource, rTarget)
	local rFumble = nil;
	if not rRoll or not rAction or not nDistance or not rSource or not rTarget then
		handleHackmasterFumble(bIsUnarmed);
	else
		rFumble = {};
		rFumble.nSeverity = getFumbleSeverity(rRoll, rAction, nDefenseVal, rSource, rTarget);
		rFumble.sResult = getFumbleEffectBySeverity(bIsUnarmed, rFumble.nSeverity);
	end

	return rFumble;
end

-- CURRENTLY UNUSED
function getFumbleEffectBySeverity(bIsUnarmed, nSeverity)
	if nSeverity <= 0 then 
		return "No effect";
	else
		local nRollValue = DiceManagerPO.getDieResult(1000);
		return getHackmasterFumbleResult(nRollValue, bIsUnarmed);
	end
end

-- CURRENTLY UNUSED
function getFumbleSeverity(rRoll, rAction, nDefenseVal, rSource, rTarget)
	local nAttackerThaco = 20 - rRoll.nBaseAttack;
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nAttackerThaco", nAttackerThaco);
	local nTargetAc = 20 - nDefenseVal;
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nTargetAc", nTargetAc);
	local nAttackBonus = rAction.nTotal - 20; 
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nAttackBonus", nAttackBonus);
	local nBaseSeverity = calculateBaseFumbleSeverity(nAttackerThaco, nTargetAc, nAttackBonus);
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nBaseSeverity", nBaseSeverity);
	local nSeverityDieRoll = DiceManagerPO.rollPenetrateInBothDirection(8);
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nSeverityDieRoll", nSeverityDieRoll);
	local nSeverityBeforeReversal = nBaseSeverity + nSeverityDieRoll + getFumbleSeverityBonus(rSource, rTarget, rAction);
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nSeverityBeforeReversal", nSeverityBeforeReversal);
	local nFinalSeverity = math.min(24, 24 - nSeverityBeforeReversal);
	DebugPO.log("manager_fumble_po.lua", "getFumbleSeverity", "nFinalSeverity", nFinalSeverity);
	return nFinalSeverity;
end


-- CURRENTLY UNUSED
function getFumbleSeverityBonus(rSource, rTarget, rAction)
	-- attacker's fumble bonus
	local nModBonus = EffectManager5E.getEffectsBonus(rSource, {"FUMBLESEVERITY"}, true, {}, rTarget);
	if rAction.nCritSeverityMod then
		nModBonus = nModBonus + rAction.nCritSeverityMod;
	end
end

-- CURRENTLY UNUSED
function calculateBaseFumbleSeverity(nAttackerThaco, nTargetAc, nAttackBonus)
	local nToHitAc15 = nAttackerThaco - 15;
	return nTargetAc - nToHitAc15 + nAttackBonus;
end

function getArmorTroubleResult()
	local nRollValue = DiceManagerPO.getDieResult(6);
	if nRollValue < 3 then return "Armor Trouble: Helm lost, victim's head exposed";
	else return "Armor Trouble: Shield dropped";
	end
end

function getWeaponTroubleResult()
	local nRollValue = DiceManagerPO.getDieResult(6);
	if nRollValue < 5 then return "Weapon Trouble: The character loses their grip on their weapon and drops it."
	else return "Weapon Trouble: Hard strike may break the weapon. Roll a succesful item saving throw vs crushing blow to avoid."
	end
end

function handleHackmasterFumble(bIsUnarmed)
	local nRollValue = DiceManagerPO.getDieResult(1000);
	local sRollName = "Fumble";
	if isUnarmed then
		sRollName = "Unarmed" .. sRollName;
	end

	local sResult = getHackmasterFumbleResult(nRollValue, bIsUnarmed);
	local sText = "[" .. sRollName .. "(d1000=" .. nRollValue .. ")] " .. sResult;
	ChatManagerPO.deliverChatMessage(sText);
end

function getHackmasterFumbleResult(nRollValue, isUnarmed)
	if isUnarmed then
		return getUnarmedHackmasterFumbleResult(nRollValue);
	else
		return getNormalHackmasterFumbleResult(nRollValue);
	end;
end

function getRandomCantrip(nRollValue)
	return "Not Yet Implemented"; -- TODO
end

function getMishapResult(nRollValue)
	local sResult = "";
	if nRollValue < 276 then sResult = "Spell dissolves in a harmless puff of smoke" 
	elseif nRollValue < 296 then sResult = "Ears turn " .. getColorChange() .. " for " .. getMishapDuration();
	elseif nRollValue < 308 then sResult = "Ears turn " .. getColorChange() .. " permanently";
	elseif nRollValue < 328 then sResult = "Nose turns " .. getColorChange() .. " for " .. getMishapDuration(); 
	elseif nRollValue < 340 then sResult = "Nose turns " .. getColorChange() .. " permanently";
	elseif nRollValue < 360 then sResult = "Neck turns " .. getColorChange() .. " for " .. getMishapDuration(); 
	elseif nRollValue < 372 then sResult = "Neck turns " .. getColorChange() .. " permanently";
	elseif nRollValue < 392 then sResult = "Hands turn " .. getColorChange() .. " for " .. getMishapDuration(); 
	elseif nRollValue < 404 then sResult = "Hands turn " .. getColorChange() .. " permanently";
	elseif nRollValue < 454 then sResult = "Eyes turn " .. getColorChange() .. " for " .. getMishapDuration(); 
	elseif nRollValue < 504 then sResult = "Hair turns " .. getColorChange() .. " for " .. getMishapDuration(); 
	elseif nRollValue < 554 then sResult = "Skin turns " .. getColorChange() .. " for " .. getMishapDuration(); 
	elseif nRollValue < 579 then sResult = "Biting fingernails";
	elseif nRollValue < 594 then sResult = "Hair grows {1d4} feet in one round";
	elseif nRollValue < 612 then sResult = "Chews own hair";
	elseif nRollValue < 637 then sResult = "Burst of soot in face";
	elseif nRollValue < 687 then sResult = "Affected by cantrip: " .. getRandomCantrip(); -- TODO: Random cantrip table
	elseif nRollValue < 712 then sResult = "Becomes chronic nagger";
	elseif nRollValue < 772 then sResult = "Skin complaint (unpleasant rash) for " .. getMishapDuration();
	elseif nRollValue < 802 then sResult = "Skin complaint (unpleasant rash) permanently";
	elseif nRollValue < 852 then sResult = "Suffer 1 point of damage";
	elseif nRollValue < 932 then sResult = "1 random memorized spell goes off";
	elseif nRollValue < 997 then sResult = "Choke for {1d4} rounds";
	elseif nRollValue < 1029 then sResult = "Rash (-1 dex) for " .. getMishapDuration();
	elseif nRollValue < 1069 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(1, 4, -2) .. " points of damage";
	elseif nRollValue < 1084 then sResult = "Lose sense of touch in fingers for " .. getMishapDuration();
	elseif nRollValue < 1096 then sResult = CharBackgroundManagerPO.getBodySide() .. " arm goes numb for " .. getMishapDuration();
	elseif nRollValue < 1122 then sResult = CharBackgroundManagerPO.getBodySide() .. " leg goes numb for " .. getMishapDuration
	elseif nRollValue < 1146 then sResult = "Constantly gasping for air (slows speech by half, doubles casting times)";
	elseif nRollValue < 1196 then sResult = "Personal cloudburst";
	elseif nRollValue < 1236 then sResult = "2 random memorized spells go off simultaneously";
	elseif nRollValue < 1271 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(1, 4) .. " points of damage";
	elseif nRollValue < 1296 then sResult = "Loss of one spell slot for " .. getMishapDuration();
	elseif nRollValue < 1326 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(1, 6, 1) .. " points of damage";
	elseif nRollValue < 1376 then sResult = "Spell dissolves in minor explosion: " .. DiceManagerPO.getDamageRoll(1, 6, -2) .. " points of damage in a 5-foot radius";
	elseif nRollValue < 1409 then sResult = "Loss of two spell slots for " .. getMishapDuration();
	elseif nRollValue < 1469 then sResult = "Cannot memorize that spell again for " .. getMishapDuration();
	elseif nRollValue < 1494 then sResult = "Eyes turn " .. getColorChange() .. " permanently";
	elseif nRollValue < 1519 then sResult = "Hair turns " .. getColorChange() .. " permanently";
	elseif nRollValue < 1544 then sResult = "Skin turns " .. getColorChange() .. " permanently";
	elseif nRollValue < 1555 then sResult = "Polymorphed to amphibian for " .. getMishapDuration();
	elseif nRollValue < 1590 then sResult = "Skin covered in large blotches (-3 Comeliness) for " .. getMishapDuration();
	elseif nRollValue < 1601 then sResult = "Skin covered in large blotches (-3 Comeliness) permanently";
	elseif nRollValue < 1681 then sResult = "Now talks to self";
	elseif nRollValue < 1711 then sResult = "Fingernails turn " .. getColorChange() .. " for " .. getMishapDuration();
	elseif nRollValue < 1725 then sResult = "Fingernails turn " .. getColorChange() .. " permanently";
	elseif nRollValue < 1800 then sResult = "Tingling in fingers (+25% chance of spell mishap for somatic components) for " .. getMishapDuration();
	elseif nRollValue < 1840 then sResult = "Ringing in ears for " .. getMishapDuration();
	elseif nRollValue < 1860 then sResult = "Narcissism";
	elseif nRollValue < 1900 then sResult = "Contracts the flu";
	elseif nRollValue < 1920 then sResult = "Becomes convicned he is a clone of his original self";
	elseif nRollValue < 1933 then sResult = "Tinnitus - permanent ringing in ears";
	elseif nRollValue < 1973 then sResult = "Vision blurred (reduced 50%) for " .. getMishapDuration();
	elseif nRollValue < 2013 then sResult = "Amnesia back 1 day";
	elseif nRollValue < 2033 then sResult = "Amnesia back 2 days";
	elseif nRollValue < 2073 then sResult = "Enlarge random object (as spell)";
	elseif nRollValue < 2093 then sResult = "Reduce random object (as spell)";
	elseif nRollValue < 2133 then sResult = "Enlarge self";
	elseif nRollValue < 2153 then sResult = "Reduce self";
	elseif nRollValue < 2878 then sResult = "Gain minor mental quirk: " .. CharBackgroundManagerPO.getMinorMentalQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 3178 then sResult = "Gain minor mental quirk: " .. CharBackgroundManagerPO.getMinorMentalQuirk() .. " permanently";
	elseif nRollValue < 3278 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMinorMentalQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 3323 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMinorMentalQuirk() .. " permanently";
	elseif nRollValue < 4048 then sResult = "Gain " .. CharBackgroundManagerPO.getMinorPersonalityQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 4348 then sResult = "Gain " .. CharBackgroundManagerPO.getMinorPersonalityQuirk() .. " permanently";
	elseif nRollValue < 4448 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMinorPersonalityQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 4493 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMinorPersonalityQuirk() .. " permanently";
	elseif nRollValue < 4793 then sResult = "Gain " .. CharBackgroundManagerPO.getMajorMentalQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 4943 then sResult = "Gain " .. CharBackgroundManagerPO.getMajorMentalQuirk() .. " permanently";
	elseif nRollValue < 4983 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMajorMentalQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 5003 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMajorMentalQuirk() .. " permanently";
	elseif nRollValue < 5303 then sResult = "Gain " .. CharBackgroundManagerPO.getMajorPersonalityQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 5453 then sResult = "Gain " .. CharBackgroundManagerPO.getMajorPersonalityQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 5523 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMajorPersonalityQuirk() .. " for " .. getMishapDuration();
	elseif nRollValue < 5553 then sResult = "Sibling (or parent) gains " .. CharBackgroundManagerPO.getMajorPersonalityQuirk() .. " permanently";
	elseif nRollValue < 5583 then sResult = "Wandering eye for " .. getMishapDuration();
	elseif nRollValue < 5603 then sResult = "Gain 1 alignment infration point";
	elseif nRollValue < 5653 then sResult = "Blinks (as per spell)";
	elseif nRollValue < 5678 then sResult = "Unquenchable thirst for " .. getMishapDuration();
	elseif nRollValue < 5703 then sResult = "Entire body glows as per Light spell";
	elseif nRollValue < 5712 then sResult = "Continual Light spell on tongue";
	elseif nRollValue < 5722 then sResult = "Gain 2 alignment infraction points";
	elseif nRollValue < 5758 then sResult = "Emit unpleasant odor (-1 to reaction rolls) for " .. getMishapDuration();
	elseif nRollValue < 5780 then sResult = "Emit vile odor (-3 to reaction rolls) for " .. getMishapDuration();
	elseif nRollValue < 5802 then sResult = "Sibling (or parent) emits unpleasant odor (-1 to reaction rolls) for " .. getMishapDuration();
	elseif nRollValue < 5820 then sResult = "Sibling (or parent) emits vile odor (-3 to reaction rolls) for " .. getMishapDuration();
	elseif nRollValue < 5833 then sResult = "Must memorize all spells as if they were one level higher than actual";
	elseif nRollValue < 5835 then sResult = "Temporary compulsion to become a mime";
	elseif nRollValue < 5855 then sResult = "Teleport 5 feet in random direction";
	elseif nRollValue < 5870 then sResult = "Teleport 10 feet in random direction";
	elseif nRollValue < 5880 then sResult = "Teleport 50 feet in random direction";
	elseif nRollValue < 5895 then sResult = "Wandering eye - permanent";
	elseif nRollValue < 5945 then sResult = "Cannot memorize that spell again - permanently";
	elseif nRollValue < 5995 then sResult = "Becomes center of a Stinking Cloud spell";
	elseif nRollValue < 6195 then sResult = "Gains " .. CharBackgroundManagerPO.getMinorPhysicalFlaw6b() .. " for " .. getMishapDuration();
	elseif nRollValue < 6285 then sResult = "Gains " .. CharBackgroundManagerPO.getMinorPhysicalFlaw6b() .. " permanently";
	elseif nRollValue < 6485 then sResult = "Gains " .. CharBackgroundManagerPO.getMinorPhysicalFlaw6c() .. " for " .. getMishapDuration();
	elseif nRollValue < 6575 then sResult = "Gains " .. CharBackgroundManagerPO.getMinorPhysicalFlaw6c() .. " permanently";
	elseif nRollValue < 6775 then sResult = "Gains " .. CharBackgroundManagerPO.getMinorPhysicalFlaw6d() .. " for " .. getMishapDuration();
	elseif nRollValue < 6900 then sResult = "Gains " .. CharBackgroundManagerPO.getMinorPhysicalFlaw6d() .. " permanently";
	elseif nRollValue < 6920 then sResult = "Teleport 5 feet straight up";
	elseif nRollValue < 6929 then sResult = "Teleport 10 feet straight up";
	elseif nRollValue < 6937 then sResult = "Teleport 50 feet straight up";
	elseif nRollValue < 6959 then sResult = "Needs 1 extra hour of sleep for " .. getMishapDuration();
	elseif nRollValue < 6969 then sResult = "Loses all tattoos for " .. getMishapDuration();
	elseif nRollValue < 6979 then sResult = "Permanently loses all tattoos";
	elseif nRollValue < 6984 then sResult = "Shaking (-1 to-hit, -1 to damage, +3 segments to casting times for spells with somatic components) for " .. getMishapDuration();
	elseif nRollValue < 6999 then sResult = "Needs 2 extra hours of sleep for " .. getMishapDuration();
	elseif nRollValue < 7017 then sResult = "Conversations with self (thinks others respond) for " .. getMishapDuration();
	elseif nRollValue < 7032 then sResult = "Is convinced he has a long lost sibling";
	elseif nRollValue < 7038 then sResult = "Polymorphed into primate for " .. getMishapDuration();
	elseif nRollValue < 7063 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(2, 6) .. " points of damage";
	elseif nRollValue < 7074 then sResult = "Suffer permanent loss of 1 hit point";
	elseif nRollValue < 7078 then sResult = "Constant thirst (must drink 3 times normal volume per day) permanently";
	elseif nRollValue < 7089 then sResult = "Permanently emits unpleasant odor (-1 to reaction rolls)";
	elseif nRollValue < 7096 then sResult = "Permanently emits vile odor (-3 to reaction rolls)";
	elseif nRollValue < 7186 then sResult = "Gains " .. CharBackgroundManagerPO.getMajorPhysicalFlaw() .. " for " .. getMishapDuration();
	elseif nRollValue < 7276 then sResult = "Gains " .. CharBackgroundManagerPO.getMajorPhysicalFlaw() .. " permanently";
	elseif nRollValue < 7296 then sResult = "Immediate alignment audit";
	elseif nRollValue < 7306 then sResult = "Summon hostile monsters (MS1)"; -- TODO, MS1
	elseif nRollValue < 7315 then sResult = "Summon hostile monsters (MS2)"; -- TODO, ms2
	elseif nRollValue < 7357 then sResult = "Struck by Lightning Bolt from above";
	elseif nRollValue < 7369 then sResult = "Switch gender for " .. getMishapDuration();
	elseif nRollValue < 7384 then sResult = "Change race to " .. CharBackgroundManagerPO.getRandomRace() .. " for " .. getMishapDuration();
	elseif nRollValue < 7386 then sResult = "Shaking (-1 to-hit, -1 to damage, +3 segments to casting times for spells with somatic components) - permanent";
	elseif nRollValue < 7398 then sResult = "Uncontrollable falling down at random (1d100 minute) intervals for " .. getMishapDuration();
	elseif nRollValue < 7403 then sResult = "Uncontrollable falling down at random (1d100 minute) intervals - permanent";
	elseif nRollValue < 7428 then sResult = "Enters HackFrenzy immediately ({2d20} 'effective' points of damage)";
	elseif nRollValue < 7448 then sResult = "Enter HackLust immediately ({2d20} 'effective' points of damage)";
	elseif nRollValue < 7548 then sResult = "Becomes misanthrope for " .. getMishapDuration();
	elseif nRollValue < 7556 then sResult = "Lose one talent temporarily";
	elseif nRollValue < 7560 then sResult = "Lose two talents temporarily";
	elseif nRollValue < 7580 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(3, 6) .. " points of damage";
	elseif nRollValue < 7588 then sResult = "Summon hostile monsters (MS3)"; -- TODO: ms3
	elseif nRollValue < 7608 then sResult = "Lower temperature 10 degrees in a 5-foot radius";
	elseif nRollValue < 7618 then sResult = "Lower temperature 25 degrees in a 5-foot radius";
	elseif nRollValue < 7623 then sResult = "Lower temperature 50 degrees in a 5-foot radius";
	elseif nRollValue < 7643 then sResult = "Raise temperature 10 degrees in a 5-foot radius";
	elseif nRollValue < 7653 then sResult = "Raise temperature 25 degrees in a 5-foot radius";
	elseif nRollValue < 7658 then sResult = "Raise temperature 50 degrees in a 5-foot radius";
	elseif nRollValue < 7665 then sResult = "Summon hostile monsters (MS4)"; -- TODO ms4
	elseif nRollValue < 7685 then sResult = "Lose one class-specific ability for " .. getMishapDuration();
	elseif nRollValue < 7690 then sResult = "Lose two class-specific abilities for " .. getMishapDuration();
	elseif nRollValue < 7696 then sResult = "Sibling (or parents) contracts the flu";
	elseif nRollValue < 7699 then sResult = "Sibling (or parents) contracts leprosy`";
	elseif nRollValue < 7715 then sResult = "Introversion";
	elseif nRollValue < 7730 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(3, 10) .. " points of damage";
	elseif nRollValue < 7740 then sResult = "Suffer " .. DiceManagerPO.getDamageRoll(2, 20) .. " points of damage";
	elseif nRollValue < 7765 then sResult = "Slowed (as spell)";
	elseif nRollValue < 7775 then sResult = "Hasted (as spell)";
	elseif nRollValue < 7805 then sResult = "-1 to-hit for " .. getMishapDuration();
	elseif nRollValue < 7833 then sResult = "-1 to damage rolls for " .. getMishapDuration();
	elseif nRollValue < 7843 then sResult = "Hatred of one gender (" .. CharBackgroundManagerPO.getGender() .. ")";
	elseif nRollValue < 7857 then sResult = "-2 to-hit for " .. getMishapDuration();
	elseif nRollValue < 7881 then sResult = "-1 to all rolls for " .. getMishapDuration();
	elseif nRollValue < 7887 then sResult = "Summon hostile monsters (MS5)"; -- TODO: MS5
	elseif nRollValue < 7896 then sResult = "Suffer permanent loss of 2 hp";
	elseif nRollValue < 7901 then sResult = "Switdh gender permanently";
	elseif nRollValue < 7903 then sResult = "Sibling (or parent) contracts malaria";
	elseif nRollValue < 7909 then sResult = "Permanent compulsion to become a mime";
	elseif nRollValue < 7917 then sResult = "-2 to damage rolls for " .. getMishapDuration();
	elseif nRollValue < 7957 then sResult = "-1 points of Honor";
	elseif nRollValue < 7989 then sResult = "-2 points of Honor";
	elseif nRollValue < 8064 then sResult = "Ages 1 day";
	elseif nRollValue < 8076 then sResult = "-2 to all rolls for " .. getMishapDuration();
	elseif nRollValue < 8092 then sResult = "-{1d4} points of Honor";
	elseif nRollValue < 8100 then sResult = "-{1d6} points of Honor";
	elseif nRollValue < 8130 then sResult = "Becomes center of Fireball";
	elseif nRollValue < 8200 then sResult = "Ages {2d6} days";
	elseif nRollValue < 8265 then sResult = "Ages {1d4} weeks";
	elseif nRollValue < 8325 then sResult = "Ages {1d3} months";
	elseif nRollValue < 8380 then sResult = "Ages {1d6} months";
	elseif nRollValue < 8428 then sResult = "Ages {2d6} months";
	elseif nRollValue < 8464 then sResult = "Ages 1 year";
	elseif nRollValue < 8488 then sResult = "Ages {1d4} years";
	elseif nRollValue < 8500 then sResult = "Ages {2d4} years";
	elseif nRollValue < 8506 then sResult = "Ages {2d6} years";
	elseif nRollValue < 8531 then sResult = "Tingling in fingers (+25% chance of spell mishap for somatic components) - permanently";
	elseif nRollValue < 8547 then sResult = "Permanent Rash (-2 dex)";
	elseif nRollValue < 8556 then sResult = "Lose ability to cast spells for " .. getMishapDuration();
	elseif nRollValue < 8570 then sResult = "Permanent -1 to damage rolls";
	elseif nRollValue < 8585 then sResult = "Permanent -1 to-hit";
	elseif nRollValue < 8589 then sResult = "Permanent -2 to dmaage rolls";
	elseif nRollValue < 8592 then sResult = "Drug Addiction (GM chooses substance)";
	elseif nRollValue < 8640 then sResult = "Lose 50 fractional points from " .. CharBackgroundManagerPO.getAbilityScore() .. " for " .. getMishapDuration();
	elseif nRollValue < 8664 then sResult = "Lose 1 point from " .. CharBackgroundManagerPO.getAbilityScore() .. " for " .. getMishapDuration();
	elseif nRollValue < 8676 then sResult = "Lose 2 points from " .. CharBackgroundManagerPO.getAbilityScore() .. " for " .. getMishapDuration();
	elseif nRollValue < 8696 then sResult = "Lose 50 fraction points from each ability score for " .. getMishapDuration();
	elseif nRollValue < 8716 then sResult = "Lose a point from each ability score for " .. getMishapDuration();
	elseif nRollValue < 8736 then sResult = "Lose 2 pointsfrom each ability score for " .. getMishapDuration();
	elseif nRollValue < 8743 then sResult = "Permanent -2 to-hit";
	elseif nRollValue < 8793 then sResult = "All memorized spells go off simultaneously";
	elseif nRollValue < 8798 then sResult = "Summon hostile monsters (MS6)"; -- MS6, TODO
	elseif nRollValue < 8802 then sResult = "Summon hostile monsters (MS7)"; -- MS7, todo
	elseif nRollValue < 8809 then sResult = "Lose sense of touch in fingers permanently (x3 casting time, -4 to hit)";
	elseif nRollValue < 8814 then sResult = CharBackgroundManagerPO.getBodySide() .. " arm goes permanently numb, becoming useless";
	elseif nRollValue < 8821 then sResult = CharBackgroundManagerPO.getBodySide() .. " leg goes permanently numb, becoming useless";
	elseif nRollValue < 8835 then sResult = "Permanent loss of one random spell";
	elseif nRollValue < 8847 then sResult = "Permanent -1 to all rolls";
	elseif nRollValue < 8857 then sResult = "Permanent loss of one spell slot";
	elseif nRollValue < 8887 then sResult = "Aphasia (speaks random meaningless phrases instead of desired words)";
	elseif nRollValue < 8896 then sResult = "Contracts leprosy";
	elseif nRollValue < 8901 then sResult = "Contracts malaria";
	elseif nRollValue < 8907 then sResult = "Permanent -2 to all rolls";
	elseif nRollValue < 8920 then sResult = "Permanent loss of two spell slots";
	elseif nRollValue < 8930 then sResult = "Alignment change - 1 step towards " .. CharBackgroundManagerPO.getLawChaos();
	elseif nRollValue < 8940 then sResult = "Alignment change - 1 step towards " .. CharBackgroundManagerPO.getGoodEvil();
	elseif nRollValue < 9040 then sResult = "Becomes misanthrope permanently";
	elseif nRollValue < 9051 then sResult = "Sibling (or parent) permanently emits unpleasant odor (-1 to reaction rolls)";
	elseif nRollValue < 9060 then sResult = "Sibling (or parent) permanently emits vile odor (-3 to reaction rolls)";
	elseif nRollValue < 9075 then sResult = "Permanently needs 1 hour of extra sleep";
	elseif nRollValue < 9082 then sResult = "Permanently needs 2 hours of extra sleep";
	elseif nRollValue < 9092 then sResult = "Conversations with self (thinks others respond) - permanent";
	elseif nRollValue < 9102 then sResult = "Vision blurred (reduced 50%) permanently";
	elseif nRollValue < 9106 then sResult = "Lose one talent permanently";
	elseif nRollValue < 9108 then sResult = "Lose two talents permanently";
	elseif nRollValue < 9115 then sResult = "Suffer permanent loss of " .. DiceManagerPO.getDiceResult(1, 6, false, 1) .. " hit points";
	elseif nRollValue < 9117 then sResult = "Gain enmity of nefarion";
	elseif nRollValue < 9124 then sResult = "Is Harmed (as spell)";
	elseif nRollValue < 9129 then sResult = "Polymorphed to Amphibian - permanently";
	elseif nRollValue < 9216 then sResult = "Gain Insanity: " .. getInsanity();
	elseif nRollValue < 9236 then sResult = "Now hates one sibling (or parent)";
	elseif nRollValue < 9246 then sResult = "Now hated by one sibling (or parent)";
	elseif nRollValue < 9253 then sResult = "Change race to " .. CharBackgroundManagerPO.getRandomRace() .. " permanently";
	elseif nRollValue < 9257 then sResult = "Becomes {10d4} years younger";
	elseif nRollValue < 9261 then sResult = "Lose {1d8} points of Honor";
	elseif nRollValue < 9263 then sResult = "Lose {2d4} points of Honor";
	elseif nRollValue < 9273 then sResult = "Enervated - lose 1 experience level for " .. getMishapDuration();
	elseif nRollValue < 9278 then sResult = "Enervated - lose 2 experience levels for " .. getMishapDuration();
	elseif nRollValue < 9303 then sResult = "Amnesia back 1 week";
	elseif nRollValue < 9323 then sResult = "Amnesia back 1 month";
	elseif nRollValue < 9359 then sResult = "Permanent loss of {1d20}% to one skill (determine randomly)";
	elseif nRollValue < 9377 then sResult = "Permanent loss of {1d100}% to one skill (determine randomly)";
	elseif nRollValue < 9386 then sResult = "Suffer permanent loss of {1d4} hit points";
	elseif nRollValue < 9406 then sResult = "Dyslexia (x3 time to read anything, including spellbooks) for " .. getMishapDuration();
	elseif nRollValue < 9446 then sResult = "Loss of {1d20}% to one skill (determine randomly) for " .. getMishapDuration();
	elseif nRollValue < 9471 then sResult = "Loss of {1d100}% to one skill (determine randomly) for " .. getMishapDuration();
	elseif nRollValue < 9485 then sResult = "Lethargy (-2 to-hit, -2 to damage, double all initiative times, movement is halved) for " .. getMishapDuration();
	elseif nRollValue < 9505 then sResult = "Amnesia back 6 months";
	elseif nRollValue < 9515 then sResult = "Amnesia back 1 year";
	elseif nRollValue < 9520 then sResult = "Amnesia back 2 years";
	elseif nRollValue < 9522 then sResult = "Amnesia back 5 years";
	elseif nRollValue < 9523 then sResult = "Amnesia back 10 years";
	elseif nRollValue < 9548 then sResult = "Decides he must switch classes";
	elseif nRollValue < 9578 then sResult = "Unable to sleep for " .. getMishapDuration();
	elseif nRollValue < 9618 then sResult = "Uncontrollable weight gain - 1 pound per week for " .. getMishapDuration();
	elseif nRollValue < 9642 then sResult = "Bulimia for " .. getMishapDuration();
	elseif nRollValue < 9657 then sResult = "Permanently unable to sleep";
	elseif nRollValue < 9664 then sResult = "Permanent lethary (-2 to-hit, -2 to damage, double all initiative times, movement is halved)";
	elseif nRollValue < 9689 then sResult = "Permanent -50 fractional points to " .. CharBackgroundManagerPO.getAbilityScore();
	elseif nRollValue < 9709 then sResult = "Permanent -1 to " .. CharBackgroundManagerPO.getAbilityScore();
	elseif nRollValue < 9714 then sResult = "Permanent -2 to " .. CharBackgroundManagerPO.getAbilityScore();
	elseif nRollValue < 9724 then sResult = "Spontaneous combustion! Bursts into flame and suffers " .. DiceManagerPO.getDamageRoll(6, 8) .. " points of damage";
	elseif nRollValue < 9744 then sResult = "Sibling (or parent) suffers uncontrollable weight gain of 1 pound per week for " .. getMishapDuration();
	elseif nRollValue < 9764 then sResult = "Gains appearance of undead (-15 Comeliness, -5 Charisma) for " getMishapDuration();
	elseif nRollValue < 9774 then sResult = "Sibling (or parent) suffers uncontrollable weight gain of 1 pound per week permanently";
	elseif nRollValue < 9794 then sResult = "Permanent uncontrollable weight gain (1 pound per week)";
	elseif nRollValue < 9797 then sResult = "Permanent -50 fraction points to each ability score";
	elseif nRollValue < 9799 then sResult = "Permament -1 to each ability score";
	elseif nRollValue < 9800 then sResult = "Permanent -2 to each ability score";
	elseif nRollValue < 9806 then sResult = "Suffer permanent loss of {2d6} hit points";
	elseif nRollValue < 9815 then sResult = "Anorexia (lose 1-2 pounds per week) - permanent until cured or death";
	elseif nRollValue < 9818 then sResult = "Polymorphed into Primate permanently";
	elseif nRollValue < 9828 then sResult = "Permanent bulimia";
	elseif nRollValue < 9833 then sResult = "Suffer permanent loss of {3d6} hit points";
	elseif nRollValue < 9843 then sResult = "Permanent dyslexia (x3 time to read anything, including spell books)";
	elseif nRollValue < 9849 then sResult = "Enters coma for " .. getMishapDuration();
	elseif nRollValue < 9859 then sResult = "Lose one class-specific ability permanently";
	elseif nRollValue < 9862 then sResult = "Lose two class-specific abilities permanently";
	elseif nRollValue < 9872 then sResult = "Lose ability to cast spells permanently";
	elseif nRollValue < 9874 then sResult = "All magic items on person are Disjoined (as per Hyptor's Disjunction";
	elseif nRollValue < 9877 then sResult = "Enters permanent coma";
	elseif nRollValue < 9887 then sResult = "Gains appears of undead (-15 Comeliness, -5 Charisma) permanently";
	elseif nRollValue < 9894 then sResult = "Energy Drain: Lose 1 experience level";
	elseif nRollValue < 9899 then sResult = "Energy Drain: Lose 2 experience levels";
	elseif nRollValue < 9900 then sResult = "Spontaneous combustion! Bursts into flame and immediately dies.";
	elseif nRollValue < 9901 then sResult = "Chokes to death in 1 round";
	else sResult = getMishapResult() .. " and " .. getMishapResult();
	end
	return replaceRolls(sResult);
end

function getMishapDuration(nRollValue)
	if not nRollValue then nRollValue = DiceManagerPO.getDieResult(100); end
	
	if nRollValue < 17 then return DiceManagerPO.getDieResult(24) .. " hours";
	elseif nRollValue < 31 then	return DiceManagerPO.getDieResult(6) .. " days";
	elseif nRollValue < 46 then	return DiceManagerPO.getDieResult(4) .. " weeks";
	elseif nRollValue < 61 then	return DiceManagerPO.getDieResult(12) .. " months";
	elseif nRollValue < 71 then	return DiceManagerPO.getDieResult(12) + 12 .. " months";
	elseif nRollValue < 81 then	return DiceManagerPO.getDieResult(3) + 1 .. " years";
	elseif nRollValue < 91 then	return DiceManagerPO.getDieResult(4) + 3 .. " years";
	elseif nRollValue < 96 then	return DiceManagerPO.getDieResult(14) + 6 .. " years";
	else
		local sDuration = getMishapDuration(DiceManagerPO.getDieResult(95));
		local sRecurrenceRate = getMishapDuration(DiceManagerPO.getDieResult(95));
		return "Chronic. Lasts " .. sDuration .. " and recurs every " .. sRecurrenceRate;
	end	
end

function getPhobia(nRollValue)
	if not nRollValue then nRollValue = DiceManagerPO.getDieResult(100); end
	if nRollValue == 1 then return "fear of the color(s) " .. getColorChange(DiceManagerPO.getDieResult(88));
	elseif nRollValue == 2 then	return "Ablutophobia (washing, bathing)";
	elseif nRollValue == 3 then	return "Acousticaphobia (sounds)";
	elseif nRollValue == 4 then	return "Acrophobia (heights)";
	elseif nRollValue == 5 then	return "Aerophobia (drafts, air swallowing, or airborne noxious substances)";
	elseif nRollValue == 6 then	return "Agateophobia (insanity)";
	elseif nRollValue == 7 then	return "Agiliophobia (pain)";
	elseif nRollValue == 8 then	return "Agoraphobia (open spaces)";
	elseif nRollValue == 9 then	return "Alliumphobia (garlic)";
	elseif nRollValue == 10 then return "Animals (see quirk)";
	elseif nRollValue == 11 then return "Antrophobia (flowers)";
	elseif nRollValue == 12 then return "Anthraxaphobia (Anthraxians)";
	elseif nRollValue == 13 then return "Arachnophobia (spiders)";
	elseif nRollValue == 14 then return "Arcanophobia (magic)";
	elseif nRollValue == 15 then return "Arithmophobia (numbers)";
	elseif nRollValue == 16 then return "Aurophobia (gold)";
	elseif nRollValue == 17 then return "Autodysomophobia (emitting a vile odor)";
	elseif nRollValue == 18 then return "Bibliophobia (books, the written word)";
	elseif nRollValue == 19 then return "Caligynephobia or Venustraphobia (beautiful women)";
	elseif nRollValue == 20 then return "Chaetophobia (hair)";
	elseif nRollValue == 21 then return "Chionophobia (snow)";
	elseif nRollValue == 22 then return "Chlorophobia (plants)";
	elseif nRollValue == 23 then return "Chorophobia (dancing)";
	elseif nRollValue == 24 then return "Chrometophobia (money)";
	elseif nRollValue == 25 then return "Claustrophobia (closed spaces)";
	elseif nRollValue == 26 then return "Coulrophobia (clowns)";
	elseif nRollValue == 27 then return "Crystallophobia (crystal, glass)";
	elseif nRollValue == 28 then return "Deipnophobia (dining or dinner conversations)";
	elseif nRollValue == 29 then return "Dendrophobia (trees)";
	elseif nRollValue == 30 then return "Donutiphobia (baked goods)";
	elseif nRollValue == 31 then return "Doraphobia (fur or skins of animals)";
	elseif nRollValue == 32 then return "Dracovideriphobia (pseudo-dragons)";
	elseif nRollValue == 33 then return "Eisoptrophobia (mirrors or of seeing oneself in a mirror)";
	elseif nRollValue == 34 then return "Enissophobia (criticism)";
	elseif nRollValue == 35 then return "Epistaxiophobia (nosebleeds)";
	elseif nRollValue == 36 then return "Ferrophobia (iron, steel)";
	elseif nRollValue == 37 then return "Gamophobia (marriage)";
	elseif nRollValue == 38 then return "Geliophobia (laughter)";
	elseif nRollValue == 39 then return "Gerontophobia (old people or of growing old)";
	elseif nRollValue == 40 then return "Heresyphobia or Hereiophobia (challenges to official doctrine or of radical deviation)";
	elseif nRollValue == 41 then return "Heterophobia (the opposite sex)";
	elseif nRollValue == 42 then return "Hobophobia (bums, beggars)";
	elseif nRollValue == 43 then return "Homilophobia (sermons)";
	elseif nRollValue == 44 then return "Hydrophobia (water)";
	elseif nRollValue == 45 then return "Ichthyophobia (fish)";
	elseif nRollValue == 46 then return "Incantiphobia (casting spells, spell casters)";
	elseif nRollValue == 47 then return "Kathisophobia (sitting down)";
	elseif nRollValue == 48 then return "Kleptophobia (stealing, theft)";
	elseif nRollValue == 49 then return "Koboldophobia (kobolds)";
	elseif nRollValue == 50 then return "Limnophobia (lakes)";
	elseif nRollValue == 51 then return "Llamophobia (llamas)";
	elseif nRollValue == 52 then return "Lygophobia (darkness)";
	elseif nRollValue == 53 then return "Maniaphobia (insanity)";
	elseif nRollValue == 54 then return "Melophobia (fear or hatred of music)";
	elseif nRollValue == 55 then return "Metallophobia (metal)";
	elseif nRollValue == 56 then return "Methyphobia or Potophobia (alcohol)";
	elseif nRollValue == 57 then return "Necrophobia (dead things)";
	elseif nRollValue == 58 then return "Nephophobia (clouds)";
	elseif nRollValue == 59 then return "Nomatophobia (names)";
	elseif nRollValue == 60 then return "Ochlophobia (crowds, mobs)";
	elseif nRollValue == 61 then return "Ochophobia (wheels)";
	elseif nRollValue == 62 then return "Odinophobia (the wrath of Odin)";
	elseif nRollValue == 63 then return "Odontophobia (teeth)";
	elseif nRollValue == 64 then return "Oenophobia (wines)";
	elseif nRollValue == 65 then return "Class (" .. CharBackgroundManagerPO.getRandomClass() .. ")";
	elseif nRollValue == 66 then return "Race (" .. CharBackgroundManagerPO.getRandomRace() .. ")"; 
	elseif nRollValue == 67 then return "Pagophobia (ice, frost)";
	elseif nRollValue == 68 then return "Papyrophobia (paper, papyrus, etc)";
	elseif nRollValue == 69 then return "Pediophobia (dolls)";
	elseif nRollValue == 60 then return "Pedophobia (children)";
	elseif nRollValue == 71 then return "Peladophobia (bald people)";
	elseif nRollValue == 72 then return "Peniaphobia (poverty)";
	elseif nRollValue == 73 then return "Pharmacophobia (drugs)";
	elseif nRollValue == 74 then return "Phengophobia (sunshine)";
	elseif nRollValue == 75 then return "Phobophobias (phobias)";
	elseif nRollValue == 76 then return "Photophobia (light)";
	elseif nRollValue == 77 then return "Plutophobia (wealth)";
	elseif nRollValue == 78 then return "Pluviophobia (rain, being rained on)";
	elseif nRollValue == 79 then return "Pocrescophobia (gaining weight)";
	elseif nRollValue == 80 then return "Podophobia (feet)";
	elseif nRollValue == 81 then return "Pogonophobia (beards)";
	elseif nRollValue == 82 then return "Potamophobia (rivers or running water)";
	elseif nRollValue == 83 then return "Pyrophobia (fire)";
	elseif nRollValue == 84 then return "Rhabdophobia (magic items)";
	elseif nRollValue == 85 then return "Rupophobia (dirt)";
	elseif nRollValue == 86 then return "Selenophobia (the moon)";
	elseif nRollValue == 87 then return "Sesquipedalophobia (long words)";
	elseif nRollValue == 88 then return "Sitophobia or Sitiophobia (food, eating)";
	elseif nRollValue == 89 then return "Sominphobia (sleep)";
	elseif nRollValue == 90 then return "Statuphobia (stress)";
	elseif nRollValue == 91 then return "Staurophobia (religious symbols)";
	elseif nRollValue == 92 then return "Teluphobia (weapons)";
	elseif nRollValue == 93 then return "Thanatophobia (death or dying)";
	elseif nRollValue == 94 then return "Tonitrophobia (thunder)";
	elseif nRollValue == 95 then return "Trichophobia (hair)";
	elseif nRollValue == 96 then return "Triskaidekaphobia (the number 13)";
	elseif nRollValue == 97 then return "Vestiphobia (clothing)";
	elseif nRollValue == 98 then return "Xenophobia (foreigners, outsiders)";
	elseif nRollValue == 99 then return "Xylophobia (wood, forests)";
	else return "Zoophobia (animals (all kinds))";
	end
	
end

function getInsanity(nRollValue)
	if not nRollValue then nRollValue = DiceManagerPO.getDieResult(100); end
	
	if nRollValue < 5 then return "Gender Delusion";
	elseif nRollValue < 9 then return "Racial Delusion";
	elseif nRollValue < 16 then	return "Dipsomania";
	elseif nRollValue < 22 then	return "Schizoid";
	elseif nRollValue < 26 then	return "Monomania";
	elseif nRollValue < 30 then	return "Dementia praecox";
	elseif nRollValue < 35 then	return "Melancholia";
	elseif nRollValue < 41 then	return "Megalomania";
	elseif nRollValue < 45 then	return "Mania";
	elseif nRollValue < 50 then	return "Lunacy";
	elseif nRollValue < 56 then	return "Phobia: " .. getPhobia();
	elseif nRollValue < 59 then	return "Manic-depressive";
	elseif nRollValue < 64 then	return "Hallucinatory insanity";
	elseif nRollValue < 69 then	return "Homicidal maniac";
	elseif nRollValue < 72 then	return "Hebephrenia";
	elseif nRollValue < 75 then	return "Suicidal mania";
	elseif nRollValue < 79 then	return "Catatonia";
	elseif nRollValue < 85 then	return "Heroic idiocy";
	elseif nRollValue < 90 then	return "Masochism";
	elseif nRollValue < 95 then	return "Sadistic (as per major mental quirk)";
	elseif nRollValue < 99 then	return "Sado-masochism";
	else return getInsanity() .. " and " .. getInsanity();
	end
end

function getColorChange(nRollValue)
	if not nRollValue then nRollValue = DiceManagerPO.getDieResult(100); end
	
	if nRollValue < 10 then	return "Red";
	elseif nRollValue < 19 then	return "Orange";
	elseif nRollValue < 28 then	return "Yellow";
	elseif nRollValue < 37 then	return "Green";
	elseif nRollValue < 46 then	return "Blue";
	elseif nRollValue < 55 then	return "Purple";
	elseif nRollValue < 64 then	return "Pink";
	elseif nRollValue < 73 then	return "Black";
	elseif nRollValue < 83 then	return "White";
	elseif nRollValue < 89 then	return getColorChange() .. " and " .. getColorChange();
	elseif nRollValue < 93 then	return getColorChange(DiceManagerPO.getDieResult(88)) .. " Geometric Designs";
	elseif nRollValue < 97 then	return getColorChange(DiceManagerPO.getDieResult(88)) .. " Striped";
	else return getColorChange(DiceManagerPO.getDieResult(88)) .. " Polka Dot";
	end
	
end

function getUnarmedHackmasterFumbleResult(nRollValue)
	local sResult = "";
	if nRollValue >= 1000 then sResult = "knocks self unconscious"
	elseif nRollValue >= 997 then sResult = "slams head into floor, must save vs breath weapon or fall unconscious for {2d6} minutes / if npc immediate morale check (if conscious)"
	elseif nRollValue >= 988 then sResult = "fall prone"
	elseif nRollValue >= 983 then sResult = "slip, opponent gains +2 to-hit next attack, must save vs breath weapon or fall prone"
	elseif nRollValue >= 974 then sResult = "hinder ally; ally at -2 to-hit for {1d4} rounds / allay at +{1d4} initiative next round"
	elseif nRollValue >= 968 then sResult = "compound leg fracture; move x1/4 for 1 week, suffers {1d4} points of damage / save at -1 / -2 to-hit / opponents gain +2 to-hit for {1d3} days / if npc immediate morale check"
	elseif nRollValue >= 964 then sResult = "tear muscle badly; move x1/4 for 1 day / suffers 1 point of damage / -4 to-hit / save at -2 for 1 day"
	elseif nRollValue >= 960 then sResult = "severe strain; move x1/3 for 1 turn / saves -3 / if npc immediate morale check"
	elseif nRollValue >= 956 then sResult = "simple bone fracture; move x1/3, for one month / suffers 1 point of damage / -1 to-hit for 1 week"
	elseif nRollValue >= 951 then sResult = "hairline bone fracture; move x1/2 for 1 month / suffers 1 point of damage / save at -1 / opponents gain +2 t hit for 1d12 hours"
	elseif nRollValue >= 948 then sResult = "muscle tear; move x1/2 for 1 week / suffers 1 point of damage /-2 to-hit / save at -1 for {1d3} days / if npc immediate morale check"
	elseif nRollValue >= 945 then sResult = "bad leg crap (or similar limb); movex2/3 for 1 day / saves at -3"
	elseif nRollValue >= 941 then sResult = "leg cramp (or similar limb); move x2/3 for 1 turn / saves at -3"
	elseif nRollValue >= 936 then sResult = "bad sprain; move -3 for 1 day / saves at -3 / if npc immediate morale check"
	elseif nRollValue >= 932 then sResult = "hyperextension;move -3 for 1 turn / saves at -3 "
	elseif nRollValue >= 926 then sResult = "sprain leg (or similar limb);move -2 for {1d3} days / saves at -2 / if npc immediate morale check"
	elseif nRollValue >= 922 then sResult = "pull leg (or similar limb);move -2 for 1 day / saves at -2"
	elseif nRollValue >= 916 then sResult = "internal bleeding;move -2 for 1 turn / saves at -2"
	elseif nRollValue >= 908 then sResult = "sprain leg (or similar limb);move -1 for 1 day / saves at -1"
	elseif nRollValue >= 903 then sResult = "pull leg (or similar limb);move -1 for 1 turn / saves at -1"
	elseif nRollValue >= 896 then sResult = "slip badly;opponent gains +4 to-hit for 1 round / initiative +{1d6} on next round"
	elseif nRollValue >= 889 then sResult = "falls towards opponent's weapon;opponent gains +4 to-hit for attack / initiative +{1d4} on next round"
	elseif nRollValue >= 884 then sResult = "severely off-balanced;opponent gains +3 to-hit for {1d6} rounds / initiative +{1d4} on next round"
	elseif nRollValue >= 879 then sResult = "severely off-balanced;opponent gains +3 to-hit for 2 rounds / initiative +{1d4} on next round"
	elseif nRollValue >= 872 then sResult = "off-balanced; opponent gains +3 to-hit for 1 round / initiative +{1d3} on next round"
	elseif nRollValue >= 865 then sResult = "off-balanced;opponent gains +3 to-hit next attack / initiative +{1d3} on next round"
	elseif nRollValue >= 858 then sResult = "severely off-balanced; opponent gains +2 to-hit for {1d6} rounds / initiative +{1d3} on next round"
	elseif nRollValue >= 850 then sResult = "severely off-balanced; opponent gains +2 to-hit for 2 rounds / initiative +!d3 on next round"
	elseif nRollValue >= 842 then sResult = "off-balanced; opponent gains +2 to-hit for 1 round / initiative +{1d3} on next round"
	elseif nRollValue >= 834 then sResult = "off-balanced; opponent gains +2 to-hit next attack / initiative +1 on next round"
	elseif nRollValue >= 826 then sResult = "severely off-balanced; opponent gains +1 to-hit for {1d6} rounds / initiative +{1d3} on next round"
	elseif nRollValue >= 807 then sResult = "off-balance; opponent gains +1 to-hit for 1 round / initiative +1 on next round"
	elseif nRollValue >= 796 then sResult = "off-balance; opponent gains +1 to-hit next attack / initiative +1 on next round"
	elseif nRollValue >= 782 then sResult = "bad muscle pull;move -1, 1 day / saves at -1 for 1 day / opponent gains +1 to-hit for {1d4} rounds"
	elseif nRollValue >= 772 then sResult = "hit ally, {2d6} points or hit self, 10% change of paralyzing self"
	elseif nRollValue >= 767 then sResult = "hit ally, 1d10 points or hit self, 10% change of paralyzing self"
	elseif nRollValue >= 759 then sResult = "hit ally, {1d8} points or hit self, 8% change of paralyzing self"
	elseif nRollValue >= 749 then sResult = "hit ally, normal damage or hit self, 5% change of paralyzing self"
	elseif nRollValue >= 731 then sResult = "hit ally, {1d6} points or hit self, 4% change of paralyzing self"
	elseif nRollValue >= 718 then sResult = "hit ally, {1d4} points or hit self, 3% change of paralyzing self"
	elseif nRollValue >= 704 then sResult = "hit ally, {1d4}-1 points or hit self, 2% chance of paralyzing self"
	elseif nRollValue >= 693 then sResult = "hit ally, {1d4}-2 points or hit self, 2% chance of paralyzing self"
	elseif nRollValue >= 679 then sResult = "hit ally, 1 point or hit self, 1% chance of paralyzing self"
	elseif nRollValue >= 664 then sResult = "may hit ally, roll attack normally"
	elseif nRollValue >= 645 then sResult = "damage to self, {2d6} points / if npc immediate morale check"
	elseif nRollValue >= 640 then sResult = "damage to self, 1d10 points"
	elseif nRollValue >= 632 then sResult = "damage to self, {1d8} points"
	elseif nRollValue >= 622 then sResult = "damage to self, normal damage"
	elseif nRollValue >= 604 then sResult = "damage to self, {1d6} points"
	elseif nRollValue >= 594 then sResult = "damage to self, {1d4} points"
	elseif nRollValue >= 580 then sResult = "damage to self, {1d4}-1 points"
	elseif nRollValue >= 570 then sResult = "damage to self, {1d4}-2 points"
	elseif nRollValue >= 558 then sResult = "damage to self, 1 point"
	elseif nRollValue >= 545 then sResult = "may hit self, roll attack normally"
	elseif nRollValue >= 531 then sResult = "back strain; saves at -3 for 1 turn / if npc immediate morale check"
	elseif nRollValue >= 526 then sResult = "severe dizziness; saves at -3 for {1d4} rounds / if npc immediate morale check"
	elseif nRollValue >= 521 then sResult = "whiplash; saves at -3 for 1 round"
	elseif nRollValue >= 516 then sResult = "overextended; saves at -2 for 1 turn"
	elseif nRollValue >= 510 then sResult = "overextended; saves at -2 for {1d4} rounds"
	elseif nRollValue >= 504 then sResult = "overextended; saves at -2 for 1 round"
	elseif nRollValue >= 498 then sResult = "overextended; saves at -1 for 1 turn"
	elseif nRollValue >= 490 then sResult = "accidentally swallowed dust, insect or tooth;saves at -1 for {1d4} rounds"
	elseif nRollValue >= 481 then sResult = "overextended; saves at -1 for 1 round"
	elseif nRollValue >= 471 then sResult = "slip badly; opponent gains +4 to-hit for 1 round"
	elseif nRollValue >= 466 then sResult = "falls towards opponent's weapon; opponent gains +4 to-hit next attack"
	elseif nRollValue >= 461 then sResult = "severely off-balanced; opponent gains +3 to-hit for {1d6} rounds"
	elseif nRollValue >= 455 then sResult = "severely off-balanced; opponent gains +3 to-hit for 2 rounds"
	elseif nRollValue >= 449 then sResult = "off-balanced; opponent gains +3 to-hit for 1 round"
	elseif nRollValue >= 442 then sResult = "off-balanced; opponent gains +3 to-hit next attack"
	elseif nRollValue >= 434 then sResult = "severely off-balanced; opponent at +2 to-hit for {1d6} rounds"
	elseif nRollValue >= 426 then sResult = "severely off-balanced; opponent gains +2 to-hit for 2 rounds"
	elseif nRollValue >= 409 then sResult = "off-balanced; opponent gains +2 to-hit for 1 round"
	elseif nRollValue >= 400 then sResult = "severely off-balanced; opponent gains +1 to-hit for {1d6} rounds"
	elseif nRollValue >= 392 then sResult = "severely off-balanced; opponent gains +1 to-hit for 2 rounds"
	elseif nRollValue >= 383 then sResult = "breaks tooth; opponent gains +1 to-hit for 1 round"
	elseif nRollValue >= 371 then sResult = "off-balance; opponent at +1 to-hit next attack"
	elseif nRollValue >= 356 then sResult = "bad pull; move x1/4, 1 day / saves t -3 for 1 day / immediate morale check if npc"
	elseif nRollValue >= 352 then sResult = "pull; move x1/4, 1 day / saves -3 for 1 day"
	elseif nRollValue >= 348 then sResult = "bad pull; move x1/4, 1 turn"
	elseif nRollValue >= 344 then sResult = "very bad pull; move x1/3, 1 day / saves at -3 for 1 day"
	elseif nRollValue >= 340 then sResult = "twisted ankle;move x1/3,1 day"
	elseif nRollValue >= 335 then sResult = "very bad pull; move x1/3, 1 turn"
	elseif nRollValue >= 330 then sResult = "severe strain; move x1/2, 1 day / saves at -3 for 1 day"
	elseif nRollValue >= 326 then sResult = "severe leg crap; move x1/2, 1 turn / saves at -3 for 1 turn"
	elseif nRollValue >= 322 then sResult = "severe strain; move x1/2, 1 day"
	elseif nRollValue >= 317 then sResult = "severe leg crap; move 1/2, 1 turn"
	elseif nRollValue >= 312 then sResult = "strain limb; move x2/3, 1 week"
	elseif nRollValue >= 308 then sResult = "bad leg(or similar limb) cramp; move x2/3, 1 day"
	elseif nRollValue >= 297 then sResult = "bad sprain; move -3, 1 week"
	elseif nRollValue >= 292 then sResult = "hyperextention; move -3, 1 day"
	elseif nRollValue >= 286 then sResult = "hyperextention; move -3, 1 turn"
	elseif nRollValue >= 280 then sResult = "sprain leg (or similar limb); move -2, 1 week"
	elseif nRollValue >= 275 then sResult = "pull leg (or similar limb); move -2, 1 day"
	elseif nRollValue >= 269 then sResult = "pull leg (or similar limb); move -2, 1 turn"
	elseif nRollValue >= 262 then sResult = "sprain leg (or similar limb); move -1, 1 week"
	elseif nRollValue >= 257 then sResult = "pull leg (or similar limb); move -1, 1 day"
	elseif nRollValue >= 251 then sResult = "pull leg (or similar limb); move -1, 1 turn"
	elseif nRollValue >= 244 then sResult = "broken finger(or similar limb); -5 to-hit, 1 turn"
	elseif nRollValue >= 240 then sResult = "broken pinky (or similar limb); -5 to hit, {1d4} rounds"
	elseif nRollValue >= 235 then sResult = "bad pull; -4 to-hit, {1d6} minutes"
	elseif nRollValue >= 229 then sResult = "pull muscle; -4 to-hit, 1 turn"
	elseif nRollValue >= 222 then sResult = "strain limb; -4 to-hit, {1d8} rounds"
	elseif nRollValue >= 215 then sResult = "overextended; -4 to-hit, {1d4} rounds"
	elseif nRollValue >= 205 then sResult = "off-balance; -4 to hit, 1 round"
	elseif nRollValue >= 198 then sResult = "bad pull; -3 to-hit, {1d6} minutes"
	elseif nRollValue >= 190 then sResult = "pull muscle; -3 to-hit, 1 turn"
	elseif nRollValue >= 182 then sResult = "strain limb; -3 to-hit, {1d8} rounds"
	elseif nRollValue >= 174 then sResult = "overextended; -3 to-hit, {1d4} rounds"
	elseif nRollValue >= 166 then sResult = "off-balance; -3 to hit, 1 round"
	elseif nRollValue >= 158 then sResult = "bad pull; -2 to-hit, {1d6} minutes"
	elseif nRollValue >= 151 then sResult = "pull muscle; -2 to-hit, 1 turn"
	elseif nRollValue >= 142 then sResult = "strain limb; -2 to-hit, {1d8} rounds"
	elseif nRollValue >= 133 then sResult = "overextended; -2 to-hit, {1d4} rounds"
	elseif nRollValue >= 124 then sResult = "off-balance; -2 to hit, 1 round"
	elseif nRollValue >= 114 then sResult = "bad pull; -1 to-hit, {1d6} minutes"
	elseif nRollValue >= 106 then sResult = "pull muscle; -1 to-hit, 1 turn"
	elseif nRollValue >= 96 then sResult = "strain limb; -1 to-hit, {1d8} rounds"
	elseif nRollValue >= 86 then sResult = "overextended; -1 to-hit, {1d4} rounds"
	elseif nRollValue >= 75 then sResult = "off-balance; -1 to-hit, 1 round"
	elseif nRollValue >= 62 then sResult = "Severly off-balanced; Lose next attack"
	elseif nRollValue >= 56 then sResult = "Overextended thrust; initiative +{1d6} on next round"
	elseif nRollValue >= 48 then sResult = "bites inside of cheek; initiative +{1d4} on next round"
	elseif nRollValue >= 37 then sResult = "off-balance;initiative +{1d3} on next round"
	elseif nRollValue >= 25 then sResult = "off-balance; initiative + 1 on next round"
	elseif nRollValue >= 12 then sResult = "Slaps/Claws/bites self - looks funny"
	else sResult = "Would have hit, but slips away at last moment"
	end
	
	return replaceRolls(sResult);
end

function getNormalHackmasterFumbleResult(nRollValue)
	local sResult = "";
	if nRollValue >= 985 then sResult = "Clumsiness; Slip, opponent gains +2 to next to hit roll, -4 Dex for one round and make check vs. 1/2 Dex or fall prone"
	elseif nRollValue >= 969 then sResult = "Clumsiness; overextended, opponent gains +2 to next to-hit"  
	elseif nRollValue >= 953 then sResult = "Clumsiness; off balance +{1d4} penalty to next initiative"  
	elseif nRollValue >= 937 then sResult = "Clumsiness; hinder ally - takes +{1d6} initiative penalty, suffers -{1d4+1} to hit penalty on next attack or have 25% chance of hitting you"  
	elseif nRollValue >= 921 then sResult = "Clumsiness; overextended +d4 penalty to next initiative, opponent gains +2 to next attack roll"  
	elseif nRollValue >= 904 then sResult = "Hinderance; distracted, -4 to hit and no Dex bonus to AC for 1 round"  
	elseif nRollValue >= 886 then sResult = "Hinderance; nearby ally is automatically hit"  
	elseif nRollValue >= 869 then sResult = "Hinderance; blood in eyes -3 to hit for 1 turn"  
	elseif nRollValue >= 851 then sResult = "Hinderance; sweat in eyes -1 to hit for 1 round"  
	elseif nRollValue >= 821 then sResult = "Equipment Mishap; shield strap breaks, -3 to hit until repaired or discarded"  
	elseif nRollValue >= 814 then sResult = "Equipment Mishap; armor strap breaks, +1 AC penalty and -1 to hit until repaired"  
	elseif nRollValue >= 791 then sResult = "Equipment Mishap; armor loosened, -1 to hit until readjusted (by redonning or by another person helping for 1 round)"  
	elseif nRollValue >= 761 then sResult = "Equipment Mishap; belt, girdle, etc. breaks"  
	elseif nRollValue >= 716 then sResult = "Equipment Mishap; backpack, pouch or other container strap breaks, -1 to hit until item repaired or discarded"  
	elseif nRollValue >= 701 then sResult = "Equipment Mishap; boot/footgear breaks, -1 to hit until repaired or discarded"  
	elseif nRollValue >= 661 then sResult = "Weapon damaged/broken; edge dulled, nicked and/or cracked (-1 to hit & damage)"  
	elseif nRollValue >= 651 then sResult = "Weapon damaged/broken; blade/head sheared/cracked -50% to dmg"  
	elseif nRollValue >= 631 then sResult = "Weapon damaged/broken; blade/head badly broken -2 dmg"  
	elseif nRollValue >= 611 then sResult = "Weapon damaged/broken; handle badly broken -2 to hit"  
	elseif nRollValue >= 601 then sResult = "Weapon damaged/broken; sheared (useless)"  
	elseif nRollValue >= 591 then sResult = "Weapon damaged/broken; handle/haft sheared (useless)"  
	elseif nRollValue >= 581 then sResult = "Weapon damaged/broken; blade shattered (useless)"  
	elseif nRollValue >= 541 then sResult = "Weapon damaged/broken; blade/head broken -1 to damage"  
	elseif nRollValue >= 501 then sResult = "Weapon damaged/broken; handle broken -1 to hit"  
	elseif nRollValue >= 401 then sResult = "Damage to ally, make Dex check to deliver only half damage"  
	elseif nRollValue >= 359 then sResult = "Damage own armor for {1d3} points"  
	elseif nRollValue >= 358 then sResult = "Non-wpn injury to self; hyperexted back,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1d6} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 355 then sResult = "Non-wpn injury to self; hyperexted neck,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1d6} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 354 then sResult = "Non-wpn injury to self; hyperextention left elbow,minus {1d4} to hit for {1d4} days unless magically cured, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 353 then sResult = "Non-wpn injury to self; hyperextention left shoulder,minus {1d4} to hit for {1d4} days unless magically cured, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 352 then sResult = "Non-wpn injury to self; hyperextention left wrist,minus {1d4} to hit for {1d4} days unless magically cured, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 351 then sResult = "Non-wpn injury to self; hyperextention left hip,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1d6} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 349 then sResult = "Non-wpn injury to self; hyperextention left knee,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 347 then sResult = "Non-wpn injury to self; hyperextention left ankle,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 346 then sResult = "Non-wpn injury to self; hyperextention left foot,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 345 then sResult = "Non-wpn injury to self; hyperextention right elbow,minus {1d4} to hit for {1d4} days unless magically cured, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 343 then sResult = "Non-wpn injury to self; hyperextention right shoulder,minus {1d4} to hit for {1d4} days unless magically cured, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 342 then sResult = "Non-wpn injury to self; hyperextention right wrist,minus {1d4} to hit for {1d4} days unless magically cured, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 341 then sResult = "Non-wpn injury to self; hyperextention right hip,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 340 then sResult = "Non-wpn injury to self; hyperextention right knee,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 338 then sResult = "Non-wpn injury to self; hyperextention right ankle,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 337 then sResult = "Non-wpn injury to self; hyperextention right foot,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns, {1d20}% temporal honor reduction."  
	elseif nRollValue >= 319 then sResult = "Non-wpn injury to self, pulled muscle, Roll on crit (puncture) chart until reasonable result attained"  
	elseif nRollValue >= 318 then sResult = "Non-wpn injury to self; sprain back,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 317 then sResult = "Non-wpn injury to self; sprain neck,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 316 then sResult = "Non-wpn injury to self; sprain left elbow,minus {1d4} to hit for {1d4} days unless magically cured"  
	elseif nRollValue >= 315 then sResult = "Non-wpn injury to self; sprain left shoulder,minus {1d4} to hit for {1d4} days unless magically cured"  
	elseif nRollValue >= 314 then sResult = "Non-wpn injury to self; sprain left wrist,minus {1d4} to hit for {1d4} days unless magically cured"  
	elseif nRollValue >= 313 then sResult = "Non-wpn injury to self; sprain left hip,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 312 then sResult = "Non-wpn injury to self; sprain left knee,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 311 then sResult = "Non-wpn injury to self; sprain left ankle,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 310 then sResult = "Non-wpn injury to self; sprain left foot,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 309 then sResult = "Non-wpn injury to self; sprain right elbow,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 308 then sResult = "Non-wpn injury to self; sprain right shoulder,minus {1d4} to hit for {1d4} days unless magically cured"  
	elseif nRollValue >= 307 then sResult = "Non-wpn injury to self; sprain right wrist,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 306 then sResult = "Non-wpn injury to self; sprain right hip,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 305 then sResult = "Non-wpn injury to self; sprain right knee,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 304 then sResult = "Non-wpn injury to self; sprain right ankle,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 303 then sResult = "Non-wpn injury to self; sprain right foot,50% movement reduction for 1 round then 10% for {2d4} rounds, then 25% for {1{1d6}} turns"  
	elseif nRollValue >= 301 then sResult = "Non-wpn injury to self; bad twist to back,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 297 then sResult = "Non-wpn injury to self; bad twist to neck,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 294 then sResult = "Non-wpn injury to self; bad twist left elbow,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 291 then sResult = "Non-wpn injury to self; bad twist left shoulder,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 289 then sResult = "Non-wpn injury to self; bad twist left wrist,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 288 then sResult = "Non-wpn injury to self; bad twist left hip,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 285 then sResult = "Non-wpn injury to self; bad twist left knee,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 282 then sResult = "Non-wpn injury to self; bad twist left ankle,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 280 then sResult = "Non-wpn injury to self; bad twist left foot,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 277 then sResult = "Non-wpn injury to self; bad twist right elbow,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 274 then sResult = "Non-wpn injury to self; bad twist right shoulder,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 272 then sResult = "Non-wpn injury to self; bad twist right wrist,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 271 then sResult = "Non-wpn injury to self; bad twist right hip,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 268 then sResult = "Non-wpn injury to self; bad twist right knee,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 265 then sResult = "Non-wpn injury to self; bad twist right ankle,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 263 then sResult = "Non-wpn injury to self; bad twist right foot,50% movement reduction for 1 round then 10% for {2d4} rounds"  
	elseif nRollValue >= 201 then sResult = "Dmg to self, roll dmg as normal, make Dex check to suffer half dmg"  
	elseif nRollValue >= 200 then sResult = "Drop weapon 20 feet away"  
	elseif nRollValue >= 199 then sResult = "Drop weapon 19 feet away"  
	elseif nRollValue >= 198 then sResult = "Drop weapon 18 feet away"  
	elseif nRollValue >= 196 then sResult = "Drop weapon 17 feet away"  
	elseif nRollValue >= 194 then sResult = "Drop weapon 16 feet away"  
	elseif nRollValue >= 192 then sResult = "Drop weapon 15 feet away"  
	elseif nRollValue >= 190 then sResult = "Drop weapon 14 feet away"  
	elseif nRollValue >= 187 then sResult = "Drop weapon 13 feet away"  
	elseif nRollValue >= 184 then sResult = "Drop weapon 12 feet away"  
	elseif nRollValue >= 181 then sResult = "Drop weapon 11 feet away"  
	elseif nRollValue >= 177 then sResult = "Drop weapon 10 feet away"  
	elseif nRollValue >= 173 then sResult = "Drop weapon 9 feet away"  
	elseif nRollValue >= 168 then sResult = "Drop weapon 8 feet away"  
	elseif nRollValue >= 162 then sResult = "Drop weapon 7 feet away"  
	elseif nRollValue >= 155 then sResult = "Drop weapon 6 feet away"  
	elseif nRollValue >= 145 then sResult = "Drop weapon 5 feet away"  
	elseif nRollValue >= 131 then sResult = "Drop weapon 4 feet away"  
	elseif nRollValue >= 111 then sResult = "Drop weapon 3 feet away"  
	elseif nRollValue >= 86 then sResult = "Drop weapon 2 feet away"  
	else sResult = "Drop weapon at feet" 
	end
	
	return replaceRolls(sResult);
end

function replaceRolls(sText)
	local sNeededRoll = sText:match("{%d+d%d+}");
	
	if sNeededRoll then	
		local sDiceString = string.sub(sNeededRoll, 2, -2);
		local rDice = StringManager.convertStringToDice(sDiceString);
		local nTotal = getDiceTotal(rDice);
		local sReplaced = string.gsub(sText, sNeededRoll, nTotal, 1);
		return replaceRolls(sReplaced);
	end
	return sText;
end

function getDiceTotal(rDice)
	local nTotal = 0;
	for kDieType in ipairs(rDice) do
		local vDieType = rDice[kDieType];
		local nSides = tonumber(vDieType:match("^d(%d+)"));
		nTotal = nTotal + math.random(1, nSides);
	end
	return nTotal;
end