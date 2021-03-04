local aHackingCritMatrix = {};
local aCrushingCritMatrix = {};
local aPuncturingCritMatrix = {};
local aCritLocations = {};

function onInit()
	buildHackingCritMatrix();
	buildCrushingCritMatrix();
	buildPuncturingCritMatrix();
	buildCritLocationInfo();		
end


function getCritType(aDamageTypes)
	Debug.console("manager_crit_hm.lua", "getCritType", "aDamageTypes", aDamageTypes);
	local sCritType = CritManagerPO.selectRandomCritDamageType(aDamageTypes);
	if not sCritType or sCritType == "" then
		sCritType = "h"; -- couldn't parse anything, so call it hacking.
	else
		local sFirstChar = string.sub(sCritType, 1, 1);
		if sFirstChar == "s" or sFirstChar == "h" then
			sCritType = "h";
		elseif sFirstChar == "b" or sFirstChar == "c" then
			sCritType = "c";
		elseif sFirstChar == "p" then
			sCritType = "p"
		else
			sCritType = "h"; -- couldn't parse anything, so call it hacking.
		end
	end
	
	return sCritType;
end

function getCritEffects(sLocation, nSeverity, aDamageTypes)
	local sCritType = getCritType(aDamageTypes);
	local rCritEffect;
	if sCritType == "p" then
		rCritEffect = getPuncturingCrit(sLocation, nSeverity);
		rCritEffect.sDamageType = "piercing";
	elseif sCritType == "b" then
		rCritEffect = getCrushingCrit(sLocation, nSeverity);
		rCritEffect.sDamageType = "bludgeoning";
	else	
		rCritEffect = getHackingCrit(sLocation, nSeverity);
		rCritEffect.sDamageType = "slashing";
	end
	return rCritEffect;
end

function handleCrit(rRoll, rAction, nDefenseVal, rSource, rTarget)
	local rCrit = {};
	local nSeverity = getCritSeverity(rRoll, rAction, nDefenseVal, rSource, rTarget);
	local rHitLocation = HitLocationManagerPO.getHackmasterHitLocation(rSource, rTarget, rAction.sCalledShotLocation);
	Debug.console("manager_crit_hm.lua", "handleCrit", "hit location", rHitLocation.desc);

	local sResult = "[Severity: " .. nSeverity .. "]"
	sResult = sResult .. "\r[Location (d10000=" .. rHitLocation.roll .. "): " .. rHitLocation.desc .. "(" .. rHitLocation.side .. ")]";
	if nSeverity < 0 then	
		sResult = sResult .. "\rNo extra effect";
	else
		
		local sEffect = "crit effect";
		local bHasScar = math.random(1, 100) <= 5 * nSeverity;
		local bPermanentDamage = nSeverity >= 13;
		if bHasScar then
			sResult = sResult .. "\r[Will Scar?: Yes]";
		else
			sResult = sResult .. "\r[Will Scar?: No]";
		end
		if bPermanentDamage then
			sResult = sResult .. "\r[Permanent Penalties: Will not heal normally. 50% of ability reductions, movement penalties, etc. will remain permanently if left to heal naturally. If cured by magic, 25% will remain permanently. A Cure Critical Wounds spell can cure one critical injury per application if the wound has not been healed by another method and one week has not transpired. See other Cleric spells for other healing possibilities.]"
		end
		local nConstitution = ActorManagerPO.getConstitution(rTarget);
		local nBruiseDays = math.max(1, 20 - nConstitution);
		sResult = sResult .. "\r[Bruised: " .. nBruiseDays .. " days. If injured in same location again before healed, suffer +1 damage per injury.]"; 
		if nSeverity > 5 then
			sResult = sResult .. "\r[Unable to follow-through damage until wound healed]";
		end
		if nSeverity > 10 then	
			sResult = sResult .. "\r[Unable to crit until wound healed]";
		end
		if nSeverity > 15 then
			sResult = sResult .. "\r[Unable to penetrate damage until wound healed]";
		end
		
		local rCritEffect = getCritEffects(rHitLocation.desc, nSeverity, rRoll.aDamageTypes);		

		sResult = sResult .. "\r" .. decodeCritEffect(rCritEffect, rHitLocation.desc, nSeverity, rTarget);

		rCrit.sDamageType = rCritEffect.sDamageType;
		if rCritEffect.dm then 
			rCrit.dmgMultiplier = rCritEffect.dm;
		end

		if rCritEffect.db then
			rCrit.dmgBonusDie = rCritEffect.db;
		end
		
		StateManagerPO.setCritState(rSource, rTarget, rCrit);

	end

	rCrit.sHitLocation = rHitLocation.desc;
	rCrit.nSeverity = nSeverity;
	rCrit.message = sResult;

	return rCrit;

end

function getCritSeverity(rRoll, rAction, nDefenseVal, rSource, rTarget)
	local nAttackerThaco = 20 - rRoll.nBaseAttack;
	Debug.console("manager_crit_hm.lua", "getCritSeverity", "nAttackerThaco", nAttackerThaco);
	local nTargetAc = 20 - nDefenseVal;
	Debug.console("manager_crit_hm.lua", "getCritSeverity", "nTargetAc", nTargetAc);
	local nAttackBonus = rAction.nTotal - 20; 
	Debug.console("manager_crit_hm.lua", "nAttackBonus", "nAttackBonus", nAttackBonus);
	local nBaseSeverity = calculateBaseSeverity(nAttackerThaco, nTargetAc, nAttackBonus);
	Debug.console("manager_crit_hm.lua", "getCritSeverity", "nBaseSeverity", nBaseSeverity);
	local nSeverityDieRoll = DiceManagerPO.rollPenetrateInBothDirection(8);
	Debug.console("manager_crit_hm.lua", "getCritSeverity", "nSeverityDieRoll", nSeverityDieRoll);
	local nFinalSeverity = math.min(24, nBaseSeverity + nSeverityDieRoll + CritManagerPO.getCritSeverityBonus(rSource, rTarget, rAction));
	Debug.console("manager_crit_hm.lua", "getCritSeverity", "nFinalSeverity", nFinalSeverity);
	return nFinalSeverity;
end


function calculateBaseSeverity(nAttackerThaco, nTargetAc, nAttackBonus)
	local nToHitAc15 = nAttackerThaco - 15;
	return nTargetAc - nToHitAc15 + nAttackBonus;
end

function getPuncturingCrit(sLocation, nSeverity)
	return aPuncturingCritMatrix[sLocation][nSeverity];
end

function getCrushingCrit(sLocation, nSeverity)
	return aCrushingCritMatrix[sLocation][nSeverity];
end

function getHackingCrit(sLocation, nSeverity)
	return aHackingCritMatrix[sLocation][nSeverity];
end

function decodeCritEffect(rCritEffect, sLocation, nSeverity, rTarget)
	local rLocation = getLocation(sLocation);
	local aEffects = {};
	
	if rCritEffect.db then
		decodeDamageBonus(aEffects, rCritEffect.db, rLocation, rTarget);
	end
	if rCritEffect.dm then
		decodeDamageMultiplier(aEffects, rCritEffect.dm, rLocation, rTarget);
	end
	if rCritEffect.m then
		decodeMovement(aEffects, rCritEffect.m);
	end
	if rCritEffect.f then
		decodeFall(aEffects);
	end
	if rCritEffect.a then
		decodeToHitReduction(aEffects, rCritEffect.a);
	end
	if rCritEffect.s then
		decodeStrengthReduction(aEffects, rCritEffect.s);
	end
	if rCritEffect.d then
		decodeStrengthReduction(aEffects, rCritEffect.d);
	end
	if rCritEffect.w then
		decodeWeaponDrop(aEffects, false);
	end
	if rCritEffect.ws then
		decodeWeaponDrop(aEffects, true);
	end
	if rCritEffect.mc then
		decodeMinorConcussion(aEffects, nSeverity);
	end
	if rCritEffect.sc then
		decodeSevereConcussion(aEffects, nSeverity);
	end
	if rCritEffect.p then
		decodeParalyzation(aEffects, nSeverity, rLocation);
	end
	if rCritEffect.pb then
		decodeProfuseBleeding(aEffects, rTarget);
	end
	if rCritEffect.v then
		decodeVitalOrgan(aEffects, rCritEffect.v, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.h then
		decodeTemporalHonorLoss(aEffects, rCritEffect.h);
	end
	if rCritEffect.mt then
		decodeMuscleTear(aEffects, rCritEffect.mt, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.b then
		decodeBrokenBone(aEffects, 0, rCritEffect.b, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.tl then
		decodeTornLigaments(aEffects, rCritEffect.tl, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.bf then
		decodeBrokenBone(aEffects, 1, rCritEffect.bf, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.bm then
		decodeBrokenBone(aEffects, 2, rCritEffect.bm, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.bs then
		decodeBrokenBone(aEffects, 3, rCritEffect.bs, nSeverity, rLocation, rTarget);
	end
	if rCritEffect.ib then
		decodeInternalBleeding(aEffects);
	end
	if rCritEffect.u then
		decodeUnconscious(aEffects);
	end
	if rCritEffect.ls then
		decodeLimbSevered(aEffects, rLocation, rTarget);
	end
	if rCritEffect.dead then
		decodeDead(aEffects, rCritEffect.dead);
	end
	
	return toCsv(aEffects);
end

function decodeDead(aEffects, sDeath)
	table.insert(aEffects, "Death! (" .. sDeath .. ")");
end

function decodeFall(aEffects)
	table.insert(aEffects, "Falls to the ground prone and drops anything held");
end

function decodeToHitReduction(aEffects, nValue)
	table.insert(aEffects, "Receives a -" .. nValue .. " penalty to hit until wound completely healed");
end

function decodeStrengthReduction(aEffects, nValue)
	table.insert(aEffects, "Loses " .. nValue .. " points of Strength until wound completely healed");
end

function decodeDexterityReduction(aEffects, nValue)
	table.insert(aEffects, "Loses " .. nValue .. " points of Dexterity until wound completely healed");
end

function decodeWeaponDrop(aEffects, bStrengthCheck)
	local sMsg =  "Drops any weapon and/or items carried";
	if bStrengthCheck then
		sMsg = sMsg .. " unless a Strength check at half is passed";
	end
	table.insert(aEffects, sMsg);
end

function decodeMinorConcussion(aEffects, nSeverity)
	local nDuration = math.random(1, 12) + nSeverity;
	
	local sFlaws = "the migraine flaw (PHB 94)";
	if math.random(1, 100) <= 3 * nSeverity then
		sFlaws = sFlaws .. " and the seizure disorder character flaw (PHB 94)"
	end
	
	table.insert(aEffects, "Gains " .. sFlaws .. " with an immediate headache. Lasts " .. nDuration .. " hours or until healed.");
end

function decodeSevereConcussion(aEffects, nSeverity)
	local sFlaws = "the migraine flaw (PHB 94)";
	if math.random(1, 100) <= 5 * nSeverity then
		sFlaws = sFlaws .. " and the seizure disorder character flaw (PHB 94)"
	end
	
	table.insert(aEffects, "Gains " .. sFlaws .. " with an immediate headache. Lasts until healed.");
end

function getLocation(sLocation)
	local rLocation = aCritLocations[sLocation];
	if not rLocation then rLocation = {}; end
	return rLocation;
end

function getMuscle(rLocation, nIndex)
	local sMuscle = rLocation.muscular[nIndex];
	if not sMuscle then sMuscle = "Unknown"; end;
	return sMuscle;
end

function getBone(rLocation, nIndex)
	local sBone = rLocation.skeletal[nIndex];
	if not sBone then sBone = "Unknown"; end;
	return sBone;
end

function getOrgan(rLocation, nIndex)
	local sOrgan = rLocation.vital[nIndex];
	if not sOrgan then sOrgan = "Unknown"; end;
	return sOrgan;
end

function decodeParalyzation(aEffects, nSeverity, rLocation)
	local sCannotMove = "lower body";
	if rLocation.isHead or rLocation.isSpine then
		sCannotMove = "anything but their head";
	end
	local sMsg = "";
	if math.random(1, 100) <= nSeverity * 5 then
		sMsg = "Paralyzed. Cannot move " .. sCannotMove;
	else
		sMsg = "Avoided paralyzation.";
	end
	table.insert(aEffects, sMsg);
end

function decodeProfuseBleeding(aEffects, rTarget)
	local nConstitution = ActorManagerPO.getConstitution(rTarget);
	local nHalfCon = math.max(1, math.floor(nConstitution/2));
	table.insert(aEffects, "Profuse bleeding! Will bleed to death in ".. nHalfCon .. " rounds unless the wound has been treated by a successful first aid-related skill check or any cure spell that heals half the wound's HPs in damage, or one Cure Critical Wounds or better spell. Severed limbs may be cauterized by applying open flame for one round (1d4 damage)");
end

function decodeVitalOrgan(aEffects, nIndex, nSeverity, rLocation, rTarget)
	local sVitalOrganDamage, bWasHit = rollVitalOrganDamage(rLocation, nIndex);
	table.insert(aEffects, sVitalOrganDamage);
	if bWasHit then
		decodeWeaponDrop(aEffects);
		decodeInternalBleeding(aEffects);
		if math.random(1, 100) <= 3 * nSeverity then
			decodeProfuseBleeding(aEffects, rTarget);
		end
		if rLocation.isHead or rLocation.isSpine then
			decodeParalyzation(aEffects, nSeverity, rLocation);
		end
	end
end

function decodeTemporalHonorLoss(aEffects, nValue)
	local nLoss = nValue * 5;
	
	table.insert(aEffects, "Lose " .. nLoss .. "% of his temporal honor. Only affects males.");
end

function decodeMuscleTear(aEffects, nIndex, nSeverity, rLocation, rTarget)
	local nDays = math.max(1, 20 - ActorManagerPO.getConstitution(rTarget));
	table.insert(aEffects, "Muscle Tear (" .. getMuscle(rLocation, nIndex) .. ")! These wounds heal naturally at half normal rate. Any Dexterity and Strength reductions from this crit last for " .. nDays .. " days, then are reduced by half for like periods until reduce to zero. This lasting effect occurs regardless of whether the wounds have been healed fully by spells. A Cure Critical Wounds spell or better will eliminate all ill effects instantly.");
	if rLocation.isArm then 
		decodeWeaponDrop(aEffects, true);
	end
	if math.random(1, 100) <= 3 * nSeverity then
		decodeProfuseBleeding(aEffects, rTarget);
	end
end

-- nFracture = 0 normal broken, 1 = compound fracture, 2 = multiple fracture, 3 = bone shatter
function decodeBrokenBone(aEffects, nFracture, nIndex, nSeverity, rLocation, rTarget) 
	local sBone = getBone(rLocation, nIndex);

	local sHealRate = "onetenth";
	local sEffectName = "Broken bone (" .. getBone(rLocation, nIndex) .. ")!"
	local nExtraEffectChance = 15;
	if nFracture and nFracture == 1 then
		sEffectName = "Broken bone (" .. getBone(rLocation, nIndex) .. ") with compound fracture!";
		nExtraEffectChance = 30;
	elseif nFracture and nFracture == 2 then
		sEffectName = "Broken bone (" .. getBone(rLocation, nIndex) .. ") with multiple fractures!";
		nExtraEffectChance = 50;
		sHealRate = "one twelfth";
	elseif nFracture and nFracture == 3 then
		sEffectName = "Bone (" .. getBone(rLocation, nIndex) .. ") shattered!";
		nExtraEffectChance = 65;
		sHealRate = "one twentieth";
	end
	
	table.insert(aEffects, sEffectName .. " Can be cured by magical means or through healing at " .. sHealRate .. "  the normal rate. Successfully setting a broken bone using first aid-related skills allows healing at one quarter the normal rate. Unless set properly prior to healing, even magical healing, fractures will heal incorrectly giving rise to lasting limps, obvious lumps, etc. In this case, half of any associated movement and/or ability score penalties will be permanent. A Cure Critical Wounds spell or better will eliminate all ill effects instantly.");
	if rLocation.isSpine then
		decodeParalyzation(aEffects, nSeverity, rLocation);
	end
	if rLocation.isArm then
		decodeWeaponDrop(aEffects, true);
	end
	if rLocation.isTorso then
		if math.random(1, 100) <= nExtraEffectChance then
			decodeProfuseBleeding(aEffects, rTarget);
		end
		if math.random(1, 100) <= nExtraEffectChance then
			decodeInternalBleeding(aEffects);
		end
	end
end

function decodeTornLigaments(aEffects, nIndex, nSeverity, rLocation, rTarget)
	
	table.insert("Torn ligament or tendon (" .. getMuscle(rLocation, nIndex) .. ")! Unless the appropriate body part is isolated prior to healing, even magical healing, will heal incorrectly or incompletely, giving rise to lasting limps, obvious lumps, etc. In this case, half of any associated movement and/or ability score penalties will become permanent. A Cure Critical Wounds spell or better will eliminate all ill effects instantly.");
	
	if rLocation.isArm then
		decodeWeaponDrop(aEffects);
	else
		decodeWeaponDrop(aEffects, true);
	end
	
	if rLocation.isLeg then
		decodeParalyzation(aEffects, nSeverity, rLocation);
	end
	
	if math.random(1, 100) <= 30 then
		decodeProfuseBleeding(aEffects, rTarget);
	end
end

function decodeInternalBleeding(aEffects)
	table.insert(aEffects, "Internal bleeding! Each hour lose 1d4 hit points and make a Constitution check, with failure indicating that the character goes into shock (see Trauma Damage). May live for many hours or days with this problem and not know it; will feel pains in the area, but will otherwise not know that he has been injured");
end

function decodeUnconscious(aEffects)
	table.insert(aEffects, "Falls to the ground unconscious. Remains in a coma until the hit points suffered from this wound are healed (naturally or magically)");
end

function decodeLimbSevered(aEffects, rLocation, rTarget)
	table.insert(aEffects, "Limb severed! The stump can be cured by magical means or through natural healing at one third the normal rate. Regeneration, Reattach Limb, or the like needed to recover the limb.");
	
	if not rLocation.isDigit then
		decodeProfuseBleeding(aEffects, rTarget);
	end
end

function rollVitalOrganDamage(rLocation, nIndex, nRollValue)
	if not nRollValue then nRollValue = math.random(1, 100); end
	
	local sStatLost = "Constitution";
	if rLocation.isHead or rLocation.isSpine then
		if math.random(1, 100) <= 80 then
			sStatLost = "Intelligence";
		else
			sStatLost = "Dexterity";
		end
	end
	local bWasHit = true;
	local sMsg = "";
	if nRollValue < 26 then sMsg = "Vital organ missed!"; bWasHit = false;
	elseif nRollValue < 51 then sMsg = "Vital organ (" .. getOrgan(rLocation, nIndex) .. ")! Lose " .. DiceManagerPO.getDiceResult(2, 6) .. " points of " .. sStatLost .. ". 1 point returns per day for the next " .. math.random(1, 6) .. " day(s). Unreturned points are lost permanently.";
	elseif nRollValue < 71 then sMsg = "Vital organ (" .. getOrgan(rLocation, nIndex) .. ")! Death in " .. math.random(1, 12) .. " days";
	elseif nRollValue < 81 then sMsg = "Vital organ (" .. getOrgan(rLocation, nIndex) .. ")! Death in " .. math.random(1, 12) .. " hours";
	elseif nRollValue < 91 then sMsg = "Vital organ (" .. getOrgan(rLocation, nIndex) .. ")! Death in " .. math.random(1, 12) .. " rounds";
	else sMsg = "Vital organ(" .. getOrgan(rLocation, nIndex) .. ")! Death in " .. math.random(1, 12) .. " segments";
	end
	return sMsg, bWasHit;
end

function decodeMovement(aEffects, nValue)
	local sMsg = "";
	if nValue == 1 then sMsg = "Lose 50% move for 1 rd, then 10% for " .. DiceManagerPO.getDiceResult(2, 4) .. " rds";
	elseif nValue == 2 then sMsg =  "Lose 50% move for 2 rds, then 25% for " .. DiceManagerPO.getDiceResult(2, 10) .. " rds";
	elseif nValue == 3 then sMsg =  "Lose 50% move for 1 rd, 10% for " .. DiceManagerPO.getDiceResult(2, 4) .. " rds, then 25% for " .. DiceManagerPO.getDiceResult(1, 4) .. " turns";
	elseif nValue == 4 then sMsg =  "Lose 50% move for " .. DiceManagerPO.getDiceResult(1, 12) .. " hours";
	elseif nValue == 5 then sMsg =  "Lose 50% move for " .. DiceManagerPO.getDiceResult(1, 12) .. " hours, then 25% for " .. DiceManagerPO.getDiceResult(1, 12) .. " days";
	elseif nValue == 6 then sMsg =  "Lose 75% move for 6 hours, then 50% for " .. DiceManagerPO.getDiceResult(2, 12) .. " days";
	elseif nValue == 7 then sMsg =  "Lose 75% move for 6 hours, then 50% for " .. DiceManagerPO.getDiceResult(4, 12) .. " days";
	elseif nValue == 8 then sMsg =  "Lose 75% move for 6 hours, then 50% for " .. DiceManagerPO.getDiceResult(1, 3) .. " months";
	elseif nValue == 9 then sMsg =  "Lose 75% move for 1 day, then 50% for " .. DiceManagerPO.getDiceResult(1, 4) .. " months";
	else sMsg =  "Lose 75% move for 1 week, then 50% for " .. DiceManagerPO.getDiceResult(1, 6) .. " months";
	end
	table.insert(aEffects, sMsg);
end

function decodeMaxDamageBonus(rLocation, rTarget)
	if rLocation.dam == 1.0 then	
		return ""; -- No point in saying the bonus damage can't exceed 100% of their hp.
	else
		local nMaxHp = ActorManagerPO.getMaxHp(rTarget);
		local nAffectedHp = math.floor(nMaxHp * rLocation.dam);

		if rLocation.isDigit then
			return "If bonus damage exceeds " .. rLocation.dam * 100 .. "% of health (" .. nAffectedHp .. "), affected body part is severed or destroyed.";
		else
			return "If bonus damage exceeds " .. rLocation.dam * 100 .. "% of health (" .. nAffectedHp .. "), affected body part is severed or destroyed.";
		end
	end
end

function decodeDamageBonus(aEffects, nDieType, rLocation, rTarget)
	table.insert(aEffects, "Damage Bonus: (d" .. nDieType .. ") " .. decodeMaxDamageBonus(rLocation, rTarget));
end

function decodeDamageMultiplier(aEffects, nMultiplier, rLocation, rTarget)
	table.insert(aEffects, "Damage Multiplier: (x" .. nMultiplier .. ") " .. decodeMaxDamageBonus(rLocation, rTarget));
end

function toCsv(tt)
	local s = "";
	for _, p in ipairs(tt) do
		s = s .. "\r[Effect: " .. p .. "]";
	end
	return string.sub(s, 2);
end

function buildHackingCritMatrix()
	aHackingCritMatrix["Foot, top"] = {};
	aHackingCritMatrix["Foot, top"][1] = {db=1};
	aHackingCritMatrix["Foot, top"][2] = {db=1};
	aHackingCritMatrix["Foot, top"][3] = {db=3};
	aHackingCritMatrix["Foot, top"][4] = {db=3};
	aHackingCritMatrix["Foot, top"][5] = {db=4,m=1};
	aHackingCritMatrix["Foot, top"][6] = {db=4,m=1};
	aHackingCritMatrix["Foot, top"][7] = {db=6,t=1,m=2};
	aHackingCritMatrix["Foot, top"][8] = {db=6,t=1,m=2};
	aHackingCritMatrix["Foot, top"][9] = {db=8,t=1,m=3};
	aHackingCritMatrix["Foot, top"][10] = {db=8,t=1,m=3};
	aHackingCritMatrix["Foot, top"][11] = {dm=2,t=1,m=4};
	aHackingCritMatrix["Foot, top"][12] = {dm=2,t=1,m=4};
	aHackingCritMatrix["Foot, top"][13] = {dm=2,t=1,m=5};
	aHackingCritMatrix["Foot, top"][14] = {dm=2,t=1,m=5};
	aHackingCritMatrix["Foot, top"][15] = {dm=2,t=1,m=6};
	aHackingCritMatrix["Foot, top"][16] = {dm=2,t=1,m=6};
	aHackingCritMatrix["Foot, top"][17] = {dm=2,t=1,m=7};
	aHackingCritMatrix["Foot, top"][18] = {dm=2,t=1,m=7};
	aHackingCritMatrix["Foot, top"][19] = {dm=2,t=1,m=7,b=1};
	aHackingCritMatrix["Foot, top"][20] = {dm=2,t=1,m=8,bm=1};
	aHackingCritMatrix["Foot, top"][21] = {dm=2,t=1,bf=1,m=8};
	aHackingCritMatrix["Foot, top"][22] = {dm=2,t=1,bf=1,m=9};
	aHackingCritMatrix["Foot, top"][23] = {dm=2,ls=true,m=9};
	aHackingCritMatrix["Foot, top"][24] = {dm=2,ls=true,m=10};
	
	aHackingCritMatrix["Heel"] = {};
	aHackingCritMatrix["Heel"][1] = {db=1};
	aHackingCritMatrix["Heel"][2] = {db=1};
	aHackingCritMatrix["Heel"][3] = {db=3};
	aHackingCritMatrix["Heel"][4] = {db=3};
	aHackingCritMatrix["Heel"][5] = {db=4,m=1};
	aHackingCritMatrix["Heel"][6] = {db=4,m=1};
	aHackingCritMatrix["Heel"][7] = {db=6,t=1,m=2};
	aHackingCritMatrix["Heel"][8] = {db=6,t=1,m=2,a=1};
	aHackingCritMatrix["Heel"][9] = {db=8,t=1,m=3,a=1};
	aHackingCritMatrix["Heel"][10] = {db=8,t=1,m=3,a=2};
	aHackingCritMatrix["Heel"][11] = {dm=2,t=1,m=4,a=2};
	aHackingCritMatrix["Heel"][12] = {dm=2,t=1,d=1,m=4};
	aHackingCritMatrix["Heel"][13] = {dm=2,t=1,a=2,d=2,m=5};
	aHackingCritMatrix["Heel"][14] = {dm=2,t=1,a=2,d=2,m=5};
	aHackingCritMatrix["Heel"][15] = {dm=2,t=1,a=2,d=2,m=6};
	aHackingCritMatrix["Heel"][16] = {dm=2,t=1,a=3,d=2,m=6};
	aHackingCritMatrix["Heel"][17] = {dm=2,t=1,a=3,d=2,m=7};
	aHackingCritMatrix["Heel"][18] = {dm=2,t=1,b=1,a=3,d=2,m=7};
	aHackingCritMatrix["Heel"][19] = {dm=2,t=1,bm=1,a=3,d=2,m=7};
	aHackingCritMatrix["Heel"][20] = {dm=2,t=1,bm=1,a=3,d=2,m=8};
	aHackingCritMatrix["Heel"][21] = {dm=2,t=1,bf=1,a=3,d=2,m=8};
	aHackingCritMatrix["Heel"][22] = {dm=2,t=1,bf=1,a=3,d=2,m=9};
	aHackingCritMatrix["Heel"][23] = {dm=2,t=1,bs=1,a=3,d=2,m=9};
	aHackingCritMatrix["Heel"][24] = {dm=2,t=1,bs=1,a=3,d=2,m=10};

	aHackingCritMatrix["Toe(s)"] = {};
	aHackingCritMatrix["Toe(s)"][1] = {db=1};
	aHackingCritMatrix["Toe(s)"][2] = {db=1};
	aHackingCritMatrix["Toe(s)"][3] = {db=3};
	aHackingCritMatrix["Toe(s)"][4] = {db=3};
	aHackingCritMatrix["Toe(s)"][5] = {db=4,m=1};
	aHackingCritMatrix["Toe(s)"][6] = {db=4,m=1};
	aHackingCritMatrix["Toe(s)"][7] = {db=6,t=1,m=2};
	aHackingCritMatrix["Toe(s)"][8] = {db=6,t=1,m=2};
	aHackingCritMatrix["Toe(s)"][9] = {db=8,t=1,m=3};
	aHackingCritMatrix["Toe(s)"][10] = {db=8,t=1,m=3};
	aHackingCritMatrix["Toe(s)"][11] = {dm=2,t=1,m=4};
	aHackingCritMatrix["Toe(s)"][12] = {dm=2,t=1,m=4};
	aHackingCritMatrix["Toe(s)"][13] = {dm=2,t=1,m=5};
	aHackingCritMatrix["Toe(s)"][14] = {dm=2,t=1,m=5};
	aHackingCritMatrix["Toe(s)"][15] = {dm=2,t=1,m=6};
	aHackingCritMatrix["Toe(s)"][16] = {dm=2,t=1,b=1,m=6};
	aHackingCritMatrix["Toe(s)"][17] = {dm=2,t=1,bm=1,m=7};
	aHackingCritMatrix["Toe(s)"][18] = {dm=2,t=1,bm=1,m=7};
	aHackingCritMatrix["Toe(s)"][19] = {dm=2,ls=true,m=7};
	aHackingCritMatrix["Toe(s)"][20] = {dm=2,ls=true,m=8};
	aHackingCritMatrix["Toe(s)"][21] = {dm=2,ls=true,m=8};
	aHackingCritMatrix["Toe(s)"][22] = {dm=2,ls=true,m=9};
	aHackingCritMatrix["Toe(s)"][23] = {dm=2,ls=true,m=9};
	aHackingCritMatrix["Toe(s)"][24] = {dm=2,ls=true,m=10};
	
	aHackingCritMatrix["Foot, arch"] = {};
	aHackingCritMatrix["Foot, arch"][1] = {db=1};
	aHackingCritMatrix["Foot, arch"][2] = {db=1};
	aHackingCritMatrix["Foot, arch"][3] = {db=3};
	aHackingCritMatrix["Foot, arch"][4] = {db=3};
	aHackingCritMatrix["Foot, arch"][5] = {db=4,m=1};
	aHackingCritMatrix["Foot, arch"][6] = {db=4,m=1};
	aHackingCritMatrix["Foot, arch"][7] = {db=6,t=1,m=2};
	aHackingCritMatrix["Foot, arch"][8] = {db=6,t=1,m=2,a=1};
	aHackingCritMatrix["Foot, arch"][9] = {db=8,t=1,m=3,a=1};
	aHackingCritMatrix["Foot, arch"][10] = {db=8,t=1,m=3,a=2};
	aHackingCritMatrix["Foot, arch"][11] = {dm=2,t=1,m=4,a=2};
	aHackingCritMatrix["Foot, arch"][12] = {dm=2,t=1,a=2,d=1,m=4};
	aHackingCritMatrix["Foot, arch"][13] = {dm=2,t=1,a=2,d=2,m=5};
	aHackingCritMatrix["Foot, arch"][14] = {dm=2,b=1,a=2,d=2,m=5};
	aHackingCritMatrix["Foot, arch"][15] = {dm=2,b=1,a=2,d=2,m=6};
	aHackingCritMatrix["Foot, arch"][16] = {dm=2,b=1,a=3,d=2,m=6};
	aHackingCritMatrix["Foot, arch"][17] = {dm=2,b=1,a=3,d=2,m=7};
	aHackingCritMatrix["Foot, arch"][18] = {dm=2,b=1,a=3,d=2,m=7};
	aHackingCritMatrix["Foot, arch"][19] = {dm=2,bm=1,a=3,d=2,m=7};
	aHackingCritMatrix["Foot, arch"][20] = {dm=2,bm=1,a=3,d=2,m=8};
	aHackingCritMatrix["Foot, arch"][21] = {dm=2,bf=1,a=3,d=2,m=8};
	aHackingCritMatrix["Foot, arch"][22] = {dm=2,t=1,bf=1,a=3,d=2,m=9};
	aHackingCritMatrix["Foot, arch"][23] = {dm=2,ls=true,a=3,d=2,m=9};
	aHackingCritMatrix["Foot, arch"][24] = {dm=2,ls=true,a=3,d=2,m=10};
	
	aHackingCritMatrix["Ankle, inner"] = {};
	aHackingCritMatrix["Ankle, inner"][1] = {db=1};
	aHackingCritMatrix["Ankle, inner"][2] = {db=1};
	aHackingCritMatrix["Ankle, inner"][3] = {db=3};
	aHackingCritMatrix["Ankle, inner"][4] = {db=4,m=1};
	aHackingCritMatrix["Ankle, inner"][5] = {db=6,m=1};
	aHackingCritMatrix["Ankle, inner"][6] = {db=6,m=2,f=true};
	aHackingCritMatrix["Ankle, inner"][7] = {db=8,m=2,f=true};
	aHackingCritMatrix["Ankle, inner"][8] = {dm=2,d=1,m=3,f=true,t=1};
	aHackingCritMatrix["Ankle, inner"][9] = {dm=2,d=2,f=true,m=4,t=1};
	aHackingCritMatrix["Ankle, inner"][10] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Ankle, inner"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Ankle, inner"][12] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Ankle, inner"][13] = {dm=2,d=2,b=1,t=1,f=true,m=5};
	aHackingCritMatrix["Ankle, inner"][14] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Ankle, inner"][15] = {dm=2,d=3,t=1,b=1,f=true,m=5};
	aHackingCritMatrix["Ankle, inner"][16] = {dm=2,d=3,t=1,b=1,f=true,m=6};
	aHackingCritMatrix["Ankle, inner"][17] = {dm=2,d=4,t=1,bm=1,f=true,m=7};
	aHackingCritMatrix["Ankle, inner"][18] = {dm=2,d=5,t=1,bf=1,f=true,m=7};
	aHackingCritMatrix["Ankle, inner"][19] = {dm=2,d=5,b=1,t=1,f=true,m=8};
	aHackingCritMatrix["Ankle, inner"][20] = {dm=2,bm=1,t=1,f=true,m=8,d=6};
	aHackingCritMatrix["Ankle, inner"][21] = {dm=2,d=6,bm=1,t=1,f=true,m=9};
	aHackingCritMatrix["Ankle, inner"][22] = {dm=2,d=6,ls=true,f=true,m=9};
	aHackingCritMatrix["Ankle, inner"][23] = {dm=2,d=6,ls=true,m=10,f=true};
	aHackingCritMatrix["Ankle, inner"][24] = {dm=2,d=7,ls=true,m=10,f=true};
	
	aHackingCritMatrix["Ankle, outer"] = {};
	aHackingCritMatrix["Ankle, outer"][1] = {db=1};
	aHackingCritMatrix["Ankle, outer"][2] = {db=1};
	aHackingCritMatrix["Ankle, outer"][3] = {db=3};
	aHackingCritMatrix["Ankle, outer"][4] = {db=4,m=1};
	aHackingCritMatrix["Ankle, outer"][5] = {db=6,m=1};
	aHackingCritMatrix["Ankle, outer"][6] = {db=6,m=2,f=true};
	aHackingCritMatrix["Ankle, outer"][7] = {db=8,m=2,f=true};
	aHackingCritMatrix["Ankle, outer"][8] = {dm=2,d=1,m=3,f=true,t=1};
	aHackingCritMatrix["Ankle, outer"][9] = {dm=2,d=2,f=true,m=4,t=1};
	aHackingCritMatrix["Ankle, outer"][10] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Ankle, outer"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Ankle, outer"][12] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Ankle, outer"][13] = {dm=2,d=2,b=1,t=1,f=true,m=5};
	aHackingCritMatrix["Ankle, outer"][14] = {dm=2,d=3,t=1,mt=2,f=true,m=5};
	aHackingCritMatrix["Ankle, outer"][15] = {dm=2,d=3,t=1,mt=2,f=true,m=6};
	aHackingCritMatrix["Ankle, outer"][16] = {dm=2,d=3,t=1,mt=2,b=1,f=true,m=6};
	aHackingCritMatrix["Ankle, outer"][17] = {dm=2,d=4,t=1,mt=2,b=1,f=true,m=7};
	aHackingCritMatrix["Ankle, outer"][18] = {dm=2,d=4,t=1,mt=2,bf=1,f=true,m=7};
	aHackingCritMatrix["Ankle, outer"][19] = {dm=2,d=5,t=1,mt=2,bf=1,f=true,m=8};
	aHackingCritMatrix["Ankle, outer"][20] = {dm=2,t=1,mt=2,bm=1,f=true,m=8,d=6};
	aHackingCritMatrix["Ankle, outer"][21] = {dm=2,d=6,t=1,mt=2,bm=1,f=true,m=9};
	aHackingCritMatrix["Ankle, outer"][22] = {dm=2,d=6,ls=true,f=true,m=9};
	aHackingCritMatrix["Ankle, outer"][23] = {dm=2,d=6,ls=true,f=true,m=10};
	aHackingCritMatrix["Ankle, outer"][24] = {dm=2,d=7,ls=true,f=true,m=10};
	
	aHackingCritMatrix["Ankle, upper/Achilles"] = {};
	aHackingCritMatrix["Ankle, upper/Achilles"][1] = {db=1};
	aHackingCritMatrix["Ankle, upper/Achilles"][2] = {db=1};
	aHackingCritMatrix["Ankle, upper/Achilles"][3] = {db=3};
	aHackingCritMatrix["Ankle, upper/Achilles"][4] = {db=3};
	aHackingCritMatrix["Ankle, upper/Achilles"][5] = {db=4,m=1};
	aHackingCritMatrix["Ankle, upper/Achilles"][6] = {db=4,m=1};
	aHackingCritMatrix["Ankle, upper/Achilles"][7] = {db=6,m=1};
	aHackingCritMatrix["Ankle, upper/Achilles"][8] = {db=6,m=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][9] = {db=8,m=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][10] = {dm=2,d=1,m=3};
	aHackingCritMatrix["Ankle, upper/Achilles"][11] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Ankle, upper/Achilles"][12] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Ankle, upper/Achilles"][13] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Ankle, upper/Achilles"][14] = {dm=2,d=2,f=true,mt=1,m=5};
	aHackingCritMatrix["Ankle, upper/Achilles"][15] = {dm=2,d=2,t=2,f=true,m=6};
	aHackingCritMatrix["Ankle, upper/Achilles"][16] = {dm=2,d=3,mt=1,f=true,m=6,t=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][17] = {dm=2,d=3,mt=1,b=1,f=true,t=2,m=7};
	aHackingCritMatrix["Ankle, upper/Achilles"][18] = {dm=2,d=4,mt=1,b=1,f=true,m=8,t=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][19] = {dm=2,d=5,mt=1,bf=1,t=2,f=true,m=9};
	aHackingCritMatrix["Ankle, upper/Achilles"][20] = {dm=2,d=5,mt=1,bf=2,f=true,m=10,t=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][21] = {dm=2,mt=1,bm=2,f=true,m=10,d=6,t=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][22] = {dm=2,d=6,mt=1,bm=2,f=true,m=10,t=2};
	aHackingCritMatrix["Ankle, upper/Achilles"][23] = {dm=2,ls=true,f=true,d=6,m=10};
	aHackingCritMatrix["Ankle, upper/Achilles"][24] = {dm=2,d=6,ls=true,f=true,m=10};
	
	aHackingCritMatrix["Shin"] = {};
	aHackingCritMatrix["Shin"][1] = {db=1};
	aHackingCritMatrix["Shin"][2] = {db=1};
	aHackingCritMatrix["Shin"][3] = {db=3};
	aHackingCritMatrix["Shin"][4] = {db=3};
	aHackingCritMatrix["Shin"][5] = {db=4};
	aHackingCritMatrix["Shin"][6] = {db=4};
	aHackingCritMatrix["Shin"][7] = {db=6,m=1};
	aHackingCritMatrix["Shin"][8] = {db=6,m=1};
	aHackingCritMatrix["Shin"][9] = {db=8,m=1};
	aHackingCritMatrix["Shin"][10] = {db=8,d=1,m=1};
	aHackingCritMatrix["Shin"][11] = {dm=2,d=2,f=true,m=1};
	aHackingCritMatrix["Shin"][12] = {dm=2,d=2,f=true,m=2};
	aHackingCritMatrix["Shin"][13] = {dm=2,d=2,f=true,m=2};
	aHackingCritMatrix["Shin"][14] = {dm=2,d=2,f=true,m=2};
	aHackingCritMatrix["Shin"][15] = {dm=2,d=2,t=1,f=true,m=2};
	aHackingCritMatrix["Shin"][16] = {dm=2,d=3,t=1,f=true,m=2};
	aHackingCritMatrix["Shin"][17] = {dm=2,d=3,t=1,b=1,f=true,m=3};
	aHackingCritMatrix["Shin"][18] = {dm=2,d=4,t=1,f=true,m=3};
	aHackingCritMatrix["Shin"][19] = {dm=2,d=5,t=1,b=1,f=true,m=3};
	aHackingCritMatrix["Shin"][20] = {dm=2,d=5,t=1,mt=2,b=2,f=true,m=3};
	aHackingCritMatrix["Shin"][21] = {dm=2,t=1,b=2,f=true,m=4,d=6};
	aHackingCritMatrix["Shin"][22] = {dm=2,d=6,t=1,bf=2,mt=2,f=true,m=4};
	aHackingCritMatrix["Shin"][23] = {dm=2,ls=true,f=true,d=6,m=10};
	aHackingCritMatrix["Shin"][24] = {dm=2,d=6,ls=true,f=true,m=10};

	aHackingCritMatrix["Calf"] = {};
	aHackingCritMatrix["Calf"][1] = {db=1};
	aHackingCritMatrix["Calf"][2] = {db=1};
	aHackingCritMatrix["Calf"][3] = {db=3};
	aHackingCritMatrix["Calf"][4] = {db=3};
	aHackingCritMatrix["Calf"][5] = {db=4,m=1};
	aHackingCritMatrix["Calf"][6] = {db=4,m=1};
	aHackingCritMatrix["Calf"][7] = {db=6,m=1};
	aHackingCritMatrix["Calf"][8] = {db=6,m=2};
	aHackingCritMatrix["Calf"][9] = {db=8,m=2};
	aHackingCritMatrix["Calf"][10] = {dm=2,d=1,m=3};
	aHackingCritMatrix["Calf"][11] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Calf"][12] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Calf"][13] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Calf"][14] = {dm=2,d=2,f=true,mt=1,m=5};
	aHackingCritMatrix["Calf"][15] = {dm=2,d=2,mt=1,f=true,m=5};
	aHackingCritMatrix["Calf"][16] = {dm=2,d=3,f=true,mt=1,m=6};
	aHackingCritMatrix["Calf"][17] = {dm=2,d=3,t=2,mt=1,f=true,m=6};
	aHackingCritMatrix["Calf"][18] = {dm=2,d=4,t=2,f=true,mt=1,m=6};
	aHackingCritMatrix["Calf"][19] = {dm=2,d=5,b=1,mt=1,f=true,m=6};
	aHackingCritMatrix["Calf"][20] = {dm=2,d=5,t=2,mt=1,f=true,m=7};
	aHackingCritMatrix["Calf"][21] = {dm=2,b=2,f=true,mt=1,d=6,m=7};
	aHackingCritMatrix["Calf"][22] = {dm=2,d=6,t=2,mt=1,bf=2,f=true,m=8};
	aHackingCritMatrix["Calf"][23] = {dm=2,ls=true,d=6,m=10};
	aHackingCritMatrix["Calf"][24] = {dm=2,d=6,ls=true,f=true,m=10};

	aHackingCritMatrix["Knee"] = {};
	aHackingCritMatrix["Knee"][1] = {db=1};
	aHackingCritMatrix["Knee"][2] = {db=1};
	aHackingCritMatrix["Knee"][3] = {db=3};
	aHackingCritMatrix["Knee"][4] = {db=4,m=1};
	aHackingCritMatrix["Knee"][5] = {db=6,m=1};
	aHackingCritMatrix["Knee"][6] = {db=6,m=2,f=true};
	aHackingCritMatrix["Knee"][7] = {db=8,m=2,f=true};
	aHackingCritMatrix["Knee"][8] = {dm=2,d=1,m=3,f=true,mt=1};
	aHackingCritMatrix["Knee"][9] = {dm=2,d=2,f=true,m=4,t=1};
	aHackingCritMatrix["Knee"][10] = {dm=2,d=2,f=true,m=5,mt=1};
	aHackingCritMatrix["Knee"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Knee"][12] = {dm=2,d=2,f=true,m=5,t=1};
	aHackingCritMatrix["Knee"][13] = {dm=2,d=2,mt=1,t=1,f=true,m=5};
	aHackingCritMatrix["Knee"][14] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Knee"][15] = {dm=2,d=3,t=1,b=1,f=true,m=5};
	aHackingCritMatrix["Knee"][16] = {dm=2,d=3,t=1,b=1,f=true,m=6};
	aHackingCritMatrix["Knee"][17] = {dm=2,d=4,t=1,b=2,f=true,m=7};
	aHackingCritMatrix["Knee"][18] = {dm=2,d=5,t=1,b=2,f=true,m=7};
	aHackingCritMatrix["Knee"][19] = {dm=2,d=5,t=1,bf=3,f=true,m=8};
	aHackingCritMatrix["Knee"][20] = {dm=2,bm=3,t=1,f=true,m=8,d=6};
	aHackingCritMatrix["Knee"][21] = {dm=2,d=6,t=1,bm=3,f=true,m=9};
	aHackingCritMatrix["Knee"][22] = {dm=2,d=6,ls=true,f=true,m=10};
	aHackingCritMatrix["Knee"][23] = {dm=2,d=6,ls=true,f=true,m=10};
	aHackingCritMatrix["Knee"][24] = {dm=2,d=7,ls=true,f=true,m=10};
		
	aHackingCritMatrix["Knee, back"] = {};
	aHackingCritMatrix["Knee, back"][1] = {db=1};
	aHackingCritMatrix["Knee, back"][2] = {db=1};
	aHackingCritMatrix["Knee, back"][3] = {db=3};
	aHackingCritMatrix["Knee, back"][4] = {db=4};
	aHackingCritMatrix["Knee, back"][5] = {db=6,m=1};
	aHackingCritMatrix["Knee, back"][6] = {db=6,m=1};
	aHackingCritMatrix["Knee, back"][7] = {db=8,m=2};
	aHackingCritMatrix["Knee, back"][8] = {dm=2,d=1,m=2};
	aHackingCritMatrix["Knee, back"][9] = {dm=2,d=2,f=true,m=3};
	aHackingCritMatrix["Knee, back"][10] = {dm=2,d=2,f=true,m=3};
	aHackingCritMatrix["Knee, back"][11] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Knee, back"][12] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Knee, back"][13] = {dm=2,d=2,t=1,f=true,m=5};
	aHackingCritMatrix["Knee, back"][14] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Knee, back"][15] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Knee, back"][16] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Knee, back"][17] = {dm=2,d=4,t=1,f=true,m=6};
	aHackingCritMatrix["Knee, back"][18] = {dm=2,d=5,b=1,t=1,f=true,m=6};
	aHackingCritMatrix["Knee, back"][19] = {dm=2,d=5,b=1,t=1,f=tue,m=7};
	aHackingCritMatrix["Knee, back"][20] = {dm=2,bf=1,t=1,f=true,m=7,d=6};
	aHackingCritMatrix["Knee, back"][21] = {dm=2,d=6, bf=1,t=1,f=true,m=8};
	aHackingCritMatrix["Knee, back"][22] = {dm=2,bm=1,t=1,f=true,d=6,m=8};
	aHackingCritMatrix["Knee, back"][23] = {dm=2,d=6,ls=true,m=10,u=true};
	aHackingCritMatrix["Knee, back"][24] = {dm=2,d=7,ls=true,m=10,u=true};
	
	aHackingCritMatrix["Hamstring"] = {};
	aHackingCritMatrix["Hamstring"][1] = {db=1};
	aHackingCritMatrix["Hamstring"][2] = {db=3};
	aHackingCritMatrix["Hamstring"][3] = {db=4,m=1};
	aHackingCritMatrix["Hamstring"][4] = {db=6,m=1};
	aHackingCritMatrix["Hamstring"][5] = {db=6,m=2};
	aHackingCritMatrix["Hamstring"][6] = {db=8,m=2};
	aHackingCritMatrix["Hamstring"][7] = {dm=2,d=1,m=3};
	aHackingCritMatrix["Hamstring"][8] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Hamstring"][9] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Hamstring"][10] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Hamstring"][11] = {dm=2,d=2,f=true,m=5,mt=1};
	aHackingCritMatrix["Hamstring"][12] = {dm=2,d=2,mt=1,f=true,m=5};
	aHackingCritMatrix["Hamstring"][13] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Hamstring"][14] = {dm=2,d=3,t=1,f=true,m=5};
	aHackingCritMatrix["Hamstring"][15] = {dm=2,d=3,t=1,f=true,m=6};
	aHackingCritMatrix["Hamstring"][16] = {dm=2,d=3,t=1,mt=1,f=true,m=6};
	aHackingCritMatrix["Hamstring"][17] = {dm=2,d=4,t=1,f=true,m=6};
	aHackingCritMatrix["Hamstring"][18] = {dm=2,d=5,t=1,f=true,m=7};
	aHackingCritMatrix["Hamstring"][19] = {dm=2,b=1,mt=1,t=1,f=true,m=7,d=6};
	aHackingCritMatrix["Hamstring"][20] = {dm=2,d=6,t=1,mt=1,bm=1,f=true,m=8};
	aHackingCritMatrix["Hamstring"][21] = {dm=2,d=6,ls=true,m=10,u=true};
	aHackingCritMatrix["Hamstring"][22] = {dm=2,d=6,ls=true,m=10,u=true};
	aHackingCritMatrix["Hamstring"][23] = {dm=2,d=7,ls=true,m=10,u=true};
	aHackingCritMatrix["Hamstring"][24] = {dm=3,d=8,ls=true,m=10,u=true};
	
	aHackingCritMatrix["Thigh"] = {};
	aHackingCritMatrix["Thigh"][1] = {db=1};
	aHackingCritMatrix["Thigh"][2] = {db=3};
	aHackingCritMatrix["Thigh"][3] = {db=4,m=1};
	aHackingCritMatrix["Thigh"][4] = {db=6,m=1};
	aHackingCritMatrix["Thigh"][5] = {db=6,m=2};
	aHackingCritMatrix["Thigh"][6] = {db=8,m=2};
	aHackingCritMatrix["Thigh"][7] = {dm=2,d=1,m=3};
	aHackingCritMatrix["Thigh"][8] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Thigh"][9] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Thigh"][10] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Thigh"][11] = {dm=2,d=2,f=true,m=5};
	aHackingCritMatrix["Thigh"][12] = {dm=2,d=2,mt=2,f=true,m=5};
	aHackingCritMatrix["Thigh"][13] = {dm=2,d=3,t=1,f=true,m=5,mt=2};
	aHackingCritMatrix["Thigh"][14] = {dm=2,d=3,mt=2,f=true,m=5};
	aHackingCritMatrix["Thigh"][15] = {dm=2,d=3,b=1,f=true,m=6,mt=3};
	aHackingCritMatrix["Thigh"][16] = {dm=2,d=3,bf=1,mt=3,f=true,m=6};
	aHackingCritMatrix["Thigh"][17] = {dm=2,d=4,b=1,f=true,m=6,mt=3};
	aHackingCritMatrix["Thigh"][18] = {dm=2,d=5,mt=4,f=true,m=7};
	aHackingCritMatrix["Thigh"][19] = {dm=2,bf=1,f=true,m=7,d=6,mt=4};
	aHackingCritMatrix["Thigh"][20] = {dm=2,d=6,bm=1,f=true,m=8,mt=5};
	aHackingCritMatrix["Thigh"][21] = {dm=2,ls=true,pb=true,f=true,d=6,m=10};
	aHackingCritMatrix["Thigh"][22] = {dm=2,d=6,ls=true,m=10,u=true};
	aHackingCritMatrix["Thigh"][23] = {dm=2,d=7,ls=true,m=10,u=true};
	aHackingCritMatrix["Thigh"][24] = {dm=3,d=8,ls=true,m=10,u=true};
	
	aHackingCritMatrix["Hip"] = {};
	aHackingCritMatrix["Hip"][1] = {db=1};
	aHackingCritMatrix["Hip"][2] = {db=3};
	aHackingCritMatrix["Hip"][3] = {db=4,m=1};
	aHackingCritMatrix["Hip"][4] = {db=6,m=1};
	aHackingCritMatrix["Hip"][5] = {db=8,m=2};
	aHackingCritMatrix["Hip"][6] = {dm=2,m=2};
	aHackingCritMatrix["Hip"][7] = {dm=2,d=1,m=3};
	aHackingCritMatrix["Hip"][8] = {dm=2,d=2,f=true,m=4};
	aHackingCritMatrix["Hip"][9] = {dm=2,d=2,b=1,f=true,m=5};
	aHackingCritMatrix["Hip"][10] = {dm=2,d=2,b=1,f=true,m=5};
	aHackingCritMatrix["Hip"][11] = {dm=3,d=2,f=true,b=1,m=5};
	aHackingCritMatrix["Hip"][12] = {dm=3,d=2,bm=1,f=true,m=5};
	aHackingCritMatrix["Hip"][13] = {dm=3,d=3,bf=2,f=true,m=5};
	aHackingCritMatrix["Hip"][14] = {dm=3,d=3,b=2,f=true,m=5}
	aHackingCritMatrix["Hip"][15] = {dm=3,d=3,b=2,v=1,f=true,m=6};
	aHackingCritMatrix["Hip"][16] = {dm=3,d=3,bm=2,f=true,m=6};
	aHackingCritMatrix["Hip"][17] = {dm=3,d=5,b=3,f=true,m=6};
	aHackingCritMatrix["Hip"][18] = {dm=3,d=6,b=3,f=true,m=7};
	aHackingCritMatrix["Hip"][19] = {dm=3,bm=3,v=1,f=true,m=7,d=7};
	aHackingCritMatrix["Hip"][20] = {dm=3,bm=3,v=1,f=true,m=8,d=7};
	aHackingCritMatrix["Hip"][21] = {dm=3,bs=4,v=2,f=true,m=8,d=8};
	aHackingCritMatrix["Hip"][22] = {dm=3,bs=4,v=2,m=9,u=true,d=8};
	aHackingCritMatrix["Hip"][23] = {dm=4,bs=4,v=2,m=9,u=true,d=9};
	aHackingCritMatrix["Hip"][24] = {dm=4,bs=4,v=2,m=10,u=true,d=9};

	aHackingCritMatrix["Groin"] = {};
	aHackingCritMatrix["Groin"][1] = {db=1,f=true,h=1};
	aHackingCritMatrix["Groin"][2] = {db=3,f=true,h=1};
	aHackingCritMatrix["Groin"][3] = {db=4,f=true,h=2};
	aHackingCritMatrix["Groin"][4] = {db=4,m=1,f=true,h=2};
	aHackingCritMatrix["Groin"][5] = {db=6,m=1,f=true,h=2};
	aHackingCritMatrix["Groin"][6] = {db=6,m=1,f=true,h=3};
	aHackingCritMatrix["Groin"][7] = {db=8,m=2,f=true,h=3};
	aHackingCritMatrix["Groin"][8] = {db=8,m=2,f=true,h=4};
	aHackingCritMatrix["Groin"][9] = {dm=2,m=2,f=true,h=4};
	aHackingCritMatrix["Groin"][10] = {dm=2,m=3,f=true,h=4};
	aHackingCritMatrix["Groin"][11] = {dm=2,m=3,f=true,h=5};
	aHackingCritMatrix["Groin"][12] = {dm=3,m=3,f=true,h=5};
	aHackingCritMatrix["Groin"][13] = {dm=3,m=4,f=true,h=5};
	aHackingCritMatrix["Groin"][14] = {dm=3,m=4,f=true,h=6};
	aHackingCritMatrix["Groin"][15] = {dm=3,m=4,f=true,h=6,v=1};
	aHackingCritMatrix["Groin"][16] = {dm=3,m=4,f=true,h=6,v=1};
	aHackingCritMatrix["Groin"][17] = {dm=3,m=4,f=true,h=7,v=1};
	aHackingCritMatrix["Groin"][18] = {dm=3,m=4,f=true,h=8,v=2};
	aHackingCritMatrix["Groin"][19] = {dm=3,m=4,f=true,h=9,v=2};
	aHackingCritMatrix["Groin"][20] = {dm=3,m=5,f=true,h=10,v=2};
	aHackingCritMatrix["Groin"][21] = {dm=3,m=5,f=true,h=9,v=2,b=1};
	aHackingCritMatrix["Groin"][22] = {dm=3,m=5,f=true,h=10,v=2,bm=1};
	aHackingCritMatrix["Groin"][23] = {dm=3,m=5,f=true,h=10,v=2,bf=1};
	aHackingCritMatrix["Groin"][24] = {dm=3,m=5,f=true,h=10,v=2,bs=1};
	
	aHackingCritMatrix["Buttock"] = {};
	aHackingCritMatrix["Buttock"][1] = {db=1};
	aHackingCritMatrix["Buttock"][2] = {db=3};
	aHackingCritMatrix["Buttock"][3] = {db=4};
	aHackingCritMatrix["Buttock"][4] = {db=6};
	aHackingCritMatrix["Buttock"][5] = {db=8};
	aHackingCritMatrix["Buttock"][6] = {dm=2};
	aHackingCritMatrix["Buttock"][7] = {dm=2,m=1};
	aHackingCritMatrix["Buttock"][8] = {dm=1,m=1};
	aHackingCritMatrix["Buttock"][9] = {dm=2,m=2};
	aHackingCritMatrix["Buttock"][10] = {dm=2,m=2,mt=1};
	aHackingCritMatrix["Buttock"][11] = {dm=3,m=3};
	aHackingCritMatrix["Buttock"][12] = {dm=3,m=3,d=1};
	aHackingCritMatrix["Buttock"][13] = {dm=3,m=3,d=1,b=1};
	aHackingCritMatrix["Buttock"][14] = {dm=3,m=3,d=2,mt=1};
	aHackingCritMatrix["Buttock"][15] = {dm=3,m=3,d=2,b=1,f=true};
	aHackingCritMatrix["Buttock"][16] = {dm=3,m=3,d=2,mt=1,f=true,ib=true};
	aHackingCritMatrix["Buttock"][17] = {dm=3,m=3,d=2,mt=1,f=true,ib=true};
	aHackingCritMatrix["Buttock"][18] = {dm=3,m=4,d=2,b=2,f=true};
	aHackingCritMatrix["Buttock"][19] = {dm=3,m=5,d=3,b=2,f=true};
	aHackingCritMatrix["Buttock"][20] = {dm=3,m=5,d=3,b=2,f=true};
	aHackingCritMatrix["Buttock"][21] = {dm=3,m=5,d=4,b=3,f=true,mt=1};
	aHackingCritMatrix["Buttock"][22] = {dm=3,m=6,d=5,bm=3,f=true,mt=1};
	aHackingCritMatrix["Buttock"][23] = {dm=4,m=7,d=6,bs=3,f=true};
	aHackingCritMatrix["Buttock"][24] = {dm=4,m=8,d=7,bs=3,f=true,mt=1};

	aHackingCritMatrix["Abdomen, Lower"] = {};
	aHackingCritMatrix["Abdomen, Lower"][1] = {db=3};
	aHackingCritMatrix["Abdomen, Lower"][2] = {db=4};
	aHackingCritMatrix["Abdomen, Lower"][3] = {db=6};
	aHackingCritMatrix["Abdomen, Lower"][4] = {db=8};
	aHackingCritMatrix["Abdomen, Lower"][5] = {dm=2};
	aHackingCritMatrix["Abdomen, Lower"][6] = {dm=2, ws=true};
	aHackingCritMatrix["Abdomen, Lower"][7] = {dm=2,ib=true};
	aHackingCritMatrix["Abdomen, Lower"][8] = {dm=2,ib=true,f=true};
	aHackingCritMatrix["Abdomen, Lower"][9] = {dm=3,ws=true,v=1};
	aHackingCritMatrix["Abdomen, Lower"][10] = {dm=3,w=true,ib=true,f=true};
	aHackingCritMatrix["Abdomen, Lower"][11] = {dm=3,w=true,v=1,f=true};
	aHackingCritMatrix["Abdomen, Lower"][12] = {dm=3,mt=1,w=true,ib=true,f=true};
	aHackingCritMatrix["Abdomen, Lower"][13] = {dm=3,mt=1,v=2,w=true,f=true};
	aHackingCritMatrix["Abdomen, Lower"][14] = {dm=3,v=2,f=true,mt=1};
	aHackingCritMatrix["Abdomen, Lower"][15] = {dm=3,mt=1,v=2,f=true};
	aHackingCritMatrix["Abdomen, Lower"][16] = {dm=3,a=3,v=3,f=true};
	aHackingCritMatrix["Abdomen, Lower"][17] = {dm=3,a=2,v=3,f=true,mt=2};
	aHackingCritMatrix["Abdomen, Lower"][18] = {dm=3,a=3,v=3,f=true};
	aHackingCritMatrix["Abdomen, Lower"][19] = {dm=3,a=3,v=3,f=true};
	aHackingCritMatrix["Abdomen, Lower"][20] = {dm=3,a=3,mt=2,v=4,f=true};
	aHackingCritMatrix["Abdomen, Lower"][21] = {dm=3,u=true,v=4,f=true};
	aHackingCritMatrix["Abdomen, Lower"][22] = {dm=3,b=1,v=4,u=true,f=true};
	aHackingCritMatrix["Abdomen, Lower"][23] = {dm=4,b=2,v=4,mt=2,u=true};
	aHackingCritMatrix["Abdomen, Lower"][24] = {dead="cut in twain"};

	aHackingCritMatrix["Side, lower"] = {};
	aHackingCritMatrix["Side, lower"][1] = {db=1};
	aHackingCritMatrix["Side, lower"][2] = {db=3};
	aHackingCritMatrix["Side, lower"][3] = {db=4};
	aHackingCritMatrix["Side, lower"][4] = {db=6};
	aHackingCritMatrix["Side, lower"][5] = {db=8};
	aHackingCritMatrix["Side, lower"][6] = {dm=2};
	aHackingCritMatrix["Side, lower"][7] = {dm=2,a=1};
	aHackingCritMatrix["Side, lower"][8] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Side, lower"][9] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Side, lower"][10] = {dm=3,a=2,ws=true,mt=1};
	aHackingCritMatrix["Side, lower"][11] = {dm=3,a=2,ws=true,mt=1};
	aHackingCritMatrix["Side, lower"][12] = {dm=3,a=2,ws=true};
	aHackingCritMatrix["Side, lower"][13] = {dm=3,a=2,w=true};
	aHackingCritMatrix["Side, lower"][14] = {dm=3,a=2,mt=1,w=true};
	aHackingCritMatrix["Side, lower"][15] = {dm=3,a=2,f=true};
	aHackingCritMatrix["Side, lower"][16] = {dm=3,a=2,mt=1,f=true};
	aHackingCritMatrix["Side, lower"][17] = {dm=3,a=3,mt=2,f=true};
	aHackingCritMatrix["Side, lower"][18] = {dm=3,a=3,ib=true,mt=2,f=true};
	aHackingCritMatrix["Side, lower"][19] = {dm=3,a=3,mt=2,v=1,f=true};
	aHackingCritMatrix["Side, lower"][20] = {dm=3,a=4,b=1,f=true};
	aHackingCritMatrix["Side, lower"][21] = {dm=3,u=true,b=2,mt=2};
	aHackingCritMatrix["Side, lower"][22] = {dm=3,b=2,v=2,u=true};
	aHackingCritMatrix["Side, lower"][23] = {dm=4,b=2,v=2,mt=2,u=true};
	aHackingCritMatrix["Side, lower"][24] = {dead="cut in twain"};
	
	aHackingCritMatrix["Abdomen, upper"] = {};
	aHackingCritMatrix["Abdomen, upper"][1] = {db=3};
	aHackingCritMatrix["Abdomen, upper"][2] = {db=4};
	aHackingCritMatrix["Abdomen, upper"][3] = {db=6};
	aHackingCritMatrix["Abdomen, upper"][4] = {db=8};
	aHackingCritMatrix["Abdomen, upper"][5] = {dm=2};
	aHackingCritMatrix["Abdomen, upper"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Abdomen, upper"][7] = {dm=2,ib=true};
	aHackingCritMatrix["Abdomen, upper"][8] = {dm=2,ib=true,f=true};
	aHackingCritMatrix["Abdomen, upper"][9] = {dm=3,ws=true,v=1};
	aHackingCritMatrix["Abdomen, upper"][10] = {dm=3,w=true,ib=true,f=true};
	aHackingCritMatrix["Abdomen, upper"][11] = {dm=3,w=true,v=1,f=true};
	aHackingCritMatrix["Abdomen, upper"][12] = {dm=3,mt=1,w=true,ib=true,f=true};
	aHackingCritMatrix["Abdomen, upper"][13] = {dm=3,mt=1,v=2,w=true,f=true};
	aHackingCritMatrix["Abdomen, upper"][14] = {dm=3,v=2,mt=1,f=true};
	aHackingCritMatrix["Abdomen, upper"][15] = {dm=3,mt=2,v=2,f=true};
	aHackingCritMatrix["Abdomen, upper"][16] = {dm=3,a=1,v=2,f=true};
	aHackingCritMatrix["Abdomen, upper"][17] = {dm=3,a=2,v=3,f=true,mt=2};
	aHackingCritMatrix["Abdomen, upper"][18] = {dm=3,a=3,v=3,f=true};
	aHackingCritMatrix["Abdomen, upper"][19] = {dm=3,a=3,v=3,f=true};
	aHackingCritMatrix["Abdomen, upper"][20] = {dm=3,a=3,mt=2,v=3,f=true};
	aHackingCritMatrix["Abdomen, upper"][21] = {dm=3,u=true,v=3,f=true};
	aHackingCritMatrix["Abdomen, upper"][22] = {dm=3,b=1,v=3,u=true};
	aHackingCritMatrix["Abdomen, upper"][23] = {dm=4,b=1,v=3,mt=2,u=true};
	aHackingCritMatrix["Abdomen, upper"][24] = {dead="cut in twain"};

	aHackingCritMatrix["Back, small of"] = {};
	aHackingCritMatrix["Back, small of"][1] = {db=3};
	aHackingCritMatrix["Back, small of"][2] = {db=4};
	aHackingCritMatrix["Back, small of"][3] = {db=6};
	aHackingCritMatrix["Back, small of"][4] = {db=8};
	aHackingCritMatrix["Back, small of"][5] = {dm=2};
	aHackingCritMatrix["Back, small of"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Back, small of"][7] = {dm=2,ib=true};
	aHackingCritMatrix["Back, small of"][8] = {dm=2,w=true,ib=true};
	aHackingCritMatrix["Back, small of"][9] = {dm=2,w=true,mt=1};
	aHackingCritMatrix["Back, small of"][10] = {dm=3,w=true,ib=true};
	aHackingCritMatrix["Back, small of"][11] = {dm=3,w=true,mt=1,ib=true};
	aHackingCritMatrix["Back, small of"][12] = {dm=3,mt=1,w=true,ib=true};
	aHackingCritMatrix["Back, small of"][13] = {dm=3,mt=1,v=1,w=true};
	aHackingCritMatrix["Back, small of"][14] = {dm=3,v=1,mt=1};
	aHackingCritMatrix["Back, small of"][15] = {dm=3,mt=2,v=1};
	aHackingCritMatrix["Back, small of"][16] = {dm=3,b=1,v=1};
	aHackingCritMatrix["Back, small of"][17] = {dm=3,s=5,b=1,v=2,f=true,mt=2};
	aHackingCritMatrix["Back, small of"][18] = {dm=3,bf=1,v=2,f=true};
	aHackingCritMatrix["Back, small of"][19] = {dm=3,bm=1,v=2,f=true};
	aHackingCritMatrix["Back, small of"][20] = {dm=3,bm=1,mt=2,v=2,f=true};
	aHackingCritMatrix["Back, small of"][21] = {dm=3,bs=1,u=true,v=2};
	aHackingCritMatrix["Back, small of"][22] = {dm=3,bs=1,v=2,u=true};
	aHackingCritMatrix["Back, small of"][23] = {dm=4,bs=1,v=2,mt=2,u=true};
	aHackingCritMatrix["Back, small of"][24] = {dead="cut in twain"};

	aHackingCritMatrix["Back, lower"] = {};
	aHackingCritMatrix["Back, lower"][1] = {db=3};
	aHackingCritMatrix["Back, lower"][2] = {db=4};
	aHackingCritMatrix["Back, lower"][3] = {db=6};
	aHackingCritMatrix["Back, lower"][4] = {db=8};
	aHackingCritMatrix["Back, lower"][5] = {dm=2};
	aHackingCritMatrix["Back, lower"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Back, lower"][7] = {dm=2,ib=true};
	aHackingCritMatrix["Back, lower"][8] = {dm=3,ws=true,b=1};
	aHackingCritMatrix["Back, lower"][9] = {dm=3,w=true,ib=true,f=1};
	aHackingCritMatrix["Back, lower"][10] = {dm=3,w=true,b=1,f=true};
	aHackingCritMatrix["Back, lower"][11] = {dm=3,w=true,b=1,f=true};
	aHackingCritMatrix["Back, lower"][12] = {dm=3,mt=1,w=true,ib=true,f=true};
	aHackingCritMatrix["Back, lower"][13] = {dm=3,mt=1,b=1,w=true,f=true};
	aHackingCritMatrix["Back, lower"][14] = {dm=3,b=1,mt=1,f=true};
	aHackingCritMatrix["Back, lower"][15] = {dm=3,b=1,v=1,f=true};
	aHackingCritMatrix["Back, lower"][16] = {dm=3,a=1,v=1,f=true};
	aHackingCritMatrix["Back, lower"][17] = {dm=3,a=2,v=1,f=true,b=1};
	aHackingCritMatrix["Back, lower"][18] = {dm=3,a=3,v=2,b=1,f=true};
	aHackingCritMatrix["Back, lower"][19] = {dm=3,a=3,v=2,f=true};
	aHackingCritMatrix["Back, lower"][20] = {dm=3,a=3,b=1,v=2,f=true};
	aHackingCritMatrix["Back, lower"][21] = {dm=3,u=true,b=1,mt=1,v=2};
	aHackingCritMatrix["Back, lower"][22] = {dm=3,b=1,v=2,u=true};
	aHackingCritMatrix["Back, lower"][23] = {dm=4,b=1,v=2,mt=1,u=true};
	aHackingCritMatrix["Back, lower"][24] = {dead="cut in twain"};

	aHackingCritMatrix["Chest"] = {};
	aHackingCritMatrix["Chest"][1] = {db=3};
	aHackingCritMatrix["Chest"][2] = {db=4};
	aHackingCritMatrix["Chest"][3] = {db=6};
	aHackingCritMatrix["Chest"][4] = {db=8};
	aHackingCritMatrix["Chest"][5] = {dm=2};
	aHackingCritMatrix["Chest"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Chest"][7] = {dm=2,ws=true,b=1};
	aHackingCritMatrix["Chest"][8] = {dm=2,w=true,b=1};
	aHackingCritMatrix["Chest"][9] = {dm=2,w=true,b=1,ib=true};
	aHackingCritMatrix["Chest"][10] = {dm=3,w=true,b=1};
	aHackingCritMatrix["Chest"][11] = {dm=3,w=true,bm=2};
	aHackingCritMatrix["Chest"][12] = {dm=3,bf=2,w=true,ib=true};
	aHackingCritMatrix["Chest"][13] = {dm=3,mt=1,b=2,w=true};
	aHackingCritMatrix["Chest"][14] = {dm=3,v=1,b=3};
	aHackingCritMatrix["Chest"][15] = {dm=3,mt=2,v=1,b=3};
	aHackingCritMatrix["Chest"][16] = {dm=3,bf=3,v=1};
	aHackingCritMatrix["Chest"][17] = {dm=3,s=5,b=3,b=2,f=true,mt=2};
	aHackingCritMatrix["Chest"][18] = {dm=3,bf=4,v=2,f=true};
	aHackingCritMatrix["Chest"][19] = {dm=3,bm=4,v=2,f=true};
	aHackingCritMatrix["Chest"][20] = {dm=3,bm=4,mt=3,v=3,f=true};
	aHackingCritMatrix["Chest"][21] = {dm=3,bs=4,u=true,v=3};
	aHackingCritMatrix["Chest"][22] = {dm=3,bs=4,v=3,u=true};
	aHackingCritMatrix["Chest"][23] = {dm=4,bs=4,v=3,mt=3,u=true};
	aHackingCritMatrix["Chest"][24] = {dead="cut in twain"};
	
	aHackingCritMatrix["Side, upper"] = {};
	aHackingCritMatrix["Side, upper"][1] = {db=3};
	aHackingCritMatrix["Side, upper"][2] = {db=4};
	aHackingCritMatrix["Side, upper"][3] = {db=6};
	aHackingCritMatrix["Side, upper"][4] = {db=8};
	aHackingCritMatrix["Side, upper"][5] = {dm=2};
	aHackingCritMatrix["Side, upper"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Side, upper"][7] = {dm=2,ws=true,b=1};
	aHackingCritMatrix["Side, upper"][8] = {dm=2,w=true,b=1};
	aHackingCritMatrix["Side, upper"][9] = {dm=2,w=true,b=1,ib=true};
	aHackingCritMatrix["Side, upper"][10] = {dm=3,w=true,b=1};
	aHackingCritMatrix["Side, upper"][11] = {dm=3,w=true,bm=1};
	aHackingCritMatrix["Side, upper"][12] = {dm=3,bm=1,w=true,v=1};
	aHackingCritMatrix["Side, upper"][13] = {dm=3,b=1,v=1,w=true};
	aHackingCritMatrix["Side, upper"][14] = {dm=3,v=1,b=1,w=true};
	aHackingCritMatrix["Side, upper"][15] = {dm=3,bm=2,v=1,w=true};
	aHackingCritMatrix["Side, upper"][16] = {dm=3,b=2,v=1,w};
	aHackingCritMatrix["Side, upper"][17] = {dm=3,s=5,b=2,v=1,f=true};
	aHackingCritMatrix["Side, upper"][18] = {dm=3,b=2,v=1,f=true};
	aHackingCritMatrix["Side, upper"][19] = {dm=3,bm=2,v=1,f=true};
	aHackingCritMatrix["Side, upper"][20] = {dm=3,bm=2,v=1,f=true};
	aHackingCritMatrix["Side, upper"][21] = {dm=3,bs=2,u=true,v=1};
	aHackingCritMatrix["Side, upper"][22] = {dm=3,bs=2,v=1,u=true};
	aHackingCritMatrix["Side, upper"][23] = {dm=4,bs=2,v=1,u=true};
	aHackingCritMatrix["Side, upper"][24] = {dead="cut in twain"};
	
	aHackingCritMatrix["Back, upper"] = {};
	aHackingCritMatrix["Back, upper"][1] = {db=3};
	aHackingCritMatrix["Back, upper"][2] = {db=4};
	aHackingCritMatrix["Back, upper"][3] = {db=6};
	aHackingCritMatrix["Back, upper"][4] = {db=8};
	aHackingCritMatrix["Back, upper"][5] = {dm=2};
	aHackingCritMatrix["Back, upper"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Back, upper"][7] = {dm=2,ws=true};
	aHackingCritMatrix["Back, upper"][8] = {dm=2,w=true};
	aHackingCritMatrix["Back, upper"][9] = {dm=2,w=true,mt=1};
	aHackingCritMatrix["Back, upper"][10] = {dm=3,w=true,mt=1};
	aHackingCritMatrix["Back, upper"][11] = {dm=3,w=true,f=true};
	aHackingCritMatrix["Back, upper"][12] = {dm=3,b=1,w=true};
	aHackingCritMatrix["Back, upper"][13] = {dm=3,mt=1,f=true,w=true};
	aHackingCritMatrix["Back, upper"][14] = {dm=3,f=true,b=2};
	aHackingCritMatrix["Back, upper"][15] = {dm=3,mt=1,f=true};
	aHackingCritMatrix["Back, upper"][16] = {dm=3,v=1};
	aHackingCritMatrix["Back, upper"][17] = {dm=3,s=5,b=3,f=true};
	aHackingCritMatrix["Back, upper"][18] = {dm=3,b=3,v=1};
	aHackingCritMatrix["Back, upper"][19] = {dm=3,bm=3,mt=2};
	aHackingCritMatrix["Back, upper"][20] = {dm=3,bm=4,v=1,mt=2};
	aHackingCritMatrix["Back, upper"][21] = {dm=3,bs=4,u=true,mt=2};
	aHackingCritMatrix["Back, upper"][22] = {dm=3,bs=4,v=1,mt=2,u=true};
	aHackingCritMatrix["Back, upper"][23] = {dm=4,bs=4,v=1,mt=2, u=true};
	aHackingCritMatrix["Back, upper"][24] = {dead="cut in twain"};
	
	aHackingCritMatrix["Back, upper middle"] = {};
	aHackingCritMatrix["Back, upper middle"][1] = {db=3};
	aHackingCritMatrix["Back, upper middle"][2] = {db=4};
	aHackingCritMatrix["Back, upper middle"][3] = {db=6};
	aHackingCritMatrix["Back, upper middle"][4] = {db=8};
	aHackingCritMatrix["Back, upper middle"][5] = {dm=2};
	aHackingCritMatrix["Back, upper middle"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Back, upper middle"][7] = {dm=2,ws=true};
	aHackingCritMatrix["Back, upper middle"][8] = {dm=2,w=true};
	aHackingCritMatrix["Back, upper middle"][9] = {dm=2,w=true,mt=1};
	aHackingCritMatrix["Back, upper middle"][10] = {dm=3,w=true,mt=1};
	aHackingCritMatrix["Back, upper middle"][11] = {dm=3,w=true,f=true};
	aHackingCritMatrix["Back, upper middle"][12] = {dm=3,b=1,w=true};
	aHackingCritMatrix["Back, upper middle"][13] = {dm=3,mt=1,f=true,w=true};
	aHackingCritMatrix["Back, upper middle"][14] = {dm=3,f=true,b=1};
	aHackingCritMatrix["Back, upper middle"][15] = {dm=3,mt=1,f=true};
	aHackingCritMatrix["Back, upper middle"][16] = {dm=3,v=1};
	aHackingCritMatrix["Back, upper middle"][17] = {dm=3,s=5,b=2,f=true,};
	aHackingCritMatrix["Back, upper middle"][18] = {dm=3,b=2,v=1};
	aHackingCritMatrix["Back, upper middle"][19] = {dm=3,bm=3,mt=1};
	aHackingCritMatrix["Back, upper middle"][20] = {dm=3,bm=3,v=1,mt=1};
	aHackingCritMatrix["Back, upper middle"][21] = {dm=3,bs=3,u=true,mt=1};
	aHackingCritMatrix["Back, upper middle"][22] = {dm=4,bs=1,v=1,mt=1,u=true};
	aHackingCritMatrix["Back, upper middle"][23] = {dm=4,p=true,v=1,u=true};
	aHackingCritMatrix["Back, upper middle"][24] = {dead="cut in twain"};
	
	aHackingCritMatrix["Armpit"] = {};
	aHackingCritMatrix["Armpit"][1] = {db=1};
	aHackingCritMatrix["Armpit"][2] = {db=3};
	aHackingCritMatrix["Armpit"][3] = {db=4};
	aHackingCritMatrix["Armpit"][4] = {db=6};
	aHackingCritMatrix["Armpit"][5] = {db=8};
	aHackingCritMatrix["Armpit"][6] = {dm=2,ws=true};
	aHackingCritMatrix["Armpit"][7] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Armpit"][8] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Armpit"][9] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Armpit"][10] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Armpit"][11] = {dm=2,a=3,d=1,ws=true};
	aHackingCritMatrix["Armpit"][12] = {dm=2,a=3,d=1,w=true};
	aHackingCritMatrix["Armpit"][13] = {dm=3,a=3,d=1,w=true};
	aHackingCritMatrix["Armpit"][14] = {dm=3,a=3,d=1,w=true};
	aHackingCritMatrix["Armpit"][15] = {dm=3,a=3,d=2,w=true};
	aHackingCritMatrix["Armpit"][16] = {dm=3,a=3,d=2,mt=1,w=true};
	aHackingCritMatrix["Armpit"][17] = {dm=3,a=3,d=2,t=2,w=true};
	aHackingCritMatrix["Armpit"][18] = {dm=3,a=3,d=2,t=2,mt=1,w=true};
	aHackingCritMatrix["Armpit"][19] = {dm=3,a=3,d=2,bf=1,mt=3};
	aHackingCritMatrix["Armpit"][20] = {dm=3,a=3,d=2,bm=2,mt=3};
	aHackingCritMatrix["Armpit"][21] = {dm=3,a=3,d=2,b=3,mt=3,t=2,w=true};
	aHackingCritMatrix["Armpit"][22] = {dm=3,a=3,d=2,bf=3,mt=3,t=2};
	aHackingCritMatrix["Armpit"][23] = {dm=3,a=3,d=2,bm=3,mt=3,t=2};
	aHackingCritMatrix["Armpit"][24] = {dm=3,a=3,d=2,ls=true,w=true};
	
	aHackingCritMatrix["Arm, upper outer"] = {};
	aHackingCritMatrix["Arm, upper outer"][1] = {db=1};
	aHackingCritMatrix["Arm, upper outer"][2] = {db=3};
	aHackingCritMatrix["Arm, upper outer"][3] = {db=4};
	aHackingCritMatrix["Arm, upper outer"][4] = {db=6};
	aHackingCritMatrix["Arm, upper outer"][5] = {db=6};
	aHackingCritMatrix["Arm, upper outer"][6] = {db=8};
	aHackingCritMatrix["Arm, upper outer"][7] = {dm=2};
	aHackingCritMatrix["Arm, upper outer"][8] = {dm=2,ws=true};
	aHackingCritMatrix["Arm, upper outer"][9] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Arm, upper outer"][10] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Arm, upper outer"][11] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Arm, upper outer"][12] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Arm, upper outer"][13] = {dm=2,a=3,ws=true};
	aHackingCritMatrix["Arm, upper outer"][14] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Arm, upper outer"][15] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Arm, upper outer"][16] = {dm=2,a=3,mt=1,w=true};
	aHackingCritMatrix["Arm, upper outer"][17] = {dm=2,a=3,b=1,w=true};
	aHackingCritMatrix["Arm, upper outer"][18] = {dm=2,a=3,mt=1,b=1,w=true};
	aHackingCritMatrix["Arm, upper outer"][19] = {dm=2,a=3,bf=1,mt=2};
	aHackingCritMatrix["Arm, upper outer"][20] = {dm=2,a=3,bm=1,mt=2};
	aHackingCritMatrix["Arm, upper outer"][21] = {dm=2,a=4,mt=2,bf=1};
	aHackingCritMatrix["Arm, upper outer"][22] = {dm=2,a=4,bm=1,mt=2};
	aHackingCritMatrix["Arm, upper outer"][23] = {dm=2,a=4,bm=1,mt=2};
	aHackingCritMatrix["Arm, upper outer"][24] = {dm=2,a=4,ls=true,w=true};
	
	aHackingCritMatrix["Arm, upper inner"] = {};
	aHackingCritMatrix["Arm, upper inner"][1] = {db=1};
	aHackingCritMatrix["Arm, upper inner"][2] = {db=3};
	aHackingCritMatrix["Arm, upper inner"][3] = {db=4};
	aHackingCritMatrix["Arm, upper inner"][4] = {db=6};
	aHackingCritMatrix["Arm, upper inner"][5] = {db=6};
	aHackingCritMatrix["Arm, upper inner"][6] = {db=8};
	aHackingCritMatrix["Arm, upper inner"][7] = {dm=2};
	aHackingCritMatrix["Arm, upper inner"][8] = {dm=2,ws=true};
	aHackingCritMatrix["Arm, upper inner"][9] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Arm, upper inner"][10] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Arm, upper inner"][11] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Arm, upper inner"][12] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Arm, upper inner"][13] = {dm=2,a=3,ws=true};
	aHackingCritMatrix["Arm, upper inner"][14] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Arm, upper inner"][15] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Arm, upper inner"][16] = {dm=2,a=3,mt=1,w=true};
	aHackingCritMatrix["Arm, upper inner"][17] = {dm=2,a=3,b=1,w=true};
	aHackingCritMatrix["Arm, upper inner"][18] = {dm=2,a=3,mt=1,b=1,w=true};
	aHackingCritMatrix["Arm, upper inner"][19] = {dm=2,a=3,bf=1,mt=2};
	aHackingCritMatrix["Arm, upper inner"][20] = {dm=2,a=3,bm=1,mt=2};
	aHackingCritMatrix["Arm, upper inner"][21] = {dm=2,a=4,mt=2,bf=1};
	aHackingCritMatrix["Arm, upper inner"][22] = {dm=2,a=4,bm=1,mt=2};
	aHackingCritMatrix["Arm, upper inner"][23] = {dm=2,a=4,bm=1,mt=2};
	aHackingCritMatrix["Arm, upper inner"][24] = {dm=2,a=4,ls=true,w=true};
	
	aHackingCritMatrix["Elbow"] = {};
	aHackingCritMatrix["Elbow"][1] = {db=1};
	aHackingCritMatrix["Elbow"][2] = {db=1};
	aHackingCritMatrix["Elbow"][3] = {db=3};
	aHackingCritMatrix["Elbow"][4] = {db=3};
	aHackingCritMatrix["Elbow"][5] = {db=4};
	aHackingCritMatrix["Elbow"][6] = {db=4,a=1,ws=true};
	aHackingCritMatrix["Elbow"][7] = {db=6,a=1,ws=true};
	aHackingCritMatrix["Elbow"][8] = {db=6,a=1,ws=true};
	aHackingCritMatrix["Elbow"][9] = {db=8,a=2,ws=true};
	aHackingCritMatrix["Elbow"][10] = {db=8,a=2,w=true,t=1};
	aHackingCritMatrix["Elbow"][11] = {dm=2,a=2,w=true,t=1};
	aHackingCritMatrix["Elbow"][12] = {dm=2,w=true,a=2,t=1};
	aHackingCritMatrix["Elbow"][13] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Elbow"][14] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Elbow"][15] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Elbow"][16] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Elbow"][17] = {dm=2,w=true,a=4,t=1};
	aHackingCritMatrix["Elbow"][18] = {dm=2,w=true,a=4,t=1,b=1};
	aHackingCritMatrix["Elbow"][19] = {dm=2,w=true,a=4,t=1,b=1};
	aHackingCritMatrix["Elbow"][20] = {dm=2,w=true,a=4,t=1,bf=1};
	aHackingCritMatrix["Elbow"][21] = {dm=2,t=true,a=5,t=1,bm=1};
	aHackingCritMatrix["Elbow"][22] = {dm=2,w=true,a=5,ls=true};
	aHackingCritMatrix["Elbow"][23] = {dm=2,w=true,a=5,ls=true};
	aHackingCritMatrix["Elbow"][24] = {dm=2,w=true,a=5,ls=true};
	
	aHackingCritMatrix["Inner joint"] = {};
	aHackingCritMatrix["Inner joint"][1] = {db=1};
	aHackingCritMatrix["Inner joint"][2] = {db=1};
	aHackingCritMatrix["Inner joint"][3] = {db=3};
	aHackingCritMatrix["Inner joint"][4] = {db=3};
	aHackingCritMatrix["Inner joint"][5] = {db=4};
	aHackingCritMatrix["Inner joint"][6] = {db=4,a=1};
	aHackingCritMatrix["Inner joint"][7] = {db=6,a=1};
	aHackingCritMatrix["Inner joint"][8] = {db=6,a=1,ws=true};
	aHackingCritMatrix["Inner joint"][9] = {db=8,a=2,ws=true};
	aHackingCritMatrix["Inner joint"][10] = {db=8,a=2,ws=true};
	aHackingCritMatrix["Inner joint"][11] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Inner joint"][12] = {dm=2,w=true,a=2,t=1};
	aHackingCritMatrix["Inner joint"][13] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Inner joint"][14] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Inner joint"][15] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Inner joint"][16] = {dm=2,w=true,a=3,b=1,t=2};
	aHackingCritMatrix["Inner joint"][17] = {dm=2,w=true,a=4,t=2,b=1};
	aHackingCritMatrix["Inner joint"][18] = {dm=2,w=true,a=4,t=2,bf=2};
	aHackingCritMatrix["Inner joint"][19] = {dm=2,w=true,a=4,t=2,bf=2};
	aHackingCritMatrix["Inner joint"][20] = {dm=2,w=true,a=4,t=2,bm=2};
	aHackingCritMatrix["Inner joint"][21] = {dm=2,w=true,a=5,t=2,bm=2};
	aHackingCritMatrix["Inner joint"][22] = {dm=2,w=true,a=5,ls=true};
	aHackingCritMatrix["Inner joint"][23] = {dm=2,w=true,a=5,ls=true};
	aHackingCritMatrix["Inner joint"][24] = {dm=2,w=true,a=5,ls=true};
	
	aHackingCritMatrix["Forearm, back"] = {};
	aHackingCritMatrix["Forearm, back"][1] = {db=1};
	aHackingCritMatrix["Forearm, back"][2] = {db=3};
	aHackingCritMatrix["Forearm, back"][3] = {db=4};
	aHackingCritMatrix["Forearm, back"][4] = {db=6};
	aHackingCritMatrix["Forearm, back"][5] = {db=6};
	aHackingCritMatrix["Forearm, back"][6] = {db=8};
	aHackingCritMatrix["Forearm, back"][7] = {dm=2};
	aHackingCritMatrix["Forearm, back"][8] = {dm=2,ws=true};
	aHackingCritMatrix["Forearm, back"][9] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Forearm, back"][10] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Forearm, back"][11] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Forearm, back"][12] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Forearm, back"][13] = {dm=2,a=3,ws=true};
	aHackingCritMatrix["Forearm, back"][14] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Forearm, back"][15] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Forearm, back"][16] = {dm=2,a=3,mt=1,w=true};
	aHackingCritMatrix["Forearm, back"][17] = {dm=2,a=3,b=1,w=true};
	aHackingCritMatrix["Forearm, back"][18] = {dm=2,a=3,mt=1,b=1,w=true};
	aHackingCritMatrix["Forearm, back"][19] = {dm=2,a=3,bf=2,mt=2,w=true};
	aHackingCritMatrix["Forearm, back"][20] = {dm=2,a=3,bm=2,mt=2,w=true};
	aHackingCritMatrix["Forearm, back"][21] = {dm=2,a=4,mt=2,bm=2,w=true};
	aHackingCritMatrix["Forearm, back"][22] = {dm=2,a=3,bf=2,mt=2,w=true};
	aHackingCritMatrix["Forearm, back"][23] = {dm=2,a=4,bm=2,mt=2,w=true};
	aHackingCritMatrix["Forearm, back"][24] = {dm=3,a=4,ls=true,w=true};
	
	aHackingCritMatrix["Forearm, inner"] = {};
	aHackingCritMatrix["Forearm, inner"][1] = {db=1};
	aHackingCritMatrix["Forearm, inner"][2] = {db=3};
	aHackingCritMatrix["Forearm, inner"][3] = {db=4};
	aHackingCritMatrix["Forearm, inner"][4] = {db=6};
	aHackingCritMatrix["Forearm, inner"][5] = {db=6,ws=true};
	aHackingCritMatrix["Forearm, inner"][6] = {db=8,ws=true};
	aHackingCritMatrix["Forearm, inner"][7] = {dm=2,ws=true};
	aHackingCritMatrix["Forearm, inner"][8] = {dm=2,ws=true};
	aHackingCritMatrix["Forearm, inner"][9] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Forearm, inner"][10] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Forearm, inner"][11] = {dm=2,a=2,w=true};
	aHackingCritMatrix["Forearm, inner"][12] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Forearm, inner"][13] = {dm=2,a=3,ws=true};
	aHackingCritMatrix["Forearm, inner"][14] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Forearm, inner"][15] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Forearm, inner"][16] = {dm=2,a=3,mt=1,w=true};
	aHackingCritMatrix["Forearm, inner"][17] = {dm=2,a=3,b=1,w=true};
	aHackingCritMatrix["Forearm, inner"][18] = {dm=2,a=3,mt=2,b=1,w=true};
	aHackingCritMatrix["Forearm, inner"][19] = {dm=2,a=3,bf=2,mt=2,w=true};
	aHackingCritMatrix["Forearm, inner"][20] = {dm=2,a=3,bm=2,mt=2,w=true};
	aHackingCritMatrix["Forearm, inner"][21] = {dm=2,a=4,mt=3,bm=2,w=true};
	aHackingCritMatrix["Forearm, inner"][22] = {dm=2,a=3,bf=2,mt=3,w=true};
	aHackingCritMatrix["Forearm, inner"][23] = {dm=2,a=4,bm=2,mt=3,w=true};
	aHackingCritMatrix["Forearm, inner"][24] = {dm=3,a=4,ls=true,w=true};
	
	aHackingCritMatrix["Wrist, back"] = {};
	aHackingCritMatrix["Wrist, back"][1] = {db=1};
	aHackingCritMatrix["Wrist, back"][2] = {db=3};
	aHackingCritMatrix["Wrist, back"][3] = {db=3};
	aHackingCritMatrix["Wrist, back"][4] = {db=4,ws=true};
	aHackingCritMatrix["Wrist, back"][5] = {db=4,ws=true,a=1};
	aHackingCritMatrix["Wrist, back"][6] = {db=6,ws=true,a=1};
	aHackingCritMatrix["Wrist, back"][7] = {db=8,ws=true,a=1};
	aHackingCritMatrix["Wrist, back"][8] = {db=8,ws=true,a=2};
	aHackingCritMatrix["Wrist, back"][9] = {db=8,ws=true,a=2,t=1};
	aHackingCritMatrix["Wrist, back"][10] = {db=8,w=true,a=2,t=1};
	aHackingCritMatrix["Wrist, back"][11] = {db=8,w=true,a=2,t=1};
	aHackingCritMatrix["Wrist, back"][12] = {dm=2,w=true,a=2,t=1};
	aHackingCritMatrix["Wrist, back"][13] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Wrist, back"][14] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Wrist, back"][15] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Wrist, back"][16] = {dm=2,w=true,a=3,b=1,t=1};
	aHackingCritMatrix["Wrist, back"][17] = {dm=2,w=true,a=3,t=1,b=1};
	aHackingCritMatrix["Wrist, back"][18] = {dm=2,w=true,a=3,t=1,bf=1};
	aHackingCritMatrix["Wrist, back"][19] = {dm=2,w=true,a=3,t=1,bf=1};
	aHackingCritMatrix["Wrist, back"][20] = {dm=2,w=true,a=3,t=1,bm=1};
	aHackingCritMatrix["Wrist, back"][21] = {dm=2,w=true,a=3,t=1,bm=1};
	aHackingCritMatrix["Wrist, back"][22] = {dm=2,w=true,a=3,ls=true};
	aHackingCritMatrix["Wrist, back"][23] = {dm=2,w=true,a=3,ls=true};
	aHackingCritMatrix["Wrist, back"][24] = {dm=2,w=true,a=3,ls=true};
	
	aHackingCritMatrix["Wrist, front"] = {};
	aHackingCritMatrix["Wrist, front"][1] = {db=1};
	aHackingCritMatrix["Wrist, front"][2] = {db=3};
	aHackingCritMatrix["Wrist, front"][3] = {db=3};
	aHackingCritMatrix["Wrist, front"][4] = {db=4,ws=true};
	aHackingCritMatrix["Wrist, front"][5] = {db=4,ws=true,a=1};
	aHackingCritMatrix["Wrist, front"][6] = {db=6,ws=true,a=1};
	aHackingCritMatrix["Wrist, front"][7] = {db=8,ws=true,a=1};
	aHackingCritMatrix["Wrist, front"][8] = {db=8,ws=true,a=2};
	aHackingCritMatrix["Wrist, front"][9] = {db=8,ws=true,a=2,t=1};
	aHackingCritMatrix["Wrist, front"][10] = {db=8,w=true,a=2,t=1};
	aHackingCritMatrix["Wrist, front"][11] = {db=8,w=true,a=2,t=1};
	aHackingCritMatrix["Wrist, front"][12] = {dm=2,w=true,a=2,t=1};
	aHackingCritMatrix["Wrist, front"][13] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Wrist, front"][14] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Wrist, front"][15] = {dm=2,w=true,a=3,t=1};
	aHackingCritMatrix["Wrist, front"][16] = {dm=2,w=true,a=3,b=1,t=1};
	aHackingCritMatrix["Wrist, front"][17] = {dm=2,w=true,a=3,t=1,b=1};
	aHackingCritMatrix["Wrist, front"][18] = {dm=2,w=true,a=3,t=1,bf=1};
	aHackingCritMatrix["Wrist, front"][19] = {dm=2,w=true,a=3,t=1,bf=1};
	aHackingCritMatrix["Wrist, front"][20] = {dm=2,w=true,a=3,t=1,bm=1};
	aHackingCritMatrix["Wrist, front"][21] = {dm=2,w=true,a=3,t=1,bm=1};
	aHackingCritMatrix["Wrist, front"][22] = {dm=2,w=true,a=3,ls=true};
	aHackingCritMatrix["Wrist, front"][23] = {dm=2,w=true,a=3,ls=true};
	aHackingCritMatrix["Wrist, front"][24] = {dm=2,w=true,a=3,ls=true};

	aHackingCritMatrix["Hand, back"] = {};
	aHackingCritMatrix["Hand, back"][1] = {db=1};
	aHackingCritMatrix["Hand, back"][2] = {db=1};
	aHackingCritMatrix["Hand, back"][3] = {db=3};
	aHackingCritMatrix["Hand, back"][4] = {db=3};
	aHackingCritMatrix["Hand, back"][5] = {db=4};
	aHackingCritMatrix["Hand, back"][6] = {db=4};
	aHackingCritMatrix["Hand, back"][7] = {db=6,t=1};
	aHackingCritMatrix["Hand, back"][8] = {db=6,t=1};
	aHackingCritMatrix["Hand, back"][9] = {db=8,t=1,a=1};
	aHackingCritMatrix["Hand, back"][10] = {db=8,t=1,a=1};
	aHackingCritMatrix["Hand, back"][11] = {dm=2,t=1,a=2};
	aHackingCritMatrix["Hand, back"][12] = {dm=2,t=1,a=2};
	aHackingCritMatrix["Hand, back"][13] = {dm=2,t=1,a=2};
	aHackingCritMatrix["Hand, back"][14] = {dm=2,t=1,a=2};
	aHackingCritMatrix["Hand, back"][15] = {dm=2,t=1,a=2,ws=true};
	aHackingCritMatrix["Hand, back"][16] = {dm=2,t=2,a=3,ws=true};
	aHackingCritMatrix["Hand, back"][17] = {dm=2,t=2,a=3,ws=true};
	aHackingCritMatrix["Hand, back"][18] = {dm=2,t=2,a=3,w=true};
	aHackingCritMatrix["Hand, back"][19] = {dm=2,t=2,b=1,a=3,w=true};
	aHackingCritMatrix["Hand, back"][20] = {dm=2,t=2,b=1,a=3,w=true};
	aHackingCritMatrix["Hand, back"][21] = {dm=2,t=2,bf=2,a=3,w=true};
	aHackingCritMatrix["Hand, back"][22] = {dm=2,t=2,bm=2,a=3,w=true};
	aHackingCritMatrix["Hand, back"][23] = {dm=2,a=3,ls=true,w=true};
	aHackingCritMatrix["Hand, back"][24] = {dm=2,ls=true,a=3,w=true};
	
	aHackingCritMatrix["Palm"] = {};
	aHackingCritMatrix["Palm"][1] = {db=1};
	aHackingCritMatrix["Palm"][2] = {db=1};
	aHackingCritMatrix["Palm"][3] = {db=3};
	aHackingCritMatrix["Palm"][4] = {db=3};
	aHackingCritMatrix["Palm"][5] = {db=4};
	aHackingCritMatrix["Palm"][6] = {db=4};
	aHackingCritMatrix["Palm"][7] = {db=6};
	aHackingCritMatrix["Palm"][8] = {db=6};
	aHackingCritMatrix["Palm"][9] = {db=6,t=1};
	aHackingCritMatrix["Palm"][10] = {db=6,t=1,a=1};
	aHackingCritMatrix["Palm"][11] = {db=8,t=1,a=1};
	aHackingCritMatrix["Palm"][12] = {db=8,t=1,a=2};
	aHackingCritMatrix["Palm"][13] = {dm=2,t=1,a=2};
	aHackingCritMatrix["Palm"][14] = {dm=2,t=1,a=2};
	aHackingCritMatrix["Palm"][15] = {dm=2,t=2,a=2};
	aHackingCritMatrix["Palm"][16] = {dm=2,t=2,a=2};
	aHackingCritMatrix["Palm"][17] = {dm=2,t=2,a=2,ws=true};
	aHackingCritMatrix["Palm"][18] = {dm=2,t=2,a=3,ws=true};
	aHackingCritMatrix["Palm"][19] = {dm=2,t=1,mt=2,a=3,ws=true};
	aHackingCritMatrix["Palm"][20] = {dm=2,t=1,mt=2,b=1,a=3,w=true};
	aHackingCritMatrix["Palm"][21] = {dm=2,t=1,mt=2,bf=1,a=3,w=true};
	aHackingCritMatrix["Palm"][22] = {dm=2,t=1,mt=2,bm=1,a=3,w=true};
	aHackingCritMatrix["Palm"][23] = {dm=2,a=3,ls=true,w=true};
	aHackingCritMatrix["Palm"][24] = {dm=2,ls=true,a=3,w=true};
	
	aHackingCritMatrix["Finger(s)"] = {};
	aHackingCritMatrix["Finger(s)"][1] = {db=1};
	aHackingCritMatrix["Finger(s)"][2] = {db=1};
	aHackingCritMatrix["Finger(s)"][3] = {db=3};
	aHackingCritMatrix["Finger(s)"][4] = {db=3};
	aHackingCritMatrix["Finger(s)"][5] = {db=4};
	aHackingCritMatrix["Finger(s)"][6] = {db=4};
	aHackingCritMatrix["Finger(s)"][7] = {db=6,t=1};
	aHackingCritMatrix["Finger(s)"][8] = {db=6,t=1};
	aHackingCritMatrix["Finger(s)"][9] = {db=8,t=1};
	aHackingCritMatrix["Finger(s)"][10] = {db=8,t=1};
	aHackingCritMatrix["Finger(s)"][11] = {dm=2,t=1};
	aHackingCritMatrix["Finger(s)"][12] = {dm=2,t=1};
	aHackingCritMatrix["Finger(s)"][13] = {dm=2,t=1};
	aHackingCritMatrix["Finger(s)"][14] = {dm=2,t=1};
	aHackingCritMatrix["Finger(s)"][15] = {dm=2,t=1};
	aHackingCritMatrix["Finger(s)"][16] = {dm=2,b=1,t=1};
	aHackingCritMatrix["Finger(s)"][17] = {dm=2,bm=1,t=1};
	aHackingCritMatrix["Finger(s)"][18] = {dm=2,bm=1,t=1};
	aHackingCritMatrix["Finger(s)"][19] = {dm=2,ls=true};
	aHackingCritMatrix["Finger(s)"][20] = {dm=2,ls=true};
	aHackingCritMatrix["Finger(s)"][21] = {dm=2,ls=true};
	aHackingCritMatrix["Finger(s)"][22] = {dm=2,ls=true};
	aHackingCritMatrix["Finger(s)"][23] = {dm=2,ls=true};
	aHackingCritMatrix["Finger(s)"][24] = {dm=2,ls=true};

	aHackingCritMatrix["Shoulder, side"] = {};
	aHackingCritMatrix["Shoulder, side"][1] = {db=1};
	aHackingCritMatrix["Shoulder, side"][2] = {db=3};
	aHackingCritMatrix["Shoulder, side"][3] = {db=4};
	aHackingCritMatrix["Shoulder, side"][4] = {db=6};
	aHackingCritMatrix["Shoulder, side"][5] = {db=6};
	aHackingCritMatrix["Shoulder, side"][6] = {db=8};
	aHackingCritMatrix["Shoulder, side"][7] = {dm=2};
	aHackingCritMatrix["Shoulder, side"][8] = {dm=2,ws=true};
	aHackingCritMatrix["Shoulder, side"][9] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Shoulder, side"][10] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Shoulder, side"][11] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Shoulder, side"][12] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Shoulder, side"][13] = {dm=2,a=3,ws=true};
	aHackingCritMatrix["Shoulder, side"][14] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Shoulder, side"][15] = {dm=2,a=3,w=true};
	aHackingCritMatrix["Shoulder, side"][16] = {dm=2,a=3,mt=1,w=true};
	aHackingCritMatrix["Shoulder, side"][17] = {dm=2,a=3,b=1,w=true};
	aHackingCritMatrix["Shoulder, side"][18] = {dm=3,a=3,mt=1,b=1,w=true};
	aHackingCritMatrix["Shoulder, side"][19] = {dm=3,a=3,bf=1,mt=2,w=true};
	aHackingCritMatrix["Shoulder, side"][20] = {dm=3,a=3,bm=1,mt=3,w=true};
	aHackingCritMatrix["Shoulder, side"][21] = {dm=3,a=4,mt=1,bm=4,w=true};
	aHackingCritMatrix["Shoulder, side"][22] = {dm=4,a=3,mt=4,bf=1,w=true};
	aHackingCritMatrix["Shoulder, side"][23] = {dm=3,a=4,mt=4,bm=1,w=true};
	aHackingCritMatrix["Shoulder, side"][24] = {dm=3,a=4,ls=true};
	
	aHackingCritMatrix["Shoulder, top"] = {};
	aHackingCritMatrix["Shoulder, top"][1] = {db=1};
	aHackingCritMatrix["Shoulder, top"][2] = {db=3};
	aHackingCritMatrix["Shoulder, top"][3] = {db=4};
	aHackingCritMatrix["Shoulder, top"][4] = {db=6};
	aHackingCritMatrix["Shoulder, top"][5] = {db=8};
	aHackingCritMatrix["Shoulder, top"][6] = {dm=2};
	aHackingCritMatrix["Shoulder, top"][7] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Shoulder, top"][8] = {dm=2,a=1,ws=true};
	aHackingCritMatrix["Shoulder, top"][9] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Shoulder, top"][10] = {dm=2,a=2,ws=true};
	aHackingCritMatrix["Shoulder, top"][11] = {dm=2,a=3,d=1,ws=true};
	aHackingCritMatrix["Shoulder, top"][12] = {dm=2,a=3,d=1,w=true};
	aHackingCritMatrix["Shoulder, top"][13] = {dm=3,a=3,d=1,w=true};
	aHackingCritMatrix["Shoulder, top"][14] = {dm=3,a=3,d=1,w=true};
	aHackingCritMatrix["Shoulder, top"][15] = {dm=3,a=3,d=2,w=true};
	aHackingCritMatrix["Shoulder, top"][16] = {dm=3,a=3,d=2,mt=1,w=true};
	aHackingCritMatrix["Shoulder, top"][17] = {dm=3,a=3,d=2,t=2,w=true};
	aHackingCritMatrix["Shoulder, top"][18] = {dm=3,a=3,d=2,t=2,mt=1,w=true};
	aHackingCritMatrix["Shoulder, top"][19] = {dm=3,a=3,d=2,bf=1,mt=1};
	aHackingCritMatrix["Shoulder, top"][20] = {dm=3,a=3,d=2,bm=2,mt=1};
	aHackingCritMatrix["Shoulder, top"][21] = {dm=3,a=3,d=2,b=3,mt=1,t=2,w=true};
	aHackingCritMatrix["Shoulder, top"][22] = {dm=3,a=3,d=2,bf=3,mt=1,t=2};
	aHackingCritMatrix["Shoulder, top"][23] = {dm=3,a=3,d=2,bm=3,mt=1,t=2};
	aHackingCritMatrix["Shoulder, top"][24] = {dm=3,a=3,d=2,ls=true};
	
	aHackingCritMatrix["Neck, front"] = {};
	aHackingCritMatrix["Neck, front"][1] = {db=3};
	aHackingCritMatrix["Neck, front"][2] = {db=4};
	aHackingCritMatrix["Neck, front"][3] = {db=6};
	aHackingCritMatrix["Neck, front"][4] = {db=8};
	aHackingCritMatrix["Neck, front"][5] = {dm=2};
	aHackingCritMatrix["Neck, front"][6] = {dm=2,ws=true,a=1,d=1};
	aHackingCritMatrix["Neck, front"][7] = {dm=2,w=true,a=1,d=1};
	aHackingCritMatrix["Neck, front"][8] = {dm=2,f=true,a=1,d=1};
	aHackingCritMatrix["Neck, front"][9] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Neck, front"][10] = {dm=2,a=2,d=2,f=true,mc=true};
	aHackingCritMatrix["Neck, front"][11] = {dm=2,a=2,d=2,f=true,mc=true};
	aHackingCritMatrix["Neck, front"][12] = {dm=3,a=3,d=3,u=true};
	aHackingCritMatrix["Neck, front"][13] = {dm=3,a=3,d=3,u=true};
	aHackingCritMatrix["Neck, front"][14] = {dm=3,a=3,d=3,u=true,mc=true};
	aHackingCritMatrix["Neck, front"][15] = {dm=3,a=3,d=4,u=true,p=true,mc=true};
	aHackingCritMatrix["Neck, front"][16] = {dm=3,a=3,d=5,u=true,mc=true};
	aHackingCritMatrix["Neck, front"][17] = {dm=4,a=4,d=6,u=true,sc=true};
	aHackingCritMatrix["Neck, front"][18] = {dm=4,a=5,p=true,u=true,sc=true};
	aHackingCritMatrix["Neck, front"][19] = {dm=4,pb=true,ib=true,v=1};
	aHackingCritMatrix["Neck, front"][20] = {dm=4,pb=true,ib=true,v=1};
	aHackingCritMatrix["Neck, front"][21] = {dm=4,p=true,u=true,sc=true};
	aHackingCritMatrix["Neck, front"][22] = {dm=4,pb=true,ib=true,v=2};
	aHackingCritMatrix["Neck, front"][23] = {dead="decapitated"};
	aHackingCritMatrix["Neck, front"][24] = {dead="decapitated"};

	aHackingCritMatrix["Neck, back"] = {};
	aHackingCritMatrix["Neck, back"][1] = {db=3};
	aHackingCritMatrix["Neck, back"][2] = {db=4};
	aHackingCritMatrix["Neck, back"][3] = {db=6};
	aHackingCritMatrix["Neck, back"][4] = {db=8};
	aHackingCritMatrix["Neck, back"][5] = {dm=2};
	aHackingCritMatrix["Neck, back"][6] = {dm=2,ws=true,a=1,d=1};
	aHackingCritMatrix["Neck, back"][7] = {dm=2,w=true,a=1,d=1};
	aHackingCritMatrix["Neck, back"][8] = {dm=2,f=true,a=1,d=1,p=true};
	aHackingCritMatrix["Neck, back"][9] = {dm=2,a=2,d=2,f=true,p=true};
	aHackingCritMatrix["Neck, back"][10] = {dm=2,a=2,d=2,f=true,p=true};
	aHackingCritMatrix["Neck, back"][11] = {dm=2,a=2,d=2,f=true,p=true};
	aHackingCritMatrix["Neck, back"][12] = {dm=3,a=2,d=3,u=true};
	aHackingCritMatrix["Neck, back"][13] = {dm=3,a=2,d=3,u=true};
	aHackingCritMatrix["Neck, back"][14] = {dm=3,a=2,d=3,u=true,mc=true};
	aHackingCritMatrix["Neck, back"][15] = {dm=3,a=2,d=3,u=true,p=true,mc=true};
	aHackingCritMatrix["Neck, back"][16] = {dm=3,a=3,d=4,u=true,mc=true};
	aHackingCritMatrix["Neck, back"][17] = {dm=4,a=4,d=5,b=1,u=true,sc=true};
	aHackingCritMatrix["Neck, back"][18] = {dm=4,a=5,d=6,b=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Neck, back"][19] = {dm=4,p=true,bm=1,u=true,sc=true};
	aHackingCritMatrix["Neck, back"][20] = {dm=4,p=true,bm=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Neck, back"][21] = {dm=4,p=true,bs=1,u=true,sc=true};
	aHackingCritMatrix["Neck, back"][22] = {dm=4,p=true,bs=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Neck, back"][23] = {dead="decapitated"};
	aHackingCritMatrix["Neck, back"][24] = {dead="decapitated"};
	
	aHackingCritMatrix["Neck, side"] = {};	
	aHackingCritMatrix["Neck, side"][1] = {db=3};
	aHackingCritMatrix["Neck, side"][2] = {db=4};
	aHackingCritMatrix["Neck, side"][3] = {db=6};
	aHackingCritMatrix["Neck, side"][4] = {db=8};
	aHackingCritMatrix["Neck, side"][5] = {dm=2};
	aHackingCritMatrix["Neck, side"][6] = {dm=2,ws=true,a=1,d=1};
	aHackingCritMatrix["Neck, side"][7] = {dm=2,w=true,a=1,d=1};
	aHackingCritMatrix["Neck, side"][8] = {dm=2,f=true,a=1,d=1};
	aHackingCritMatrix["Neck, side"][9] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Neck, side"][10] = {dm=2,a=2,d=2,f=true,mc=true};
	aHackingCritMatrix["Neck, side"][11] = {dm=2,a=2,d=2,f=true,p=true};
	aHackingCritMatrix["Neck, side"][12] = {dm=3,a=2,d=3,f=true,mt=1};
	aHackingCritMatrix["Neck, side"][13] = {dm=3,a=2,d=3,f=true,mt=1};
	aHackingCritMatrix["Neck, side"][14] = {dm=3,a=2,d=3,u=true,mt=1};
	aHackingCritMatrix["Neck, side"][15] = {dm=3,a=2,d=3,u=true,mt=1};
	aHackingCritMatrix["Neck, side"][16] = {dm=3,a=3,d=4,u=true,mt=1};
	aHackingCritMatrix["Neck, side"][17] = {dm=4,a=4,d=5,u=true,mt=2,mc=true};
	aHackingCritMatrix["Neck, side"][18] = {dm=4,a=5,d=6,mt=2,u=true,sc=true};
	aHackingCritMatrix["Neck, side"][19] = {dm=4,p=true,bm=1,u=true,sc=true};
	aHackingCritMatrix["Neck, side"][20] = {dm=4,p=true,bm=2,v=1,u=true,sc=true};
	aHackingCritMatrix["Neck, side"][21] = {dm=4,p=true,bs=2,u=true,sc=true};
	aHackingCritMatrix["Neck, side"][22] = {dm=4,p=true,bs=2,v=2,u=true,sc=true};
	aHackingCritMatrix["Neck, side"][23] = {dead="decapitated"};
	aHackingCritMatrix["Neck, side"][24] = {dead="decapitated"};

	aHackingCritMatrix["Head, side"] = {};
	aHackingCritMatrix["Head, side"][1] = {db=6};
	aHackingCritMatrix["Head, side"][2] = {db=8};
	aHackingCritMatrix["Head, side"][3] = {dm=2};
	aHackingCritMatrix["Head, side"][4] = {dm=2,f=true};
	aHackingCritMatrix["Head, side"][5] = {dm=2,a=1,d=1,f=true};
	aHackingCritMatrix["Head, side"][6] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Head, side"][7] = {dm=3,a=2,d=2,f=true};
	aHackingCritMatrix["Head, side"][8] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Head, side"][9] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Head, side"][10] = {dm=3,a=4,d=4,f=true};
	aHackingCritMatrix["Head, side"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aHackingCritMatrix["Head, side"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aHackingCritMatrix["Head, side"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Head, side"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, side"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, side"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aHackingCritMatrix["Head, side"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, side"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, side"][19] = {dm=4,a=8,d=8,b=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, side"][20] = {dm=4,a=8,d=8,bm=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, side"][21] = {dm=4,a=9,d=9,bm=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, side"][22] = {dm=4,a=9,d=9,bs=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, side"][23] = {dead="skull caved-in"};
	aHackingCritMatrix["Head, side"][24] = {dead="brain goo"};
	
	aHackingCritMatrix["Head, back lower"] = {};
	aHackingCritMatrix["Head, back lower"][1] = {db=6};
	aHackingCritMatrix["Head, back lower"][2] = {db=8};
	aHackingCritMatrix["Head, back lower"][3] = {dm=2};
	aHackingCritMatrix["Head, back lower"][4] = {dm=2,f=true};
	aHackingCritMatrix["Head, back lower"][5] = {dm=2,d=1,f=true};
	aHackingCritMatrix["Head, back lower"][6] = {dm=2,a=1,d=2,f=true};
	aHackingCritMatrix["Head, back lower"][7] = {dm=3,a=1,d=2,f=true};
	aHackingCritMatrix["Head, back lower"][8] = {dm=3,a=2,d=3,f=true};
	aHackingCritMatrix["Head, back lower"][9] = {dm=3,a=2,d=3,f=true,p=true};
	aHackingCritMatrix["Head, back lower"][10] = {dm=3,a=3,d=4,f=true};
	aHackingCritMatrix["Head, back lower"][11] = {dm=3,a=3,d=4,f=true,mc=true};
	aHackingCritMatrix["Head, back lower"][12] = {dm=4,a=3,d=4,f=true,sc=true,p=true};
	aHackingCritMatrix["Head, back lower"][13] = {dm=4,a=4,d=5,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][14] = {dm=4,a=5,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][15] = {dm=4,a=5,d=6,u=true,sc=true,p=true};
	aHackingCritMatrix["Head, back lower"][16] = {dm=4,a=6,d=7,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][17] = {dm=4,a=6,d=7,b=1,u=true,sc=true,p=true};
	aHackingCritMatrix["Head, back lower"][18] = {dm=4,a=6,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][19] = {dm=4,a=7,d=8,b=2,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][20] = {dm=4,a=7,d=8,bm=3,v=2,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][21] = {dm=4,p=true,bm=3,v=2,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][22] = {dm=4,p=true,bs=3,v=2,u=true,sc=true};
	aHackingCritMatrix["Head, back lower"][23] = {dead="skull caved=in"};
	aHackingCritMatrix["Head, back lower"][24] = {dead="brain goo"};
	
	aHackingCritMatrix["Face, lower side"] = {};
	aHackingCritMatrix["Face, lower side"][1] = {db=4};
	aHackingCritMatrix["Face, lower side"][2] = {db=6};
	aHackingCritMatrix["Face, lower side"][3] = {db=8};
	aHackingCritMatrix["Face, lower side"][4] = {dm=2};
	aHackingCritMatrix["Face, lower side"][5] = {dm=2,f=true};
	aHackingCritMatrix["Face, lower side"][6] = {dm=2,a=2,f=true};
	aHackingCritMatrix["Face, lower side"][7] = {dm=2,a=2,u=true};
	aHackingCritMatrix["Face, lower side"][8] = {dm=3,mt=1,a=3,d=1,f=true};
	aHackingCritMatrix["Face, lower side"][9] = {dm=3,mt=1,a=3,d=1,u=true};
	aHackingCritMatrix["Face, lower side"][10] = {dm=3,mt=1,a=4,d=2,f=true,mc=true};
	aHackingCritMatrix["Face, lower side"][11] = {dm=3,mt=1,a=4,d=2,u=true,mc=true};
	aHackingCritMatrix["Face, lower side"][12] = {dm=4,mt=2,a=4,d=2,u=true,mc=true};
	aHackingCritMatrix["Face, lower side"][13] = {dm=4,mt=2,a=3,d=1,f=true,sc=true};
	aHackingCritMatrix["Face, lower side"][14] = {dm=4,bf=1,a=3,d=1,u=true,mc=true};
	aHackingCritMatrix["Face, lower side"][15] = {dm=4,bm=1,a=4,d=2,f=true,mc=true};
	aHackingCritMatrix["Face, lower side"][16] = {dm=4,bf=2,a=5,d=3,f=true,mc=true};
	aHackingCritMatrix["Face, lower side"][17] = {dm=4,bm=2,a=5,d=3,f=true,mc=true};
	aHackingCritMatrix["Face, lower side"][18] = {dm=4,bf=3,a=5,d=3,f=true,mc=true};
	aHackingCritMatrix["Face, lower side"][19] = {dm=4,bm=3,a=5,d=3,f=true,sc=true};
	aHackingCritMatrix["Face, lower side"][20] = {dm=4,bm=3,a=6,d=4,u=true,mc=true};
	aHackingCritMatrix["Face, lower side"][21] = {dm=4,bf=3,a=6,d=4,u=true,sc=true};
	aHackingCritMatrix["Face, lower side"][22] = {dm=4,bm=3,a=6,d=4,u=true,sc=true};
	aHackingCritMatrix["Face, lower side"][23] = {dm=4,bs=3,a=7,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, lower side"][24] = {dead="jaw removed"};

	aHackingCritMatrix["Face, lower center"] = {};
	aHackingCritMatrix["Face, lower center"][1] = {db=4};
	aHackingCritMatrix["Face, lower center"][2] = {db=6};
	aHackingCritMatrix["Face, lower center"][3] = {db=8};
	aHackingCritMatrix["Face, lower center"][4] = {dm=2};
	aHackingCritMatrix["Face, lower center"][5] = {dm=2,f=true};
	aHackingCritMatrix["Face, lower center"][6] = {dm=2,a=1,d=1,f=true};
	aHackingCritMatrix["Face, lower center"][7] = {dm=2,a=2,d=2,u=true};
	aHackingCritMatrix["Face, lower center"][8] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Face, lower center"][9] = {dm=3,a=3,d=3,u=true};
	aHackingCritMatrix["Face, lower center"][10] = {dm=3,a=4,d=4,f=true,mt=1};
	aHackingCritMatrix["Face, lower center"][11] = {dm=3,a=4,d=4,mc=true};
	aHackingCritMatrix["Face, lower center"][12] = {dm=4,a=4,d=4,u=true,mc=true};
	aHackingCritMatrix["Face, lower center"][13] = {dm=4,b=1,a=3,d=3,f=true,mc=true,mt=2};
	aHackingCritMatrix["Face, lower center"][14] = {dm=4,b=1,a=3,d=3,u=true,mc=true};
	aHackingCritMatrix["Face, lower center"][15] = {dm=4,b=1,a=4,d=4,f=true,mc=true};
	aHackingCritMatrix["Face, lower center"][16] = {dm=4,b=2,a=5,d=5,f=true,mc=true};
	aHackingCritMatrix["Face, lower center"][17] = {dm=4,b=2,a=5,d=5,f=true,mc=true};
	aHackingCritMatrix["Face, lower center"][18] = {dm=4,bm=2,a=5,d=5,f=true,mc=true};
	aHackingCritMatrix["Face, lower center"][19] = {dm=4,bm=3,a=5,d=5,f=true,sc=true};
	aHackingCritMatrix["Face, lower center"][20] = {dm=4,bm=3,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, lower center"][21] = {dm=4,bm=3,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, lower center"][22] = {dm=4,bs=3,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, lower center"][23] = {dm=4,bs=3,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, lower center"][24] = {dead="skull caved-in"};
	
	aHackingCritMatrix["Head, back upper"] = {};
	aHackingCritMatrix["Head, back upper"][1] = {db=6};
	aHackingCritMatrix["Head, back upper"][2] = {db=8};
	aHackingCritMatrix["Head, back upper"][3] = {dm=2};
	aHackingCritMatrix["Head, back upper"][4] = {dm=2,f=true};
	aHackingCritMatrix["Head, back upper"][5] = {dm=2,a=1,d=1,f=true};
	aHackingCritMatrix["Head, back upper"][6] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Head, back upper"][7] = {dm=3,a=2,d=2,f=true};
	aHackingCritMatrix["Head, back upper"][8] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Head, back upper"][9] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Head, back upper"][10] = {dm=3,a=4,d=4,f=true};
	aHackingCritMatrix["Head, back upper"][11] = {dm=3,a=4,d=4,f=true,mt=1,mc=true};
	aHackingCritMatrix["Head, back upper"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aHackingCritMatrix["Head, back upper"][13] = {dm=4,a=5,d=5,u=true,mt=1,sc=true};
	aHackingCritMatrix["Head, back upper"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][19] = {dm=4,a=8,d=8,b=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][20] = {dm=4,a=8,d=8,bm=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][21] = {dm=4,a=9,d=9,bm=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][22] = {dm=4,a=9,d=9,bs=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, back upper"][23] = {dead="skull caved-in"};
	aHackingCritMatrix["Head, back upper"][24] = {dead="brain goo"};
	
	aHackingCritMatrix["Face, upper side"] = {};
	aHackingCritMatrix["Face, upper side"][1] = {db=6};
	aHackingCritMatrix["Face, upper side"][2] = {db=8};
	aHackingCritMatrix["Face, upper side"][3] = {dm=2};
	aHackingCritMatrix["Face, upper side"][4] = {dm=2,f=true};
	aHackingCritMatrix["Face, upper side"][5] = {dm=2,a=1,d=1,f=true};
	aHackingCritMatrix["Face, upper side"][6] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Face, upper side"][7] = {dm=3,a=2,d=2,f=true};
	aHackingCritMatrix["Face, upper side"][8] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Face, upper side"][9] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Face, upper side"][10] = {dm=3,a=4,d=4,f=true};
	aHackingCritMatrix["Face, upper side"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aHackingCritMatrix["Face, upper side"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aHackingCritMatrix["Face, upper side"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][19] = {dm=4,a=7,d=7,b=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][20] = {dm=4,a=8,d=8,bm=2,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][21] = {dm=4,a=8,d=8,bm=2,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][22] = {dm=4,a=9,d=9,bs=2,v=1, u=true,sc=true};
	aHackingCritMatrix["Face, upper side"][23] = {dead="skull caved-in"};
	aHackingCritMatrix["Face, upper side"][24] = {dead="brain goo"};
	
	aHackingCritMatrix["Face, upper center"] = {};
	aHackingCritMatrix["Face, upper center"][1] = {db=6};
	aHackingCritMatrix["Face, upper center"][2] = {db=8};
	aHackingCritMatrix["Face, upper center"][3] = {dm=2};
	aHackingCritMatrix["Face, upper center"][4] = {dm=2,f=true};
	aHackingCritMatrix["Face, upper center"][5] = {dm=2,a=1,d=1,f=true};
	aHackingCritMatrix["Face, upper center"][6] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Face, upper center"][7] = {dm=3,a=2,d=2,f=true};
	aHackingCritMatrix["Face, upper center"][8] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Face, upper center"][9] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Face, upper center"][10] = {dm=3,a=4,d=4,f=true};
	aHackingCritMatrix["Face, upper center"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aHackingCritMatrix["Face, upper center"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aHackingCritMatrix["Face, upper center"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][19] = {dm=4,a=8,d=8,b=2,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][20] = {dm=4,a=8,d=8,bm=2,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][21] = {dm=4,a=9,d=9,bm=3,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][22] = {dm=4,a=9,d=9,bs=3,v=1,u=true,sc=true};
	aHackingCritMatrix["Face, upper center"][23] = {dead="skull caved-in"};
	aHackingCritMatrix["Face, upper center"][24] = {dead="brain goo"};
	
	aHackingCritMatrix["Head, top"] = {};
	aHackingCritMatrix["Head, top"][1] = {db=8};
	aHackingCritMatrix["Head, top"][2] = {dm=2};
	aHackingCritMatrix["Head, top"][3] = {dm=2, f=true};
	aHackingCritMatrix["Head, top"][4] = {dm=2,a=1,d=1,f=true};
	aHackingCritMatrix["Head, top"][5] = {dm=2,a=2,d=2,f=true};
	aHackingCritMatrix["Head, top"][6] = {dm=3,a=2,d=2,f=true};
	aHackingCritMatrix["Head, top"][7] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Head, top"][8] = {dm=3,a=3,d=3,f=true};
	aHackingCritMatrix["Head, top"][9] = {dm=3,a=4,d=4,f=true};
	aHackingCritMatrix["Head, top"][10] = {dm=3,a=4,d=4,f=true,mc=true};
	aHackingCritMatrix["Head, top"][11] = {dm=4,a=4,d=4,u=true,sc=true};
	aHackingCritMatrix["Head, top"][12] = {dm=4,a=5,d=5,u=true,sc=true};
	aHackingCritMatrix["Head, top"][13] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, top"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aHackingCritMatrix["Head, top"][15] = {dm=4,a=7,d=7,u=true,sc=true};
	aHackingCritMatrix["Head, top"][16] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, top"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aHackingCritMatrix["Head, top"][18] = {dm=4,a=8,d=8,b=1,v=1,u=true,sc=true};
	aHackingCritMatrix["Head, top"][19] = {dm=4,a=8,d=8,bm=1,v=1,u=true,s=true,};
	aHackingCritMatrix["Head, top"][20] = {dm=4,a=9,d=9,bm=1,v=1,u=true,s=true};
	aHackingCritMatrix["Head, top"][21] = {cm=4,a=9,d=9,bs=1,v=1,u=true,s=true};
	aHackingCritMatrix["Head, top"][22] = {dead="skull caved-in"};
	aHackingCritMatrix["Head, top"][23] = {dead="brain goo"};
	aHackingCritMatrix["Head, top"][24] = {dead="brain goo"};
end

function buildPuncturingCritMatrix()
	aPuncturingCritMatrix["Foot, top"] = {};
	aPuncturingCritMatrix["Foot, top"][1] = {db=1};
	aPuncturingCritMatrix["Foot, top"][2] = {db=1};
	aPuncturingCritMatrix["Foot, top"][3] = {db=3};
	aPuncturingCritMatrix["Foot, top"][4] = {db=3};
	aPuncturingCritMatrix["Foot, top"][5] = {db=4,m=1};
	aPuncturingCritMatrix["Foot, top"][6] = {db=4,m=1};
	aPuncturingCritMatrix["Foot, top"][7] = {db=6,ib=true,m=2};
	aPuncturingCritMatrix["Foot, top"][8] = {db=6,ib=true,m=2};
	aPuncturingCritMatrix["Foot, top"][9] = {db=8,ib=true,m=3};
	aPuncturingCritMatrix["Foot, top"][10] = {db=8,ib=true,m=3};
	aPuncturingCritMatrix["Foot, top"][11] = {dm=2,ib=true,m=4};
	aPuncturingCritMatrix["Foot, top"][12] = {dm=2,ib=true,m=4};
	aPuncturingCritMatrix["Foot, top"][13] = {dm=2,ib=true,m=5};
	aPuncturingCritMatrix["Foot, top"][14] = {dm=2,ib=true,m=5};
	aPuncturingCritMatrix["Foot, top"][15] = {dm=2,ib=true,m=6};
	aPuncturingCritMatrix["Foot, top"][16] = {dm=2,ib=true,m=6};
	aPuncturingCritMatrix["Foot, top"][17] = {dm=2,ib=true,m=7};
	aPuncturingCritMatrix["Foot, top"][18] = {dm=2,ib=true,m=7};
	aPuncturingCritMatrix["Foot, top"][19] = {dm=2,ib=true,m=7,b=1};
	aPuncturingCritMatrix["Foot, top"][20] = {dm=2,ib=true,m=8,b=1};
	aPuncturingCritMatrix["Foot, top"][21] = {dm=2,ib=true,mt=1,m=8};
	aPuncturingCritMatrix["Foot, top"][22] = {dm=2,ib=true,mt=1,m=9};
	aPuncturingCritMatrix["Foot, top"][23] = {dm=2,ls=true,m=9};
	aPuncturingCritMatrix["Foot, top"][24] = {dm=2,ls=true,m=10};
	
	aPuncturingCritMatrix["Heel"] = {};
	aPuncturingCritMatrix["Heel"][1] = {db=1};
	aPuncturingCritMatrix["Heel"][2] = {db=1};
	aPuncturingCritMatrix["Heel"][3] = {db=3};
	aPuncturingCritMatrix["Heel"][4] = {db=3};
	aPuncturingCritMatrix["Heel"][5] = {db=4,m=1};
	aPuncturingCritMatrix["Heel"][6] = {db=4,m=1};
	aPuncturingCritMatrix["Heel"][7] = {db=6,ib=true,m=2};
	aPuncturingCritMatrix["Heel"][8] = {db=6,ib=true,m=2,a=1};
	aPuncturingCritMatrix["Heel"][9] = {db=8,ib=true,m=3,a=1};
	aPuncturingCritMatrix["Heel"][10] = {db=8,ib=true,m=3,a=2};
	aPuncturingCritMatrix["Heel"][11] = {dm=2,ib=true,m=4,a=2};
	aPuncturingCritMatrix["Heel"][12] = {dm=2,ib=true,d=1,m=4};
	aPuncturingCritMatrix["Heel"][13] = {dm=2,ib=true,a=2,d=2,m=5};
	aPuncturingCritMatrix["Heel"][14] = {dm=2,ib=true,a=2,d=2,m=5};
	aPuncturingCritMatrix["Heel"][15] = {dm=2,ib=true,a=2,d=2,m=6};
	aPuncturingCritMatrix["Heel"][16] = {dm=2,ib=true,a=3,d=2,m=6};
	aPuncturingCritMatrix["Heel"][17] = {dm=2,ib=true,a=3,d=2,m=7};
	aPuncturingCritMatrix["Heel"][18] = {dm=2,ib=true,b=1,a=3,d=2,m=7};
	aPuncturingCritMatrix["Heel"][19] = {dm=2,ib=true,b=1,a=3,d=2,m=7};
	aPuncturingCritMatrix["Heel"][20] = {dm=2,ib=true,b=1,a=3,d=2,m=8};
	aPuncturingCritMatrix["Heel"][21] = {dm=2,ib=true,mt=1,a=3,d=2,m=8};
	aPuncturingCritMatrix["Heel"][22] = {dm=2,ib=true,a=3,d=2,m=9};
	aPuncturingCritMatrix["Heel"][23] = {dm=2,ib=true,a=3,d=2,m=9};
	aPuncturingCritMatrix["Heel"][24] = {dm=2,ib=true,a=3,d=2,m=10};

	aPuncturingCritMatrix["Toe(s)"] = {};
	aPuncturingCritMatrix["Toe(s)"][1] = {db=1};
	aPuncturingCritMatrix["Toe(s)"][2] = {db=1};
	aPuncturingCritMatrix["Toe(s)"][3] = {db=3};
	aPuncturingCritMatrix["Toe(s)"][4] = {db=3};
	aPuncturingCritMatrix["Toe(s)"][5] = {db=4,m=1};
	aPuncturingCritMatrix["Toe(s)"][6] = {db=4,m=1};
	aPuncturingCritMatrix["Toe(s)"][7] = {db=6,ib=true,m=2};
	aPuncturingCritMatrix["Toe(s)"][8] = {db=6,ib=true,m=2};
	aPuncturingCritMatrix["Toe(s)"][9] = {db=8,ib=true,m=3};
	aPuncturingCritMatrix["Toe(s)"][10] = {db=8,ib=true,m=3};
	aPuncturingCritMatrix["Toe(s)"][11] = {dm=2,ib=true,m=4};
	aPuncturingCritMatrix["Toe(s)"][12] = {dm=2,ib=true,m=4};
	aPuncturingCritMatrix["Toe(s)"][13] = {dm=2,ib=true,m=5};
	aPuncturingCritMatrix["Toe(s)"][14] = {dm=2,ib=true,m=5};
	aPuncturingCritMatrix["Toe(s)"][15] = {dm=2,ib=true,m=6};
	aPuncturingCritMatrix["Toe(s)"][16] = {dm=2,ib=true,b=1,m=6};
	aPuncturingCritMatrix["Toe(s)"][17] = {dm=2,ib=true,b=1,m=7};
	aPuncturingCritMatrix["Toe(s)"][18] = {dm=2,ib=true,b=1,m=7};
	aPuncturingCritMatrix["Toe(s)"][19] = {dm=2,ls=true,m=7};
	aPuncturingCritMatrix["Toe(s)"][20] = {dm=2,ls=true,m=8};
	aPuncturingCritMatrix["Toe(s)"][21] = {dm=2,ls=true,m=8};
	aPuncturingCritMatrix["Toe(s)"][22] = {dm=2,ls=true,m=9};
	aPuncturingCritMatrix["Toe(s)"][23] = {dm=2,ls=true,m=9};
	aPuncturingCritMatrix["Toe(s)"][24] = {dm=2,ls=true,m=10};
	
	aPuncturingCritMatrix["Foot, arch"] = {};
	aPuncturingCritMatrix["Foot, arch"][1] = {db=1};
	aPuncturingCritMatrix["Foot, arch"][2] = {db=1};
	aPuncturingCritMatrix["Foot, arch"][3] = {db=3};
	aPuncturingCritMatrix["Foot, arch"][4] = {db=3};
	aPuncturingCritMatrix["Foot, arch"][5] = {db=4,m=1};
	aPuncturingCritMatrix["Foot, arch"][6] = {db=4,m=1};
	aPuncturingCritMatrix["Foot, arch"][7] = {db=6,ib=true,m=2};
	aPuncturingCritMatrix["Foot, arch"][8] = {db=6,ib=true,m=2,a=1};
	aPuncturingCritMatrix["Foot, arch"][9] = {db=8,ib=true,m=3,a=1};
	aPuncturingCritMatrix["Foot, arch"][10] = {db=8,ib=true,m=3,a=2};
	aPuncturingCritMatrix["Foot, arch"][11] = {dm=2,ib=true,m=4,a=2};
	aPuncturingCritMatrix["Foot, arch"][12] = {dm=2,ib=true,a=2,d=1,m=4};
	aPuncturingCritMatrix["Foot, arch"][13] = {dm=2,ib=true,a=2,d=2,m=5};
	aPuncturingCritMatrix["Foot, arch"][14] = {dm=2,b=1,a=2,d=2,m=5};
	aPuncturingCritMatrix["Foot, arch"][15] = {dm=2,b=1,a=2,d=2,m=6};
	aPuncturingCritMatrix["Foot, arch"][16] = {dm=2,b=1,a=3,d=2,m=6};
	aPuncturingCritMatrix["Foot, arch"][17] = {dm=2,b=1,a=3,d=2,m=7};
	aPuncturingCritMatrix["Foot, arch"][18] = {dm=2,b=1,a=3,d=2,m=7};
	aPuncturingCritMatrix["Foot, arch"][19] = {dm=2,b=1,a=3,d=2,m=7};
	aPuncturingCritMatrix["Foot, arch"][20] = {dm=2,b=1,a=3,d=2,m=8};
	aPuncturingCritMatrix["Foot, arch"][21] = {dm=2,mt=1,a=3,d=2,m=8};
	aPuncturingCritMatrix["Foot, arch"][22] = {dm=2,ib=1,mt=1,a=3,d=2,m=9};
	aPuncturingCritMatrix["Foot, arch"][23] = {dm=2,ls=true,a=3,d=2,m=9};
	aPuncturingCritMatrix["Foot, arch"][24] = {dm=2,ls=true,a=3,d=2,m=10};
	
	aPuncturingCritMatrix["Ankle, inner"] = {};
	aPuncturingCritMatrix["Ankle, inner"][1] = {db=1};
	aPuncturingCritMatrix["Ankle, inner"][2] = {db=1};
	aPuncturingCritMatrix["Ankle, inner"][3] = {db=3};
	aPuncturingCritMatrix["Ankle, inner"][4] = {db=4,m=1};
	aPuncturingCritMatrix["Ankle, inner"][5] = {db=6,m=1};
	aPuncturingCritMatrix["Ankle, inner"][6] = {db=6,m=2,f=true};
	aPuncturingCritMatrix["Ankle, inner"][7] = {db=8,m=2,f=true};
	aPuncturingCritMatrix["Ankle, inner"][8] = {dm=2,d=1,m=3,f=true,ib=true};
	aPuncturingCritMatrix["Ankle, inner"][9] = {dm=2,d=2,f=true,m=4,ib=true};
	aPuncturingCritMatrix["Ankle, inner"][10] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Ankle, inner"][11] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Ankle, inner"][12] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Ankle, inner"][13] = {dm=2,d=2,t=1,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Ankle, inner"][14] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Ankle, inner"][15] = {dm=2,d=3,ib=true,b=1,f=true,m=5};
	aPuncturingCritMatrix["Ankle, inner"][16] = {dm=2,d=3,ib=true,b=1,f=true,m=6};
	aPuncturingCritMatrix["Ankle, inner"][17] = {dm=2,d=4,ib=true,b=1,f=true,m=7};
	aPuncturingCritMatrix["Ankle, inner"][18] = {dm=2,d=5,ib=true,mt=1,f=true,m=7};
	aPuncturingCritMatrix["Ankle, inner"][19] = {dm=2,d=5,b=1,ib=true,f=true,m=8};
	aPuncturingCritMatrix["Ankle, inner"][20] = {dm=2,b=1,ib=true,f=true,m=8,d=6};
	aPuncturingCritMatrix["Ankle, inner"][21] = {dm=2,d=6,b=1,ib=true,f=true,m=9};
	aPuncturingCritMatrix["Ankle, inner"][22] = {dm=2,d=6,ls=true,f=true,m=9};
	aPuncturingCritMatrix["Ankle, inner"][23] = {dm=2,d=6,ls=true,m=10,f=true};
	aPuncturingCritMatrix["Ankle, inner"][24] = {dm=2,d=7,ls=true,m=10,f=true};
	
	aPuncturingCritMatrix["Ankle, outer"] = {};
	aPuncturingCritMatrix["Ankle, outer"][1] = {db=1};
	aPuncturingCritMatrix["Ankle, outer"][2] = {db=1};
	aPuncturingCritMatrix["Ankle, outer"][3] = {db=3};
	aPuncturingCritMatrix["Ankle, outer"][4] = {db=4,m=1};
	aPuncturingCritMatrix["Ankle, outer"][5] = {db=6,m=1};
	aPuncturingCritMatrix["Ankle, outer"][6] = {db=6,m=2,f=true};
	aPuncturingCritMatrix["Ankle, outer"][7] = {db=8,m=2,f=true};
	aPuncturingCritMatrix["Ankle, outer"][8] = {dm=2,d=1,m=3,f=true,ib=true};
	aPuncturingCritMatrix["Ankle, outer"][9] = {dm=2,d=2,f=true,m=4,ib=true};
	aPuncturingCritMatrix["Ankle, outer"][10] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Ankle, outer"][11] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Ankle, outer"][12] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Ankle, outer"][13] = {dm=2,d=2,t=1,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Ankle, outer"][14] = {dm=2,d=3,ib=true,pb=true,f=true,m=5};
	aPuncturingCritMatrix["Ankle, outer"][15] = {dm=2,d=3,ib=true,pb=true,f=true,m=6};
	aPuncturingCritMatrix["Ankle, outer"][16] = {dm=2,d=3,ib=true,pb=true,b=1,f=true,m=6};
	aPuncturingCritMatrix["Ankle, outer"][17] = {dm=2,d=4,ib=true,pb=true,b=1,f=true,m=7};
	aPuncturingCritMatrix["Ankle, outer"][18] = {dm=2,d=4,ib=true,pb=true,mt=2,f=true,m=7};
	aPuncturingCritMatrix["Ankle, outer"][19] = {dm=2,d=5,ib=true,pb=true,mt=2,f=true,m=8};
	aPuncturingCritMatrix["Ankle, outer"][20] = {dm=2,ib=true,pb=true,bm=1,f=true,m=8,d=6};
	aPuncturingCritMatrix["Ankle, outer"][21] = {dm=2,d=6,ib=true,pb=true,bm=1,f=true,m=9};
	aPuncturingCritMatrix["Ankle, outer"][22] = {dm=2,d=6,ls=true,f=true,m=9};
	aPuncturingCritMatrix["Ankle, outer"][23] = {dm=2,d=6,ls=true,f=true,m=10};
	aPuncturingCritMatrix["Ankle, outer"][24] = {dm=2,d=7,ls=true,f=true,m=10};
	
	aPuncturingCritMatrix["Ankle, upper/Achilles"] = {};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][1] = {db=1};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][2] = {db=1};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][3] = {db=3};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][4] = {db=3};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][5] = {db=4,m=1};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][6] = {db=4,m=1};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][7] = {db=6,m=1};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][8] = {db=6,m=2};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][9] = {db=8,m=2};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][10] = {dm=2,d=1,m=3};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][11] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][12] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][13] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][14] = {dm=2,d=2,f=true,pb=true,m=5};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][15] = {dm=2,d=2,ib=true,f=true,m=6};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][16] = {dm=2,d=3,pb=true,f=true,m=6,ib=true};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][17] = {dm=2,d=3,pb=true,b=1,f=true,ib=true,m=7};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][18] = {dm=2,d=4,pb=true,b=1,f=true,m=8,ib=true};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][19] = {dm=2,d=5,pb=true,mt=1,ib=true,f=true,m=9};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][20] = {dm=2,d=5,pb=true,mt=2,f=true,m=10,ib=true};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][21] = {dm=2,pb=true,b=2,f=true,m=10,d=6,ib=true};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][22] = {dm=2,d=6,pb=true,b=2,f=true,m=10,ib=true};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][23] = {dm=2,ls=true,f=true,d=6,m=10};
	aPuncturingCritMatrix["Ankle, upper/Achilles"][24] = {dm=2,d=6,ls=true,f=true,m=10};
	
	aPuncturingCritMatrix["Shin"] = {};
	aPuncturingCritMatrix["Shin"][1] = {db=1};
	aPuncturingCritMatrix["Shin"][2] = {db=1};
	aPuncturingCritMatrix["Shin"][3] = {db=3};
	aPuncturingCritMatrix["Shin"][4] = {db=3};
	aPuncturingCritMatrix["Shin"][5] = {db=4};
	aPuncturingCritMatrix["Shin"][6] = {db=4};
	aPuncturingCritMatrix["Shin"][7] = {db=6,m=1};
	aPuncturingCritMatrix["Shin"][8] = {db=6,m=1};
	aPuncturingCritMatrix["Shin"][9] = {db=8,m=1};
	aPuncturingCritMatrix["Shin"][10] = {db=8,d=1,m=1};
	aPuncturingCritMatrix["Shin"][11] = {dm=2,d=2,f=true,m=1};
	aPuncturingCritMatrix["Shin"][12] = {dm=2,d=2,f=true,m=2};
	aPuncturingCritMatrix["Shin"][13] = {dm=2,d=2,f=true,m=2};
	aPuncturingCritMatrix["Shin"][14] = {dm=2,d=2,f=true,m=2};
	aPuncturingCritMatrix["Shin"][15] = {dm=2,d=2,ib=true,f=true,m=2};
	aPuncturingCritMatrix["Shin"][16] = {dm=2,d=3,ib=true,f=true,m=2};
	aPuncturingCritMatrix["Shin"][17] = {dm=2,d=3,ib=true,b=1,f=true,m=3};
	aPuncturingCritMatrix["Shin"][18] = {dm=2,d=4,ib=true,f=true,m=3};
	aPuncturingCritMatrix["Shin"][19] = {dm=2,d=5,ib=true,b=1,f=true,m=3};
	aPuncturingCritMatrix["Shin"][20] = {dm=2,d=5,ib=true,pb=true,b=2,f=true,m=3};
	aPuncturingCritMatrix["Shin"][21] = {dm=2,ib=true,b=2,f=true,m=4,d=6};
	aPuncturingCritMatrix["Shin"][22] = {dm=2,d=6,ib=true,bf=2,pb=true,f=true,m=4};
	aPuncturingCritMatrix["Shin"][23] = {dm=2,ls=true,f=true,d=6,m=10};
	aPuncturingCritMatrix["Shin"][24] = {dm=2,d=6,ls=true,f=true,m=10};

	aPuncturingCritMatrix["Calf"] = {};
	aPuncturingCritMatrix["Calf"][1] = {db=1};
	aPuncturingCritMatrix["Calf"][2] = {db=1};
	aPuncturingCritMatrix["Calf"][3] = {db=3};
	aPuncturingCritMatrix["Calf"][4] = {db=3};
	aPuncturingCritMatrix["Calf"][5] = {db=4,m=1};
	aPuncturingCritMatrix["Calf"][6] = {db=4,m=1};
	aPuncturingCritMatrix["Calf"][7] = {db=6,m=1};
	aPuncturingCritMatrix["Calf"][8] = {db=6,m=2};
	aPuncturingCritMatrix["Calf"][9] = {db=8,m=2};
	aPuncturingCritMatrix["Calf"][10] = {dm=2,d=1,m=3};
	aPuncturingCritMatrix["Calf"][11] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Calf"][12] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Calf"][13] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Calf"][14] = {dm=2,d=2,f=true,pb=true,m=5};
	aPuncturingCritMatrix["Calf"][15] = {dm=2,d=2,pb=true,f=true,m=5};
	aPuncturingCritMatrix["Calf"][16] = {dm=2,d=3,f=true,pb=true,m=6};
	aPuncturingCritMatrix["Calf"][17] = {dm=2,d=3,ib=true,pb=true,f=true,m=6};
	aPuncturingCritMatrix["Calf"][18] = {dm=2,d=4,ib=true,f=true,pb=true,m=6};
	aPuncturingCritMatrix["Calf"][19] = {dm=2,d=5,b=1,pb=true,f=true,m=6};
	aPuncturingCritMatrix["Calf"][20] = {dm=2,d=5,ib=true,pb=true,f=true,m=7};
	aPuncturingCritMatrix["Calf"][21] = {dm=2,b=2,f=true,pb=true,d=6,m=7};
	aPuncturingCritMatrix["Calf"][22] = {dm=2,d=6,ib=true,pb=true,bf=2,f=true,m=8};
	aPuncturingCritMatrix["Calf"][23] = {dm=2,ls=true,d=6,m=10};
	aPuncturingCritMatrix["Calf"][24] = {dm=2,d=6,ls=true,f=true,m=10};

	aPuncturingCritMatrix["Knee"] = {};
	aPuncturingCritMatrix["Knee"][1] = {db=1};
	aPuncturingCritMatrix["Knee"][2] = {db=1};
	aPuncturingCritMatrix["Knee"][3] = {db=3};
	aPuncturingCritMatrix["Knee"][4] = {db=4,m=1};
	aPuncturingCritMatrix["Knee"][5] = {db=6,m=1};
	aPuncturingCritMatrix["Knee"][6] = {db=6,m=2,f=true};
	aPuncturingCritMatrix["Knee"][7] = {db=8,m=2,f=true};
	aPuncturingCritMatrix["Knee"][8] = {dm=2,d=1,m=3,f=true,t=1};
	aPuncturingCritMatrix["Knee"][9] = {dm=2,d=2,f=true,m=4,ib=true};
	aPuncturingCritMatrix["Knee"][10] = {dm=2,d=2,f=true,m=5,t=1};
	aPuncturingCritMatrix["Knee"][11] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Knee"][12] = {dm=2,d=2,f=true,m=5,ib=true};
	aPuncturingCritMatrix["Knee"][13] = {dm=2,d=2,ib=true,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Knee"][14] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Knee"][15] = {dm=2,d=3,ib=true,b=1,f=true,m=5};
	aPuncturingCritMatrix["Knee"][16] = {dm=2,d=3,ib=true,b=1,f=true,m=6};
	aPuncturingCritMatrix["Knee"][17] = {dm=2,d=4,ib=true,b=2,f=true,m=7};
	aPuncturingCritMatrix["Knee"][18] = {dm=2,d=5,ib=true,b=2,f=true,m=7};
	aPuncturingCritMatrix["Knee"][19] = {dm=2,d=5,ib=true,mt=1,f=true,m=8};
	aPuncturingCritMatrix["Knee"][20] = {dm=2,b=3,ib=true,f=true,m=8,d=6};
	aPuncturingCritMatrix["Knee"][21] = {dm=2,d=6,ib=true,b=3,f=true,m=9};
	aPuncturingCritMatrix["Knee"][22] = {dm=2,d=6,ls=true,f=true,m=10};
	aPuncturingCritMatrix["Knee"][23] = {dm=2,d=6,ls=true,f=true,m=10};
	aPuncturingCritMatrix["Knee"][24] = {dm=2,d=7,ls=true,f=true,m=10};
		
	aPuncturingCritMatrix["Knee, back"] = {};
	aPuncturingCritMatrix["Knee, back"][1] = {db=1};
	aPuncturingCritMatrix["Knee, back"][2] = {db=1};
	aPuncturingCritMatrix["Knee, back"][3] = {db=3};
	aPuncturingCritMatrix["Knee, back"][4] = {db=4};
	aPuncturingCritMatrix["Knee, back"][5] = {db=6,m=1};
	aPuncturingCritMatrix["Knee, back"][6] = {db=6,m=1};
	aPuncturingCritMatrix["Knee, back"][7] = {db=8,m=2};
	aPuncturingCritMatrix["Knee, back"][8] = {dm=2,d=1,m=2};
	aPuncturingCritMatrix["Knee, back"][9] = {dm=2,d=2,f=true,m=3};
	aPuncturingCritMatrix["Knee, back"][10] = {dm=2,d=2,f=true,m=3};
	aPuncturingCritMatrix["Knee, back"][11] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Knee, back"][12] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Knee, back"][13] = {dm=2,d=2,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Knee, back"][14] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Knee, back"][15] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Knee, back"][16] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Knee, back"][17] = {dm=2,d=4,ib=true,f=true,m=6};
	aPuncturingCritMatrix["Knee, back"][18] = {dm=2,d=5,b=1,ib=true,f=true,m=6};
	aPuncturingCritMatrix["Knee, back"][19] = {dm=2,d=5,b=1,ib=true,f=tue,m=7};
	aPuncturingCritMatrix["Knee, back"][20] = {dm=2,mt=1,ib=true,f=true,m=7,d=6};
	aPuncturingCritMatrix["Knee, back"][21] = {dm=2,d=6,mt=1,ib=true,f=true,m=8};
	aPuncturingCritMatrix["Knee, back"][22] = {dm=2,bm=1,ib=true,f=true,d=6,m=8};
	aPuncturingCritMatrix["Knee, back"][23] = {dm=2,d=6,ls=true,m=10,u=true};
	aPuncturingCritMatrix["Knee, back"][24] = {dm=2,d=7,ls=true,m=10,u=true};
	
	aPuncturingCritMatrix["Hamstring"] = {};
	aPuncturingCritMatrix["Hamstring"][1] = {db=1};
	aPuncturingCritMatrix["Hamstring"][2] = {db=3};
	aPuncturingCritMatrix["Hamstring"][3] = {db=4,m=1};
	aPuncturingCritMatrix["Hamstring"][4] = {db=6,m=1};
	aPuncturingCritMatrix["Hamstring"][5] = {db=6,m=2};
	aPuncturingCritMatrix["Hamstring"][6] = {db=8,m=2};
	aPuncturingCritMatrix["Hamstring"][7] = {dm=2,d=1,m=3};
	aPuncturingCritMatrix["Hamstring"][8] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Hamstring"][9] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Hamstring"][10] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Hamstring"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aPuncturingCritMatrix["Hamstring"][12] = {dm=2,d=2,mt=1,f=true,m=5};
	aPuncturingCritMatrix["Hamstring"][13] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Hamstring"][14] = {dm=2,d=3,ib=true,f=true,m=5};
	aPuncturingCritMatrix["Hamstring"][15] = {dm=2,d=3,ib=true,f=true,m=6};
	aPuncturingCritMatrix["Hamstring"][16] = {dm=2,d=3,ib=true,pb=true,f=true,m=6};
	aPuncturingCritMatrix["Hamstring"][17] = {dm=2,d=4,ib=true,f=true,m=6};
	aPuncturingCritMatrix["Hamstring"][18] = {dm=2,d=5,ib=true,f=true,m=7};
	aPuncturingCritMatrix["Hamstring"][19] = {dm=2,b=1,pb=true,ib=true,f=true,m=7,d=6};
	aPuncturingCritMatrix["Hamstring"][20] = {dm=2,d=6,ib=true,pb=true,b=1,f=true,m=8};
	aPuncturingCritMatrix["Hamstring"][21] = {dm=2,d=6,ls=true,m=10,u=true};
	aPuncturingCritMatrix["Hamstring"][22] = {dm=2,d=6,ls=true,m=10,u=true};
	aPuncturingCritMatrix["Hamstring"][23] = {dm=2,d=7,ls=true,m=10,u=true};
	aPuncturingCritMatrix["Hamstring"][24] = {dm=3,d=8,ls=true,m=10,u=true};
	
	aPuncturingCritMatrix["Thigh"] = {};
	aPuncturingCritMatrix["Thigh"][1] = {db=1};
	aPuncturingCritMatrix["Thigh"][2] = {db=3};
	aPuncturingCritMatrix["Thigh"][3] = {db=4,m=1};
	aPuncturingCritMatrix["Thigh"][4] = {db=6,m=1};
	aPuncturingCritMatrix["Thigh"][5] = {db=6,m=2};
	aPuncturingCritMatrix["Thigh"][6] = {db=8,m=2};
	aPuncturingCritMatrix["Thigh"][7] = {dm=2,d=1,m=3};
	aPuncturingCritMatrix["Thigh"][8] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Thigh"][9] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Thigh"][10] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Thigh"][11] = {dm=2,d=2,f=true,m=5};
	aPuncturingCritMatrix["Thigh"][12] = {dm=2,d=2,mt=1,f=true,m=5};
	aPuncturingCritMatrix["Thigh"][13] = {dm=2,d=3,ib=true,f=true,m=5,pb=true};
	aPuncturingCritMatrix["Thigh"][14] = {dm=2,d=3,pb=true,f=true,m=5};
	aPuncturingCritMatrix["Thigh"][15] = {dm=2,d=3,b=1,f=true,m=6,pb=true};
	aPuncturingCritMatrix["Thigh"][16] = {dm=2,d=3,b=1,pb=true,f=true,m=6};
	aPuncturingCritMatrix["Thigh"][17] = {dm=2,d=4,b=1,f=true,m=6,pb=true};
	aPuncturingCritMatrix["Thigh"][18] = {dm=2,d=5,pb=true,f=true,m=7};
	aPuncturingCritMatrix["Thigh"][19] = {dm=2,mt=4,f=true,m=7,d=6,pb=true};
	aPuncturingCritMatrix["Thigh"][20] = {dm=2,d=6,b=1,f=true,m=8,pb=true};
	aPuncturingCritMatrix["Thigh"][21] = {dm=2,ls=true,pb=true,f=true,d=6,m=10};
	aPuncturingCritMatrix["Thigh"][22] = {dm=2,d=6,ls=true,m=10,u=true};
	aPuncturingCritMatrix["Thigh"][23] = {dm=2,d=7,ls=true,m=10,u=true};
	aPuncturingCritMatrix["Thigh"][24] = {dm=3,d=8,ls=true,m=10,u=true};
	
	aPuncturingCritMatrix["Hip"] = {};
	aPuncturingCritMatrix["Hip"][1] = {db=1};
	aPuncturingCritMatrix["Hip"][2] = {db=3};
	aPuncturingCritMatrix["Hip"][3] = {db=4,m=1};
	aPuncturingCritMatrix["Hip"][4] = {db=6,m=1};
	aPuncturingCritMatrix["Hip"][5] = {db=8,m=2};
	aPuncturingCritMatrix["Hip"][6] = {dm=2,m=2};
	aPuncturingCritMatrix["Hip"][7] = {dm=2,d=1,m=3};
	aPuncturingCritMatrix["Hip"][8] = {dm=2,d=2,f=true,m=4};
	aPuncturingCritMatrix["Hip"][9] = {dm=2,d=2,t=1,f=true,m=5};
	aPuncturingCritMatrix["Hip"][10] = {dm=2,d=2,t=1,f=true,m=5};
	aPuncturingCritMatrix["Hip"][11] = {dm=3,d=2,f=true,t=1,m=5};
	aPuncturingCritMatrix["Hip"][12] = {dm=3,d=2,bm=1,f=true,m=5};
	aPuncturingCritMatrix["Hip"][13] = {dm=3,d=3,bf=2,f=true,m=5};
	aPuncturingCritMatrix["Hip"][14] = {dm=3,d=3,b=2,f=true,m=5}
	aPuncturingCritMatrix["Hip"][15] = {dm=3,d=3,b=3,pb=true,v=1,f=true,m=6};
	aPuncturingCritMatrix["Hip"][16] = {dm=3,d=3,b=3,f=true,m=6};
	aPuncturingCritMatrix["Hip"][17] = {dm=3,d=5,b=3,f=true,m=6};
	aPuncturingCritMatrix["Hip"][18] = {dm=3,d=6,b=4,f=true,m=7};
	aPuncturingCritMatrix["Hip"][19] = {dm=3,b=4,ib=true,v=1,f=true,m=7,d=7};
	aPuncturingCritMatrix["Hip"][20] = {dm=3,b=4,ib=true,v=1,f=true,m=8,d=7};
	aPuncturingCritMatrix["Hip"][21] = {dm=3,ib=true,v=2,f=true,m=8,d=8};
	aPuncturingCritMatrix["Hip"][22] = {dm=3,ib=true,v=2,m=9,u=true,d=8};
	aPuncturingCritMatrix["Hip"][23] = {dm=4,ib=true,v=2,m=9,u=true,d=9};
	aPuncturingCritMatrix["Hip"][24] = {dm=4,ib=true,v=2,m=10,u=true,d=9};

	aPuncturingCritMatrix["Groin"] = {};
	aPuncturingCritMatrix["Groin"][1] = {db=1,f=true,h=1};
	aPuncturingCritMatrix["Groin"][2] = {db=3,f=true,h=1};
	aPuncturingCritMatrix["Groin"][3] = {db=4,f=true,h=2};
	aPuncturingCritMatrix["Groin"][4] = {db=4,m=1,f=true,h=2};
	aPuncturingCritMatrix["Groin"][5] = {db=6,m=1,f=true,h=2};
	aPuncturingCritMatrix["Groin"][6] = {db=6,m=1,f=true,h=3};
	aPuncturingCritMatrix["Groin"][7] = {db=8,m=2,f=true,h=3};
	aPuncturingCritMatrix["Groin"][8] = {db=8,m=2,f=true,h=4};
	aPuncturingCritMatrix["Groin"][9] = {dm=2,m=2,f=true,h=4};
	aPuncturingCritMatrix["Groin"][10] = {dm=2,m=3,f=true,h=4};
	aPuncturingCritMatrix["Groin"][11] = {dm=2,m=3,f=true,h=5};
	aPuncturingCritMatrix["Groin"][12] = {dm=3,m=3,f=true,h=5};
	aPuncturingCritMatrix["Groin"][13] = {dm=3,m=4,f=true,h=5};
	aPuncturingCritMatrix["Groin"][14] = {dm=3,m=4,f=true,h=6};
	aPuncturingCritMatrix["Groin"][15] = {dm=3,m=4,f=true,h=6,ib=true,v=1};
	aPuncturingCritMatrix["Groin"][16] = {dm=3,m=4,f=true,h=6,ib=true,v=1};
	aPuncturingCritMatrix["Groin"][17] = {dm=3,m=4,f=true,h=7,ib=true,v=1};
	aPuncturingCritMatrix["Groin"][18] = {dm=3,m=4,f=true,h=8,ib=true,v=2};
	aPuncturingCritMatrix["Groin"][19] = {dm=3,m=4,f=true,h=9,ib=true,v=2};
	aPuncturingCritMatrix["Groin"][20] = {dm=3,m=5,f=true,h=10,ib=true,v=2};
	aPuncturingCritMatrix["Groin"][21] = {dm=3,m=5,f=true,h=9,ib=true,v=2,b=1};
	aPuncturingCritMatrix["Groin"][22] = {dm=3,m=5,f=true,h=10,ib=true,v=2,b=1};
	aPuncturingCritMatrix["Groin"][23] = {dm=3,m=5,f=true,h=10,ib=true,v=2,mt=1};
	aPuncturingCritMatrix["Groin"][24] = {dm=3,m=5,f=true,h=10,ib=true,v=2};
	
	aPuncturingCritMatrix["Buttock"] = {};
	aPuncturingCritMatrix["Buttock"][1] = {db=1};
	aPuncturingCritMatrix["Buttock"][2] = {db=3};
	aPuncturingCritMatrix["Buttock"][3] = {db=4};
	aPuncturingCritMatrix["Buttock"][4] = {db=6};
	aPuncturingCritMatrix["Buttock"][5] = {db=8};
	aPuncturingCritMatrix["Buttock"][6] = {dm=2};
	aPuncturingCritMatrix["Buttock"][7] = {dm=2,m=1};
	aPuncturingCritMatrix["Buttock"][8] = {dm=1,m=1};
	aPuncturingCritMatrix["Buttock"][9] = {dm=2,m=2};
	aPuncturingCritMatrix["Buttock"][10] = {dm=2,m=2,mt=1};
	aPuncturingCritMatrix["Buttock"][11] = {dm=3,m=3};
	aPuncturingCritMatrix["Buttock"][12] = {dm=3,m=3,d=1};
	aPuncturingCritMatrix["Buttock"][13] = {dm=3,m=3,d=1,t=1};
	aPuncturingCritMatrix["Buttock"][14] = {dm=3,m=3,d=2,pb=true};
	aPuncturingCritMatrix["Buttock"][15] = {dm=3,m=3,d=2,b=1,f=true};
	aPuncturingCritMatrix["Buttock"][16] = {dm=3,m=3,d=2,pb=true,f=true,ib=true};
	aPuncturingCritMatrix["Buttock"][17] = {dm=3,m=3,d=2,pb=true,f=true,ib=true};
	aPuncturingCritMatrix["Buttock"][18] = {dm=3,m=4,d=2,b=2,f=true};
	aPuncturingCritMatrix["Buttock"][19] = {dm=3,m=5,d=3,b=2,f=true};
	aPuncturingCritMatrix["Buttock"][20] = {dm=3,m=5,d=3,b=2,f=true};
	aPuncturingCritMatrix["Buttock"][21] = {dm=3,m=5,d=4,b=3,f=true,pb=true};
	aPuncturingCritMatrix["Buttock"][22] = {dm=3,m=6,d=5,b=3,f=true,pb=true};
	aPuncturingCritMatrix["Buttock"][23] = {dm=4,m=7,d=6,ib=true,f=true};
	aPuncturingCritMatrix["Buttock"][24] = {dm=4,m=8,d=7,ib=true,f=true,pb=true};

	aPuncturingCritMatrix["Abdomen, Lower"] = {};
	aPuncturingCritMatrix["Abdomen, Lower"][1] = {db=3};
	aPuncturingCritMatrix["Abdomen, Lower"][2] = {db=4};
	aPuncturingCritMatrix["Abdomen, Lower"][3] = {db=6};
	aPuncturingCritMatrix["Abdomen, Lower"][4] = {db=8};
	aPuncturingCritMatrix["Abdomen, Lower"][5] = {dm=2};
	aPuncturingCritMatrix["Abdomen, Lower"][6] = {dm=2, ws=true};
	aPuncturingCritMatrix["Abdomen, Lower"][7] = {dm=2,ib=true};
	aPuncturingCritMatrix["Abdomen, Lower"][8] = {dm=2,ib=true,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][9] = {dm=3,ws=true,v=1};
	aPuncturingCritMatrix["Abdomen, Lower"][10] = {dm=3,w=true,ib=true,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][11] = {dm=3,w=true,v=1,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][12] = {dm=3,mt=1,w=true,ib=true,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][13] = {dm=3,mt=1,v=2,w=true,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][14] = {dm=3,ib=true,v=2,f=true,pb=true};
	aPuncturingCritMatrix["Abdomen, Lower"][15] = {dm=3,pb=true,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][16] = {dm=3,a=1,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][17] = {dm=3,a=2,ib=true,v=3,f=true,pb=true};
	aPuncturingCritMatrix["Abdomen, Lower"][18] = {dm=3,a=3,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][19] = {dm=3,a=3,ib=true,v=4,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][20] = {dm=3,a=3,pb=true,v=4,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][21] = {dm=3,ib=true,u=true,v=4,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][22] = {dm=3,b=2,ib=true,v=4,u=true,f=true};
	aPuncturingCritMatrix["Abdomen, Lower"][23] = {dm=4,b=3,ib=true,v=4,pb=true,u=true};
	aPuncturingCritMatrix["Abdomen, Lower"][24] = {dead="run thru"};

	aPuncturingCritMatrix["Side, lower"] = {};
	aPuncturingCritMatrix["Side, lower"][1] = {db=1};
	aPuncturingCritMatrix["Side, lower"][2] = {db=3};
	aPuncturingCritMatrix["Side, lower"][3] = {db=4};
	aPuncturingCritMatrix["Side, lower"][4] = {db=6};
	aPuncturingCritMatrix["Side, lower"][5] = {db=8};
	aPuncturingCritMatrix["Side, lower"][6] = {dm=2};
	aPuncturingCritMatrix["Side, lower"][7] = {dm=2,a=1};
	aPuncturingCritMatrix["Side, lower"][8] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Side, lower"][9] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Side, lower"][10] = {dm=3,a=2,ws=true,mt=1};
	aPuncturingCritMatrix["Side, lower"][11] = {dm=3,a=2,ws=true,mt=2};
	aPuncturingCritMatrix["Side, lower"][12] = {dm=3,a=2,ws=true};
	aPuncturingCritMatrix["Side, lower"][13] = {dm=3,a=2,w=true};
	aPuncturingCritMatrix["Side, lower"][14] = {dm=3,a=2,pb=true,w=true};
	aPuncturingCritMatrix["Side, lower"][15] = {dm=3,a=2,f=true};
	aPuncturingCritMatrix["Side, lower"][16] = {dm=3,a=2,pb=true,f=true};
	aPuncturingCritMatrix["Side, lower"][17] = {dm=3,a=3,pb=true,f=true};
	aPuncturingCritMatrix["Side, lower"][18] = {dm=3,a=3,ib=true,pb=true,f=true};
	aPuncturingCritMatrix["Side, lower"][19] = {dm=3,a=3,ib=true,pb=true,v=1,f=true};
	aPuncturingCritMatrix["Side, lower"][20] = {dm=3,a=4,b=1,f=true};
	aPuncturingCritMatrix["Side, lower"][21] = {dm=3,u=true,b=1,pb=true};
	aPuncturingCritMatrix["Side, lower"][22] = {dm=3,b=2,ib=true,v=2,u=true};
	aPuncturingCritMatrix["Side, lower"][23] = {dm=4,b=2,v=2,ib=true,pb=true,u=true};
	aPuncturingCritMatrix["Side, lower"][24] = {dead="run thru"};
	
	aPuncturingCritMatrix["Abdomen, upper"] = {};
	aPuncturingCritMatrix["Abdomen, upper"][1] = {db=3};
	aPuncturingCritMatrix["Abdomen, upper"][2] = {db=4};
	aPuncturingCritMatrix["Abdomen, upper"][3] = {db=6};
	aPuncturingCritMatrix["Abdomen, upper"][4] = {db=8};
	aPuncturingCritMatrix["Abdomen, upper"][5] = {dm=2};
	aPuncturingCritMatrix["Abdomen, upper"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Abdomen, upper"][7] = {dm=2,ib=true};
	aPuncturingCritMatrix["Abdomen, upper"][8] = {dm=2,ib=true,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][9] = {dm=3,ws=true,v=1};
	aPuncturingCritMatrix["Abdomen, upper"][10] = {dm=3,w=true,ib=true,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][11] = {dm=3,w=true,v=1,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][12] = {dm=3,mt=1,w=true,ib=true,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][13] = {dm=3,mt=1,v=1,w=true,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][14] = {dm=3,ib=true,v=2,pb=true,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][15] = {dm=3,ib=true,v=2,pb=true,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][16] = {dm=3,a=1,ib=true,v=2,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][17] = {dm=3,a=2,ib=true,v=2,f=true,pb=true};
	aPuncturingCritMatrix["Abdomen, upper"][18] = {dm=3,a=3,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][19] = {dm=3,a=3,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][20] = {dm=3,a=3,pb=true,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][21] = {dm=3,ib=true,u=true,v=3,f=true};
	aPuncturingCritMatrix["Abdomen, upper"][22] = {dm=3,b=1,v=3,ib=true,u=true};
	aPuncturingCritMatrix["Abdomen, upper"][23] = {dm=4,b=2,v=3,ib=true,pb=true,u=true};
	aPuncturingCritMatrix["Abdomen, upper"][24] = {dead="run thru"};

	aPuncturingCritMatrix["Back, small of"] = {};
	aPuncturingCritMatrix["Back, small of"][1] = {db=3};
	aPuncturingCritMatrix["Back, small of"][2] = {db=4};
	aPuncturingCritMatrix["Back, small of"][3] = {db=6};
	aPuncturingCritMatrix["Back, small of"][4] = {db=8};
	aPuncturingCritMatrix["Back, small of"][5] = {dm=2};
	aPuncturingCritMatrix["Back, small of"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Back, small of"][7] = {dm=2,ib=true};
	aPuncturingCritMatrix["Back, small of"][8] = {dm=2,w=true,ib=true};
	aPuncturingCritMatrix["Back, small of"][9] = {dm=2,w=true,mt=1};
	aPuncturingCritMatrix["Back, small of"][10] = {dm=3,w=true,ib=true};
	aPuncturingCritMatrix["Back, small of"][11] = {dm=3,w=true,mt=1,ib=true};
	aPuncturingCritMatrix["Back, small of"][12] = {dm=3,mt=2,w=true,ib=true};
	aPuncturingCritMatrix["Back, small of"][13] = {dm=3,mt=2,v=1,w=true};
	aPuncturingCritMatrix["Back, small of"][14] = {dm=3,ib=true,v=1,pb=true};
	aPuncturingCritMatrix["Back, small of"][15] = {dm=3,ib=true,pb=true,v=1};
	aPuncturingCritMatrix["Back, small of"][16] = {dm=3,b=1,ib=true,v=1};
	aPuncturingCritMatrix["Back, small of"][17] = {dm=3,b=1,v=2,f=true,pb=true};
	aPuncturingCritMatrix["Back, small of"][18] = {dm=3,mt=2,ib=true,v=2,f=true};
	aPuncturingCritMatrix["Back, small of"][19] = {dm=3,b=1,ib=true,v=2,f=true};
	aPuncturingCritMatrix["Back, small of"][20] = {dm=3,b=1,pb=true,ib=true,v=2,f=true};
	aPuncturingCritMatrix["Back, small of"][21] = {dm=3,ib=true,u=true,v=2};
	aPuncturingCritMatrix["Back, small of"][22] = {dm=3,ib=true,v=2,u=true};
	aPuncturingCritMatrix["Back, small of"][23] = {dm=4,ib=true,v=2,pb=true,u=true};
	aPuncturingCritMatrix["Back, small of"][24] = {dead="run thru"};

	aPuncturingCritMatrix["Back, lower"] = {};
	aPuncturingCritMatrix["Back, lower"][1] = {db=3};
	aPuncturingCritMatrix["Back, lower"][2] = {db=4};
	aPuncturingCritMatrix["Back, lower"][3] = {db=6};
	aPuncturingCritMatrix["Back, lower"][4] = {db=8};
	aPuncturingCritMatrix["Back, lower"][5] = {dm=2};
	aPuncturingCritMatrix["Back, lower"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Back, lower"][7] = {dm=2,ib=true};
	aPuncturingCritMatrix["Back, lower"][8] = {dm=3,ws=true,ib=true};
	aPuncturingCritMatrix["Back, lower"][9] = {dm=3,ws=true,mt=1};
	aPuncturingCritMatrix["Back, lower"][10] = {dm=3,w=true,ib=true,f=true};
	aPuncturingCritMatrix["Back, lower"][11] = {dm=3,w=true,b=1,f=true};
	aPuncturingCritMatrix["Back, lower"][12] = {dm=3,mt=1,w=true,ib=true,f=true};
	aPuncturingCritMatrix["Back, lower"][13] = {dm=3,mt=1,w=true,f=true};
	aPuncturingCritMatrix["Back, lower"][14] = {dm=3,b=1,pb=true,f=true};
	aPuncturingCritMatrix["Back, lower"][15] = {dm=3,b=1,ib=true,v=1,f=true};
	aPuncturingCritMatrix["Back, lower"][16] = {dm=3,a=1,ib=true,v=1,f=true};
	aPuncturingCritMatrix["Back, lower"][17] = {dm=3,a=2,ib=true,v=1,f=true,b=1};
	aPuncturingCritMatrix["Back, lower"][18] = {dm=3,a=3,ib=true,v=2,b=1,f=true};
	aPuncturingCritMatrix["Back, lower"][19] = {dm=3,a=3,ib=true,v=2,f=true};
	aPuncturingCritMatrix["Back, lower"][20] = {dm=3,a=3,ib=true,b=1,v=2,f=true};
	aPuncturingCritMatrix["Back, lower"][21] = {dm=3,u=true,b=1,pb=true,ib=true,v=2};
	aPuncturingCritMatrix["Back, lower"][22] = {dm=3,b=1,ib=true,v=2,u=true};
	aPuncturingCritMatrix["Back, lower"][23] = {dm=4,b=1,ib=true,v=2,pb=true,u=true};
	aPuncturingCritMatrix["Back, lower"][24] = {dead="run thru"};

	aPuncturingCritMatrix["Chest"] = {};
	aPuncturingCritMatrix["Chest"][1] = {db=3};
	aPuncturingCritMatrix["Chest"][2] = {db=4};
	aPuncturingCritMatrix["Chest"][3] = {db=6};
	aPuncturingCritMatrix["Chest"][4] = {db=8};
	aPuncturingCritMatrix["Chest"][5] = {dm=2};
	aPuncturingCritMatrix["Chest"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Chest"][7] = {dm=2,ws=true,t=1};
	aPuncturingCritMatrix["Chest"][8] = {dm=2,w=true,t=1};
	aPuncturingCritMatrix["Chest"][9] = {dm=2,w=true,t=2,ib=true};
	aPuncturingCritMatrix["Chest"][10] = {dm=3,w=true,t=2};
	aPuncturingCritMatrix["Chest"][11] = {dm=3,w=true,bm=1};
	aPuncturingCritMatrix["Chest"][12] = {dm=3,bf=1,w=true,ib=true};
	aPuncturingCritMatrix["Chest"][13] = {dm=3,mt=2,t=3,w=true};
	aPuncturingCritMatrix["Chest"][14] = {dm=3,ib=true,v=1,b=2};
	aPuncturingCritMatrix["Chest"][15] = {dm=3,ib=true,pb=true,v=1,b=2};
	aPuncturingCritMatrix["Chest"][16] = {dm=3,ib=true,mt=3,v=2};
	aPuncturingCritMatrix["Chest"][17] = {dm=3,ib=true,b=2,f=true,pb=true};
	aPuncturingCritMatrix["Chest"][18] = {dm=3,mt=3,ib=true,v=3,f=true};
	aPuncturingCritMatrix["Chest"][19] = {dm=3,ib=true,b=3,v=3,f=true};
	aPuncturingCritMatrix["Chest"][20] = {dm=3,ib=true,b=3,v=3,f=true};
	aPuncturingCritMatrix["Chest"][21] = {dm=3,ib=true,b=4,pb=true,u=true,v=3};
	aPuncturingCritMatrix["Chest"][22] = {dm=3,ib=true,bm=4,mt=3,v=3,u=true};
	aPuncturingCritMatrix["Chest"][23] = {dm=4,ib=true,bm=4,v=3,pb=true,u=true};
	aPuncturingCritMatrix["Chest"][24] = {dead="run thru"};
	
	aPuncturingCritMatrix["Side, upper"] = {};
	aPuncturingCritMatrix["Side, upper"][1] = {db=3};
	aPuncturingCritMatrix["Side, upper"][2] = {db=4};
	aPuncturingCritMatrix["Side, upper"][3] = {db=6};
	aPuncturingCritMatrix["Side, upper"][4] = {db=8};
	aPuncturingCritMatrix["Side, upper"][5] = {dm=2};
	aPuncturingCritMatrix["Side, upper"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Side, upper"][7] = {dm=2,ws=true,t=1};
	aPuncturingCritMatrix["Side, upper"][8] = {dm=2,w=true,t=1};
	aPuncturingCritMatrix["Side, upper"][9] = {dm=2,w=true,t=1,ib=true};
	aPuncturingCritMatrix["Side, upper"][10] = {dm=3,w=true,t=2};
	aPuncturingCritMatrix["Side, upper"][11] = {dm=3,w=true,bm=1};
	aPuncturingCritMatrix["Side, upper"][12] = {dm=3,bm=1,w=true,v=1};
	aPuncturingCritMatrix["Side, upper"][13] = {dm=3,t=2,v=1,w=true};
	aPuncturingCritMatrix["Side, upper"][14] = {dm=3,ib=true,v=1,b=2,w=true};
	aPuncturingCritMatrix["Side, upper"][15] = {dm=3,b=2,ib=true,v=1,w=true};
	aPuncturingCritMatrix["Side, upper"][16] = {dm=3,b=2,ib=true,v=1,w};
	aPuncturingCritMatrix["Side, upper"][17] = {dm=3,b=2,ib=true,v=1,f=true,w=true};
	aPuncturingCritMatrix["Side, upper"][18] = {dm=3,b=2,ib=true,v=1,f=true,w=true};
	aPuncturingCritMatrix["Side, upper"][19] = {dm=3,b=2,ib=true,v=1,f=true,w=true};
	aPuncturingCritMatrix["Side, upper"][20] = {dm=3,b=2,pb=true,ib=true,v=1,f=true};
	aPuncturingCritMatrix["Side, upper"][21] = {dm=3,bf=2,pb=true,ib=true,v=1};
	aPuncturingCritMatrix["Side, upper"][22] = {dm=3,bm=2,mt=2,ib=true,v=1,u=true};
	aPuncturingCritMatrix["Side, upper"][23] = {dm=4,bm=2,ib=true,v=1,pb=true,u=true};
	aPuncturingCritMatrix["Side, upper"][24] = {dead="run thru"};
	
	aPuncturingCritMatrix["Back, upper"] = {};
	aPuncturingCritMatrix["Back, upper"][1] = {db=3};
	aPuncturingCritMatrix["Back, upper"][2] = {db=4};
	aPuncturingCritMatrix["Back, upper"][3] = {db=6};
	aPuncturingCritMatrix["Back, upper"][4] = {db=8};
	aPuncturingCritMatrix["Back, upper"][5] = {dm=2};
	aPuncturingCritMatrix["Back, upper"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Back, upper"][7] = {dm=2,ws=true};
	aPuncturingCritMatrix["Back, upper"][8] = {dm=2,w=true};
	aPuncturingCritMatrix["Back, upper"][9] = {dm=2,w=true,mt=1};
	aPuncturingCritMatrix["Back, upper"][10] = {dm=3,w=true,mt=1};
	aPuncturingCritMatrix["Back, upper"][11] = {dm=3,w=true,f=true};
	aPuncturingCritMatrix["Back, upper"][12] = {dm=3,t=1,w=true};
	aPuncturingCritMatrix["Back, upper"][13] = {dm=3,mt=2,f=true,w=true};
	aPuncturingCritMatrix["Back, upper"][14] = {dm=3,f=true,b=1};
	aPuncturingCritMatrix["Back, upper"][15] = {dm=3,pb=true,f=true};
	aPuncturingCritMatrix["Back, upper"][16] = {dm=3,ib=true,v=1};
	aPuncturingCritMatrix["Back, upper"][17] = {dm=3,b=1,f=true,ib=true,v=1};
	aPuncturingCritMatrix["Back, upper"][18] = {dm=3,b=1,ib=true,v=1};
	aPuncturingCritMatrix["Back, upper"][19] = {dm=3,b=2,pb=true};
	aPuncturingCritMatrix["Back, upper"][20] = {dm=3,b=2,ib=true,v=1,pb=true};
	aPuncturingCritMatrix["Back, upper"][21] = {dm=3,bf=2,ib=true,u=true,pb=true};
	aPuncturingCritMatrix["Back, upper"][22] = {dm=3,bm=2,ib=true,v=1,pb=true,u=true};
	aPuncturingCritMatrix["Back, upper"][23] = {dm=4,ib=true,v=1,pb=true,u=true};
	aPuncturingCritMatrix["Back, upper"][24] = {dead="run thru"};
	
	aPuncturingCritMatrix["Back, upper middle"] = {};
	aPuncturingCritMatrix["Back, upper middle"][1] = {db=3};
	aPuncturingCritMatrix["Back, upper middle"][2] = {db=4};
	aPuncturingCritMatrix["Back, upper middle"][3] = {db=6};
	aPuncturingCritMatrix["Back, upper middle"][4] = {db=8};
	aPuncturingCritMatrix["Back, upper middle"][5] = {dm=2};
	aPuncturingCritMatrix["Back, upper middle"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Back, upper middle"][7] = {dm=2,ws=true};
	aPuncturingCritMatrix["Back, upper middle"][8] = {dm=2,w=true};
	aPuncturingCritMatrix["Back, upper middle"][9] = {dm=2,w=true,mt=1};
	aPuncturingCritMatrix["Back, upper middle"][10] = {dm=3,w=true,mt=1};
	aPuncturingCritMatrix["Back, upper middle"][11] = {dm=3,w=true,f=true};
	aPuncturingCritMatrix["Back, upper middle"][12] = {dm=3,t=1,w=true};
	aPuncturingCritMatrix["Back, upper middle"][13] = {dm=3,mt=1,f=true,w=true};
	aPuncturingCritMatrix["Back, upper middle"][14] = {dm=3,f=true,b=1};
	aPuncturingCritMatrix["Back, upper middle"][15] = {dm=3,pb=true,f=true};
	aPuncturingCritMatrix["Back, upper middle"][16] = {dm=3,ib=true,v=1};
	aPuncturingCritMatrix["Back, upper middle"][17] = {dm=3,b=1,f=true,ib=true,v=1};
	aPuncturingCritMatrix["Back, upper middle"][18] = {dm=3,b=1,ib=true,v=1};
	aPuncturingCritMatrix["Back, upper middle"][19] = {dm=3,b=2,pb=true};
	aPuncturingCritMatrix["Back, upper middle"][20] = {dm=3,b=2,ib=true,v=1,pb=true};
	aPuncturingCritMatrix["Back, upper middle"][21] = {dm=3,bf=2,ib=true,u=true,pb=true};
	aPuncturingCritMatrix["Back, upper middle"][22] = {dm=3,bm=2,ib=true,v=1,pb=true,u=true};
	aPuncturingCritMatrix["Back, upper middle"][23] = {dm=4,ib=true,v=1,pb=true,u=true};
	aPuncturingCritMatrix["Back, upper middle"][24] = {dead="run thru"};
	
	aPuncturingCritMatrix["Armpit"] = {};
	aPuncturingCritMatrix["Armpit"][1] = {db=1};
	aPuncturingCritMatrix["Armpit"][2] = {db=3};
	aPuncturingCritMatrix["Armpit"][3] = {db=4};
	aPuncturingCritMatrix["Armpit"][4] = {db=6};
	aPuncturingCritMatrix["Armpit"][5] = {db=8};
	aPuncturingCritMatrix["Armpit"][6] = {dm=2,ws=true};
	aPuncturingCritMatrix["Armpit"][7] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Armpit"][8] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Armpit"][9] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Armpit"][10] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Armpit"][11] = {dm=2,a=3,d=1,ws=true};
	aPuncturingCritMatrix["Armpit"][12] = {dm=2,a=3,d=1,w=true};
	aPuncturingCritMatrix["Armpit"][13] = {dm=3,a=3,d=1,w=true};
	aPuncturingCritMatrix["Armpit"][14] = {dm=3,a=3,d=1,w=true};
	aPuncturingCritMatrix["Armpit"][15] = {dm=3,a=3,d=2,w=true};
	aPuncturingCritMatrix["Armpit"][16] = {dm=3,a=3,d=2,pb=true,w=true};
	aPuncturingCritMatrix["Armpit"][17] = {dm=3,a=3,d=2,ib=true,w=true};
	aPuncturingCritMatrix["Armpit"][18] = {dm=3,a=3,d=2,ib=true,pb=true,w=true};
	aPuncturingCritMatrix["Armpit"][19] = {dm=3,a=3,d=2,mt=1,pb=true};
	aPuncturingCritMatrix["Armpit"][20] = {dm=3,a=3,d=2,b=1,pb=true};
	aPuncturingCritMatrix["Armpit"][21] = {dm=3,a=3,d=2,b=2,pb=true,ib=true,w=true};
	aPuncturingCritMatrix["Armpit"][22] = {dm=3,a=3,d=2,mt=2,pb=true,ib=true};
	aPuncturingCritMatrix["Armpit"][23] = {dm=3,a=3,d=2,b=3,pb=true,ib=true};
	aPuncturingCritMatrix["Armpit"][24] = {dm=3,a=3,d=2,ls=true,w=true};
	
	aPuncturingCritMatrix["Arm, upper outer"] = {};
	aPuncturingCritMatrix["Arm, upper outer"][1] = {db=1};
	aPuncturingCritMatrix["Arm, upper outer"][2] = {db=3};
	aPuncturingCritMatrix["Arm, upper outer"][3] = {db=4};
	aPuncturingCritMatrix["Arm, upper outer"][4] = {db=6};
	aPuncturingCritMatrix["Arm, upper outer"][5] = {db=6};
	aPuncturingCritMatrix["Arm, upper outer"][6] = {db=8};
	aPuncturingCritMatrix["Arm, upper outer"][7] = {dm=2};
	aPuncturingCritMatrix["Arm, upper outer"][8] = {dm=2,ws=true};
	aPuncturingCritMatrix["Arm, upper outer"][9] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Arm, upper outer"][10] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Arm, upper outer"][11] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Arm, upper outer"][12] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Arm, upper outer"][13] = {dm=2,a=3,ws=true};
	aPuncturingCritMatrix["Arm, upper outer"][14] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][15] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][16] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][17] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][18] = {dm=2,a=3,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][19] = {dm=2,a=3,mt=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][20] = {dm=2,a=3,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][21] = {dm=2,a=4,pb=true,mt=2,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][22] = {dm=2,a=4,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][23] = {dm=2,a=4,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper outer"][24] = {dm=2,a=4,ls=true,w=true};
	
	aPuncturingCritMatrix["Arm, upper inner"] = {};
	aPuncturingCritMatrix["Arm, upper inner"][1] = {db=1};
	aPuncturingCritMatrix["Arm, upper inner"][2] = {db=3};
	aPuncturingCritMatrix["Arm, upper inner"][3] = {db=4};
	aPuncturingCritMatrix["Arm, upper inner"][4] = {db=6};
	aPuncturingCritMatrix["Arm, upper inner"][5] = {db=6};
	aPuncturingCritMatrix["Arm, upper inner"][6] = {db=8};
	aPuncturingCritMatrix["Arm, upper inner"][7] = {dm=2};
	aPuncturingCritMatrix["Arm, upper inner"][8] = {dm=2,ws=true};
	aPuncturingCritMatrix["Arm, upper inner"][9] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Arm, upper inner"][10] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Arm, upper inner"][11] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Arm, upper inner"][12] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Arm, upper inner"][13] = {dm=2,a=3,ws=true};
	aPuncturingCritMatrix["Arm, upper inner"][14] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][15] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][16] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][17] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][18] = {dm=2,a=3,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][19] = {dm=2,a=3,mt=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][20] = {dm=2,a=3,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][21] = {dm=2,a=4,pb=true,mt=2,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][22] = {dm=2,a=4,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][23] = {dm=2,a=4,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Arm, upper inner"][24] = {dm=2,a=4,ls=true,w=true};
	
	aPuncturingCritMatrix["Elbow"] = {};
	aPuncturingCritMatrix["Elbow"][1] = {db=1};
	aPuncturingCritMatrix["Elbow"][2] = {db=1};
	aPuncturingCritMatrix["Elbow"][3] = {db=3};
	aPuncturingCritMatrix["Elbow"][4] = {db=3};
	aPuncturingCritMatrix["Elbow"][5] = {db=4};
	aPuncturingCritMatrix["Elbow"][6] = {db=4,a=1,ws=true};
	aPuncturingCritMatrix["Elbow"][7] = {db=6,a=1,ws=true};
	aPuncturingCritMatrix["Elbow"][8] = {db=6,a=1,ws=true};
	aPuncturingCritMatrix["Elbow"][9] = {db=8,a=2,ws=true};
	aPuncturingCritMatrix["Elbow"][10] = {db=8,a=2,w=true,ib=true};
	aPuncturingCritMatrix["Elbow"][11] = {dm=2,a=2,w=true,ib=true};
	aPuncturingCritMatrix["Elbow"][12] = {dm=2,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Elbow"][13] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Elbow"][14] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Elbow"][15] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Elbow"][16] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Elbow"][17] = {dm=2,w=true,a=4,ib=true};
	aPuncturingCritMatrix["Elbow"][18] = {dm=2,w=true,a=4,ib=true,b=1};
	aPuncturingCritMatrix["Elbow"][19] = {dm=2,w=true,a=4,ib=true,b=1};
	aPuncturingCritMatrix["Elbow"][20] = {dm=2,w=true,a=4,ib=true,mt=1};
	aPuncturingCritMatrix["Elbow"][21] = {dm=2,t=true,a=5,ib=true,b=1};
	aPuncturingCritMatrix["Elbow"][22] = {dm=2,w=true,a=5,bm=1};
	aPuncturingCritMatrix["Elbow"][23] = {dm=2,w=true,a=5,bs=1};
	aPuncturingCritMatrix["Elbow"][24] = {dm=2,w=true,a=5,ls=true};
	
	aPuncturingCritMatrix["Inner joint"] = {};
	aPuncturingCritMatrix["Inner joint"][1] = {db=1};
	aPuncturingCritMatrix["Inner joint"][2] = {db=1};
	aPuncturingCritMatrix["Inner joint"][3] = {db=3};
	aPuncturingCritMatrix["Inner joint"][4] = {db=3};
	aPuncturingCritMatrix["Inner joint"][5] = {db=4};
	aPuncturingCritMatrix["Inner joint"][6] = {db=4,a=1};
	aPuncturingCritMatrix["Inner joint"][7] = {db=6,a=1};
	aPuncturingCritMatrix["Inner joint"][8] = {db=6,a=1,ws=true};
	aPuncturingCritMatrix["Inner joint"][9] = {db=8,a=2,ws=true};
	aPuncturingCritMatrix["Inner joint"][10] = {db=8,a=2,ws=true};
	aPuncturingCritMatrix["Inner joint"][11] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Inner joint"][12] = {dm=2,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Inner joint"][13] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Inner joint"][14] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Inner joint"][15] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Inner joint"][16] = {dm=2,w=true,a=3,b=1,ib=true};
	aPuncturingCritMatrix["Inner joint"][17] = {dm=2,w=true,a=4,ib=true,b=1};
	aPuncturingCritMatrix["Inner joint"][18] = {dm=2,w=true,a=4,ib=true,mt=1};
	aPuncturingCritMatrix["Inner joint"][19] = {dm=2,w=true,a=4,ib=true,mt=2};
	aPuncturingCritMatrix["Inner joint"][20] = {dm=2,w=true,a=4,ib=true,b=2};
	aPuncturingCritMatrix["Inner joint"][21] = {dm=2,w=true,a=5,ib=true,b=2};
	aPuncturingCritMatrix["Inner joint"][22] = {dm=2,w=true,a=5,bm=2};
	aPuncturingCritMatrix["Inner joint"][23] = {dm=2,w=true,a=5,bs=2};
	aPuncturingCritMatrix["Inner joint"][24] = {dm=2,w=true,a=5,ls=true};
	
	aPuncturingCritMatrix["Forearm, back"] = {};
	aPuncturingCritMatrix["Forearm, back"][1] = {db=1};
	aPuncturingCritMatrix["Forearm, back"][2] = {db=3};
	aPuncturingCritMatrix["Forearm, back"][3] = {db=4};
	aPuncturingCritMatrix["Forearm, back"][4] = {db=6};
	aPuncturingCritMatrix["Forearm, back"][5] = {db=6};
	aPuncturingCritMatrix["Forearm, back"][6] = {db=8};
	aPuncturingCritMatrix["Forearm, back"][7] = {dm=2};
	aPuncturingCritMatrix["Forearm, back"][8] = {dm=2,ws=true};
	aPuncturingCritMatrix["Forearm, back"][9] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Forearm, back"][10] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Forearm, back"][11] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Forearm, back"][12] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Forearm, back"][13] = {dm=2,a=3,ws=true};
	aPuncturingCritMatrix["Forearm, back"][14] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Forearm, back"][15] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Forearm, back"][16] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, back"][17] = {dm=2,a=3,b=1,w=true};
	aPuncturingCritMatrix["Forearm, back"][18] = {dm=2,a=3,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Forearm, back"][19] = {dm=2,a=3,mt=1,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, back"][20] = {dm=2,a=3,b=2,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, back"][21] = {dm=2,a=4,pb=true,b=2,w=true};
	aPuncturingCritMatrix["Forearm, back"][22] = {dm=2,a=3,mt=2,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, back"][23] = {dm=2,a=4,b=2,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, back"][24] = {dm=3,a=4,ls=true,w=true};
	
	aPuncturingCritMatrix["Forearm, inner"] = {};
	aPuncturingCritMatrix["Forearm, inner"][1] = {db=1};
	aPuncturingCritMatrix["Forearm, inner"][2] = {db=3};
	aPuncturingCritMatrix["Forearm, inner"][3] = {db=4};
	aPuncturingCritMatrix["Forearm, inner"][4] = {db=6};
	aPuncturingCritMatrix["Forearm, inner"][5] = {db=6,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][6] = {db=8,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][7] = {dm=2,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][8] = {dm=2,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][9] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][10] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][11] = {dm=2,a=2,w=true};
	aPuncturingCritMatrix["Forearm, inner"][12] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][13] = {dm=2,a=3,ws=true};
	aPuncturingCritMatrix["Forearm, inner"][14] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Forearm, inner"][15] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Forearm, inner"][16] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, inner"][17] = {dm=2,a=3,b=1,w=true};
	aPuncturingCritMatrix["Forearm, inner"][18] = {dm=2,a=3,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Forearm, inner"][19] = {dm=2,a=3,mt=1,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, inner"][20] = {dm=2,a=3,b=2,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, inner"][21] = {dm=2,a=4,pb=true,b=2,w=true};
	aPuncturingCritMatrix["Forearm, inner"][22] = {dm=2,a=3,mt=2,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, inner"][23] = {dm=2,a=4,b=2,pb=true,w=true};
	aPuncturingCritMatrix["Forearm, inner"][24] = {dm=3,a=4,ls=true,w=true};
	
	aPuncturingCritMatrix["Wrist, back"] = {};
	aPuncturingCritMatrix["Wrist, back"][1] = {db=1};
	aPuncturingCritMatrix["Wrist, back"][2] = {db=3};
	aPuncturingCritMatrix["Wrist, back"][3] = {db=3};
	aPuncturingCritMatrix["Wrist, back"][4] = {db=4,ws=true};
	aPuncturingCritMatrix["Wrist, back"][5] = {db=4,ws=true,a=1};
	aPuncturingCritMatrix["Wrist, back"][6] = {db=6,ws=true,a=1};
	aPuncturingCritMatrix["Wrist, back"][7] = {db=8,ws=true,a=1};
	aPuncturingCritMatrix["Wrist, back"][8] = {db=8,ws=true,a=2};
	aPuncturingCritMatrix["Wrist, back"][9] = {db=8,ws=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, back"][10] = {db=8,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, back"][11] = {db=8,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, back"][12] = {dm=2,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, back"][13] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Wrist, back"][14] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Wrist, back"][15] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Wrist, back"][16] = {dm=2,w=true,a=3,b=1,ib=true};
	aPuncturingCritMatrix["Wrist, back"][17] = {dm=2,w=true,a=3,ib=true,b=1};
	aPuncturingCritMatrix["Wrist, back"][18] = {dm=2,w=true,a=3,ib=true,mt=1};
	aPuncturingCritMatrix["Wrist, back"][19] = {dm=2,w=true,a=3,ib=true,mt=1};
	aPuncturingCritMatrix["Wrist, back"][20] = {dm=2,w=true,a=3,ib=true,b=1};
	aPuncturingCritMatrix["Wrist, back"][21] = {dm=2,w=true,a=3,ib=true,b=1};
	aPuncturingCritMatrix["Wrist, back"][22] = {dm=2,w=true,a=3,bm=1};
	aPuncturingCritMatrix["Wrist, back"][23] = {dm=2,w=true,a=3,bs=1};
	aPuncturingCritMatrix["Wrist, back"][24] = {dm=2,w=true,a=3,ls=true};
	
	aPuncturingCritMatrix["Wrist, front"] = {};
	aPuncturingCritMatrix["Wrist, front"][1] = {db=1};
	aPuncturingCritMatrix["Wrist, front"][2] = {db=3};
	aPuncturingCritMatrix["Wrist, front"][3] = {db=3};
	aPuncturingCritMatrix["Wrist, front"][4] = {db=4,ws=true};
	aPuncturingCritMatrix["Wrist, front"][5] = {db=4,ws=true,a=1};
	aPuncturingCritMatrix["Wrist, front"][6] = {db=6,ws=true,a=1};
	aPuncturingCritMatrix["Wrist, front"][7] = {db=8,ws=true,a=1};
	aPuncturingCritMatrix["Wrist, front"][8] = {db=8,ws=true,a=2};
	aPuncturingCritMatrix["Wrist, front"][9] = {db=8,ws=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, front"][10] = {db=8,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, front"][11] = {db=8,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, front"][12] = {dm=2,w=true,a=2,ib=true};
	aPuncturingCritMatrix["Wrist, front"][13] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Wrist, front"][14] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Wrist, front"][15] = {dm=2,w=true,a=3,ib=true};
	aPuncturingCritMatrix["Wrist, front"][16] = {dm=2,w=true,a=3,b=1,ib=true};
	aPuncturingCritMatrix["Wrist, front"][17] = {dm=2,w=true,a=3,ib=true,b=1};
	aPuncturingCritMatrix["Wrist, front"][18] = {dm=2,w=true,a=3,ib=true,mt=1};
	aPuncturingCritMatrix["Wrist, front"][19] = {dm=2,w=true,a=3,ib=true,mt=1};
	aPuncturingCritMatrix["Wrist, front"][20] = {dm=2,w=true,a=3,ib=true,b=1};
	aPuncturingCritMatrix["Wrist, front"][21] = {dm=2,w=true,a=3,ib=true,b=1};
	aPuncturingCritMatrix["Wrist, front"][22] = {dm=2,w=true,a=3,bm=1};
	aPuncturingCritMatrix["Wrist, front"][23] = {dm=2,w=true,a=3,bs=1};
	aPuncturingCritMatrix["Wrist, front"][24] = {dm=2,w=true,a=3,ls=true};

	aPuncturingCritMatrix["Hand, back"] = {};
	aPuncturingCritMatrix["Hand, back"][1] = {db=1};
	aPuncturingCritMatrix["Hand, back"][2] = {db=1};
	aPuncturingCritMatrix["Hand, back"][3] = {db=3};
	aPuncturingCritMatrix["Hand, back"][4] = {db=3};
	aPuncturingCritMatrix["Hand, back"][5] = {db=4};
	aPuncturingCritMatrix["Hand, back"][6] = {db=4};
	aPuncturingCritMatrix["Hand, back"][7] = {db=6,ib=true};
	aPuncturingCritMatrix["Hand, back"][8] = {db=6,ib=true};
	aPuncturingCritMatrix["Hand, back"][9] = {db=8,ib=true,a=1};
	aPuncturingCritMatrix["Hand, back"][10] = {db=8,ib=true,a=1};
	aPuncturingCritMatrix["Hand, back"][11] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Hand, back"][12] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Hand, back"][13] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Hand, back"][14] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Hand, back"][15] = {dm=2,ib=true,a=2,ws=true};
	aPuncturingCritMatrix["Hand, back"][16] = {dm=2,ib=true,a=3,ws=true};
	aPuncturingCritMatrix["Hand, back"][17] = {dm=2,ib=true,a=3,ws=true};
	aPuncturingCritMatrix["Hand, back"][18] = {dm=2,ib=true,a=3,w=true};
	aPuncturingCritMatrix["Hand, back"][19] = {dm=2,ib=true,b=1,a=3,w=true};
	aPuncturingCritMatrix["Hand, back"][20] = {dm=2,ib=true,b=1,a=3,w=true};
	aPuncturingCritMatrix["Hand, back"][21] = {dm=2,ib=true,mt=1,a=3,w=true};
	aPuncturingCritMatrix["Hand, back"][22] = {dm=2,ib=true,b=2,a=3,w=true};
	aPuncturingCritMatrix["Hand, back"][23] = {dm=2,a=3,bs=2,w=true};
	aPuncturingCritMatrix["Hand, back"][24] = {dm=2,ls=true,a=3,w=true};
	
	aPuncturingCritMatrix["Palm"] = {};
	aPuncturingCritMatrix["Palm"][1] = {db=1};
	aPuncturingCritMatrix["Palm"][2] = {db=1};
	aPuncturingCritMatrix["Palm"][3] = {db=3};
	aPuncturingCritMatrix["Palm"][4] = {db=3};
	aPuncturingCritMatrix["Palm"][5] = {db=4};
	aPuncturingCritMatrix["Palm"][6] = {db=4};
	aPuncturingCritMatrix["Palm"][7] = {db=6};
	aPuncturingCritMatrix["Palm"][8] = {db=6};
	aPuncturingCritMatrix["Palm"][9] = {db=6,ib=true};
	aPuncturingCritMatrix["Palm"][10] = {db=6,ib=true,a=1};
	aPuncturingCritMatrix["Palm"][11] = {db=8,ib=true,a=1};
	aPuncturingCritMatrix["Palm"][12] = {db=8,ib=true,a=2};
	aPuncturingCritMatrix["Palm"][13] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Palm"][14] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Palm"][15] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Palm"][16] = {dm=2,ib=true,a=2};
	aPuncturingCritMatrix["Palm"][17] = {dm=2,ib=true,a=2,ws=true};
	aPuncturingCritMatrix["Palm"][18] = {dm=2,ib=true,a=3,ws=true};
	aPuncturingCritMatrix["Palm"][19] = {dm=2,ib=true,pb=true,a=3,ws=true};
	aPuncturingCritMatrix["Palm"][20] = {dm=2,ib=true,pb=true,b=1,a=3,w=true};
	aPuncturingCritMatrix["Palm"][21] = {dm=2,ib=true,pb=true,mt=1,a=3,w=true};
	aPuncturingCritMatrix["Palm"][22] = {dm=2,ib=true,pb=true,b=1,a=3,w=true};
	aPuncturingCritMatrix["Palm"][23] = {dm=2,a=3,bs=1,w=true};
	aPuncturingCritMatrix["Palm"][24] = {dm=2,ls=true,a=3,w=true};
	
	aPuncturingCritMatrix["Finger(s)"] = {};
	aPuncturingCritMatrix["Finger(s)"][1] = {db=1};
	aPuncturingCritMatrix["Finger(s)"][2] = {db=1};
	aPuncturingCritMatrix["Finger(s)"][3] = {db=3};
	aPuncturingCritMatrix["Finger(s)"][4] = {db=3};
	aPuncturingCritMatrix["Finger(s)"][5] = {db=4};
	aPuncturingCritMatrix["Finger(s)"][6] = {db=4};
	aPuncturingCritMatrix["Finger(s)"][7] = {db=6,ib=true};
	aPuncturingCritMatrix["Finger(s)"][8] = {db=6,ib=true};
	aPuncturingCritMatrix["Finger(s)"][9] = {db=8,ib=true};
	aPuncturingCritMatrix["Finger(s)"][10] = {db=8,ib=true};
	aPuncturingCritMatrix["Finger(s)"][11] = {dm=2,ib=true};
	aPuncturingCritMatrix["Finger(s)"][12] = {dm=2,ib=true};
	aPuncturingCritMatrix["Finger(s)"][13] = {dm=2,ib=true};
	aPuncturingCritMatrix["Finger(s)"][14] = {dm=2,ib=true};
	aPuncturingCritMatrix["Finger(s)"][15] = {dm=2,ib=true};
	aPuncturingCritMatrix["Finger(s)"][16] = {dm=2,b=1,ib=true};
	aPuncturingCritMatrix["Finger(s)"][17] = {dm=2,b=1,ib=true};
	aPuncturingCritMatrix["Finger(s)"][18] = {dm=2,b=1,ib=true};
	aPuncturingCritMatrix["Finger(s)"][19] = {dm=2,ls=true};
	aPuncturingCritMatrix["Finger(s)"][20] = {dm=2,ls=true};
	aPuncturingCritMatrix["Finger(s)"][21] = {dm=2,ls=true};
	aPuncturingCritMatrix["Finger(s)"][22] = {dm=2,ls=true};
	aPuncturingCritMatrix["Finger(s)"][23] = {dm=2,ls=true};
	aPuncturingCritMatrix["Finger(s)"][24] = {dm=2,ls=true};

	aPuncturingCritMatrix["Shoulder, side"] = {};
	aPuncturingCritMatrix["Shoulder, side"][1] = {db=1};
	aPuncturingCritMatrix["Shoulder, side"][2] = {db=3};
	aPuncturingCritMatrix["Shoulder, side"][3] = {db=4};
	aPuncturingCritMatrix["Shoulder, side"][4] = {db=6};
	aPuncturingCritMatrix["Shoulder, side"][5] = {db=6};
	aPuncturingCritMatrix["Shoulder, side"][6] = {db=8};
	aPuncturingCritMatrix["Shoulder, side"][7] = {dm=2};
	aPuncturingCritMatrix["Shoulder, side"][8] = {dm=2,ws=true};
	aPuncturingCritMatrix["Shoulder, side"][9] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Shoulder, side"][10] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Shoulder, side"][11] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Shoulder, side"][12] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Shoulder, side"][13] = {dm=2,a=3,ws=true};
	aPuncturingCritMatrix["Shoulder, side"][14] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Shoulder, side"][15] = {dm=2,a=3,w=true};
	aPuncturingCritMatrix["Shoulder, side"][16] = {dm=2,a=3,pb=true,w=true};
	aPuncturingCritMatrix["Shoulder, side"][17] = {dm=2,a=3,b=1,w=true};
	aPuncturingCritMatrix["Shoulder, side"][18] = {dm=3,a=3,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Shoulder, side"][19] = {dm=3,a=3,mt=1,pb=true,w=true};
	aPuncturingCritMatrix["Shoulder, side"][20] = {dm=3,a=3,b=1,pb=true,w=true};
	aPuncturingCritMatrix["Shoulder, side"][21] = {dm=3,a=4,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Shoulder, side"][22] = {dm=4,a=3,pb=true,mt=2,w=true};
	aPuncturingCritMatrix["Shoulder, side"][23] = {dm=3,a=4,pb=true,b=1,w=true};
	aPuncturingCritMatrix["Shoulder, side"][24] = {dm=3,a=4,ls=true};
	
	aPuncturingCritMatrix["Shoulder, top"] = {};
	aPuncturingCritMatrix["Shoulder, top"][1] = {db=1};
	aPuncturingCritMatrix["Shoulder, top"][2] = {db=3};
	aPuncturingCritMatrix["Shoulder, top"][3] = {db=4};
	aPuncturingCritMatrix["Shoulder, top"][4] = {db=6};
	aPuncturingCritMatrix["Shoulder, top"][5] = {db=8};
	aPuncturingCritMatrix["Shoulder, top"][6] = {dm=2};
	aPuncturingCritMatrix["Shoulder, top"][7] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Shoulder, top"][8] = {dm=2,a=1,ws=true};
	aPuncturingCritMatrix["Shoulder, top"][9] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Shoulder, top"][10] = {dm=2,a=2,ws=true};
	aPuncturingCritMatrix["Shoulder, top"][11] = {dm=2,a=3,d=1,ws=true};
	aPuncturingCritMatrix["Shoulder, top"][12] = {dm=2,a=3,d=1,w=true};
	aPuncturingCritMatrix["Shoulder, top"][13] = {dm=3,a=3,d=1,w=true};
	aPuncturingCritMatrix["Shoulder, top"][14] = {dm=3,a=3,d=1,w=true};
	aPuncturingCritMatrix["Shoulder, top"][15] = {dm=3,a=3,d=2,w=true};
	aPuncturingCritMatrix["Shoulder, top"][16] = {dm=3,a=3,d=2,pb=true,w=true};
	aPuncturingCritMatrix["Shoulder, top"][17] = {dm=3,a=3,d=2,ib=true,w=true};
	aPuncturingCritMatrix["Shoulder, top"][18] = {dm=3,a=3,d=2,ib=true,pb=true,w=true};
	aPuncturingCritMatrix["Shoulder, top"][19] = {dm=3,a=3,d=2,mt=1,pb=true};
	aPuncturingCritMatrix["Shoulder, top"][20] = {dm=3,a=3,d=2,b=1,pb=true};
	aPuncturingCritMatrix["Shoulder, top"][21] = {dm=3,a=3,d=2,b=2,pb=true,ib=true,w=true};
	aPuncturingCritMatrix["Shoulder, top"][22] = {dm=3,a=3,d=2,mt=2,pb=true,ib=true};
	aPuncturingCritMatrix["Shoulder, top"][23] = {dm=3,a=3,d=2,b=3,pb=true,ib=true};
	aPuncturingCritMatrix["Shoulder, top"][24] = {dm=3,a=3,d=2,ls=true};
	
	aPuncturingCritMatrix["Neck, front"] = {};
	aPuncturingCritMatrix["Neck, front"][1] = {db=3};
	aPuncturingCritMatrix["Neck, front"][2] = {db=4};
	aPuncturingCritMatrix["Neck, front"][3] = {db=6};
	aPuncturingCritMatrix["Neck, front"][4] = {db=8};
	aPuncturingCritMatrix["Neck, front"][5] = {dm=2};
	aPuncturingCritMatrix["Neck, front"][6] = {dm=2,ws=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, front"][7] = {dm=2,w=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, front"][8] = {dm=2,f=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, front"][9] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Neck, front"][10] = {dm=2,a=2,d=2,f=true,mc=true};
	aPuncturingCritMatrix["Neck, front"][11] = {dm=2,a=2,d=2,f=true,mc=true};
	aPuncturingCritMatrix["Neck, front"][12] = {dm=3,a=3,d=3,u=true};
	aPuncturingCritMatrix["Neck, front"][13] = {dm=3,a=3,d=3,u=true};
	aPuncturingCritMatrix["Neck, front"][14] = {dm=3,a=3,d=3,u=true,mc=true};
	aPuncturingCritMatrix["Neck, front"][15] = {dm=3,a=3,d=4,u=true,p=true,mc=true};
	aPuncturingCritMatrix["Neck, front"][16] = {dm=3,a=3,d=5,u=true,mc=true};
	aPuncturingCritMatrix["Neck, front"][17] = {dm=4,a=4,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Neck, front"][18] = {dm=4,a=5,p=true,u=true,sc=true};
	aPuncturingCritMatrix["Neck, front"][19] = {dm=4,pb=true,ib=true,v=1};
	aPuncturingCritMatrix["Neck, front"][20] = {dm=4,pb=true,ib=true,v=1};
	aPuncturingCritMatrix["Neck, front"][21] = {dm=4,p=true,u=true,sc=true};
	aPuncturingCritMatrix["Neck, front"][22] = {dm=4,pb=true,ib=true,v=2};
	aPuncturingCritMatrix["Neck, front"][23] = {dm=4,pb=true,ib=true,v=2};
	aPuncturingCritMatrix["Neck, front"][24] = {dead="decapitated"};

	aPuncturingCritMatrix["Neck, back"] = {};
	aPuncturingCritMatrix["Neck, back"][1] = {db=3};
	aPuncturingCritMatrix["Neck, back"][2] = {db=4};
	aPuncturingCritMatrix["Neck, back"][3] = {db=6};
	aPuncturingCritMatrix["Neck, back"][4] = {db=8};
	aPuncturingCritMatrix["Neck, back"][5] = {dm=2};
	aPuncturingCritMatrix["Neck, back"][6] = {dm=2,ws=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, back"][7] = {dm=2,w=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, back"][8] = {dm=2,f=true,a=1,d=1,p=true};
	aPuncturingCritMatrix["Neck, back"][9] = {dm=2,a=2,d=2,f=true,p=true};
	aPuncturingCritMatrix["Neck, back"][10] = {dm=2,a=2,d=2,f=true,p=true};
	aPuncturingCritMatrix["Neck, back"][11] = {dm=2,a=2,d=2,f=true,p=true};
	aPuncturingCritMatrix["Neck, back"][12] = {dm=3,a=2,d=3,u=true};
	aPuncturingCritMatrix["Neck, back"][13] = {dm=3,a=2,d=3,u=true};
	aPuncturingCritMatrix["Neck, back"][14] = {dm=3,a=2,d=3,u=true,mc=true};
	aPuncturingCritMatrix["Neck, back"][15] = {dm=3,a=2,d=3,u=true,p=true,mc=true};
	aPuncturingCritMatrix["Neck, back"][16] = {dm=3,a=3,d=4,u=true,mc=true};
	aPuncturingCritMatrix["Neck, back"][17] = {dm=4,a=4,d=5,b=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, back"][18] = {dm=4,a=5,d=6,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, back"][19] = {dm=4,p=true,b=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, back"][20] = {dm=4,p=true,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, back"][21] = {dm=4,p=true,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, back"][22] = {dm=4,p=true,bf=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, back"][23] = {dm=4,pb=true,bm=1,ib=true,v=1};
	aPuncturingCritMatrix["Neck, back"][24] = {dead="decapitated"};
	
	aPuncturingCritMatrix["Neck, side"] = {};	
	aPuncturingCritMatrix["Neck, side"][1] = {db=3};
	aPuncturingCritMatrix["Neck, side"][2] = {db=4};
	aPuncturingCritMatrix["Neck, side"][3] = {db=6};
	aPuncturingCritMatrix["Neck, side"][4] = {db=8};
	aPuncturingCritMatrix["Neck, side"][5] = {dm=2};
	aPuncturingCritMatrix["Neck, side"][6] = {dm=2,ws=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, side"][7] = {dm=2,w=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, side"][8] = {dm=2,f=true,a=1,d=1};
	aPuncturingCritMatrix["Neck, side"][9] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Neck, side"][10] = {dm=2,a=2,d=2,f=true,mc=true};
	aPuncturingCritMatrix["Neck, side"][11] = {dm=2,a=2,d=2,f=true,p=true};
	aPuncturingCritMatrix["Neck, side"][12] = {dm=3,a=2,d=3,f=true,mt=1};
	aPuncturingCritMatrix["Neck, side"][13] = {dm=3,a=2,d=3,f=true,mt=1};
	aPuncturingCritMatrix["Neck, side"][14] = {dm=3,a=2,d=3,u=true,pb=true};
	aPuncturingCritMatrix["Neck, side"][15] = {dm=3,a=2,d=3,u=true,pb=true};
	aPuncturingCritMatrix["Neck, side"][16] = {dm=3,a=3,d=4,u=true,pb=true};
	aPuncturingCritMatrix["Neck, side"][17] = {dm=4,a=4,d=5,u=true,pb=true,mc=true};
	aPuncturingCritMatrix["Neck, side"][18] = {dm=4,a=5,d=6,pb=true,u=true,sc=true};
	aPuncturingCritMatrix["Neck, side"][19] = {dm=4,p=true,b=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, side"][20] = {dm=4,p=true,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Neck, side"][21] = {dm=4,p=true,b=2,ib=true,v=2,u=true,sc=true};
	aPuncturingCritMatrix["Neck, side"][22] = {dm=4,p=true,bf=2,v=2,u=true,sc=true};
	aPuncturingCritMatrix["Neck, side"][23] = {dm=4,pb=true,ib=true,v=2};
	aPuncturingCritMatrix["Neck, side"][24] = {dead="decapitated"};

	aPuncturingCritMatrix["Head, side"] = {};
	aPuncturingCritMatrix["Head, side"][1] = {db=6};
	aPuncturingCritMatrix["Head, side"][2] = {db=8};
	aPuncturingCritMatrix["Head, side"][3] = {dm=2};
	aPuncturingCritMatrix["Head, side"][4] = {dm=2,f=true};
	aPuncturingCritMatrix["Head, side"][5] = {dm=2,a=1,d=1,f=true};
	aPuncturingCritMatrix["Head, side"][6] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Head, side"][7] = {dm=3,a=2,d=2,f=true};
	aPuncturingCritMatrix["Head, side"][8] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Head, side"][9] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Head, side"][10] = {dm=3,a=4,d=4,f=true};
	aPuncturingCritMatrix["Head, side"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aPuncturingCritMatrix["Head, side"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aPuncturingCritMatrix["Head, side"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][17] = {dm=4,a=7,d=7,t=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][18] = {dm=4,a=7,d=7,t=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][19] = {dm=4,a=8,d=8,t=2,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][20] = {dm=4,a=8,d=8,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][21] = {dm=4,a=9,d=9,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][22] = {dm=4,a=9,d=9,ib=true,v=1,bf=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, side"][23] = {dead="skull caved-in"};
	aPuncturingCritMatrix["Head, side"][24] = {dead="brain goo"};
	
	aPuncturingCritMatrix["Head, back lower"] = {};
	aPuncturingCritMatrix["Head, back lower"][1] = {db=6};
	aPuncturingCritMatrix["Head, back lower"][2] = {db=8};
	aPuncturingCritMatrix["Head, back lower"][3] = {dm=2};
	aPuncturingCritMatrix["Head, back lower"][4] = {dm=2,f=true};
	aPuncturingCritMatrix["Head, back lower"][5] = {dm=2,d=1,f=true};
	aPuncturingCritMatrix["Head, back lower"][6] = {dm=2,a=1,d=2,f=true};
	aPuncturingCritMatrix["Head, back lower"][7] = {dm=3,a=1,d=2,f=true};
	aPuncturingCritMatrix["Head, back lower"][8] = {dm=3,a=2,d=3,f=true};
	aPuncturingCritMatrix["Head, back lower"][9] = {dm=3,a=2,d=3,f=true,p=true};
	aPuncturingCritMatrix["Head, back lower"][10] = {dm=3,a=3,d=4,f=true};
	aPuncturingCritMatrix["Head, back lower"][11] = {dm=3,a=3,d=4,f=true,mc=true};
	aPuncturingCritMatrix["Head, back lower"][12] = {dm=4,a=3,d=4,f=true,sc=true,p=true};
	aPuncturingCritMatrix["Head, back lower"][13] = {dm=4,a=4,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][14] = {dm=4,a=5,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][15] = {dm=4,a=5,d=6,u=true,sc=true,p=true};
	aPuncturingCritMatrix["Head, back lower"][16] = {dm=4,a=6,d=7,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][17] = {dm=4,a=6,d=7,t=1,u=true,sc=true,p=true};
	aPuncturingCritMatrix["Head, back lower"][18] = {dm=4,a=6,d=7,t=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][19] = {dm=4,a=7,d=8,t=2,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][20] = {dm=4,a=7,d=8,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][21] = {dm=4,p=true,b=1,ib=true,v=2,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][22] = {dm=4,p=true,ib=true,v=2,u=true,sc=true};
	aPuncturingCritMatrix["Head, back lower"][23] = {dead="skull caved=in"};
	aPuncturingCritMatrix["Head, back lower"][24] = {dead="brain goo"};
	
	aPuncturingCritMatrix["Face, lower side"] = {};
	aPuncturingCritMatrix["Face, lower side"][1] = {db=4};
	aPuncturingCritMatrix["Face, lower side"][2] = {db=6};
	aPuncturingCritMatrix["Face, lower side"][3] = {db=8};
	aPuncturingCritMatrix["Face, lower side"][4] = {dm=2};
	aPuncturingCritMatrix["Face, lower side"][5] = {dm=2,f=true};
	aPuncturingCritMatrix["Face, lower side"][6] = {dm=2,a=2,f=true};
	aPuncturingCritMatrix["Face, lower side"][7] = {dm=2,a=2,u=true};
	aPuncturingCritMatrix["Face, lower side"][8] = {dm=3,mt=1,a=3,d=1,f=true};
	aPuncturingCritMatrix["Face, lower side"][9] = {dm=3,mt=1,a=3,d=1,u=true};
	aPuncturingCritMatrix["Face, lower side"][10] = {dm=3,mt=1,a=4,d=2,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][11] = {dm=3,mt=1,a=4,d=2,u=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][12] = {dm=4,mt=2,a=4,d=2,u=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][13] = {dm=4,mt=2,a=3,d=1,f=true,sc=true};
	aPuncturingCritMatrix["Face, lower side"][14] = {dm=4,mt=2,a=3,d=1,u=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][15] = {dm=4,b=1,a=4,d=2,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][16] = {dm=4,mt=2,a=5,d=3,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][17] = {dm=4,b=1,a=5,d=3,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][18] = {dm=4,mt=2,a=5,d=3,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][19] = {dm=4,b=1,a=5,d=3,f=true,sc=true};
	aPuncturingCritMatrix["Face, lower side"][20] = {dm=4,b=2,a=6,d=4,u=true,mc=true};
	aPuncturingCritMatrix["Face, lower side"][21] = {dm=4,mt=2,a=6,d=4,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower side"][22] = {dm=4,b=2,a=6,d=4,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower side"][23] = {dm=4,ib=true,a=7,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower side"][24] = {dead="jaw removed"};

	aPuncturingCritMatrix["Face, lower center"] = {};
	aPuncturingCritMatrix["Face, lower center"][1] = {db=4};
	aPuncturingCritMatrix["Face, lower center"][2] = {db=6};
	aPuncturingCritMatrix["Face, lower center"][3] = {db=8};
	aPuncturingCritMatrix["Face, lower center"][4] = {dm=2};
	aPuncturingCritMatrix["Face, lower center"][5] = {dm=2,f=true};
	aPuncturingCritMatrix["Face, lower center"][6] = {dm=2,a=1,d=1,f=true};
	aPuncturingCritMatrix["Face, lower center"][7] = {dm=2,a=2,d=2,u=true};
	aPuncturingCritMatrix["Face, lower center"][8] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Face, lower center"][9] = {dm=3,a=3,d=3,u=true};
	aPuncturingCritMatrix["Face, lower center"][10] = {dm=3,a=4,d=4,f=true,mt=1};
	aPuncturingCritMatrix["Face, lower center"][11] = {dm=3,a=4,d=4,mc=true};
	aPuncturingCritMatrix["Face, lower center"][12] = {dm=4,a=4,d=4,u=true,mc=true};
	aPuncturingCritMatrix["Face, lower center"][13] = {dm=4,t=2,a=3,d=3,f=true,mc=true,mt=1};
	aPuncturingCritMatrix["Face, lower center"][14] = {dm=4,t=2,a=3,d=3,u=true,mc=true};
	aPuncturingCritMatrix["Face, lower center"][15] = {dm=4,t=2,a=4,d=4,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower center"][16] = {dm=4,t=2,a=5,d=5,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower center"][17] = {dm=4,t=2,a=5,d=5,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower center"][18] = {dm=4,b1=1,a=5,d=5,f=true,mc=true};
	aPuncturingCritMatrix["Face, lower center"][19] = {dm=4,b=2,a=5,d=5,f=true,sc=true};
	aPuncturingCritMatrix["Face, lower center"][20] = {dm=4,b=2,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower center"][21] = {dm=4,b=3,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower center"][22] = {dm=4,ib=true,v=1,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower center"][23] = {dm=4,ib=true,v=1,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, lower center"][24] = {dead="skull caved-in"};
	
	aPuncturingCritMatrix["Head, back upper"] = {};
	aPuncturingCritMatrix["Head, back upper"][1] = {db=6};
	aPuncturingCritMatrix["Head, back upper"][2] = {db=8};
	aPuncturingCritMatrix["Head, back upper"][3] = {dm=2};
	aPuncturingCritMatrix["Head, back upper"][4] = {dm=2,f=true};
	aPuncturingCritMatrix["Head, back upper"][5] = {dm=2,a=1,d=1,f=true};
	aPuncturingCritMatrix["Head, back upper"][6] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Head, back upper"][7] = {dm=3,a=2,d=2,f=true};
	aPuncturingCritMatrix["Head, back upper"][8] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Head, back upper"][9] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Head, back upper"][10] = {dm=3,a=4,d=4,f=true};
	aPuncturingCritMatrix["Head, back upper"][11] = {dm=3,a=4,d=4,f=true,ib=true,mc=true};
	aPuncturingCritMatrix["Head, back upper"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][13] = {dm=4,a=5,d=5,u=true,mt=1,sc=true};
	aPuncturingCritMatrix["Head, back upper"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][17] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][18] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][19] = {dm=4,a=8,d=8,mt=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][20] = {dm=4,a=8,d=8,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][21] = {dm=4,a=9,d=9,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][22] = {dm=4,a=9,d=9,bf=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, back upper"][23] = {dead="skull caved-in"};
	aPuncturingCritMatrix["Head, back upper"][24] = {dead="brain goo"};
	
	aPuncturingCritMatrix["Face, upper side"] = {};
	aPuncturingCritMatrix["Face, upper side"][1] = {db=6};
	aPuncturingCritMatrix["Face, upper side"][2] = {db=8};
	aPuncturingCritMatrix["Face, upper side"][3] = {dm=2};
	aPuncturingCritMatrix["Face, upper side"][4] = {dm=2,f=true};
	aPuncturingCritMatrix["Face, upper side"][5] = {dm=2,a=1,d=1,f=true};
	aPuncturingCritMatrix["Face, upper side"][6] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Face, upper side"][7] = {dm=3,a=2,d=2,f=true};
	aPuncturingCritMatrix["Face, upper side"][8] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Face, upper side"][9] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Face, upper side"][10] = {dm=3,a=4,d=4,f=true};
	aPuncturingCritMatrix["Face, upper side"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aPuncturingCritMatrix["Face, upper side"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][17] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][18] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][19] = {dm=4,a=7,d=7,mt=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][20] = {dm=4,a=8,d=8,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][21] = {dm=4,a=8,d=8,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][22] = {dm=4,a=9,d=9,bf=2,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper side"][23] = {dead="skull caved-in"};
	aPuncturingCritMatrix["Face, upper side"][24] = {dead="brain goo"};
	
	aPuncturingCritMatrix["Face, upper center"] = {};
	aPuncturingCritMatrix["Face, upper center"][1] = {db=6};
	aPuncturingCritMatrix["Face, upper center"][2] = {db=8};
	aPuncturingCritMatrix["Face, upper center"][3] = {dm=2};
	aPuncturingCritMatrix["Face, upper center"][4] = {dm=2,f=true};
	aPuncturingCritMatrix["Face, upper center"][5] = {dm=2,a=1,d=1,f=true};
	aPuncturingCritMatrix["Face, upper center"][6] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Face, upper center"][7] = {dm=3,a=2,d=2,f=true};
	aPuncturingCritMatrix["Face, upper center"][8] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Face, upper center"][9] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Face, upper center"][10] = {dm=3,a=4,d=4,f=true};
	aPuncturingCritMatrix["Face, upper center"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aPuncturingCritMatrix["Face, upper center"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][17] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][18] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][19] = {dm=4,a=8,d=8,mt=2,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][20] = {dm=4,a=8,d=8,b=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][21] = {dm=4,a=9,d=9,b=2,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][22] = {dm=4,a=9,d=9,bf=3,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Face, upper center"][23] = {dead="skull caved-in"};
	aPuncturingCritMatrix["Face, upper center"][24] = {dead="brain goo"};
	
	aPuncturingCritMatrix["Head, top"] = {};
	aPuncturingCritMatrix["Head, top"][1] = {db=8};
	aPuncturingCritMatrix["Head, top"][2] = {dm=2};
	aPuncturingCritMatrix["Head, top"][3] = {dm=2, f=true};
	aPuncturingCritMatrix["Head, top"][4] = {dm=2,a=1,d=1,f=true};
	aPuncturingCritMatrix["Head, top"][5] = {dm=2,a=2,d=2,f=true};
	aPuncturingCritMatrix["Head, top"][6] = {dm=3,a=2,d=2,f=true};
	aPuncturingCritMatrix["Head, top"][7] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Head, top"][8] = {dm=3,a=3,d=3,f=true};
	aPuncturingCritMatrix["Head, top"][9] = {dm=3,a=4,d=4,f=true};
	aPuncturingCritMatrix["Head, top"][10] = {dm=3,a=4,d=4,f=true,mc=true};
	aPuncturingCritMatrix["Head, top"][11] = {dm=4,a=4,d=4,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][12] = {dm=4,a=5,d=5,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][13] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][15] = {dm=4,a=7,d=7,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][16] = {dm=4,a=7,d=7,t=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][17] = {dm=4,a=7,d=7,mt=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][18] = {dm=4,a=8,d=8,mt=1,ib=true,v=1,u=true,sc=true};
	aPuncturingCritMatrix["Head, top"][19] = {dm=4,a=8,d=8,b=1,ib=true,v=1,u=true,s=true,};
	aPuncturingCritMatrix["Head, top"][20] = {dm=4,a=9,d=9,b=1,ib=true,v=1,u=true,s=true};
	aPuncturingCritMatrix["Head, top"][21] = {cm=4,a=9,d=9,bf=1,ib=true,v=1,u=true,s=true};
	aPuncturingCritMatrix["Head, top"][22] = {dead="skull caved-in"};
	aPuncturingCritMatrix["Head, top"][23] = {dead="brain goo"};
	aPuncturingCritMatrix["Head, top"][24] = {dead="brain goo"};
	
end

function buildCrushingCritMatrix()

	aCrushingCritMatrix["Foot, top"] = {};
	aCrushingCritMatrix["Foot, top"][1] = {db=1};
	aCrushingCritMatrix["Foot, top"][2] = {db=1};
	aCrushingCritMatrix["Foot, top"][3] = {db=3};
	aCrushingCritMatrix["Foot, top"][4] = {db=3};
	aCrushingCritMatrix["Foot, top"][5] = {db=4,m=1};
	aCrushingCritMatrix["Foot, top"][6] = {db=4,m=1};
	aCrushingCritMatrix["Foot, top"][7] = {db=6,b=1,m=2};
	aCrushingCritMatrix["Foot, top"][8] = {db=6,b=1,m=2};
	aCrushingCritMatrix["Foot, top"][9] = {db=8,b=1,m=3};
	aCrushingCritMatrix["Foot, top"][10] = {db=8,b=1,m=3};
	aCrushingCritMatrix["Foot, top"][11] = {dm=2,b=1,m=4};
	aCrushingCritMatrix["Foot, top"][12] = {dm=2,b=1,m=4};
	aCrushingCritMatrix["Foot, top"][13] = {dm=2,b=1,m=5};
	aCrushingCritMatrix["Foot, top"][14] = {dm=2,b=1,m=5};
	aCrushingCritMatrix["Foot, top"][15] = {dm=2,b=1,m=6};
	aCrushingCritMatrix["Foot, top"][16] = {dm=2,b=1,m=6};
	aCrushingCritMatrix["Foot, top"][17] = {dm=2,b=1,m=7};
	aCrushingCritMatrix["Foot, top"][18] = {dm=2,b=1,m=7};
	aCrushingCritMatrix["Foot, top"][19] = {dm=2,bm=1,m=7};
	aCrushingCritMatrix["Foot, top"][20] = {dm=2,bm=1,m=8};
	aCrushingCritMatrix["Foot, top"][21] = {dm=2,bf=1,m=8};
	aCrushingCritMatrix["Foot, top"][22] = {dm=2,bf=1,m=9};
	aCrushingCritMatrix["Foot, top"][23] = {dm=2,bs=1,m=9};
	aCrushingCritMatrix["Foot, top"][24] = {dm=2,bs=1,m=10};
	
	aCrushingCritMatrix["Heel"] = {};
	aCrushingCritMatrix["Heel"][1] = {db=1};
	aCrushingCritMatrix["Heel"][2] = {db=1};
	aCrushingCritMatrix["Heel"][3] = {db=3};
	aCrushingCritMatrix["Heel"][4] = {db=3};
	aCrushingCritMatrix["Heel"][5] = {db=4,m=1};
	aCrushingCritMatrix["Heel"][6] = {db=4,m=1};
	aCrushingCritMatrix["Heel"][7] = {db=6,b=1,m=2};
	aCrushingCritMatrix["Heel"][8] = {db=6,b=1,m=2,a=1};
	aCrushingCritMatrix["Heel"][9] = {db=8,b=1,m=3,a=1};
	aCrushingCritMatrix["Heel"][10] = {db=8,b=1,m=3,a=2};
	aCrushingCritMatrix["Heel"][11] = {dm=2,b=1,m=4,a=2};
	aCrushingCritMatrix["Heel"][12] = {dm=2,b=1,a=2,d=1,m=4};
	aCrushingCritMatrix["Heel"][13] = {dm=2,b=1,a=2,d=2,m=5};
	aCrushingCritMatrix["Heel"][14] = {dm=2,b=1,a=2,d=2,m=5};
	aCrushingCritMatrix["Heel"][15] = {dm=2,b=1,a=2,d=2,m=6};
	aCrushingCritMatrix["Heel"][16] = {dm=2,b=1,a=3,d=2,m=6};
	aCrushingCritMatrix["Heel"][17] = {dm=2,b=1,a=3,d=2,m=7};
	aCrushingCritMatrix["Heel"][18] = {dm=2,b=1,a=3,d=2,m=7};
	aCrushingCritMatrix["Heel"][19] = {dm=2,bm=1,a=3,d=2,m=7};
	aCrushingCritMatrix["Heel"][20] = {dm=2,bm=1,a=3,d=2,m=8};
	aCrushingCritMatrix["Heel"][21] = {dm=2,bf=1,a=3,d=2,m=8};
	aCrushingCritMatrix["Heel"][22] = {dm=2,bf=1,a=3,d=2,m=9};
	aCrushingCritMatrix["Heel"][23] = {dm=2,bs=1,a=3,d=2,m=9};
	aCrushingCritMatrix["Heel"][24] = {dm=2,bs=1,a=3,d=2,m=10};

	aCrushingCritMatrix["Toe(s)"] = {};
	aCrushingCritMatrix["Toe(s)"][1] = {db=1,};
	aCrushingCritMatrix["Toe(s)"][2] = {db=1};
	aCrushingCritMatrix["Toe(s)"][3] = {db=3};
	aCrushingCritMatrix["Toe(s)"][4] = {db=3};
	aCrushingCritMatrix["Toe(s)"][5] = {db=4,m=1};
	aCrushingCritMatrix["Toe(s)"][6] = {db=4,m=1};
	aCrushingCritMatrix["Toe(s)"][7] = {db=6,b=1,m=2};
	aCrushingCritMatrix["Toe(s)"][8] = {db=6,b=1,m=2};
	aCrushingCritMatrix["Toe(s)"][9] = {db=8,b=1,m=3};
	aCrushingCritMatrix["Toe(s)"][10] = {db=8,b=1,m=3};
	aCrushingCritMatrix["Toe(s)"][11] = {dm=2,b=1,m=4};
	aCrushingCritMatrix["Toe(s)"][12] = {dm=2,b=1,m=4};
	aCrushingCritMatrix["Toe(s)"][13] = {dm=2,b=1,m=5};
	aCrushingCritMatrix["Toe(s)"][14] = {dm=2,b=1,m=5};
	aCrushingCritMatrix["Toe(s)"][15] = {dm=2,b=1,m=6};
	aCrushingCritMatrix["Toe(s)"][16] = {dm=2,b=1,m=6};
	aCrushingCritMatrix["Toe(s)"][17] = {dm=2,b=1,m=7};
	aCrushingCritMatrix["Toe(s)"][18] = {dm=2,b=1,m=7};
	aCrushingCritMatrix["Toe(s)"][19] = {dm=2,bm=1,m=7};
	aCrushingCritMatrix["Toe(s)"][20] = {dm=2,bm=1,m=8};
	aCrushingCritMatrix["Toe(s)"][21] = {dm=2,bf=1,m=8};
	aCrushingCritMatrix["Toe(s)"][22] = {dm=2,bf=1,m=9};
	aCrushingCritMatrix["Toe(s)"][23] = {dm=2,bs=1,m=9};
	aCrushingCritMatrix["Toe(s)"][24] = {dm=2,bs=1,m=10};
	
	aCrushingCritMatrix["Foot, arch"] = {};
	aCrushingCritMatrix["Foot, arch"][1] = {db=1};
	aCrushingCritMatrix["Foot, arch"][2] = {db=1};
	aCrushingCritMatrix["Foot, arch"][3] = {db=3};
	aCrushingCritMatrix["Foot, arch"][4] = {db=3};
	aCrushingCritMatrix["Foot, arch"][5] = {db=4,m=1};
	aCrushingCritMatrix["Foot, arch"][6] = {db=4,m=1};
	aCrushingCritMatrix["Foot, arch"][7] = {db=6,b=1,m=2};
	aCrushingCritMatrix["Foot, arch"][8] = {db=6,b=1,m=2,a=1};
	aCrushingCritMatrix["Foot, arch"][9] = {db=8,b=1,m=3,a=1};
	aCrushingCritMatrix["Foot, arch"][10] = {db=8,b=1,m=3,a=2};
	aCrushingCritMatrix["Foot, arch"][11] = {dm=2,b=1,m=4,a=2};
	aCrushingCritMatrix["Foot, arch"][12] = {dm=2,b=1,a=2,d=1,m=4};
	aCrushingCritMatrix["Foot, arch"][13] = {dm=2,b=1,a=2,d=2,m=5};
	aCrushingCritMatrix["Foot, arch"][14] = {dm=2,b=1,a=2,d=2,m=5};
	aCrushingCritMatrix["Foot, arch"][15] = {dm=2,b=1,a=2,d=2,m=6};
	aCrushingCritMatrix["Foot, arch"][16] = {dm=2,b=1,a=3,d=2,m=6};
	aCrushingCritMatrix["Foot, arch"][17] = {dm=2,b=1,a=3,d=2,m=7};
	aCrushingCritMatrix["Foot, arch"][18] = {dm=2,b=1,a=3,d=2,m=7};
	aCrushingCritMatrix["Foot, arch"][19] = {dm=2,bm=1,a=3,d=2,m=7};
	aCrushingCritMatrix["Foot, arch"][20] = {dm=2,bm=1,a=3,d=2,m=8};
	aCrushingCritMatrix["Foot, arch"][21] = {dm=2,bf=1,a=3,d=2,m=8};
	aCrushingCritMatrix["Foot, arch"][22] = {dm=2,bf=1,a=3,d=2,m=9};
	aCrushingCritMatrix["Foot, arch"][23] = {dm=2,bs=1,a=3,d=2,m=9};
	aCrushingCritMatrix["Foot, arch"][24] = {dm=2,bs=1,a=3,d=2,m=10};
	
	aCrushingCritMatrix["Ankle, inner"] = {};
	aCrushingCritMatrix["Ankle, inner"][1] = {db=1};
	aCrushingCritMatrix["Ankle, inner"][2] = {db=1};
	aCrushingCritMatrix["Ankle, inner"][3] = {db=3};
	aCrushingCritMatrix["Ankle, inner"][4] = {db=4,m=1};
	aCrushingCritMatrix["Ankle, inner"][5] = {db=6,m=1};
	aCrushingCritMatrix["Ankle, inner"][6] = {db=6,m=2,f=true};
	aCrushingCritMatrix["Ankle, inner"][7] = {db=8,m=2,f=true};
	aCrushingCritMatrix["Ankle, inner"][8] = {dm=2,d=1,m=3,f=true,b=1};
	aCrushingCritMatrix["Ankle, inner"][9] = {dm=2,d=2,f=true,m=4,t=1};
	aCrushingCritMatrix["Ankle, inner"][10] = {dm=2,d=2,f=true,m=5,b=1};
	aCrushingCritMatrix["Ankle, inner"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aCrushingCritMatrix["Ankle, inner"][12] = {dm=2,d=2,f=true,m=5,t=1};
	aCrushingCritMatrix["Ankle, inner"][13] = {dm=2,d=2,b=1,t=1,f=true,m=5};
	aCrushingCritMatrix["Ankle, inner"][14] = {dm=2,d=3,s=1,bf=1,f=true,m=5};
	aCrushingCritMatrix["Ankle, inner"][15] = {dm=2,d=3,s=1,b=1,t=1,f=true,m=5};
	aCrushingCritMatrix["Ankle, inner"][16] = {dm=2,d=3,s=2,bm=1,f=true,m=6};
	aCrushingCritMatrix["Ankle, inner"][17] = {dm=2,d=4,s=2,b=1,t=1,f=true,m=7};
	aCrushingCritMatrix["Ankle, inner"][18] = {dm=2,d=5,d=2,bf=1,f=true,m=7};
	aCrushingCritMatrix["Ankle, inner"][19] = {dm=2,d=5,s=3,b=1,t=1,f=true,m=8};
	aCrushingCritMatrix["Ankle, inner"][20] = {dm=2,bm=1,t=1,f=true,m=8,d=6,s=3};
	aCrushingCritMatrix["Ankle, inner"][21] = {dm=2,d=6,s=3,bm=1,t=1,f=true,m=9};
	aCrushingCritMatrix["Ankle, inner"][22] = {dm=2,d=6,s=4,bs=1,t=1,f=true,m=9};
	aCrushingCritMatrix["Ankle, inner"][23] = {dm=2,d=6,s=5,bs=1,m=10,t=1,f=true};
	aCrushingCritMatrix["Ankle, inner"][24] = {dm=2,d=7,s=5,bs=1,m=10,f=true,t=1};
	
	aCrushingCritMatrix["Ankle, outer"] = {};
	aCrushingCritMatrix["Ankle, outer"][1] = {db=1};
	aCrushingCritMatrix["Ankle, outer"][2] = {db=1};
	aCrushingCritMatrix["Ankle, outer"][3] = {db=3};
	aCrushingCritMatrix["Ankle, outer"][4] = {db=4,m=1};
	aCrushingCritMatrix["Ankle, outer"][5] = {db=6,m=1};
	aCrushingCritMatrix["Ankle, outer"][6] = {db=6,m=2,f=true};
	aCrushingCritMatrix["Ankle, outer"][7] = {db=8,m=2,f=true};
	aCrushingCritMatrix["Ankle, outer"][8] = {dm=2,d=1,m=3,f=true,b=1};
	aCrushingCritMatrix["Ankle, outer"][9] = {dm=2,d=2,f=true,m=4,t=1};
	aCrushingCritMatrix["Ankle, outer"][10] = {dm=2,d=2,f=true,m=5,b=1};
	aCrushingCritMatrix["Ankle, outer"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aCrushingCritMatrix["Ankle, outer"][12] = {dm=2,d=2,f=true,m=5,t=1};
	aCrushingCritMatrix["Ankle, outer"][13] = {dm=2,d=2,b=1,t=1,f=true,m=5};
	aCrushingCritMatrix["Ankle, outer"][14] = {dm=2,d=3,s=1,bf=1,f=true,m=5};
	aCrushingCritMatrix["Ankle, outer"][15] = {dm=2,d=3,s=1,b=1,t=2,f=true,m=6};
	aCrushingCritMatrix["Ankle, outer"][16] = {dm=2,d=3,s=2,bm=1,f=true,m=6};
	aCrushingCritMatrix["Ankle, outer"][17] = {dm=2,d=4,s=2,b=1,t=2,f=true,m=7};
	aCrushingCritMatrix["Ankle, outer"][18] = {dm=2,d=5,ds=2,bf=1,f=true,m=7};
	aCrushingCritMatrix["Ankle, outer"][19] = {dm=2,d=5,s=3,b=1,t=2,f=true,m=8};
	aCrushingCritMatrix["Ankle, outer"][20] = {dm=2,bm=1,t=2,f=true,m=8,d=6,s=3};
	aCrushingCritMatrix["Ankle, outer"][21] = {dm=2,d=6,s=3,bm=1,t=2,f=true,m=9};
	aCrushingCritMatrix["Ankle, outer"][22] = {dm=2,d=6,s=4,bs=1,t=2,f=true,m=9};
	aCrushingCritMatrix["Ankle, outer"][23] = {dm=2,d=6,s=5,bs=1,m=10,t=2,f=true};
	aCrushingCritMatrix["Ankle, outer"][24] = {dm=2,d=7,s=5,bs=1,m=10,f=true,t=2};
	
	aCrushingCritMatrix["Ankle, upper/Achilles"] = {};
	aCrushingCritMatrix["Ankle, upper/Achilles"][1] = {db=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][2] = {db=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][3] = {db=3};
	aCrushingCritMatrix["Ankle, upper/Achilles"][4] = {db=3};
	aCrushingCritMatrix["Ankle, upper/Achilles"][5] = {db=4,m=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][6] = {db=4,m=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][7] = {db=6,m=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][8] = {db=6,m=2};
	aCrushingCritMatrix["Ankle, upper/Achilles"][9] = {db=8,m=2};
	aCrushingCritMatrix["Ankle, upper/Achilles"][10] = {dm=2,d=1,m=3};
	aCrushingCritMatrix["Ankle, upper/Achilles"][11] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Ankle, upper/Achilles"][12] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Ankle, upper/Achilles"][13] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Ankle, upper/Achilles"][14] = {dm=1,d=2,f=true,m=9,t=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][15] = {dm=2,d=2,b=1,f=true,m=5};
	aCrushingCritMatrix["Ankle, upper/Achilles"][16] = {dm=2,d=3,b=1,f=true,m=9,t=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][17] = {dm=2,d=3,bm=1,f=true,m=6};
	aCrushingCritMatrix["Ankle, upper/Achilles"][18] = {dm=2,d=4,b=1,f=true,m=9,t=1};
	aCrushingCritMatrix["Ankle, upper/Achilles"][19] = {dm=2,d=5,bf=2,f=true,m=6};
	aCrushingCritMatrix["Ankle, upper/Achilles"][20] = {dm=2,d=5,b=2,f=true,m=9,t=2};
	aCrushingCritMatrix["Ankle, upper/Achilles"][21] = {dm=2,bm=2,f=true,m=10,d=6,s=3,t=2};
	aCrushingCritMatrix["Ankle, upper/Achilles"][22] = {dm=2,d=6,bm=2,f=true,m=10,t=2};
	aCrushingCritMatrix["Ankle, upper/Achilles"][23] = {dm=2,bs=2,f=true,d=6,m=10,t=2};
	aCrushingCritMatrix["Ankle, upper/Achilles"][24] = {dm=2,d=6,s=1,bs=2,t=2,m=10,f=true};
	
	aCrushingCritMatrix["Shin"] = {};
	aCrushingCritMatrix["Shin"][1] = {db=1};
	aCrushingCritMatrix["Shin"][2] = {db=1};
	aCrushingCritMatrix["Shin"][3] = {db=3};
	aCrushingCritMatrix["Shin"][4] = {db=3};
	aCrushingCritMatrix["Shin"][5] = {db=4};
	aCrushingCritMatrix["Shin"][6] = {db=4};
	aCrushingCritMatrix["Shin"][7] = {db=6,m=1};
	aCrushingCritMatrix["Shin"][8] = {db=6,m=1};
	aCrushingCritMatrix["Shin"][9] = {db=8,m=1};
	aCrushingCritMatrix["Shin"][10] = {db=8,d=1,m=1};
	aCrushingCritMatrix["Shin"][11] = {dm=2,d=2,f=true,m=1};
	aCrushingCritMatrix["Shin"][12] = {dm=2,d=2,f=true,m=2};
	aCrushingCritMatrix["Shin"][13] = {dm=2,d=2,f=true,m=2};
	aCrushingCritMatrix["Shin"][14] = {dm=2,d=2,f=true,m=2};
	aCrushingCritMatrix["Shin"][15] = {dm=2,d=2,b=1,f=true,m=2};
	aCrushingCritMatrix["Shin"][16] = {dm=2,d=3,b=1,f=true,m=2};
	aCrushingCritMatrix["Shin"][17] = {dm=2,d=3,bm=1,f=true,m=3};
	aCrushingCritMatrix["Shin"][18] = {dm=2,d=4,b=1,f=true,m=3};
	aCrushingCritMatrix["Shin"][19] = {dm=2,d=5,bf=1,f=true,m=3};
	aCrushingCritMatrix["Shin"][20] = {dm=2,d=5,b=1,f=true,m=3};
	aCrushingCritMatrix["Shin"][21] = {dm=2,bm=1,f=true,m=4,d=6,s=3};
	aCrushingCritMatrix["Shin"][22] = {dm=2,d=6,bm=1,f=true,m=4};
	aCrushingCritMatrix["Shin"][23] = {dm=2,bs=1,f=grue,d=6,m=5};
	aCrushingCritMatrix["Shin"][24] = {dm=2,d=6,s=1,bs=1,m=5,f=true};

	aCrushingCritMatrix["Calf"] = {};
	aCrushingCritMatrix["Calf"][1] = {db=1};
	aCrushingCritMatrix["Calf"][2] = {db=1};
	aCrushingCritMatrix["Calf"][3] = {db=3};
	aCrushingCritMatrix["Calf"][4] = {db=3};
	aCrushingCritMatrix["Calf"][5] = {db=4,m=1};
	aCrushingCritMatrix["Calf"][6] = {db=4,m=1};
	aCrushingCritMatrix["Calf"][7] = {db=6,m=1};
	aCrushingCritMatrix["Calf"][8] = {db=6,m=2};
	aCrushingCritMatrix["Calf"][9] = {db=8,m=2};
	aCrushingCritMatrix["Calf"][10] = {dm=2,d=1,m=3};
	aCrushingCritMatrix["Calf"][11] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Calf"][12] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Calf"][13] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Calf"][14] = {dm=2,d=2,f=true,m=5,mt=1};
	aCrushingCritMatrix["Calf"][15] = {dm=2,d=2,b=1,f=true,m=5};
	aCrushingCritMatrix["Calf"][16] = {dm=2,d=3,b=1,f=true,m=6,mt=1};
	aCrushingCritMatrix["Calf"][17] = {dm=2,d=3,bm=1,f=true,m=6};
	aCrushingCritMatrix["Calf"][18] = {dm=2,d=4,b=2,f=true,m=6,mt=2};
	aCrushingCritMatrix["Calf"][19] = {dm=2,d=5,bf=2,f=true,m=6};
	aCrushingCritMatrix["Calf"][20] = {dm=2,d=5,b=2,f=true,m=7,mt=2};
	aCrushingCritMatrix["Calf"][21] = {dm=2,bm=2,f=true,m=7,d=6,s=3,mt=2};
	aCrushingCritMatrix["Calf"][22] = {dm=2,d=6,bm=2,f=true,m=8,mt=8};
	aCrushingCritMatrix["Calf"][23] = {dm=2,bs=2,f=true,d=6,m=8,mt=2};
	aCrushingCritMatrix["Calf"][24] = {dm=2,d=6,s=1,bs=2,m=9,f=true};

	aCrushingCritMatrix["Knee"] = {};
	aCrushingCritMatrix["Knee"][1] = {db=1};
	aCrushingCritMatrix["Knee"][2] = {db=1};
	aCrushingCritMatrix["Knee"][3] = {db=3};
	aCrushingCritMatrix["Knee"][4] = {db=4,m=1};
	aCrushingCritMatrix["Knee"][5] = {db=6,m=1};
	aCrushingCritMatrix["Knee"][6] = {db=6,m=2,f=true};
	aCrushingCritMatrix["Knee"][7] = {db=8,m=2,f=true};
	aCrushingCritMatrix["Knee"][8] = {dm=2,d=1,m=3,f=true,b=1};
	aCrushingCritMatrix["Knee"][9] = {dm=2,d=2,f=true,m=4,t=1};
	aCrushingCritMatrix["Knee"][10] = {dm=2,d=2,f=true,m=5,b=1};
	aCrushingCritMatrix["Knee"][11] = {dm=2,d=2,f=true,m=5,t=1};
	aCrushingCritMatrix["Knee"][12] = {dm=2,d=2,f=true,m=5,t=1};
	aCrushingCritMatrix["Knee"][13] = {dm=2,d=2,b=2,t=1,f=true,m=5};
	aCrushingCritMatrix["Knee"][14] = {dm=2,d=3,s=1,bf=2,f=true,m=5};
	aCrushingCritMatrix["Knee"][15] = {dm=2,d=3,s=1,b=2,t=1,f=true,m=5};
	aCrushingCritMatrix["Knee"][16] = {dm=2,d=3,s=1,b=2,t=1,f=true,m=6};
	aCrushingCritMatrix["Knee"][17] = {dm=2,d=4,s=2,b=2,t=1,f=true,m=7};
	aCrushingCritMatrix["Knee"][18] = {dm=2,d=5,s=2,bf=3,f=true,m=7};
	aCrushingCritMatrix["Knee"][19] = {dm=2,d=5,s=3,b=3,t=1,f=true,m=8};
	aCrushingCritMatrix["Knee"][20] = {dm=2,bm=3,t=1,f=true,m=8,d=6,s=3};
	aCrushingCritMatrix["Knee"][21] = {dm=2,d=6,s=3,bm=3,t=1,f=true,m=9};
	aCrushingCritMatrix["Knee"][22] = {dm=2,d=6,s=4,bs=3,t=1,f=true,m=9};
	aCrushingCritMatrix["Knee"][23] = {dm=2,d=6,s=5,bs=3,m=10,t=1,f=true};
	aCrushingCritMatrix["Knee"][24] = {dm=2,d=7,s=5,bs=3,m=10,f=true,t=1};
		
	aCrushingCritMatrix["Knee, back"] = {};
	aCrushingCritMatrix["Knee, back"][1] = {db=1};
	aCrushingCritMatrix["Knee, back"][2] = {db=1};
	aCrushingCritMatrix["Knee, back"][3] = {db=3};
	aCrushingCritMatrix["Knee, back"][4] = {db=4};
	aCrushingCritMatrix["Knee, back"][5] = {db=6,m=1};
	aCrushingCritMatrix["Knee, back"][6] = {db=6,m=1};
	aCrushingCritMatrix["Knee, back"][7] = {db=8,m=2};
	aCrushingCritMatrix["Knee, back"][8] = {dm=2,d=1,m=2};
	aCrushingCritMatrix["Knee, back"][9] = {dm=2,d=2,f=true,m=3};
	aCrushingCritMatrix["Knee, back"][10] = {dm=2,d=2,f=true,m=3};
	aCrushingCritMatrix["Knee, back"][11] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Knee, back"][12] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Knee, back"][13] = {dm=2,d=2,t=1,f=true,m=5};
	aCrushingCritMatrix["Knee, back"][14] = {dm=2,d=3,s=1,t=1,f=true,m=5};
	aCrushingCritMatrix["Knee, back"][15] = {dm=2,d=3,s=1,t=1,f=true,m=5};
	aCrushingCritMatrix["Knee, back"][16] = {dm=2,d=3,s=1,t=1,f=true,m=5};
	aCrushingCritMatrix["Knee, back"][17] = {dm=2,d=4,s=2,t=1,f=true,m=6};
	aCrushingCritMatrix["Knee, back"][18] = {dm=2,d=5,s=2,b=1,t=1,f=true,m=6};
	aCrushingCritMatrix["Knee, back"][19] = {dm=2,d=5,s=3,b=1,t=1,f=true,m=7};
	aCrushingCritMatrix["Knee, back"][20] = {dm=2,bm=1,f=true,m=7,d=6,s=3};
	aCrushingCritMatrix["Knee, back"][21] = {dm=2,d=6,s=3,b=1,t=1,f=true,m=8};
	aCrushingCritMatrix["Knee, back"][22] = {dm=2,bm=1,t=1,f=true,d=6,s=4,m=8};
	aCrushingCritMatrix["Knee, back"][23] = {dm=2,d=6,s=5,bs=1,m=9,u=true};
	aCrushingCritMatrix["Knee, back"][24] = {dm=2,d=7,s=5,bs=1,t=1,m=9, u=true};
	
	aCrushingCritMatrix["Hamstring"] = {};
	aCrushingCritMatrix["Hamstring"][1] = {db=1};
	aCrushingCritMatrix["Hamstring"][2] = {db=3};
	aCrushingCritMatrix["Hamstring"][3] = {db=4,m=1};
	aCrushingCritMatrix["Hamstring"][4] = {db=6,m=1};
	aCrushingCritMatrix["Hamstring"][5] = {db=5,m=2};
	aCrushingCritMatrix["Hamstring"][6] = {db=8,m=2};
	aCrushingCritMatrix["Hamstring"][7] = {dm=2,d=1,m=3};
	aCrushingCritMatrix["Hamstring"][8] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Hamstring"][9] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Hamstring"][10] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Hamstring"][11] = {dm=2,d=2,f=true,m=5,mt=1};
	aCrushingCritMatrix["Hamstring"][12] = {dm=2,d=2,b=1,f=true,m=5};
	aCrushingCritMatrix["Hamstring"][13] = {dm=2,d=3,s=1,bf=1,f=true,m=5};
	aCrushingCritMatrix["Hamstring"][14] = {dm=2,d=3,s=1,b=1,f=true,m=5};
	aCrushingCritMatrix["Hamstring"][15] = {dm=2,d=3,s=1,b=1,f=true,m=6};
	aCrushingCritMatrix["Hamstring"][16] = {dm=2,d=3,s=2,bm=1,f=true,m=6};
	aCrushingCritMatrix["Hamstring"][17] = {dm=2,d=4,s=2,b=1,f=true,m=6};
	aCrushingCritMatrix["Hamstring"][18] = {dm=2,d=5,s=3,b=1,f=true,m=7};
	aCrushingCritMatrix["Hamstring"][19] = {dm=2,bm=1,f=true,m=7,d=6,s=3};
	aCrushingCritMatrix["Hamstring"][20] = {dm=2,d=6,s=3,bm=1,f=true,m=8};
	aCrushingCritMatrix["Hamstring"][21] = {dm=2,d=6,s=4,bs=1,f=true,m=8};
	aCrushingCritMatrix["Hamstring"][22] = {dm=2,d=6,s=5,bs=1,m=9,u=true};
	aCrushingCritMatrix["Hamstring"][23] = {dm=2,d=7,s=5,bs=1,m=9,u=true};
	aCrushingCritMatrix["Hamstring"][24] = {dm=3,d=8,s=5,bs=1,m=10,u=true};
	
	aCrushingCritMatrix["Thigh"] = {};
	aCrushingCritMatrix["Thigh"][1] = {db=1};
	aCrushingCritMatrix["Thigh"][2] = {db=3};
	aCrushingCritMatrix["Thigh"][3] = {db=4,m=1};
	aCrushingCritMatrix["Thigh"][4] = {db=6,m=1};
	aCrushingCritMatrix["Thigh"][5] = {db=6,m=2};
	aCrushingCritMatrix["Thigh"][6] = {db=8,m=2};
	aCrushingCritMatrix["Thigh"][7] = {dm=2,d=1,m=3};
	aCrushingCritMatrix["Thigh"][8] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Thigh"][9] = {dm=2,d=2,f=truce,m=5};
	aCrushingCritMatrix["Thigh"][10] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Thigh"][11] = {dm=2,d=2,f=true,m=5};
	aCrushingCritMatrix["Thigh"][12] = {dm=2,d=2,b=1,f=true,m=5};
	aCrushingCritMatrix["Thigh"][13] = {dm=2,d=3,s=1,bf=1,f=true,m=5,mt=1};
	aCrushingCritMatrix["Thigh"][14] = {dm=2,d=3,s=1,b=1,f=true,m=5};
	aCrushingCritMatrix["Thigh"][15] = {dm=2,d=3,s=1,b=1,f=true,m=6,mt=2};
	aCrushingCritMatrix["Thigh"][16] = {dm=2,d=3,s=2,bm=1,f=true,m=6};
	aCrushingCritMatrix["Thigh"][17] = {dm=2,d=4,s=2,b=1,f=true,m=6,mt=3};
	aCrushingCritMatrix["Thigh"][18] = {dm=2,d=5,s=3,b=1,f=true,m=7};
	aCrushingCritMatrix["Thigh"][19] = {dm=2,bm=1,f=true,m=7,d=6,s=3,mt=3};
	aCrushingCritMatrix["Thigh"][20] = {dm=2,d=6,s=3,bm=1,f=true,m=8,mt=4};
	aCrushingCritMatrix["Thigh"][21] = {dm=2,bs=1,f=true,d=6,s=4,m=8,mt=4};
	aCrushingCritMatrix["Thigh"][22] = {dm=2,d=6,s=5,bs=1,m=9,u=true};
	aCrushingCritMatrix["Thigh"][23] = {dm=2,d=7,s=5,bs=1,m=9,u=true,mt=5};
	aCrushingCritMatrix["Thigh"][24] = {dm=3,d=8,s=5,bs=1,m=10,u=true,mt=5};
	
	aCrushingCritMatrix["Hip"] = {};
	aCrushingCritMatrix["Hip"][1] = {db=1};
	aCrushingCritMatrix["Hip"][2] = {db=3};
	aCrushingCritMatrix["Hip"][3] = {db=4,m=1};
	aCrushingCritMatrix["Hip"][4] = {db=6,m=1};
	aCrushingCritMatrix["Hip"][5] = {db=8,m=2};
	aCrushingCritMatrix["Hip"][6] = {dm=2,m=2};
	aCrushingCritMatrix["Hip"][7] = {dm=2,d=1,m=3};
	aCrushingCritMatrix["Hip"][8] = {dm=2,d=2,f=true,m=4};
	aCrushingCritMatrix["Hip"][9] = {dm=2,d=2,b=1,f=true,m=5};
	aCrushingCritMatrix["Hip"][10] = {dm=2,d=2,b=1,f=true,m=5};
	aCrushingCritMatrix["Hip"][11] = {dm=3,d=2,f=true,b=1,m=5};
	aCrushingCritMatrix["Hip"][12] = {dm=3,d=2,bm=1,f=true,m=5};
	aCrushingCritMatrix["Hip"][13] = {dm=3,d=3,bf=2,f=true,m=5};
	aCrushingCritMatrix["Hip"][14] = {dm=3,d=3,b=2,f=true,m=5};
	aCrushingCritMatrix["Hip"][15] = {dm=3,d=3,v=1,b=2,f=true,m=6};
	aCrushingCritMatrix["Hip"][16] = {dm=3,d=3,bm=2,f=true,m=6};
	aCrushingCritMatrix["Hip"][17] = {dm=3,d=5,b=3,f=true,m=6};
	aCrushingCritMatrix["Hip"][18] = {dm=3,d=6,b=3,f=true,m=7};
	aCrushingCritMatrix["Hip"][19] = {dm=3,bm=3,v=1,f=true,m=7,d=7};
	aCrushingCritMatrix["Hip"][20] = {dm=3,bm=3,v=1,m=8,d=7};
	aCrushingCritMatrix["Hip"][21] = {dm=3,bs=4,v=2,f=true,m=8,d=8};
	aCrushingCritMatrix["Hip"][22] = {dm=3,bs=4,v=2,m=9,u=true,d=8};
	aCrushingCritMatrix["Hip"][23] = {dm=4,bs=4,v=2,m=9,u=true,d=9};
	aCrushingCritMatrix["Hip"][24] = {dm=4,bs=4,v=2,m=10,u=true,d=9};

	aCrushingCritMatrix["Groin"] = {};
	aCrushingCritMatrix["Groin"][1] = {db=1,f=true,h=1};
	aCrushingCritMatrix["Groin"][2] = {db=3,f=true,h=1};
	aCrushingCritMatrix["Groin"][3] = {db=4,f=true,h=2};
	aCrushingCritMatrix["Groin"][4] = {db=4,m=1,f=true,h=2};
	aCrushingCritMatrix["Groin"][5] = {db=6,m=1,f=true,h=2};
	aCrushingCritMatrix["Groin"][6] = {db=6,m=1,f=true,h=3};
	aCrushingCritMatrix["Groin"][7] = {db=8,m=2,f=true,h=3};
	aCrushingCritMatrix["Groin"][8] = {db=8,m=2,f=true,h=4};
	aCrushingCritMatrix["Groin"][9] = {dm=2,m=2,f=true,h=4};
	aCrushingCritMatrix["Groin"][10] = {dm=2,m=3,f=true,h=4};
	aCrushingCritMatrix["Groin"][11] = {dm=2,m=3,f=true,h=5};
	aCrushingCritMatrix["Groin"][12] = {dm=3,m=3,f=true,h=5};
	aCrushingCritMatrix["Groin"][13] = {dm=3,m=4,f=true,h=5};
	aCrushingCritMatrix["Groin"][14] = {dm=3,m=4,f=true,h=6};
	aCrushingCritMatrix["Groin"][15] = {dm=3,m=4,f=true,h=6,v=1};
	aCrushingCritMatrix["Groin"][16] = {dm=3,m=4,f=true,h=6,v=1};
	aCrushingCritMatrix["Groin"][17] = {dm=3,m=4,f=true,h=7,v=1};
	aCrushingCritMatrix["Groin"][18] = {dm=3,m=4,f=true,h=8,v=1};
	aCrushingCritMatrix["Groin"][19] = {dm=3,m=4,f=true,h=9,v=2};
	aCrushingCritMatrix["Groin"][20] = {dm=3,m=5,f=true,h=10,v=2};
	aCrushingCritMatrix["Groin"][21] = {dm=3,m=5,f=5,h=9,v=2,b=1};
	aCrushingCritMatrix["Groin"][22] = {dm=3,m=5,f=true,h=10,v=2,bm=1};
	aCrushingCritMatrix["Groin"][23] = {dm=3,m=5,f=true,h=10,v=2,bf=1};
	aCrushingCritMatrix["Groin"][24] = {dm=3,m=5,f=true,h=10,v=2,bs=1};
	
	aCrushingCritMatrix["Buttock"] = {};
	aCrushingCritMatrix["Buttock"][1] = {db=1};
	aCrushingCritMatrix["Buttock"][2] = {db=3};
	aCrushingCritMatrix["Buttock"][3] = {db=4};
	aCrushingCritMatrix["Buttock"][4] = {db=6};
	aCrushingCritMatrix["Buttock"][5] = {db=8};
	aCrushingCritMatrix["Buttock"][6] = {dm=2};
	aCrushingCritMatrix["Buttock"][7] = {dm=2,m=1};
	aCrushingCritMatrix["Buttock"][8] = {dm=2,m=1};
	aCrushingCritMatrix["Buttock"][9] = {dm=2,m=2};
	aCrushingCritMatrix["Buttock"][10] = {dm=2,m=2,mt=1};
	aCrushingCritMatrix["Buttock"][11] = {dm=3,m=3};
	aCrushingCritMatrix["Buttock"][12] = {dm=3,m=3,d=1};
	aCrushingCritMatrix["Buttock"][13] = {dm=3,m=3,d=1,b=1};
	aCrushingCritMatrix["Buttock"][14] = {dm=3,m=3,d=2,mt=1};
	aCrushingCritMatrix["Buttock"][15] = {dm=3,m=3,d=2,b=1,f=true};
	aCrushingCritMatrix["Buttock"][16] = {dm=3,m=3,d=2,mt=1,f=true,ib=true};
	aCrushingCritMatrix["Buttock"][17] = {dm=3,m=3,d=2,mt=1,f=true,ib=true};
	aCrushingCritMatrix["Buttock"][18] = {dm=3,m=4,d=2,b=2,f=true};
	aCrushingCritMatrix["Buttock"][19] = {dm=3,m=5,d=3,b=2,f=true};
	aCrushingCritMatrix["Buttock"][20] = {dm=3,m=5,d=3,b=3,f=true};
	aCrushingCritMatrix["Buttock"][21] = {dm=3,m=5,d=4,b=3,f=true,mt=1};
	aCrushingCritMatrix["Buttock"][22] = {dm=3,m=6,d=5,bm=3,f=true,m=1};
	aCrushingCritMatrix["Buttock"][23] = {dm=4,m=7,d=6,bs=3,f=true};
	aCrushingCritMatrix["Buttock"][24] = {dm=4,m=8,d=7,bs=3,f=true,mt=1};

	aCrushingCritMatrix["Abdomen, Lower"] = {};
	aCrushingCritMatrix["Abdomen, Lower"][1] = {db=3};
	aCrushingCritMatrix["Abdomen, Lower"][2] = {db=4};
	aCrushingCritMatrix["Abdomen, Lower"][3] = {db=6};
	aCrushingCritMatrix["Abdomen, Lower"][4] = {db=8};
	aCrushingCritMatrix["Abdomen, Lower"][5] = {dm=2};
	aCrushingCritMatrix["Abdomen, Lower"][6] = {dm=2,ws=true};
	aCrushingCritMatrix["Abdomen, Lower"][7] = {dm=2,ib=true,s=1};
	aCrushingCritMatrix["Abdomen, Lower"][8] = {dm=2,s=2,ib=true,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][9] = {dm=3,s=2,ws=true,v=1};
	aCrushingCritMatrix["Abdomen, Lower"][10] = {dm=3,s=2,w=true,ib=true,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][11] = {dm=3,d=2,w=true,v=1,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][12] = {dm=3,s=3,mt=1,w=true,ib=true,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][13] = {dm=3,s=3,mt=1,v=2,w=true,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][14] = {dm=3,s=3,v=2,mt=1,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][15] = {dm=3,s=3,mt=1,v=2,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][16] = {dm=3,a=3,s=3,v=3,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][17] = {dm=3,a=2,s=3,v=3,f=true,mt=1};
	aCrushingCritMatrix["Abdomen, Lower"][18] = {dm=3,a=3,s=3,v=3,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][19] = {dm=3,a=3,s=3,v=4,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][20] = {dm=3,a=3,s=3,mt=2,v=4,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][21] = {dm=3,u=true,v=4,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][22] = {dm=3,b=1,v=4,u=true,f=true};
	aCrushingCritMatrix["Abdomen, Lower"][23] = {cm=4,b=2,v=4,mt=2,u=true};
	aCrushingCritMatrix["Abdomen, Lower"][24] = {dead="body cavity crushed"};

	aCrushingCritMatrix["Side, lower"] = {};
	aCrushingCritMatrix["Side, lower"][1] = {db=1};
	aCrushingCritMatrix["Side, lower"][2] = {db=3};
	aCrushingCritMatrix["Side, lower"][3] = {db=4};
	aCrushingCritMatrix["Side, lower"][4] = {db=6};
	aCrushingCritMatrix["Side, lower"][5] = {db=8};
	aCrushingCritMatrix["Side, lower"][6] = {dm=2};
	aCrushingCritMatrix["Side, lower"][7] = {dm=2,a=1};
	aCrushingCritMatrix["Side, lower"][8] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Side, lower"][9] = {dm=2,a=2,ws=true};
	aCrushingCritMatrix["Side, lower"][10] = {dm=3,a=2,ws=true,mt=1};
	aCrushingCritMatrix["Side, lower"][11] = {dm=3,a=2,ws=true,mt=1};
	aCrushingCritMatrix["Side, lower"][12] = {dm=3,a=2,s=1,ws=true};
	aCrushingCritMatrix["Side, lower"][13] = {dm=3,a=2,s=1,w=true};
	aCrushingCritMatrix["Side, lower"][14] = {dm=3,a=2,s=2,mt=1,w=true};
	aCrushingCritMatrix["Side, lower"][15] = {dm=3,a=2,s=2,f=true};
	aCrushingCritMatrix["Side, lower"][16] = {dm=3,a=2,s=3,mt=1,f=true};
	aCrushingCritMatrix["Side, lower"][17] = {dm=3,a=3,s=3,mt=2,f=true};
	aCrushingCritMatrix["Side, lower"][18] = {dm=3,a=3,s=3,ib=true,mt=2,f=true};
	aCrushingCritMatrix["Side, lower"][19] = {dm=3,a=3,s=3,mt=2,f=true,v=1};
	aCrushingCritMatrix["Side, lower"][20] = {dm=3,a=4,s=4,b=1,f=true};
	aCrushingCritMatrix["Side, lower"][21] = {dm=3,u=true,b=1,mt=2};
	aCrushingCritMatrix["Side, lower"][22] = {dm=3,b=1,v=2,u=true};
	aCrushingCritMatrix["Side, lower"][23] = {dm=4,b=2,v=2,mt=2,u=true};
	aCrushingCritMatrix["Side, lower"][24] = {dead="body cavity crushed"};
	
	aCrushingCritMatrix["Abdomen, upper"] = {};
	aCrushingCritMatrix["Abdomen, upper"][1] = {db=3};
	aCrushingCritMatrix["Abdomen, upper"][2] = {db=4};
	aCrushingCritMatrix["Abdomen, upper"][3] = {db=6};
	aCrushingCritMatrix["Abdomen, upper"][4] = {db=8};
	aCrushingCritMatrix["Abdomen, upper"][5] = {dm=2};
	aCrushingCritMatrix["Abdomen, upper"][6] = {dm=2,ws=true};
	aCrushingCritMatrix["Abdomen, upper"][7] = {dm=2,ib=true,s=1};
	aCrushingCritMatrix["Abdomen, upper"][8] = {dm=2,s=2,ib=true,f=true};
	aCrushingCritMatrix["Abdomen, upper"][9] = {dm=3,s=2,ws=true,v=1};
	aCrushingCritMatrix["Abdomen, upper"][10] = {dm=3,s=2,w=true,ib=true,f=true};
	aCrushingCritMatrix["Abdomen, upper"][11] = {dm=3,s=2,w=true,v=1,f=true};
	aCrushingCritMatrix["Abdomen, upper"][12] = {dm=3,s=3,mt=1,w=true,ib=true};
	aCrushingCritMatrix["Abdomen, upper"][13] = {dm=3,s=3,mt=1,v=1,w=true};
	aCrushingCritMatrix["Abdomen, upper"][14] = {dm=3,s=3,v=2,mt=1,f=true};
	aCrushingCritMatrix["Abdomen, upper"][15] = {dm=3,s=3,mt=2,v=2,f=true};
	aCrushingCritMatrix["Abdomen, upper"][16] = {dm=3,a=1,s=3,v=2,f=true};
	aCrushingCritMatrix["Abdomen, upper"][17] = {dm=3,a=2,s=3,v=2,f=true,mt=2};
	aCrushingCritMatrix["Abdomen, upper"][18] = {dm=3,a=3,s=3,v=3,f=true};
	aCrushingCritMatrix["Abdomen, upper"][19] = {dm=3,a=3,s=3,v=3,f=true};
	aCrushingCritMatrix["Abdomen, upper"][20] = {dm=3,a=3,s=3,mt=2,v=3,f=true};
	aCrushingCritMatrix["Abdomen, upper"][21] = {dm=3,u=true,v=3,f=true};
	aCrushingCritMatrix["Abdomen, upper"][22] = {dm=3,b=1,v=3,u=true};
	aCrushingCritMatrix["Abdomen, upper"][23] = {dm=4,b=1,v=3,mt=2,u=true};
	aCrushingCritMatrix["Abdomen, upper"][24] = {dead="body cavity crushed"};

	aCrushingCritMatrix["Back, small of"] = {};
	aCrushingCritMatrix["Back, small of"][1] = {db=3};
	aCrushingCritMatrix["Back, small of"][2] = {db=4};
	aCrushingCritMatrix["Back, small of"][3] = {db=6};
	aCrushingCritMatrix["Back, small of"][4] = {db=8};
	aCrushingCritMatrix["Back, small of"][5] = {dm=2};
	aCrushingCritMatrix["Back, small of"][6] = {dm=2,ws=true,s=1};
	aCrushingCritMatrix["Back, small of"][7] = {dm=2,ib=true,s=2};
	aCrushingCritMatrix["Back, small of"][8] = {dm=2,s=2,w=true,ib=true};
	aCrushingCritMatrix["Back, small of"][9] = {dm=2,s=2,w=true,mt=1};
	aCrushingCritMatrix["Back, small of"][10] = {dm=3,s=2,w=true,ib=true};
	aCrushingCritMatrix["Back, small of"][11] = {dm=3,s=2,w=true,mt=1,ib=true};
	aCrushingCritMatrix["Back, small of"][12] = {dm=3,s=3,mt=1,w=true,ib=true};
	aCrushingCritMatrix["Back, small of"][13] = {dm=3,s=3,mt=1,v=1,w=true};
	aCrushingCritMatrix["Back, small of"][14] = {dm=3,s=3,v=1,mt=1};
	aCrushingCritMatrix["Back, small of"][15] = {dm=3,s=3,mt=2,v=1};
	aCrushingCritMatrix["Back, small of"][16] = {dm=3,s=4,b=1,v=1};
	aCrushingCritMatrix["Back, small of"][17] = {dm=3,s=5,b=1,v=2,f=true,mt=2};
	aCrushingCritMatrix["Back, small of"][18] = {dm=3,s=6,bf=1,v=2,f=true};
	aCrushingCritMatrix["Back, small of"][19] = {dm=3,bm=1,v=2,f=true};
	aCrushingCritMatrix["Back, small of"][20] = {dm=3,bm=1,mt=2,v=2,f=true};
	aCrushingCritMatrix["Back, small of"][21] = {dm=3,bs=1,u=true,v=2};
	aCrushingCritMatrix["Back, small of"][22] = {dm=3,bs=1,v=2,u=true};
	aCrushingCritMatrix["Back, small of"][23] = {dm=4,bs=1,v=2,mt=2,u=true};
	aCrushingCritMatrix["Back, small of"][24] = {dead="body cavity crushed"};

	aCrushingCritMatrix["Back, lower"] = {};
	aCrushingCritMatrix["Back, lower"][1] = {db=3};
	aCrushingCritMatrix["Back, lower"][2] = {db=4};
	aCrushingCritMatrix["Back, lower"][3] = {db=6};
	aCrushingCritMatrix["Back, lower"][4] = {db=8};
	aCrushingCritMatrix["Back, lower"][5] = {dm=2,};
	aCrushingCritMatrix["Back, lower"][6] = {dm=2,ws=true};
	aCrushingCritMatrix["Back, lower"][7] = {dm=2,ib=true,s=1};
	aCrushingCritMatrix["Back, lower"][8] = {dm=2,s=2,ib=true,f=true};
	aCrushingCritMatrix["Back, lower"][9] = {dm=3,s=2,wis=true,b=1};
	aCrushingCritMatrix["Back, lower"][10] = {dm=3,s=2,w=true,ib=true,f=true};
	aCrushingCritMatrix["Back, lower"][11] = {dm=3,s=2,w=true,b=1,f=true};
	aCrushingCritMatrix["Back, lower"][12] = {dm=3,s=3,mt=1,w=true,ib=true,f=true};
	aCrushingCritMatrix["Back, lower"][13] = {dm=3,s=3,mt=1,b=1,w=true,f=true};
	aCrushingCritMatrix["Back, lower"][14] = {dm=3,s=3,b=1,mt=1,f=true};
	aCrushingCritMatrix["Back, lower"][15] = {dm=3,s=3,b=1,v=1,f=true};
	aCrushingCritMatrix["Back, lower"][16] = {dm=3,a=1,s=3,v=1,f=true};
	aCrushingCritMatrix["Back, lower"][17] = {dm=3,a=2,s=3,v=1,f=true,b=1};
	aCrushingCritMatrix["Back, lower"][18] = {dm=3,a=3,s=3,v=1,b=1,f=true};
	aCrushingCritMatrix["Back, lower"][19] = {dm=3,a=3,s=3,v=2,f=true};
	aCrushingCritMatrix["Back, lower"][20] = {dm=3,a=3,s=3,b=1,v=2,f=true};
	aCrushingCritMatrix["Back, lower"][21] = {dm=3,u=true,b=1,mt=1,v=2};
	aCrushingCritMatrix["Back, lower"][22] = {dm=3,b=1,v=2,u=true};
	aCrushingCritMatrix["Back, lower"][23] = {dm=4,b=1,v=2,mt=1,u=true};
	aCrushingCritMatrix["Back, lower"][24] = {dead="body cavity crushed"};

	aCrushingCritMatrix["Chest"] = {};
	aCrushingCritMatrix["Chest"][1] = {db=3};
	aCrushingCritMatrix["Chest"][2] = {db=4};
	aCrushingCritMatrix["Chest"][3] = {db=6};
	aCrushingCritMatrix["Chest"][4] = {db=8};
	aCrushingCritMatrix["Chest"][5] = {dm=2};
	aCrushingCritMatrix["Chest"][6] = {dm=2,ws=true,s=1};
	aCrushingCritMatrix["Chest"][7] = {dm=2,ws=true,s=2,b=1};
	aCrushingCritMatrix["Chest"][8] = {dm=2,s=2,w=true,b=1};
	aCrushingCritMatrix["Chest"][9] = {dm=2,s=2,w=true,b=1,ib=true};
	aCrushingCritMatrix["Chest"][10] = {dm=3,s=2,w=true,b=1};
	aCrushingCritMatrix["Chest"][11] = {dm=3,s=2,w=true,bm=2};
	aCrushingCritMatrix["Chest"][12] = {dm=3,s=3,bf=2,w=true,ib=true};
	aCrushingCritMatrix["Chest"][13] = {dm=3,s=3,mt=1,b=2,w=true};
	aCrushingCritMatrix["Chest"][14] = {dm=3,s=3,v=1,b=3};
	aCrushingCritMatrix["Chest"][15] = {dm=3,s=3,mt=1,v=1,b=3};
	aCrushingCritMatrix["Chest"][16] = {dm=3,s=4,bf=3,v=2};
	aCrushingCritMatrix["Chest"][17] = {dm=3,s=5,b=4,v=2,f=true,mt=1};
	aCrushingCritMatrix["Chest"][18] = {dm=3,s=6,bf=4,v=2,f=true};
	aCrushingCritMatrix["Chest"][19] = {dm=3,bm=4,v=3,f=true};
	aCrushingCritMatrix["Chest"][20] = {dm=3,bm=4,mt=2,v=3,f=true};
	aCrushingCritMatrix["Chest"][21] = {dm=3,bs=4,u=true,v=3};
	aCrushingCritMatrix["Chest"][22] = {dm=3,bs=4,v=3,u=true};
	aCrushingCritMatrix["Chest"][23] = {dm=4,bs=4,v=3,mt=3,u=true};
	aCrushingCritMatrix["Chest"][24] = {dead="body cavity crushed"};
	
	aCrushingCritMatrix["Side, upper"] = {};
	aCrushingCritMatrix["Side, upper"][1] = {db=3};
	aCrushingCritMatrix["Side, upper"][2] = {db=4};
	aCrushingCritMatrix["Side, upper"][3] = {db=6};
	aCrushingCritMatrix["Side, upper"][4] = {db=8};
	aCrushingCritMatrix["Side, upper"][5] = {dm=2};
	aCrushingCritMatrix["Side, upper"][6] = {dm=2,ws=true,s=1};
	aCrushingCritMatrix["Side, upper"][7] = {dm=2,ws=true,s=2,b=1};
	aCrushingCritMatrix["Side, upper"][8] = {dm=2,s=2,w=true,b=1};
	aCrushingCritMatrix["Side, upper"][9] = {dm=2,s=2,w=true,b=1,ib=true};
	aCrushingCritMatrix["Side, upper"][10] = {dm=3,s=2,w=true,b=1};
	aCrushingCritMatrix["Side, upper"][11] = {dm=3,s=2,w=true,bm=1};
	aCrushingCritMatrix["Side, upper"][12] = {dm=3,s=3,bm=1,w=true,v=1};
	aCrushingCritMatrix["Side, upper"][13] = {dm=3,s=3,b=1,v=1,w=true};
	aCrushingCritMatrix["Side, upper"][14] = {dm=3,s=3,v=1,b=2,w=true};
	aCrushingCritMatrix["Side, upper"][15] = {dm=3,s=3,bm=2,v=1,w=true};
	aCrushingCritMatrix["Side, upper"][16] = {dm=3,s=4,b=2,v=1,w=true};
	aCrushingCritMatrix["Side, upper"][17] = {dm=3,s=5,b=2,v=1,f=true};
	aCrushingCritMatrix["Side, upper"][18] = {dm=3,s=6,b=2,v=1,f=true};
	aCrushingCritMatrix["Side, upper"][19] = {dm=3,bm=2,v=1,f=true};
	aCrushingCritMatrix["Side, upper"][20] = {dm=3,bm=2,v=1,f=true};
	aCrushingCritMatrix["Side, upper"][21] = {dm=3,bs=2,u=true,v=1};
	aCrushingCritMatrix["Side, upper"][22] = {dm=3,bs=2,v=1,u=true};
	aCrushingCritMatrix["Side, upper"][23] = {dm=4,bs=2,v=1,u=true};
	aCrushingCritMatrix["Side, upper"][24] = {dead="body cavity crushed"};
	
	aCrushingCritMatrix["Back, upper"] = {};
	aCrushingCritMatrix["Back, upper"][1] = {db=3};
	aCrushingCritMatrix["Back, upper"][2] = {db=4};
	aCrushingCritMatrix["Back, upper"][3] = {db=6};
	aCrushingCritMatrix["Back, upper"][4] = {db=8};
	aCrushingCritMatrix["Back, upper"][5] = {dm=2};
	aCrushingCritMatrix["Back, upper"][6] = {dm=2,ws=true,s=1};
	aCrushingCritMatrix["Back, upper"][7] = {dm=2,ws=true,s=2};
	aCrushingCritMatrix["Back, upper"][8] = {dm=2,s=2,w=true};
	aCrushingCritMatrix["Back, upper"][9] = {dm=2,s=2,w=true,mt=1};
	aCrushingCritMatrix["Back, upper"][10] = {dm=3,s=2,w=true,mt=1};
	aCrushingCritMatrix["Back, upper"][11] = {dm=3,s=2,w=true,f=true};
	aCrushingCritMatrix["Back, upper"][12] = {dm=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Back, upper"][13] = {dm=3,s=3,mt=1,f=true,w=true};
	aCrushingCritMatrix["Back, upper"][14] = {dm=3,s=3,f=true,b=1};
	aCrushingCritMatrix["Back, upper"][15] = {dm=3,s=3,mt=1,f=true};
	aCrushingCritMatrix["Back, upper"][16] = {dm=3,s=4,v=1};
	aCrushingCritMatrix["Back, upper"][17] = {dm=3,s=5,b=2,f=true};
	aCrushingCritMatrix["Back, upper"][18] = {dm=3,s=6,b=2,v=1};
	aCrushingCritMatrix["Back, upper"][19] = {dm=3,bm=3,mt=2};
	aCrushingCritMatrix["Back, upper"][20] = {dm=3,bm=3,v=1,mt=2};
	aCrushingCritMatrix["Back, upper"][21] = {dm=3,bs=4,u=true,mt=2};
	aCrushingCritMatrix["Back, upper"][22] = {dm=3,bs=4,v=1,mt=2,u=true};
	aCrushingCritMatrix["Back, upper"][23] = {dm=4,bs=4,v=1,mt=2,u=true};
	aCrushingCritMatrix["Back, upper"][24] = {dead="body cavity crushed"};
	
	aCrushingCritMatrix["Back, upper middle"] = {};
	aCrushingCritMatrix["Back, upper middle"][1] = {db=3};
	aCrushingCritMatrix["Back, upper middle"][2] = {db=4};
	aCrushingCritMatrix["Back, upper middle"][3] = {db=6};
	aCrushingCritMatrix["Back, upper middle"][4] = {db=8};
	aCrushingCritMatrix["Back, upper middle"][5] = {dm=2};
	aCrushingCritMatrix["Back, upper middle"][6] = {dm=2,ws=true,s=1};
	aCrushingCritMatrix["Back, upper middle"][7] = {dm=2,ws=true,s=2};
	aCrushingCritMatrix["Back, upper middle"][8] = {dm=2,s=2,w=true};
	aCrushingCritMatrix["Back, upper middle"][9] = {dm=2,s=2,w=true,mt=1};
	aCrushingCritMatrix["Back, upper middle"][10] = {dm=3,s=2,w=true,mt=1};
	aCrushingCritMatrix["Back, upper middle"][11] = {dm=3,s=2,w=true,f=true};
	aCrushingCritMatrix["Back, upper middle"][12] = {dm=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Back, upper middle"][13] = {dm=3,s=3,mt=1,f=true,w=true};
	aCrushingCritMatrix["Back, upper middle"][14] = {dm=3,s=3,f=true,b=1};
	aCrushingCritMatrix["Back, upper middle"][15] = {dm=3,s=3,mt=1,f=true};
	aCrushingCritMatrix["Back, upper middle"][16] = {dm=3,s=4,v=1};
	aCrushingCritMatrix["Back, upper middle"][17] = {dm=3,s=5,b=2,f=true};
	aCrushingCritMatrix["Back, upper middle"][18] = {dm=3,s=6,b=2,v=1};
	aCrushingCritMatrix["Back, upper middle"][19] = {dm=3,bm=2,mt=1};
	aCrushingCritMatrix["Back, upper middle"][20] = {dm=3,bm=3,v=1,mt=1};
	aCrushingCritMatrix["Back, upper middle"][21] = {dm=3,bs=3,u=true,mt=1};
	aCrushingCritMatrix["Back, upper middle"][22] = {dm=4,bs=3,v=1,mt=1,u=true};
	aCrushingCritMatrix["Back, upper middle"][23] = {dead="spine crushed"};
	aCrushingCritMatrix["Back, upper middle"][24] = {dead="body cravity crushed"};
	
	aCrushingCritMatrix["Armpit"] = {};
	aCrushingCritMatrix["Armpit"][1] = {db=1};
	aCrushingCritMatrix["Armpit"][2] = {db=3};
	aCrushingCritMatrix["Armpit"][3] = {db=4};
	aCrushingCritMatrix["Armpit"][4] = {db=6};
	aCrushingCritMatrix["Armpit"][5] = {db=8};
	aCrushingCritMatrix["Armpit"][6] = {dm=2,ws=true};
	aCrushingCritMatrix["Armpit"][7] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Armpit"][8] = {dm=2,a=1,s=1,ws=true};
	aCrushingCritMatrix["Armpit"][9] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Armpit"][10] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Armpit"][11] = {dm=2,a=3,s=2,d=1,ws=true};
	aCrushingCritMatrix["Armpit"][12] = {dm=2,a=3,s=2,d=1,w=true};
	aCrushingCritMatrix["Armpit"][13] = {dm=3,a=3,s=2,d=1,w=true};
	aCrushingCritMatrix["Armpit"][14] = {dm=3,a=3,s=3,d=1,w=true};
	aCrushingCritMatrix["Armpit"][15] = {d=3,a=3,s=3,d=2,w=true};
	aCrushingCritMatrix["Armpit"][16] = {dm=3,a=3,s=3,d=2,met=1,w=true};
	aCrushingCritMatrix["Armpit"][17] = {dm=3,a=3,s=3,d=2,t=1,w=true};
	aCrushingCritMatrix["Armpit"][18] = {dm=3,a=3,s=3,d=2,t=2,mt=1,w=true};
	aCrushingCritMatrix["Armpit"][19] = {dm=3,a=3,s=3,d=2,bf=1,mt=2,w=true};
	aCrushingCritMatrix["Armpit"][20] = {dm=3,a=3,s=3,d=2,bm=2,mt=3,w=true};
	aCrushingCritMatrix["Armpit"][21] = {dm=3,a=3,s=3,d=2,b=2,mt=3,t=3,w=true};
	aCrushingCritMatrix["Armpit"][22] = {dm=3,a=3,s=3,d=2,bf=3,mt=3,t=3,w=true};
	aCrushingCritMatrix["Armpit"][23] = {dm=3,a=3,s=3,d=2,bm=3,mt=3,t=3,w=true};
	aCrushingCritMatrix["Armpit"][24] = {dm=3,a=3,s=3,d=2,bs=3,mt=3,t=3,w=true};
	
	aCrushingCritMatrix["Arm, upper outer"] = {};
	aCrushingCritMatrix["Arm, upper outer"][1] = {db=1};
	aCrushingCritMatrix["Arm, upper outer"][2] = {db=3};
	aCrushingCritMatrix["Arm, upper outer"][3] = {db=4};
	aCrushingCritMatrix["Arm, upper outer"][4] = {db=6};
	aCrushingCritMatrix["Arm, upper outer"][5] = {db=6};
	aCrushingCritMatrix["Arm, upper outer"][6] = {db=8};
	aCrushingCritMatrix["Arm, upper outer"][7] = {dm=2};
	aCrushingCritMatrix["Arm, upper outer"][8] = {dm=2,ws=true};
	aCrushingCritMatrix["Arm, upper outer"][9] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Arm, upper outer"][10] = {dm=2,a=1,s=1,ws=true};
	aCrushingCritMatrix["Arm, upper outer"][11] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Arm, upper outer"][12] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Arm, upper outer"][13] = {dm=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Arm, upper outer"][14] = {dm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Arm, upper outer"][15] = {dm=2,a=3,s=3,w=true};
	aCrushingCritMatrix["Arm, upper outer"][16] = {dm=2,a=3,s=3,mt=1,w=true};
	aCrushingCritMatrix["Arm, upper outer"][17] = {dm=2,a=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Arm, upper outer"][18] = {dm=2,a=3,s=3,mt=1,b=1,w=true};
	aCrushingCritMatrix["Arm, upper outer"][19] = {dm=2,a=3,s=3,bf=1,mt=1,w=true};
	aCrushingCritMatrix["Arm, upper outer"][20] = {dm=2,a=3,s=3,bm=1,mt=2,w=true};
	aCrushingCritMatrix["Arm, upper outer"][21] = {dm=2,a=4,s=3,mt=2,bm=1,w=true};
	aCrushingCritMatrix["Arm, upper outer"][22] = {dm=2,a=3,s=3,bf=1,mt=2,w=true};
	aCrushingCritMatrix["Arm, upper outer"][23] = {dm=2,a=4,s=4,bm=1,mt=2,w=true};
	aCrushingCritMatrix["Arm, upper outer"][24] = {dm=2,a=4,s=4,bs=1,mt=2,w=true};
	
	aCrushingCritMatrix["Arm, upper inner"] = {};
	aCrushingCritMatrix["Arm, upper inner"][1] = {db=1};
	aCrushingCritMatrix["Arm, upper inner"][2] = {db=3};
	aCrushingCritMatrix["Arm, upper inner"][3] = {db=4};
	aCrushingCritMatrix["Arm, upper inner"][4] = {db=6};
	aCrushingCritMatrix["Arm, upper inner"][5] = {db=6};
	aCrushingCritMatrix["Arm, upper inner"][6] = {db=6};
	aCrushingCritMatrix["Arm, upper inner"][7] = {dm=2};
	aCrushingCritMatrix["Arm, upper inner"][8] = {dm=2,ws=true};
	aCrushingCritMatrix["Arm, upper inner"][9] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Arm, upper inner"][10] = {dm=2,a=1,s=1,ws=true};
	aCrushingCritMatrix["Arm, upper inner"][11] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Arm, upper inner"][12] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Arm, upper inner"][13] = {dm=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Arm, upper inner"][14] = {dm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Arm, upper inner"][15] = {dm=2,a=3,s=3,w=true};
	aCrushingCritMatrix["Arm, upper inner"][16] = {dm=2,a=3,s=3,mt=1,w=true};
	aCrushingCritMatrix["Arm, upper inner"][17] = {dm=2,a=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Arm, upper inner"][18] = {dm=2,a=3,s=3,mt=1,b=1,w=true};
	aCrushingCritMatrix["Arm, upper inner"][19] = {dm=2,a=3,s=3,bf=1,mt=1,w=true};
	aCrushingCritMatrix["Arm, upper inner"][20] = {dm=2,a=3,s=3,bm=1,mt=2,w=true};
	aCrushingCritMatrix["Arm, upper inner"][21] = {dm=2,a=4,s=3,mt=2,bm=1,w=true};
	aCrushingCritMatrix["Arm, upper inner"][22] = {dm=2,a=3,s=3,bf=1,mt=2,w=true};
	aCrushingCritMatrix["Arm, upper inner"][23] = {dm=2,a=4,s=4,bm=1,mt=2,w=true};
	aCrushingCritMatrix["Arm, upper inner"][24] = {dm=2,a=4,s=4,bs=1,mt=2,w=true};
	
	aCrushingCritMatrix["Elbow"] = {};
	aCrushingCritMatrix["Elbow"][1] = {db=1};
	aCrushingCritMatrix["Elbow"][2] = {db=1};
	aCrushingCritMatrix["Elbow"][3] = {db=3};
	aCrushingCritMatrix["Elbow"][4] = {db=3};
	aCrushingCritMatrix["Elbow"][5] = {db=4};
	aCrushingCritMatrix["Elbow"][6] = {db=4,a=1,ws=true};
	aCrushingCritMatrix["Elbow"][7] = {db=6,a=1,ws=true};
	aCrushingCritMatrix["Elbow"][8] = {db=6,a=1,ws=true};
	aCrushingCritMatrix["Elbow"][9] = {db=8,a=2,ws=true};
	aCrushingCritMatrix["Elbow"][10] = {db=8,a=2,s=1,w=true,b=1};
	aCrushingCritMatrix["Elbow"][11] = {dm=2,a=2,s=1,w=true,b=1};
	aCrushingCritMatrix["Elbow"][12] = {dm=2,w=true,a=2,s=2,b=1};
	aCrushingCritMatrix["Elbow"][13] = {dm=2,w=true,a=3,s=2,b=1};
	aCrushingCritMatrix["Elbow"][14] = {dm=2,w=true,a=3,s=2,b=1};
	aCrushingCritMatrix["Elbow"][15] = {dm=2,w=true,a=3,s=3,b=1};
	aCrushingCritMatrix["Elbow"][16] = {dm=2,w=true,a=3,s=3,b=1};
	aCrushingCritMatrix["Elbow"][17] = {dm=2,w=true,a=4,s=3,b=1};
	aCrushingCritMatrix["Elbow"][18] = {dm=2,w=true,a=4,s=3,bm=1};
	aCrushingCritMatrix["Elbow"][19] = {dm=2,w=true,a=4,s=4,bm=1};
	aCrushingCritMatrix["Elbow"][20] = {dm=2,w=true,a=4,s=4,bf=1};
	aCrushingCritMatrix["Elbow"][21] = {dm=2,w=true,a=5,s=4,bf=1};
	aCrushingCritMatrix["Elbow"][22] = {dm=2,w=true,a=5,s=4,bs=1};
	aCrushingCritMatrix["Elbow"][23] = {dm=2,w=true,a=5,s=4,bs=1};
	aCrushingCritMatrix["Elbow"][24] = {dm=2,w=true,a=5,s=4,bs=1};
	
	aCrushingCritMatrix["Inner joint"] = {};
	aCrushingCritMatrix["Inner joint"][1] = {db=1};
	aCrushingCritMatrix["Inner joint"][2] = {db=1};
	aCrushingCritMatrix["Inner joint"][3] = {db=3};
	aCrushingCritMatrix["Inner joint"][4] = {db=3};
	aCrushingCritMatrix["Inner joint"][5] = {db=4};
	aCrushingCritMatrix["Inner joint"][6] = {db=4,a=1};
	aCrushingCritMatrix["Inner joint"][7] = {db=6,a=1};
	aCrushingCritMatrix["Inner joint"][8] = {db=6,a=1,ws=true};
	aCrushingCritMatrix["Inner joint"][9] = {db=8,a=2,ws=true};
	aCrushingCritMatrix["Inner joint"][10] = {db=8,a=2,s=1,ws=true};
	aCrushingCritMatrix["Inner joint"][11] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Inner joint"][12] = {dm=2,w=true,a=2,s=2,t=1};
	aCrushingCritMatrix["Inner joint"][13] = {dm=2,w=true,a=3,s=2,t=1};
	aCrushingCritMatrix["Inner joint"][14] = {dm=2,w=true,a=3,s=2,b=1};
	aCrushingCritMatrix["Inner joint"][15] = {dm=2,w=true,a=3,s=3,t=1};
	aCrushingCritMatrix["Inner joint"][16] = {dm=2,w=true,a=3,s=3,b=1,t=1};
	aCrushingCritMatrix["Inner joint"][17] = {dm=2,w=true,a=4,s=3,t=2,b=1};
	aCrushingCritMatrix["Inner joint"][18] = {dm=2,w=true,a=4,s=3,bm=2};
	aCrushingCritMatrix["Inner joint"][19] = {dm=2,w=true,a=4,s=4,t=2,bm=2};
	aCrushingCritMatrix["Inner joint"][20] = {dm=2,w=true,a=4,s=4,bf=2};
	aCrushingCritMatrix["Inner joint"][21] = {dm=2,w=true,a=5,s=4,bf=2,t=2};
	aCrushingCritMatrix["Inner joint"][22] = {dm=2,w=true,a=5,s=4,bs=2};
	aCrushingCritMatrix["Inner joint"][23] = {dm=2,w=true,a=5,s=4,bs=2};
	aCrushingCritMatrix["Inner joint"][24] = {dm=2,w=true,a=5,s=4,bs=2,t=2};
	
	aCrushingCritMatrix["Forearm, back"] = {};
	aCrushingCritMatrix["Forearm, back"][1] = {db=1};
	aCrushingCritMatrix["Forearm, back"][2] = {db=3};
	aCrushingCritMatrix["Forearm, back"][3] = {db=4};
	aCrushingCritMatrix["Forearm, back"][4] = {db=6};
	aCrushingCritMatrix["Forearm, back"][5] = {db=6};
	aCrushingCritMatrix["Forearm, back"][6] = {db=8};
	aCrushingCritMatrix["Forearm, back"][7] = {dm=2};
	aCrushingCritMatrix["Forearm, back"][8] = {dm=2,ws=true};
	aCrushingCritMatrix["Forearm, back"][9] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Forearm, back"][10] = {dm=2,a=1,s=1,ws=true};
	aCrushingCritMatrix["Forearm, back"][11] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Forearm, back"][12] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Forearm, back"][13] = {dm=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Forearm, back"][14] = {dm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Forearm, back"][15] = {dm=2,a=3,s=3,w=true};
	aCrushingCritMatrix["Forearm, back"][16] = {dm=2,a=3,s=3,mt=1,w=true};
	aCrushingCritMatrix["Forearm, back"][17] = {dm=2,a=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Forearm, back"][18] = {dm=2,a=3,s=3,mt=1,b=1,w=true};
	aCrushingCritMatrix["Forearm, back"][19] = {dm=2,a=3,s=3,bf=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, back"][20] = {dm=2,a=3,s=3,bm=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, back"][21] = {dm=2,a=4,s=3,mt=2,bm=2,w=true};
	aCrushingCritMatrix["Forearm, back"][22] = {dm=2,a=3,s=3,bf=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, back"][23] = {dm=2,a=4,s=4,bm=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, back"][24] = {dm=3,a=4,s=4,bs=2,mt=2,w=true};
	
	aCrushingCritMatrix["Forearm, inner"] = {};
	aCrushingCritMatrix["Forearm, inner"][1] = {db=1};
	aCrushingCritMatrix["Forearm, inner"][2] = {db=3};
	aCrushingCritMatrix["Forearm, inner"][3] = {db=4};
	aCrushingCritMatrix["Forearm, inner"][4] = {db=6};
	aCrushingCritMatrix["Forearm, inner"][5] = {db=6,ws=true};
	aCrushingCritMatrix["Forearm, inner"][6] = {db=8,ws=true};
	aCrushingCritMatrix["Forearm, inner"][7] = {dm=2,ws=true};
	aCrushingCritMatrix["Forearm, inner"][8] = {dm=2,ws=true};
	aCrushingCritMatrix["Forearm, inner"][9] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Forearm, inner"][10] = {dm=2,a=1,s=1,w=true};
	aCrushingCritMatrix["Forearm, inner"][11] = {dm=2,a=2,s=1,w=true};
	aCrushingCritMatrix["Forearm, inner"][12] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Forearm, inner"][13] = {dm=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Forearm, inner"][14] = {dm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Forearm, inner"][15] = {dm=2,a=3,s=3,w=true};
	aCrushingCritMatrix["Forearm, inner"][16] = {dm=2,a=3,s=3,mt=1,w=true};
	aCrushingCritMatrix["Forearm, inner"][17] = {dm=2,a=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Forearm, inner"][18] = {dm=2,a=3,s=3,mt=1,b=1,w=true};
	aCrushingCritMatrix["Forearm, inner"][19] = {dm=2,a=3,s=3,bf=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, inner"][20] = {dm=2,a=3,s=3,bm=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, inner"][21] = {dm=2,a=4,s=3,mt=2,bm=2,w=true};
	aCrushingCritMatrix["Forearm, inner"][22] = {dm=2,a=3,s=3,bf=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, inner"][23] = {dm=2,a=4,s=4,bm=2,mt=2,w=true};
	aCrushingCritMatrix["Forearm, inner"][24] = {dm=3,a=4,s=4,bs=2,mt=2,w=true};
	
	aCrushingCritMatrix["Wrist, back"] = {};
	aCrushingCritMatrix["Wrist, back"][1] = {db=1};
	aCrushingCritMatrix["Wrist, back"][2] = {db=3};
	aCrushingCritMatrix["Wrist, back"][3] = {db=3};
	aCrushingCritMatrix["Wrist, back"][4] = {db=4,ws=true};
	aCrushingCritMatrix["Wrist, back"][5] = {db=4,ws=true,a=1};
	aCrushingCritMatrix["Wrist, back"][6] = {db=6,ws=true,a=1,s=1};
	aCrushingCritMatrix["Wrist, back"][7] = {db=8,ws=true,a=1,s=1};
	aCrushingCritMatrix["Wrist, back"][8] = {db=8,ws=true,a=2,s=1};
	aCrushingCritMatrix["Wrist, back"][9] = {db=8,ws=true,a=2,s=1,t=1};
	aCrushingCritMatrix["Wrist, back"][10] = {db=8,w=true,a=2,s=1,t=1};
	aCrushingCritMatrix["Wrist, back"][11] = {db=8,w=true,a=2,s=2,t=1};
	aCrushingCritMatrix["Wrist, back"][12] = {dm=2,w=true,a=2,s=2,t=1};
	aCrushingCritMatrix["Wrist, back"][13] = {dm=2,w=true,a=3,s=2,t=1};
	aCrushingCritMatrix["Wrist, back"][14] = {dm=2,w=true,a=3,s=2,b=1};
	aCrushingCritMatrix["Wrist, back"][15] = {dm=2,w=true,a=3,s=3,t=1};
	aCrushingCritMatrix["Wrist, back"][16] = {dm=2,w=true,a=3,s=3,b=1,t=1};
	aCrushingCritMatrix["Wrist, back"][17] = {dm=2,w=true,a=3,s=3,t=1,b=1};
	aCrushingCritMatrix["Wrist, back"][18] = {dm=2,w=true,a=3,s=3,bm=1};
	aCrushingCritMatrix["Wrist, back"][19] = {dm=2,w=true,a=3,s=3,t=1,bm=1};
	aCrushingCritMatrix["Wrist, back"][20] = {dm=2,w=true,a=3,s=3,bf=1};
	aCrushingCritMatrix["Wrist, back"][21] = {dm=2,w=true,a=3,s=3,bf=1,t=1};
	aCrushingCritMatrix["Wrist, back"][22] = {dm=2,w=true,a=3,s=3,bs=1};
	aCrushingCritMatrix["Wrist, back"][23] = {dm=2,w=true,a=3,s=3,bs=1};
	aCrushingCritMatrix["Wrist, back"][24] = {dm=2,w=true,a=3,s=3,bs=1,t=1};
	
	aCrushingCritMatrix["Wrist, front"] = {};
	aCrushingCritMatrix["Wrist, front"][1] = {db=1};
	aCrushingCritMatrix["Wrist, front"][2] = {db=3};
	aCrushingCritMatrix["Wrist, front"][3] = {db=3};
	aCrushingCritMatrix["Wrist, front"][4] = {db=4,ws=true};
	aCrushingCritMatrix["Wrist, front"][5] = {db=4,ws=true,a=1};
	aCrushingCritMatrix["Wrist, front"][6] = {db=6,ws=true,a=1,s=1};
	aCrushingCritMatrix["Wrist, front"][7] = {db=8,ws=true,a=1,s=1};
	aCrushingCritMatrix["Wrist, front"][8] = {db=8,ws=true,a=2,s=1};
	aCrushingCritMatrix["Wrist, front"][9] = {db=8,ws=true,a=2,s=1,t=1};
	aCrushingCritMatrix["Wrist, front"][10] = {db=8,w=true,a=2,s=1,t=1};
	aCrushingCritMatrix["Wrist, front"][11] = {db=8,w=true,a=2,s=2,t=1};
	aCrushingCritMatrix["Wrist, front"][12] = {dm=2,w=true,a=2,s=2,t=1};
	aCrushingCritMatrix["Wrist, front"][13] = {dm=2,w=true,a=3,s=2,t=1};
	aCrushingCritMatrix["Wrist, front"][14] = {dm=2,w=true,a=3,s=2,b=1};
	aCrushingCritMatrix["Wrist, front"][15] = {dm=2,w=true,a=3,s=3,t=1};
	aCrushingCritMatrix["Wrist, front"][16] = {dm=2,w=true,a=3,s=3,b=1,t=1};
	aCrushingCritMatrix["Wrist, front"][17] = {dm=2,w=true,a=3,s=3,t=1,b=1};
	aCrushingCritMatrix["Wrist, front"][18] = {dm=2,w=true,a=3,s=3,bm=1};
	aCrushingCritMatrix["Wrist, front"][19] = {dm=2,w=true,a=3,s=3,t=1,bm=1};
	aCrushingCritMatrix["Wrist, front"][20] = {dm=2,w=true,a=3,s=3,bf=1};
	aCrushingCritMatrix["Wrist, front"][21] = {dm=2,w=true,a=3,s=3,bf=1,t=1};
	aCrushingCritMatrix["Wrist, front"][22] = {dm=2,w=true,a=3,s=3,bs=1};
	aCrushingCritMatrix["Wrist, front"][23] = {dm=2,w=true,a=3,s=3,bs=1};
	aCrushingCritMatrix["Wrist, front"][24] = {dm=2,w=true,a=3,s=3,bs=1,t=1};

	aCrushingCritMatrix["Hand, back"] = {};
	aCrushingCritMatrix["Hand, back"][1] = {db=1};
	aCrushingCritMatrix["Hand, back"][2] = {db=1};
	aCrushingCritMatrix["Hand, back"][3] = {db=3};
	aCrushingCritMatrix["Hand, back"][4] = {db=3};
	aCrushingCritMatrix["Hand, back"][5] = {db=4};
	aCrushingCritMatrix["Hand, back"][6] = {db=4};
	aCrushingCritMatrix["Hand, back"][7] = {db=6,b=1};
	aCrushingCritMatrix["Hand, back"][8] = {db=6,b=1,a=1};
	aCrushingCritMatrix["Hand, back"][9] = {db=8,b=1,a=1};
	aCrushingCritMatrix["Hand, back"][10] = {db=8,b=1,a=2};
	aCrushingCritMatrix["Hand, back"][11] = {dm=2,b=1,a=2};
	aCrushingCritMatrix["Hand, back"][12] = {dm=2,b=1,a=2,s=1};
	aCrushingCritMatrix["Hand, back"][13] = {dm=2,b=1,a=2,s=2};
	aCrushingCritMatrix["Hand, back"][14] = {dm=2,b=2,a=2,s=2};
	aCrushingCritMatrix["Hand, back"][15] = {dm=2,b=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Hand, back"][16] = {dm=2,b=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Hand, back"][17] = {dm=2,b=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Hand, back"][18] = {dm=2,b=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Hand, back"][19] = {dm=2,bm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Hand, back"][20] = {dm=2,bm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Hand, back"][21] = {dm=2,bf=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Hand, back"][22] = {dm=2,bf=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Hand, back"][23] = {dm=2,bs=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Hand, back"][24] = {dm=2,bs=2,a=3,s=2,w=true};
	
	aCrushingCritMatrix["Palm"] = {};
	aCrushingCritMatrix["Palm"][1] = {db=1};
	aCrushingCritMatrix["Palm"][2] = {db=1};
	aCrushingCritMatrix["Palm"][3] = {db=3};
	aCrushingCritMatrix["Palm"][4] = {db=3};
	aCrushingCritMatrix["Palm"][5] = {db=4};
	aCrushingCritMatrix["Palm"][6] = {db=4};
	aCrushingCritMatrix["Palm"][7] = {db=6};
	aCrushingCritMatrix["Palm"][8] = {db=6};
	aCrushingCritMatrix["Palm"][9] = {db=6,b=1};
	aCrushingCritMatrix["Palm"][10] = {db=6,b=1,a=1};
	aCrushingCritMatrix["Palm"][11] = {db=8,b=1,a=1};
	aCrushingCritMatrix["Palm"][12] = {db=8,b=1,a=2};
	aCrushingCritMatrix["Palm"][13] = {dm=2,b=1,a=2};
	aCrushingCritMatrix["Palm"][14] = {dm=2,b=1,a=2,s=1};
	aCrushingCritMatrix["Palm"][15] = {dm=2,b=1,a=2,s=2};
	aCrushingCritMatrix["Palm"][16] = {dm=2,b=1,a=2,s=2};
	aCrushingCritMatrix["Palm"][17] = {dm=2,b=1,a=2,s=2};
	aCrushingCritMatrix["Palm"][18] = {dm=2,b=1,a=3,s=2,ws=true};
	aCrushingCritMatrix["Palm"][19] = {dm=2,b=1,a=3,s=2,ws=true};
	aCrushingCritMatrix["Palm"][20] = {dm=2,b=1,a=3,s=2,ws=true};
	aCrushingCritMatrix["Palm"][21] = {dm=2,bm=1,a=3,s=2,w=true};
	aCrushingCritMatrix["Palm"][22] = {dm=2,bm=1,a=3,s=2,w=true};
	aCrushingCritMatrix["Palm"][23] = {dm=2,bf=1,a=3,s=2,w=true};
	aCrushingCritMatrix["Palm"][24] = {dm=2,bs=1,a=3,s=2,w=true};
	
	aCrushingCritMatrix["Finger(s)"] = {};
	aCrushingCritMatrix["Finger(s)"][1] = {db=1};
	aCrushingCritMatrix["Finger(s)"][2] = {db=1};
	aCrushingCritMatrix["Finger(s)"][3] = {db=3};
	aCrushingCritMatrix["Finger(s)"][4] = {db=3};
	aCrushingCritMatrix["Finger(s)"][5] = {db=4};
	aCrushingCritMatrix["Finger(s)"][6] = {db=4};
	aCrushingCritMatrix["Finger(s)"][7] = {db=6,b=1};
	aCrushingCritMatrix["Finger(s)"][8] = {db=6,b=1};
	aCrushingCritMatrix["Finger(s)"][9] = {db=8,b=1};
	aCrushingCritMatrix["Finger(s)"][10] = {db=8,b=1};
	aCrushingCritMatrix["Finger(s)"][11] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][12] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][13] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][14] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][15] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][16] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][17] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][18] = {dm=2,b=1};
	aCrushingCritMatrix["Finger(s)"][19] = {dm=2,bm=1};
	aCrushingCritMatrix["Finger(s)"][20] = {dm=2,bm=1};
	aCrushingCritMatrix["Finger(s)"][21] = {dm=2,bf=1};
	aCrushingCritMatrix["Finger(s)"][22] = {dm=2,bf=1};
	aCrushingCritMatrix["Finger(s)"][23] = {dm=2,bs=1};
	aCrushingCritMatrix["Finger(s)"][24] = {dm=2,bs=1};

	aCrushingCritMatrix["Shoulder, side"] = {};
	aCrushingCritMatrix["Shoulder, side"][1] = {db=1};
	aCrushingCritMatrix["Shoulder, side"][2] = {db=3};
	aCrushingCritMatrix["Shoulder, side"][3] = {db=4};
	aCrushingCritMatrix["Shoulder, side"][4] = {db=6};
	aCrushingCritMatrix["Shoulder, side"][5] = {db=6};
	aCrushingCritMatrix["Shoulder, side"][6] = {db=8};
	aCrushingCritMatrix["Shoulder, side"][7] = {dm=2};
	aCrushingCritMatrix["Shoulder, side"][8] = {dm=2,ws=true};
	aCrushingCritMatrix["Shoulder, side"][9] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Shoulder, side"][10] = {dm=2,a=1,s=1,ws=true};
	aCrushingCritMatrix["Shoulder, side"][11] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Shoulder, side"][12] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Shoulder, side"][13] = {dm=2,a=3,s=2,ws=true};
	aCrushingCritMatrix["Shoulder, side"][14] = {dm=2,a=3,s=2,w=true};
	aCrushingCritMatrix["Shoulder, side"][15] = {dm=2,a=3,s=3,w=true};
	aCrushingCritMatrix["Shoulder, side"][16] = {dm=2,a=3,s=3,mt=1,w=true};
	aCrushingCritMatrix["Shoulder, side"][17] = {dm=2,a=3,s=3,b=1,w=true};
	aCrushingCritMatrix["Shoulder, side"][18] = {dm=3,a=3,s=3,mt=1,b=1,w=true};
	aCrushingCritMatrix["Shoulder, side"][19] = {dm=3,a=3,s=3,bf=1,mt=2,w=true};
	aCrushingCritMatrix["Shoulder, side"][20] = {dm=3,a=3,s=3,bm=1,mt=2,w=true};
	aCrushingCritMatrix["Shoulder, side"][21] = {dm=3,a=4,s=3,mt=3,bm=1,w=true};
	aCrushingCritMatrix["Shoulder, side"][22] = {dm=4,a=3,s=3,bf=1,mt=3,w=true};
	aCrushingCritMatrix["Shoulder, side"][23] = {dm=3,a=4,s=4,bm=1,mt=4,w=true};
	aCrushingCritMatrix["Shoulder, side"][24] = {dm=3,a=4,s=4,bs=1,mt=4,w=true};
	
	aCrushingCritMatrix["Shoulder, top"] = {};
	aCrushingCritMatrix["Shoulder, top"][1] = {db=1};
	aCrushingCritMatrix["Shoulder, top"][2] = {db=3};
	aCrushingCritMatrix["Shoulder, top"][3] = {db=4};
	aCrushingCritMatrix["Shoulder, top"][4] = {db=6};
	aCrushingCritMatrix["Shoulder, top"][5] = {db=8};
	aCrushingCritMatrix["Shoulder, top"][6] = {dm=2};
	aCrushingCritMatrix["Shoulder, top"][7] = {dm=2,a=1,ws=true};
	aCrushingCritMatrix["Shoulder, top"][8] = {dm=2,a=1,s=1,ws=true};
	aCrushingCritMatrix["Shoulder, top"][9] = {dm=2,a=2,s=1,ws=true};
	aCrushingCritMatrix["Shoulder, top"][10] = {dm=2,a=2,s=2,ws=true};
	aCrushingCritMatrix["Shoulder, top"][11] = {dm=2,a=3,s=2,d=1,ws=true};
	aCrushingCritMatrix["Shoulder, top"][12] = {dm=2,a=3,s=2,d=1,w=true};
	aCrushingCritMatrix["Shoulder, top"][13] = {dm=3,a=3,s=2,d=1,w=true};
	aCrushingCritMatrix["Shoulder, top"][14] = {dm=3,a=3,s=3,d=1,w=true};
	aCrushingCritMatrix["Shoulder, top"][15] = {dm=3,a=3,s=3,d=2,w=true};
	aCrushingCritMatrix["Shoulder, top"][16] = {dm=3,a=3,s=3,d=2,mt=1,w=true};
	aCrushingCritMatrix["Shoulder, top"][17] = {dm=3,a=3,s=3,d=2,t=1,w=true};
	aCrushingCritMatrix["Shoulder, top"][18] = {dm=3,a=3,s=3,d=2,t=2,mt=1,w=true};
	aCrushingCritMatrix["Shoulder, top"][19] = {dm=3,a=3,s=3,d=2,bf=1,mt=2,w=true};
	aCrushingCritMatrix["Shoulder, top"][20] = {dm=3,a=3,s=3,d=2,bm=2,mt=2,w=true};
	aCrushingCritMatrix["Shoulder, top"][21] = {dm=3,a=3,s=3,d=2,b=3,mt=3,t=2,w=true};
	aCrushingCritMatrix["Shoulder, top"][22] = {dm=3,a=3,s=3,d=2,bf=3,mt=3,t=2,w=true};
	aCrushingCritMatrix["Shoulder, top"][23] = {dm=3,a=3,s=3,d=2,bm=3,mt=3,t=2,w=true};
	aCrushingCritMatrix["Shoulder, top"][24] = {dm=3,a=3,s=3,d=2,bs=3,mt=3,t=2,w=true};
	
	aCrushingCritMatrix["Neck, front"] = {};
	aCrushingCritMatrix["Neck, front"][1] = {db=3};
	aCrushingCritMatrix["Neck, front"][2] = {db=4};
	aCrushingCritMatrix["Neck, front"][3] = {db=6};
	aCrushingCritMatrix["Neck, front"][4] = {db=8};
	aCrushingCritMatrix["Neck, front"][5] = {dm=2};
	aCrushingCritMatrix["Neck, front"][6] = {dm=2,ws=true,a=1,d=1};
	aCrushingCritMatrix["Neck, front"][7] = {dm=2,w=true,a=1,d=1};
	aCrushingCritMatrix["Neck, front"][8] = {dm=2,f=true,a=1,d=1};
	aCrushingCritMatrix["Neck, front"][9] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Neck, front"][10] = {dm=2,a=2,d=2,f=true,mc=true};
	aCrushingCritMatrix["Neck, front"][11] = {dm=2,a=2,d=2,f=true,mc=true};
	aCrushingCritMatrix["Neck, front"][12] = {dm=3,a=3,d=3,u=true};
	aCrushingCritMatrix["Neck, front"][13] = {dm=3,a=3,d=3,u=true};
	aCrushingCritMatrix["Neck, front"][14] = {dm=3,a=3,d=3,u=true,mc=true};
	aCrushingCritMatrix["Neck, front"][15] = {dm=3,a=3,d=3,u=true,p=true,mc=true};
	aCrushingCritMatrix["Neck, front"][16] = {dm=3,a=3,d=4,u=true,mc=true};
	aCrushingCritMatrix["Neck, front"][17] = {dm=4,a=4,d=5,b=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, front"][18] = {dm=4,a=5,d=6,b=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, front"][19] = {dm=4,a=5,d=6,b=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, front"][20] = {cm=4,a=5,d=6,b=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, front"][21] = {dm=4,p=true,u=true,sc=true};
	aCrushingCritMatrix["Neck, front"][22] = {dead="windpipe crushed"};
	aCrushingCritMatrix["Neck, front"][23] = {dead="neck snapped"};
	aCrushingCritMatrix["Neck, front"][24] = {dead="neck snapped"};

	aCrushingCritMatrix["Neck, back"] = {};
	aCrushingCritMatrix["Neck, back"][1] = {db=3};
	aCrushingCritMatrix["Neck, back"][2] = {db=4};
	aCrushingCritMatrix["Neck, back"][3] = {db=6};
	aCrushingCritMatrix["Neck, back"][4] = {db=8};
	aCrushingCritMatrix["Neck, back"][5] = {dm=2};
	aCrushingCritMatrix["Neck, back"][6] = {dm=2,ws=true,a=1,d=1};
	aCrushingCritMatrix["Neck, back"][7] = {dm=2,w=true,a=1,d=1};
	aCrushingCritMatrix["Neck, back"][8] = {dm=2,f=true,a=1,d=1,p=true};
	aCrushingCritMatrix["Neck, back"][9] = {dm=2,a=2,d=2,f=true,p=true};
	aCrushingCritMatrix["Neck, back"][10] = {dm=2,a=2,d=2,f=true,p=true}; 
	aCrushingCritMatrix["Neck, back"][11] = {dm=2,a=2,d=2,f=true,p=true}; 
	aCrushingCritMatrix["Neck, back"][12] = {dm=3,a=2,d=3,u=true};
	aCrushingCritMatrix["Neck, back"][13] = {dm=3,a=2,d=3,u=true};
	aCrushingCritMatrix["Neck, back"][14] = {dm=3,a=2,d=3,u=true,mc=true};
	aCrushingCritMatrix["Neck, back"][15] = {dm=3,a=2,d=3,u=true,p=true,mc=true};
	aCrushingCritMatrix["Neck, back"][16] = {dm=3,a=3,d=4,u=true,mc=true};
	aCrushingCritMatrix["Neck, back"][17] = {dm=4,a=4,d=5,b=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, back"][18] = {dm=4,a=5,d=6,b=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, back"][19] = {dm=4,p=true,bm=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, back"][20] = {dm=4,p=true,bm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, back"][21] = {dm=4,p=true,bs=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, back"][22] = {dm=4,p=true,bs=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, back"][23] = {dead="neck snapped"};
	aCrushingCritMatrix["Neck, back"][24] = {dead="neck snapped"};
	
	aCrushingCritMatrix["Neck, side"] = {};	
	aCrushingCritMatrix["Neck, side"][1] = {db=3};
	aCrushingCritMatrix["Neck, side"][2] = {db=4};
	aCrushingCritMatrix["Neck, side"][3] = {db=6};
	aCrushingCritMatrix["Neck, side"][4] = {db=8};
	aCrushingCritMatrix["Neck, side"][5] = {dm=2};
	aCrushingCritMatrix["Neck, side"][6] = {dm=2,ws=true,a=1,d=1};
	aCrushingCritMatrix["Neck, side"][7] = {dm=2,w=true,a=1,d=1};
	aCrushingCritMatrix["Neck, side"][8] = {dm=2,f=true,a=1,d=1};
	aCrushingCritMatrix["Neck, side"][9] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Neck, side"][10] = {dm=2,a=2,d=2,f=true,mc=true};
	aCrushingCritMatrix["Neck, side"][11] = {dm=2,a=2,d=2,f=true,p=true};
	aCrushingCritMatrix["Neck, side"][12] = {dm=3,a=2,d=3,f=true,mt=1};
	aCrushingCritMatrix["Neck, side"][13] = {dm=3,a=2,d=3,f=true,mt=1};
	aCrushingCritMatrix["Neck, side"][14] = {dm=3,a=2,d=3, u=true,mt=1};
	aCrushingCritMatrix["Neck, side"][15] = {dm=3,a=3,d=3,u=true,mt=1};
	aCrushingCritMatrix["Neck, side"][16] = {dm=3,a=3,d=4,u=true,mt=2};
	aCrushingCritMatrix["Neck, side"][17] = {dm=4,a=4,d=5,u=true,mt=2,mc=true};
	aCrushingCritMatrix["Neck, side"][18] = {dm=4,a=5,d=6,mt=2,u=true,sc=true};
	aCrushingCritMatrix["Neck, side"][19] = {dm=4,p=true,bm=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, side"][20] = {dm=4,p=true,bm=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Neck, side"][21] = {dm=4,p=true,bs=2,u=true,sc=true};
	aCrushingCritMatrix["Neck, side"][22] = {dm=4,p=true,bs=2,v=2,u=true,sc=true};
	aCrushingCritMatrix["Neck, side"][23] = {dead="neck snapped"};
	aCrushingCritMatrix["Neck, side"][24] = {dead="neck snapped"};

	aCrushingCritMatrix["Head, side"] = {};
	aCrushingCritMatrix["Head, side"][1] = {db=6};
	aCrushingCritMatrix["Head, side"][2] = {db=8};
	aCrushingCritMatrix["Head, side"][3] = {dm=2};
	aCrushingCritMatrix["Head, side"][4] = {dm=2,f=true};
	aCrushingCritMatrix["Head, side"][5] = {dm=2,a=1,d=1,f=true};
	aCrushingCritMatrix["Head, side"][6] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Head, side"][7] = {dm=3,a=2,d=2,f=true};
	aCrushingCritMatrix["Head, side"][8] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Head, side"][9] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Head, side"][10] = {dm=3,a=4,d=4,f=true};
	aCrushingCritMatrix["Head, side"][11] = {dm=3,a=4,f=4,f=true,mc=true};
	aCrushingCritMatrix["Head, side"][12] = {dm=4,a=4,d=4,f=true,sc=true};
	aCrushingCritMatrix["Head, side"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][19] = {dm=4,a=8,d=8,b=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][20] = {dm=4,a=8,d=8,bm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][21] = {dm=4,a=9,d=9,bm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][22] = {dm=4,a=9,d=9,bs=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, side"][23] = {dead="skull caved-in"};
	aCrushingCritMatrix["Head, side"][24] = {dead="skull caved-in"};
	
	aCrushingCritMatrix["Head, back lower"] = {};
	aCrushingCritMatrix["Head, back lower"][1] = {db=6};
	aCrushingCritMatrix["Head, back lower"][2] = {db=8};
	aCrushingCritMatrix["Head, back lower"][3] = {dm=2};
	aCrushingCritMatrix["Head, back lower"][4] = {dm=2,f=true};
	aCrushingCritMatrix["Head, back lower"][5] = {dm=2,d=1,f=true};
	aCrushingCritMatrix["Head, back lower"][6] = {dm=2,a=1,d=2,f=true};
	aCrushingCritMatrix["Head, back lower"][7] = {dm=3,a=3,d=2,f=true};
	aCrushingCritMatrix["Head, back lower"][8] = {dm=3,a=2,d=3,f=true};
	aCrushingCritMatrix["Head, back lower"][9] = {dm=3,a=2,d=3,f=true,p=true};
	aCrushingCritMatrix["Head, back lower"][10] = {dm=3,a=3,d=4,f=true};
	aCrushingCritMatrix["Head, back lower"][11] = {dm=3,a=3,d=4,f=true,mc=true};
	aCrushingCritMatrix["Head, back lower"][12] = {dm=4,a=3,d=4,f=true,sc=true,p=true};
	aCrushingCritMatrix["Head, back lower"][13] = {dm=4,a=4,d=5,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][14] = {dm=4,a=5,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][15] = {dm=4,a=5,d=6,u=true,sc=true,p=true};
	aCrushingCritMatrix["Head, back lower"][16] = {dm=4,a=6,d=7,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][17] = {dm=4,a=6,d=7,b=1,u=true,sc=true,p=true};
	aCrushingCritMatrix["Head, back lower"][18] = {dm=4,a=6,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][19] = {dm=4,a=7,d=8,b=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][20] = {dm=4,a=7,d=8,bm=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][21] = {dm=4,p=true,bm=3,v=2,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][22] = {dm=4,p=true,bs=3,v=2,u=true,sc=true};
	aCrushingCritMatrix["Head, back lower"][23] = {dead="skull caved-in"};
	aCrushingCritMatrix["Head, back lower"][24] = {dead="brain goo"};
	
	aCrushingCritMatrix["Face, lower side"] = {};
	aCrushingCritMatrix["Face, lower side"][1] = {db=4};
	aCrushingCritMatrix["Face, lower side"][2] = {db=6};
	aCrushingCritMatrix["Face, lower side"][3] = {db=8};
	aCrushingCritMatrix["Face, lower side"][4] = {dm=2};
	aCrushingCritMatrix["Face, lower side"][5] = {dm=2,f=true};
	aCrushingCritMatrix["Face, lower side"][6] = {dm=2,a=1,f=true};
	aCrushingCritMatrix["Face, lower side"][7] = {dm=2,a=2,u=true};
	aCrushingCritMatrix["Face, lower side"][8] = {dm=3,b=1,a=3,d=1,f=true};
	aCrushingCritMatrix["Face, lower side"][9] = {dm=3,b=1,a=3,d=1,u=true};
	aCrushingCritMatrix["Face, lower side"][10] = {dm=3,b=1,a=4,d=2,f=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][11] = {dm=3,b=1,a=4,d=2,u=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][12] = {dm=4,b=1,a=4,d=2,u=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][13] = {dm=4,b=2,a=3,d=1,f=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][14] = {dm=4,bf=2,a=3,d=1,u=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][15] = {dm=4,bm=2,a=4,d=2,f=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][16] = {dm=4,bf=2,a=5,d=3,f=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][17] = {dm=4,bm=2,a=5,d=3,f=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][18] = {dm=4,bf=3,a=5,d=3,f=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][19] = {dm=4,bm=3,a=5,d=3,f=true,sc=true};
	aCrushingCritMatrix["Face, lower side"][20] = {dm=4,bm=3,a=6,d=4,u=true,mc=true};
	aCrushingCritMatrix["Face, lower side"][21] = {dm=4,bf=3,a=6,d=4,u=true,sc=true};
	aCrushingCritMatrix["Face, lower side"][22] = {dm=4,bm=3,a=6,d=4,u=true,sc=true};
	aCrushingCritMatrix["Face, lower side"][23] = {dm=4,bs=3,a=7,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, lower side"][24] = {dead="skull caved-in"};

	aCrushingCritMatrix["Face, lower center"] = {};
	aCrushingCritMatrix["Face, lower center"][1] = {db=4};
	aCrushingCritMatrix["Face, lower center"][2] = {db=6};
	aCrushingCritMatrix["Face, lower center"][3] = {db=8};
	aCrushingCritMatrix["Face, lower center"][4] = {dm=2};
	aCrushingCritMatrix["Face, lower center"][5] = {dm=2,f=true};
	aCrushingCritMatrix["Face, lower center"][6] = {dm=2,a=1,d=1,f=true};
	aCrushingCritMatrix["Face, lower center"][7] = {dm=2,a=2,d=2,u=true};
	aCrushingCritMatrix["Face, lower center"][8] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Face, lower center"][9] = {dm=3,a=3,d=3,u=true};
	aCrushingCritMatrix["Face, lower center"][10] = {dm=3,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][11] = {dm=3,a=4,d=4,u=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][12] = {dm=4,a=4,d=4,u=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][13] = {dm=4,b=1,a=3,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][14] = {dm=4,b=1,a=3,d=3,u=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][15] = {dm=4,b=1,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][16] = {dm=4,b=2,a=5,d=5,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][17] = {dm=4,b=2,a=5,d=5,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][18] = {dm=4,bm=2,a=5,d=5,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][19] = {dm=4,bm=2,a=5,d=5,f=true,mc=true};
	aCrushingCritMatrix["Face, lower center"][20] = {dm=4,bm=3,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, lower center"][21] = {dm=4,bm=3,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, lower center"][22] = {dm=4,bs=3,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, lower center"][23] = {dm=4,bs=3,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, lower center"][24] = {dead="skull caved-in"};
	
	aCrushingCritMatrix["Head, back upper"] = {};
	aCrushingCritMatrix["Head, back upper"][1] = {db=6};
	aCrushingCritMatrix["Head, back upper"][2] = {db=8};
	aCrushingCritMatrix["Head, back upper"][3] = {dm=2};
	aCrushingCritMatrix["Head, back upper"][4] = {dm=2,f=true};
	aCrushingCritMatrix["Head, back upper"][5] = {dm=2,a=1,d=1,f=true};
	aCrushingCritMatrix["Head, back upper"][6] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Head, back upper"][7] = {dm=3,a=2,d=2,f=true};
	aCrushingCritMatrix["Head, back upper"][8] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Head, back upper"][9] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Head, back upper"][10] = {dm=3,a=4,d=4,f=true};
	aCrushingCritMatrix["Head, back upper"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Head, back upper"][12] = {dm=4,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Head, back upper"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][19] = {dm=4,a=8,d=8,b=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][20] = {dm=4,a=8,d=8,bm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][21] = {dm=4,a=9,d=9,bm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][22] = {dm=4,a=9,d=9,bs=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, back upper"][23] = {dead="skull caved-in"};
	aCrushingCritMatrix["Head, back upper"][24] = {dead="brain goo"};
	
	aCrushingCritMatrix["Face, upper side"] = {};
	aCrushingCritMatrix["Face, upper side"][1] = {db=6};
	aCrushingCritMatrix["Face, upper side"][2] = {db=8};
	aCrushingCritMatrix["Face, upper side"][3] = {dm=2};
	aCrushingCritMatrix["Face, upper side"][4] = {dm=2,f=true};
	aCrushingCritMatrix["Face, upper side"][5] = {dm=2,a=1,d=1,f=true};
	aCrushingCritMatrix["Face, upper side"][6] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Face, upper side"][7] = {dm=3,a=2,d=2,f=true};
	aCrushingCritMatrix["Face, upper side"][8] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Face, upper side"][9] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Face, upper side"][10] = {dm=3,a=4,d=4,f=true};
	aCrushingCritMatrix["Face, upper side"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, upper side"][12] = {dm=4,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, upper side"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][19] = {dm=4,a=7,d=7,b=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][20] = {dm=4,a=8,d=8,bm=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][21] = {dm=4,a=8,d=8,bm=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][22] = {dm=4,a=9,d=9,bs=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper side"][23] = {dead="skull caved-in"};
	aCrushingCritMatrix["Face, upper side"][24] = {dead="brain goo"};
	
	aCrushingCritMatrix["Face, upper center"] = {};
	aCrushingCritMatrix["Face, upper center"][1] = {db=6};
	aCrushingCritMatrix["Face, upper center"][2] = {db=8};
	aCrushingCritMatrix["Face, upper center"][3] = {dm=2};
	aCrushingCritMatrix["Face, upper center"][4] = {dm=2,f=true};
	aCrushingCritMatrix["Face, upper center"][5] = {dm=2,a=1,d=1,f=true};
	aCrushingCritMatrix["Face, upper center"][6] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Face, upper center"][7] = {dm=3,a=2,d=2,f=true};
	aCrushingCritMatrix["Face, upper center"][8] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Face, upper center"][9] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Face, upper center"][10] = {dm=3,a=4,d=4,f=true};
	aCrushingCritMatrix["Face, upper center"][11] = {dm=3,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, upper center"][12] = {dm=4,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Face, upper center"][13] = {dm=4,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][15] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][16] = {dm=4,a=7,d=7,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][18] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][19] = {dm=4,a=8,d=8,b=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][20] = {dm=4,a=8,d=8,bm=2,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][21] = {dm=4,a=9,d=9,bm=3,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][22] = {dm=4,a=9,d=9,bs=3,v=1,u=true,sc=true};
	aCrushingCritMatrix["Face, upper center"][23] = {dead="skull caved-in"};
	aCrushingCritMatrix["Face, upper center"][24] = {dead="brain goo"};
	
	aCrushingCritMatrix["Head, top"] = {};
	aCrushingCritMatrix["Head, top"][1] = {db=8};
	aCrushingCritMatrix["Head, top"][2] = {dm=2};
	aCrushingCritMatrix["Head, top"][3] = {dm=2,f=true};
	aCrushingCritMatrix["Head, top"][4] = {dm=2,a=1,d=1,f=true};
	aCrushingCritMatrix["Head, top"][5] = {dm=2,a=2,d=2,f=true};
	aCrushingCritMatrix["Head, top"][6] = {dm=3,a=2,d=2,f=true};
	aCrushingCritMatrix["Head, top"][7] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Head, top"][8] = {dm=3,a=3,d=3,f=true};
	aCrushingCritMatrix["Head, top"][9] = {dm=3,a=4,d=4,f=true};
	aCrushingCritMatrix["Head, top"][10] = {dm=3,a=4,d=4,f=true,mc=true};
	aCrushingCritMatrix["Head, top"][11] = {dm=4,a=4,d=4,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][12] = {dm=4,a=5,d=5,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][13] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][14] = {dm=4,a=6,d=6,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][15] = {dm=4,a=7,d=7,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][16] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][17] = {dm=4,a=7,d=7,b=1,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][18] = {dm=4,a=8,d=8,b=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][19] = {dm=4,a=8,d=8,bm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][20] = {dm=4,a=9,d=9,gbm=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][21] = {dm=4,a=9,d=9,bs=1,v=1,u=true,sc=true};
	aCrushingCritMatrix["Head, top"][22] = {dead="skull caved-in"};
	aCrushingCritMatrix["Head, top"][23] = {dead="brain goo"};
	aCrushingCritMatrix["Head, top"][24] = {dead="brain goo"};
	
end

function buildCritLocationInfo()
	aCritLocations["Foot, top"] 			    = { dam=0.1, isLeg=true, skeletal={"Tarsus"}, muscular={"1d5 Extensor Tendons of the Toes"}};
	aCritLocations["Heel"] 						= { dam=0.1, isLeg=true, skeletal={"Os Calcis"}, muscular={"Achilles Tendon"}};
	aCritLocations["Toe(s)"] 					= { dam=0.01, isLeg=true, isDigit=true, skeletal={"1d10 Metatarsus and Phalanges Bones"}, muscular={"1d5 Extensor Tendons of the Toes"}};
	aCritLocations["Foot, arch"] 				= { dam=0.1, isLeg=true, skeletal={"Tarsus"}, muscular={"Extensor Brevis Hallucis"}};
	aCritLocations["Ankle, inner"] 				= { dam=0.15, isLeg=true, skeletal={"Internal Malleolus"}, muscular={"Soleus"}};
	aCritLocations["Ankle, outer"] 				= { dam=0.15, isLeg=true, skeletal={"External Malleolus"}, muscular={"Extensor Longus Digitorum", "Peroneous Longus et Brevis"}};
	aCritLocations["Ankle, upper/Achilles"] 	= { dam=0.15, isLeg=true, skeletal={"Internal Malleolus", "External Malleolus"}, muscular={"Tibialis Anticus", "Extensor Longus Hallucis"}};
	aCritLocations["Shin"] 				 		= { dam=0.25, isLeg=true, skeletal={"Fibula", "Tibia"}, muscular={"Tibialis Anticus", "Soleus"}};
	aCritLocations["Calf"] 				 		= { dam=0.25, isLeg=true, skeletal={"Fibula", "Tibia"}, muscular={"Soleus", "Gastrocnemius"}};
	aCritLocations["Knee"] 				 		= { dam=0.25, isLeg=true, skeletal={"Outer Tuberosity of the Femur", "Patella", "Inner Tuberosity of the Femur"}, muscular={"Patella Tendon"}};
	aCritLocations["Knee, back"] 		 		= { dam=0.25, isLeg=true, skeletal={"Condyle of Femur"}, muscular={"Gastrocnemius"}};
	aCritLocations["Hamstring"] 		 		= { dam=1.0, isLeg=true, skeletal={"Femur"}, muscular={"Biceps Femoris"}};
	aCritLocations["Thigh"] 			 		= { dam=1.0, isLeg=true, skeletal={"Femur"}, muscular={"Tendon of the Extensors of the Leg", "Vastus Internus", "Vastus Externus", "Adductor Magnus", "Rectus Femoris"}};
	aCritLocations["Hip"] 				 		= { dam=1.0, isLeg=true, skeletal={"Trochanter", "Neck of the Femur", "Head of the Femur", "Illium"}, muscular={"Gluteus Medius", "Tensor Vaginae Femoris"}, vital={"Large Intestine", "Small Intestine"}};
	aCritLocations["Groin"] 			 		= { dam=0.2, isLeg=true, skeletal={"Os Pubis"}, muscular={"Adductor Magnus", "Extensor Longus Digitorum", "Pectineus", "Adductor Longus"}, vital={"Bladder", "Small Intestine"}};
	aCritLocations["Buttock"] 			 		= { dam=1.0, isLeg=true, skeletal={"Ilium", "Sacrum", "Coccyx"}, muscular={"Gluteus Maximus"}, vital={} };
	aCritLocations["Abdomen, Lower"] 	 		= { dam=1.0, isTorso=true, skeletal={"Ilium", "Os Pubis", "Sacrum"}, muscular={"Aponeurosis of Obliquus Externus Abdominis", "Rectus Abdominis"}, vital={"Pancreas", "Duodenum", "Kidney", "Small Intestine"} };
	aCritLocations["Side, lower"] 	 	 		= { dam=0.8, isTorso=true, skeletal={"Crest of the Ilium", "1d2 Lumbar Vertebrae: 2nd to 3rd"}, muscular={"Crest of the Ilium", "Obliquus Internus Abdominis"}, vital={"Spleen or Liver", "Lung"} };
	aCritLocations["Abdomen, upper"] 	 		= { dam=1.0, isTorso=true, skeletal={"1d2 Lumbar Vertebrae: 2nd to 3rd"}, muscular={"Aponeurosis of Obliquus Externus Abdominis", "Rectus Abdominis"}, vital={"Spleen", "Stomach", "Liver"} };
	aCritLocations["Back, small of"] 	 		= { dam=1.0, isTorso=true, isSpine=true, skeletal={"1d3 Lumbar Vertebrae: 1st to 3rd"}, muscular={"External Oblique", "Erector Spinae"}, vital={"Kidney", "Spinal Cord"} };
	aCritLocations["Back, lower"] 		 		= { dam=1.0, isTorso=true, isSpine=true, skeletal={"1d3 Lumbar Vertebrae: 1st to 3rd"}, muscular={"Latissimus Dorsi"}, vital={"1d2 Kidneys", "Spinal Cord"} };
	aCritLocations["Chest"] 			 		= { dam=1.0, isTorso=true, isSpine=true, skeletal={"1d6 Lower Ribs", "1d6 Upper Ribs", "Sternum: Manubrium", "Sternum: Gladiolus"}, muscular={"Aponeurosis of Obliquus Externus Abdominis", "Obliquus Externus Abdominis", "Rectus Abdominis"}, vital={"Lung", "Heart", "Spinal Cord"} };
	aCritLocations["Side, upper"] 		 		= { dam=0.8, isTorso=true, skeletal={"1d6 Lower Ribs", "1d6 Upper Ribs"}, muscular={"Serratus Magnus", "Obliquus Externus Abdominis"}, vital={"Lung"} };
	aCritLocations["Back, upper"] 		 		= { dam=1.0, isTorso=true, isSpine=true, skeletal={"Scapula", "1d4 Upper Ribs", "1d4 Middle Ribs", "1d4 Lower Ribs"}, muscular={"Deltoid", "Teres Major"}, vital={"Spinal Cord"} };
	aCritLocations["Back, upper middle"] 	    = { dam=1.0, isTorso=true, isSpine=true, skeletal={"1d4 Lower Dorsal Vertebrae: 9th to 12th", "1d4 Middle Dorsal Vertebrae: 5th to 8th", "1d4 Upper Dorsal Vertebrae: 1st to 4th"}, muscular={"Trapezius"}, vital={"Spinal Cord"} };
	aCritLocations["Armpit"] 			 	    = { dam=0.3, isArm=true, skeletal={"Head of the Humerus", "Scapula", "1d3 Ribs"}, muscular={"Pectoralis Major", "Coraco-brachialis", "Deltoid"}, vital={} };
	aCritLocations["Arm, upper outer"]   	    = { dam=0.3, isArm=true, skeletal={"Humerus"}, muscular={"Triceps Extensor Cubiti", "Biceps Flexor Cubiti"}, vital={} };
	aCritLocations["Arm, upper inner"]   	    = { dam=0.3, isArm=true, skeletal={"Humerus"}, muscular={"Trcipes Extensor Cubiti", "Biceps Flexor Cubiti"}, vital={} };
	aCritLocations["Elbow"] 		     	    = { dam=0.25, isArm=true, skeletal={"Olecranon Process of the Ulna"}, muscular={"Flexor Longus Pollicis"}, vital={} };
	aCritLocations["Inner joint"] 	     	    = { dam=0.25, isArm=true, skeletal={"Trochlea", "Radial Head of the Humerus"}, muscular={"Pronator Radii Teres", "Supinator Longus"}, vital={} };
	aCritLocations["Forearm, back"]      	    = { dam=0.25, isArm=true, skeletal={"Radius", "Ulna"}, muscular={"Extensor Carpi Radialis Brevior", "Extensor Carpi Radialis Longior"}, vital={} };
	aCritLocations["Forearm, inner"]     	    = { dam=0.25, isArm=true, skeletal={"Ulna", "Radius"}, muscular={"Palmaris Longus", "Supinator Longus", "Flexor Carpi Radialis"}, vital={} };
	aCritLocations["Wrist, back"]        	    = { dam=0.25, isArm=true, skeletal={"1d8 Carpus Bones"}, muscular={"Anterior Annular Ligament of the Wrist"}, vital={} };
	aCritLocations["Wrist, front"]       	    = { dam=0.25, isArm=true, skeletal={"1d8 Carpus Bones"}, muscular={"Anterior Annular Ligament of the Wrist"}, vital={} };
	aCritLocations["Hand, back"]         	    = { dam=0.1, isArm=true, skeletal={"1d5 Metacarpus Bones"}, muscular={"Extensor Communis Digitorum", "1d5 Flexor Tendons of the Fingers"}, vital={} };
	aCritLocations["Palm"]               	    = { dam=0.1, isArm=true, skeletal={"1d5 Metacarpus Bones"}, muscular={"Plamaris Brevis", "Abductor Pollicis"}, vital={} };
	aCritLocations["Finger(s)"]          	    = { dam=0.01, isArm=true, isDigit=true, skeletal={"1d4+1 Phalanges"}, muscular={"1d5 Flexor Tendons of the Fingers"}, vital={} };
	aCritLocations["Shoulder, side"]     	    = { dam=0.3, isArm=true, skeletal={"Head of the Humerus"}, muscular={"Deltoid", "Long Tendon of the Biceps Flexor Cubiti", "Tendon of the Pectoralis Major", "Coraco-brachialis"}, vital={} };
	aCritLocations["Shoulder, top"]      	    = { dam=0.3, isArm=true, skeletal={"Head of the Humerus", "Coracoid Process of the Scapula", "Clavicle"}, muscular={"Subclavius", "Deltoid"}, vital={} };
	aCritLocations["Neck, front"]        	    = { dam=1.0, isHead=true, isSpine=true, skeletal={"1d4 Cervical Vertebrae from 7th to 4th", "1d4 Cervical Vertebrae from 2nd to 5th"}, muscular={"Sterno-hyoid Muscle", "Omo-Hyoid Muscle", "Thyro-hyoid Muscle"}, vital={"Trachea", "Spinal Cord"} };
	aCritLocations["Neck, back"]         	    = { dam=1.0, isHead=true, isSpine=true, skeletal={"1d6 Cervical Vertebrae from 2nd to 7th"}, muscular={"Trapezius"}, vital={"Spinal Cord"} };
	aCritLocations["Neck, side"]         	    = { dam=1.0, isHead=true, isSpine=true, skeletal={"1d4 Cervical Vertebrae from 7th to 4th", "1d4 Cervical Vertebrae from 2nd to 5th"}, muscular={"Platysma Moyides", "Scalenus Anticus, Medius and Posticus"}, vital={"Trachea", "Spinal Cord"} };
	aCritLocations["Head, side"]         	    = { dam=1.0, isHead=true, skeletal={"Parietal Bone"}, muscular={"Masseter"}, vital={"Brain"} };
	aCritLocations["Head, back lower"]   	    = { dam=1.0, isHead=true, isSpine=true, skeletal={"Basilar Process of the Occipital Bone", "First Cervical Vertebrae", "Occipital Bone"}, muscular={"Trapezius"}, vital={"Medulla Oblongata", "Spinal Cord"} };
	aCritLocations["Face, lower side"]   	    = { dam=1.0, isHead=true, skeletal={"Inferior Maxillary Bone", "Mastoid Temporal Bone"}, muscular={"Zygomaticus Major and Minor", "Buccinator"}, vital={} };
	aCritLocations["Face, lower center"] 	    = { dam=1.0, isHead=true, isSpine=true, skeletal={"Inferior Maxillary Bone", "Teeth", "Superior Maxillary Bones"}, muscular={"Quadratus Menti", "Quadratus Oris"}, vital={"Spinal Cord"} }; 
	aCritLocations["Head, back upper"]   	    = { dam=1.0, isHead=true, skeletal={"Parietal Bones"}, muscular={"Occipito-frontalis"}, vital={"Brain"} };
	aCritLocations["Face, upper side"]   	    = { dam=1.0, isHead=true, skeletal={"Temporal Bone", "Sphenoid Bone"}, muscular={"Temporalis"}, vital={"Brain"} };
	aCritLocations["Face, upper center"] 	    = { dam=1.0, isHead=true, skeletal={"Nasal Bones", "Frontal Bone, Lower", "Frontal Bone, Upper"}, muscular={"Occipito-frontalis", "Orbicularis Palpebrarum", "Levator Labii Superioris"}, vital={"Brain"} };
	aCritLocations["Head, top"] 		 	    = { dam=1.0, isHead=true, skeletal={"Frontal Bone"}, muscular={"Occipito-frontalis"}, vital={"Brain"} };
end