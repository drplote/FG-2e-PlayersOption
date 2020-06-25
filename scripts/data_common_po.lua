aArmorVsDamageTypeModifiers = {};
aHitLocations = {};
aRaceSizes = {};
aCritCharts = {};


function onInit()
    initializeArmorVsDamageTypeModifiers();
	initializeHitLocations();
	initializeRaceSizes();
	intializeCritCharts();
end

function initializeArmorVsDamageTypeModifiers()
    aArmorVsDamageTypeModifiers["banded mail"]      = {["slashing"] = -2, ["piercing"] = 0,  ["bludgeoning"] = -1};
    aArmorVsDamageTypeModifiers["brigandine"]       = {["slashing"] = -1, ["piercing"] = -1, ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["chain mail"]       = {["slashing"] = -2, ["piercing"] = 0,  ["bludgeoning"] = 2};
    aArmorVsDamageTypeModifiers["field plate"]      = {["slashing"] = -3, ["piercing"] = -1, ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["full plate"]       = {["slashing"] = -4, ["piercing"] = -3, ["bludgeoning"] = 0}; 
    aArmorVsDamageTypeModifiers["leather armor"]    = {["slashing"] = 0,  ["piercing"] = 2,  ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["padded armor"]     = {["slashing"] = 0,  ["piercing"] = 2,  ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["hide armor"]       = {["slashing"] = 0,  ["piercing"] = 2,  ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["plate mail"]       = {["slashing"] = -3, ["piercing"] = 0,  ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["ring mail"]        = {["slashing"] = -1, ["piercing"] = -1, ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["scale mail"]       = {["slashing"] = 0,  ["piercing"] = -1, ["bludgeoning"] = 0};
    aArmorVsDamageTypeModifiers["splint mail"]      = {["slashing"] = 0,  ["piercing"] = -1, ["bludgeoning"] = -2};
    aArmorVsDamageTypeModifiers["studded leather"]  = {["slashing"] = -2, ["piercing"] = -1, ["bludgeoning"] = 0};
end

function initializeHitLocations()
	aHitLocations["humanoid"] = {
		[1]  = {desc="right leg", critchart=1},
		[2]  = {desc="right leg", critchart=1},
		[3]  = {desc="left leg", critchart=1},
		[4]  = {desc="left leg", critchart=1},
		[5]  = {desc="abdomen", critchart=2},
		[6]  = {desc="torso", critchart=3},
		[7]  = {desc="torso", critchart=3},
		[8]  = {desc="right arm", critchart=4},
		[9]  = {desc="left arm", critchart=4},
		[10] = {desc="head", critchart=5}
	};
	
	aHitLocations["animal"] = {
		[1]  = {desc="right foreleg/wing", critchart=1},
		[2]  = {desc="left foreleg/wing", critchart=1},
		[3]  = {desc="right hind leg", critchart=1},
		[4]  = {desc="left hind leg", critchart=1},
		[5]  = {desc="tail", critchart=2},
		[6]  = {desc="abdomen", critchart=3},
		[7]  = {desc="abdomen", critchart=3},
		[8]  = {desc="torso", critchart=4},
		[9]  = {desc="torso", critchart=4},
		[10] = {desc="head", critchart=5}
	};
	
	aHitLocations["monster"] = {
		[1]  = {desc="right foreleg/claw/wing", critchart=1},
		[2]  = {desc="left foreleg/claw/wing", critchart=1},
		[3]  = {desc="right hind leg", critchart=1},
		[4]  = {desc="left hind leg", critchart=1},
		[5]  = {desc="tail", critchart=2},
		[6]  = {desc="abdomen", critchart=3},
		[7]  = {desc="abdomen", critchart=3},
		[8]  = {desc="torso", critchart=4},
		[9]  = {desc="torso", critchart=4},
		[10] = {desc="head", critchart=5}
	};	
end

function initializeRaceSizes()
	-- Size category: T = 1, S = 2, M = 3, L = 4, H = 5, G = 6
	-- medium is assumed unless specified here
	aRaceSizes = {
		["dwarf"] = 3,
		["elf"] = 3,
		["gnome"] = 2,
		["half-elf"] = 3,
		["halfling"] = 2,
		["human"] = 3
	};
end

function initalizeCritCharts()
	-- aCritCharts[sCreatureType][sDamageType][nCritLocationGroup][nSeverity]
	
	-- crit effects:
	-- reduced mvoe
	-- knockdown
	-- armor damage
	-- shield damage
	-- conditional check if armor exists
	-- minor bleeding, major bleeding
	-- attack penalty
	-- no attack
	-- tripled damaged dice
	-- stun
	-- body part "injured" or "broken" or "shattered"
	-- internal bleeding
	-- Drop to 0 HP
	-- weapon/shield/item dropped
	-- permanent stat loss
	
	aCritCharts["humanoid"] = {
		["bludgeoning"] = { 
			[1] = {
				[1] = {desc="No unusual effect"},
				[2] = {desc="No unusual effect"},
				[3] = {desc="No unusual effect"},
				[4] = {desc="Victim knocked down"},
				[5] = {desc="Knee struck, knockdown, 1/2 move"},
				[6] = {desc="Foot broken, 1/2 move"},
				[7] = {desc="Armor damaged, leg injured if target has no armor to cover legs, 1/4 move"},
				[8] = {desc="Hip broken, minor bleeding, no move"},
				[9] = {desc="Armor damaged, leg broken if target has no armor to cover legs, no move"},
				[10] = {desc="Knee shattered, no move, -2 penalty to attacks"},
				[11] = {desc="Hip shattered, minor bleeding, no move or attack"},
				[12] = {desc="Leg shattered, no move or attack, major bleeding from compound fractures"},
				[13] = {desc="Leg shattered, no move or attack, major bleeding from compound fractures, tripled damaged dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim stunned 1d6 rounds"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 1/2 move"},
				[6] = {desc="Armor damaged, victim stunned 1d6 rounds, triple damage if no armor"},
				[7] = {desc="Abdomen injured, 1/2 move, -2 penalty to attacks"},
				[8] = {desc="Abdomen injured, minor internal bleeding, 1/2 move and -2 penalty to attacks"},
				[9] = {desc="Armor damaged, abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks"},
				[10] = {desc="Abdomen injured, no move or attack, minor internal bleeding"},
				[11] = {desc="Abdomen crushed, no move or attack, major internal bleeding"},
				[12] = {desc="Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding"},
				[13] = {desc="Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding, triped damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Knockdown, stunned 1d4 round"},
				[5] = {desc="Torso struck, victim stunned 1 round and reduced to 1/2 move"},
				[6] = {desc="Shield damage, torso struck, 1/2 move"},
				[7] = {desc="Armor damage, torso struck, 1/2 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, minor internal bleeding, no move or attack"},
				[9] = {desc="Ribs broken, minor internal bleeding, 1/2 move, -2 penalty to attacks"},
				[10] = {desc="Ribs broken, major internal bleeding, no move or attack"},
				[11] = {desc="Torso crushed, victim reduced to 0 hit points with severe internal bleeding"},
				[12] = {desc="Torso crushed, victim killed"},
				[13] = {desc="Torso crushed, victim killed, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Hand struck, weapon/shield dropped "},
				[5] = {desc="Arm struck, shield damage/weapon dropped"},
				[6] = {desc="Hand broken, -2 penalty to attacks/shield dropped "},
				[7] = {desc="Armor damage, arm broken if victim has no armor to cover limb "},
				[8] = {desc="Shield damage, arm broken, stunned 1 round"},
				[9] = {desc="Weapon dropped, arm broken, stunned 1d4 rounds"},
				[10] = {desc="Shoulder injured, no attacks, minor bleeding"},
				[11] = {desc="Arm shattered, 1/2 move, no attacks, minor bleeding"},
				[12] = {desc="Shoulder shattered, no move or attacks, major bleeding"},
				[13] = {desc="Shoulder shattered, no move or attacks, major bleeding, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim stunned 1d6 rounds "},
				[5] = {desc="Head struck, helm removed, victim stunned 1 round; -2 penalty to attack rolls if victim had no helm"},
				[6] = {desc="Head struck, -2 penalty to attacks"},
				[7] = {desc="Helm damaged, face injured, stunned 1d6 rounds, 1/2 move, -4 penalty to attacks "},
				[8] = {desc="Skull broken, helm damaged, victim reduced to 0 hit points and unconscious 1d4 hours "},
				[9] = {desc="Face crushed, minor bleeding, no move or attack, Cha drops by 2 points permanently "},
				[10] = {desc="Head injured, unconscious 1d6 days, lose 1 point each of Int/Wis/Cha permanently "},
				[11] = {desc="Skull crushed, reduced to 0 hit points, major bleeding, Int, Wis, Cha all drop by 1/2 permanently"},
				[12] = {desc="Skull crushed, immediate death"},
				[13] = {desc="Skull crushed, immediate death, tripled damage dice"},
			}
		},
		["piercing"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Leg struck, minor bleeding"},
				[5] = {desc="Leg struck, minor bleeding; 1/2 move"},
				[6] = {desc="Leg injured, major bleeding, 1/2 move"},
				[7] = {desc="Armor damaged; leg injured if target has no leg armor, 1/2 move, major bleeding"},
				[8] = {desc="Knee shattered, major bleeding, no move, -4 penalty to any attacks"},
				[9] = {desc="Armor damaged, leg struck, minor bleeding, 1/2 move; if target has no leg armor, leg severed at knee, severe bleeding, no move or attack"},
				[10] = {desc="Hip shattered, no move or attack, severe bleeding"},
				[11] = {desc="Leg severed, severe bleeding, no move or attack"},
				[12] = {desc="Leg severed at thigh, no move or attack, victim reduced to 0 hit points with severe bleeding"},
				[13] = {desc="Leg severed at thigh, no move or attack, victim reduced to 0 hit points with severe bleeding, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Abdomen grazed, minor bleeding"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 1/2 move with minor bleeding"},
				[6] = {desc="Armor damaged; victim stunned 1d6 rounds, major bleeding, 1/2 move if no armor"},
				[7] = {desc="Abdomen injured, major bleeding, 1/2 move, -2 penalty to attacks"},
				[8] = {desc="Abdomen injured, severe bleeding, 1/2 move, -4 penalty to attacks"},
				[9] = {desc="Armor damage, abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks; if no armor, victim at 0 hit points, major bleeding"},
				[10] = {desc="Abdomen injured, no move or attack, severe bleeding"},
				[11] = {desc="Abdomen injured, victim at 0 hp, severe bleeding"},
				[12] = {desc="Abdomen destroyed, victim killed"},
				[13] = {desc="Abdomen destroyed, victim killed, tripled damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Torso grazed, minor bleeding"},
				[5] = {desc="Torso struck, victim stunned 1 round, reduced to 1/2 move with minor bleeding "},
				[6] = {desc="Shield damage, torso struck, 1/2 move & minor bleeding"},
				[7] = {desc="Armor damage, torso struck, 1/2 move, -2 penalty to attacks; if no armor, torso injured, no move or attack, severe bleeding"},
				[8] = {desc="Torso injured, major bleeding, 1/2 move, -4 penalty to attacks"},
				[9] = {desc="Shield damage; torso struck, -2 penalty to attacks; if no shield, torso injured, severe bleeding, no move or attack"},
				[10] = {desc="Torso injured, severe bleeding, no move or attack"},
				[11] = {desc="Torso destroyed, victim reduced to 0 hit points with severe bleeding"},
				[12] = {desc="Torso destroyed, victim killed"},
				[13] = {desc="Torso destroyed, victim killed, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Hand struck, weapon dropped, minor bleeding; no effect on shield arm"},
				[5] = {desc="Arm struck, shield damage/weapon dropped, minor bleeding"},
				[6] = {desc="Hand injured, -2 penalty to attacks/shield dropped"},
				[7] = {desc="Armor damage, arm struck, minor bleeding; if no armor, arm injured, major bleeding"},
				[8] = {desc="Hand severed, stunned 1 round, major bleeding, shield or weapon dropped"},
				[9] = {desc="Armor damage, arm broken; if no armor, arm severed, stunned 1 d6 rounds, major bleeding"},
				[10] = {desc="Shoulder injured, no attacks, major bleeding"},
				[11] = {desc="Shoulder injured, no attacks, major bleeding"},
				[12] = {desc="Arm severed, no move or attacks, severe bleeding"},
				[13] = {desc="Arm severed, no move or attacks, severe bleeding, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Head grazed, stunned 1d3 rounds, minor bleeding"},
				[5] = {desc="Head struck, helm removed, victim stunned 1 round; -2 penalty to attack rolls, minor bleeding if victim had no helm"},
				[6] = {desc="Head struck, minor bleeding, victim blinded for 2d4 rounds by blood in eyes"},
				[7] = {desc="Helm damaged, face injured, stunned 2d6 rounds, minor bleeding, A move, -4 penalty to attacks"},
				[8] = {desc="Skull broken, helm damaged, victim reduced to 0 hit points, major bleeding"},
				[9] = {desc="Throat injured, severe bleeding"},
				[10] = {desc="Skull destroyed, victim reduced to 0 hp, severe bleeding, Int, Wis, Cha all drop by 1/2 permanently"},
				[11] = {desc="Throat destroyed, victim killed"},
				[12] = {desc="Head severed, immediate death"},
				[13] = {desc="Head severed, immediate death, tripled damage dice"},
			}
		},
		["slashing"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Leg grazed, victim knocked down"},
				[5] = {desc="Leg struck, minor bleeding"},
				[6] = {desc="Leg injured, minor bleeding, 2/3 move"},
				[7] = {desc="Armor damaged; leg injured if target has no leg armor, 1/2 move, major bleeding"},
				[8] = {desc="Knee broken, minor bleeding, 1/3 move, -4 penalty to any attacks"},
				[9] = {desc="Armor damaged, leg struck, minor bleeding, 2/3 move; if target has no leg armor, leg broken, major bleeding, 1/3 move, -4 penalty to attacks"},
				[10] = {desc="Hip broken, no move or attack, major bleeding"},
				[11] = {desc="Leg broken, severe bleeding, no move or attack"},
				[12] = {desc="Leg destroyed, no move or attack, severe bleeding"},
				[13] = {desc="Leg destroyed, no move or attack, severe bleeding, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Abdomen grazed, minor bleeding"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 2/3 move with minor bleeding"},
				[6] = {desc="Armor damaged; victim stunned 1d4 rounds, minor bleeding, 2/3 move if no armor"},
				[7] = {desc="Abdomen injured, major bleeding, 1/2 move, -2 penalty to attacks"},
				[8] = {desc="Abdomen injured, severe bleeding, 1/2 move, -4 penalty to attacks"},
				[9] = {desc="Armor damage, abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks; if no armor, victim at 0 hit points, major bleeding"},
				[10] = {desc="Abdomen injured, 1/3 move, no attack, severe bleeding"},
				[11] = {desc="Abdomen injured, victim at 0 hp, severe bleeding"},
				[12] = {desc="Abdomen destroyed, victim killed"},
				[13] = {desc="Abdomen destroyed, victim killed, tripled damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Torso grazed, minor bleeding"},
				[5] = {desc="Torso struck, 2/3 move with minor bleeding"},
				[6] = {desc="Shield damage, torso struck, 2/3 move & minor bleeding"},
				[7] = {desc="Armor damage, torso struck, 2/3 move, -2 penalty to attacks; if no armor, torso injured, no move or attack, severe bleeding"},
				[8] = {desc="Torso injured, major bleeding, 1/2 move, -4 penalty to attacks"},
				[9] = {desc="Shield damage; torso struck, -2 penalty to attacks; if no shield, ribs broken, severe bleeding, no move or attack"},
				[10] = {desc="Ribs broken, severe bleeding, no move or attack"},
				[11] = {desc="Torso destroyed, victim reduced to 0 hit points with severe bleeding"},
				[12] = {desc="Torso destroyed, victim killed"},
				[13] = {desc="Torso destroyed, victim killed, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Hand struck, weapon dropped, minor bleeding; no effect on shield arm"},
				[5] = {desc="Arm struck, shield damage/weapon dropped, minor bleeding"},
				[6] = {desc="Hand injured, -2 penalty to attacks/shield dropped"},
				[7] = {desc="Armor damage, arm struck, minor bleeding; if no armor, arm injured, minor bleeding"},
				[8] = {desc="Arm broken, victim stunned 1 round, minor bleeding, shield or weapon dropped"},
				[9] = {desc="Armor damage, arm injured, -2 penalty to attacks or shield dropped; if no armor, arm broken, stunned 1d6 rounds, major bleeding"},
				[10] = {desc="Shoulder injured, no attacks, major bleeding"},
				[11] = {desc="Arm destroyed, major bleeding, 2/3 move"},
				[12] = {desc="Arm destroyed, no move/attack, major bleeding"},
				[13] = {desc="Arm destroyed, no move/attack, major bleeding, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Head grazed, stunned 1d3 rounds, minor bleeding"},
				[5] = {desc="Head struck, helm removed, victim stunned 1 round; -2 penalty to attack rolls, minor bleeding if victim had no helm"},
				[6] = {desc="Eye injured, -4 penalty to all attacks; if helmed, victim is only stunned 1 round instead"},
				[7] = {desc="Helm damaged, face injured, stunned 1d6 rounds, minor bleeding, 2/3 move, -4 penalty to attack"},
				[8] = {desc="Skull broken, helm damaged, victim reduced to 0 hit points, major bleeding"},
				[9] = {desc="Throat injured, severe bleeding"},
				[10] = {desc="Skull broken, victim reduced to 0 hp, major bleeding, Int, Wis, Cha all drop by 1/2 permanently"},
				[11] = {desc="Throat destroyed, victim killed"},
				[12] = {desc="Head destroyed, immediate death"},
				[13] = {desc="Head destroyed, immediate death, tripled damage dice"},
			}
		}
	};
	aCritCharts["animal"] = {
		["bludgeoning"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim knocked down"},
				[5] = {desc="Knee struck, victim reduced to 2/3 move"},
				[6] = {desc="Foot/wrist broken, 2/3 move"},
				[7] = {desc="Leg injured, 2/3 move, -2 penalty to attack"},
				[8] = {desc="Hip broken, minor bleeding, no movement, -2 penalty to attacks; wing hit forces crash landing"},
				[9] = {desc="Leg broken, 2/3 move, minor bleeding; wing hit forces immediate landing"},
				[10] = {desc="Knee shattered, 1/3 move, -2 penalty to attacks"},
				[11] = {desc="Hip/shoulder shattered, minor bleeding, no move or attack; wing hit forces crash landing"},
				[12] = {desc="Leg/wing shattered, no move or attack, major bleeding from compound fractures"},
				[13] = {desc="Leg/wing shattered, no move or attack, major bleeding from compound fractures, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="No unusual effect"},
				[5] = {desc="No unusual effect"},
				[6] = {desc="Tip of tail struck; if prehensile, any items carried are dropped, -2 penalty to tail attacks due to pain"},
				[7] = {desc="Tail injured, normal animals must save vs. death or retreat in pain; lose any tail attacks"},
				[8] = {desc="Tail injured, normal animals must save vs. death or retreat in pain; lose any tail attacks"},
				[9] = {desc="Tail broken, lose any tail attacks, 1/2 move if animal uses tail for movement"},
				[10] = {desc="Tail broken, lose any tail attacks, 1/2 move if animal uses tail for movement"},
				[11] = {desc="Tail crushed, victim stunned 1-3 rounds, lose any tail attacks, no movement or attacks if animal uses tail for movement"},
				[12] = {desc="Tail crushed, pain reduces creature to 1/2 move and -2 penalty on any attack, minor bleeding; no move or attack if animal uses tail for movement"},
				[13] = {desc="Tail crushed, pain reduces creature to 1/2 move and -2 penalty on any attack, minor bleeding; no move or attack if animal uses tail for movement, tripled damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim stunned 1d6 round"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 1/2 move"},
				[6] = {desc="Abdomen struck, victim stunned 1d6 rounds, reduced to 1/2 move"},
				[7] = {desc="Abdomen injured, 1/2 move, -2 penalty to attack"},
				[8] = {desc="Spine broken, no move, -4 penalty to attacks"},
				[9] = {desc="Abdomen injured, minor bleeding, 1/2 move and -2 penalty to attacks"},
				[10] = {desc="Abdomen injured, no move or attack, minor internal bleeding"},
				[11] = {desc="Spine crushed, no move or attack, major internal bleeding"},
				[12] = {desc="Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding"},
				[13] = {desc="Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Knockdown, stunned 1d4 rounds"},
				[5] = {desc="Torso struck, victim stunned 1 round and reduced to 1/2 move"},
				[6] = {desc="Torso struck, stunned 1d6 rounds, 1/2 move"},
				[7] = {desc="Spine struck, 1/2 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, minor internal bleeding, no move or attack"},
				[9] = {desc="Ribs broken, minor internal bleeding, 1/2 move, -2 penalty to attacks"},
				[10] = {desc="Ribs broken, major internal bleeding, no move or attack"},
				[11] = {desc="Spine crushed, victim reduced to 0 hit points with severe internal bleeding"},
				[12] = {desc="Torso crushed, victim killed"},
				[13] = {desc="Torso crushed, victim killed, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim stunned 1d6 rounds"},
				[5] = {desc="Snout struck, animal must save vs. death or retreat in pain for 1dl0 rounds"},
				[6] = {desc="Head struck, -2 penalty to attacks"},
				[7] = {desc="Jaw injured, stunned 1d6 rounds, 2/3 move, -4 penalty to all attacks"},
				[8] = {desc="Skull broken, animal reduced to 0 hit points and unconscious 1d4 hours"},
				[9] = {desc="Snout/face crushed, minor bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks"},
				[10] = {desc="Head injured, unconscious 2d4 hours, reduced to 1/2move and -4 penalty to all attacks for 1d3 months"},
				[11] = {desc="Skull crushed, reduced to 0 hit points, major bleeding, Int, Wis, Cha all drop by 1/2 permanently"},
				[12] = {desc="Skull crushed, immediate death"},
				[13] = {desc="Skull crushed, immediate death, tripled damage dice"},
			}
		},
		["piercing"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Leg struck, minor bleeding"},
				[5] = {desc="Knee struck, 2/3 move, minor bleeding"},
				[6] = {desc="Leg injured, major bleeding, 2/3 move"},
				[7] = {desc="Foot/claw injured, 2/3 move, minor bleeding, -2 penalty to attacks with that limb"},
				[8] = {desc="Hip injured, major bleeding, 1/3 movement, -2 penalty to attacks; wing hit forces crash landing"},
				[9] = {desc="Leg/wing severed at midpoint, 1/3 move, major bleeding; wing hit forces uncontrolled fall"},
				[10] = {desc="Knee destroyed, major bleeding, 1/3 move, -2 penalty to all attacks"},
				[11] = {desc="Hip/shoulder destroyed, severe bleeding, no move or attack; wing hit forces crash landing"},
				[12] = {desc="Leg/wing severed at mid-thigh, no move or attack, severe bleeding"},
				[13] = {desc="Leg/wing severed at mid-thigh, no move or attack, severe bleeding, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="No unusual effect"},
				[5] = {desc="No unusual effect"},
				[6] = {desc="Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks"},
				[7] = {desc="Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks"},
				[8] = {desc="Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks"},
				[9] = {desc="Tail severed near end, major bleeding, lose tail attacks, move reduced by 1/3 if creature uses tail for movement"},
				[10] = {desc="Tail severed near end, major bleeding, lose tail attacks, move reduced by 1/3 if creature uses tail for movement"},
				[11] = {desc="Tail severed, victim stunned 1-3 rounds, lose tail attacks, major bleeding, no movement or attacks if animal uses tail for movement"},
				[12] = {desc="Tail severed, stunned 1-3 rounds, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack"},
				[13] = {desc="Tail severed, stunned 1-3 rounds, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack, tripled damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Abdomen grazed, minor bleeding"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding"},
				[6] = {desc="Abdomen struck, victim stunned 1d6 rounds, reduced to 2/3 move, minor bleeding "},
				[7] = {desc="Abdomen injured, 1/3 move, minor bleeding, -2 penalty to all attacks"},
				[8] = {desc="Spine injured, no move, minor bleeding, -4 penalty to attacks"},
				[9] = {desc="Abdomen injured, major bleeding, 1/3 move and -2 penalty to attacks"},
				[10] = {desc="Abdomen injured, no move or attack, major bleeding"},
				[11] = {desc="Spine destroyed, no move or attack, major bleeding, victim paralyzed"},
				[12] = {desc="Abdomen destroyed, victim reduced to 0 hit points with severe bleeding"},
				[13] = {desc="Abdomen destroyed, victim reduced to 0 hit points with severe bleeding, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Torso grazed, minor bleeding"},
				[5] = {desc="Torso struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding"},
				[6] = {desc="Torso struck, stunned 1d6 rounds, minor bleeding"},
				[7] = {desc="Spine struck, major bleeding, 2/3 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, severe bleeding, no move or attack"},
				[9] = {desc="Ribs broken, major bleeding, 1/3 move, -4 penalty to attacks"},
				[10] = {desc="Ribs broken, severe bleeding, no move or attack "},
				[11] = {desc="Spine destroyed, victim reduced to 0 hit points with severe bleeding"},
				[12] = {desc="Torso destroyed, victim killed"},
				[13] = {desc="Torso destroyed, victim killed, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Head grazed, stunned 1 round, minor bleeding"},
				[5] = {desc="Snout struck, minor bleeding, animal must save vs. death or retreat for 1d10 rounds"},
				[6] = {desc="Head struck, minor bleeding, -2 penalty to attacks"},
				[7] = {desc="Throat injured, major bleeding, 2/3 move, -4 penalty to all attacks"},
				[8] = {desc="Skull broken, animal reduced to 0 hit points, major bleeding"},
				[9] = {desc="Snout/face destroyed, major bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks"},
				[10] = {desc="Head injured, reduced to 0 hp, severe bleeding; 1/3 move and -4 penalty to all attacks for 1d3 months"},
				[11] = {desc="Throat destroyed, severe bleeding"},
				[12] = {desc="Head severed, immediate death"},
				[13] = {desc="Head severed, immediate death, tripled damage dice"},
			}
		},
		["slashing"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Leg struck, minor bleeding"},
				[5] = {desc="Knee struck, 2/3 move, minor bleeding"},
				[6] = {desc="Leg injured, minor bleeding, 2/3 move"},
				[7] = {desc="Foot/claw injured, minor bleeding, -2 penalty to attacks with that limb"},
				[8] = {desc="Hip injured, minor bleeding, 2/3 movement, -2 penalty to all attacks; wing hit forces crash landing"},
				[9] = {desc="Leg/wing broken, 1/3 move, minor bleeding; wing hit forces crash landing"},
				[10] = {desc="Knee broken, minor bleeding, 1/3 move, -2 penalty to all attacks"},
				[11] = {desc="Hip/shoulder destroyed, major bleeding, no move or attack; wing hit forces crash landing"},
				[12] = {desc="Leg/wing destroyed, no move or attack, major bleeding"},
				[13] = {desc="Leg/wing destroyed, no move or attack, major bleeding, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="No unusual effect"},
				[5] = {desc="No unusual effect"},
				[6] = {desc="Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks"},
				[7] = {desc="Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks"},
				[8] = {desc="Tail injured, minor bleeding, normal animals must save vs. death or retreat; no tail attacks"},
				[9] = {desc="Tail injured, minor bleeding, lose tail attacks; if creature uses tail for movement, 1/3 move"},
				[10] = {desc="Tail injured, minor bleeding, lose tail attacks; if creature uses tail for movement, 1/3 move"},
				[11] = {desc="Tail destroyed, victim stunned 1-3 rounds, lose tail attacks, major bleeding, no movement or attacks if animal uses tail for movement"},
				[12] = {desc="Tail destroyed, stunned 1d2 rounds, major bleeding, 1/2 move and -2 penalty on attacks; if animal uses tail for movement, no move or attack"},
				[13] = {desc="Tail destroyed, stunned 1d2 rounds, major bleeding, 1/2 move and -2 penalty on attacks; if animal uses tail for movement, no move or attack, tripled damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Abdomen grazed, minor bleeding"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding"},
				[6] = {desc="Abdomen struck, victim stunned 1d4 rounds, reduced to 2/3 move, minor bleeding"},
				[7] = {desc="Abdomen injured, 2/3 move, major bleeding, -2 penalty to all attacks"},
				[8] = {desc="Spine injured, 1/3 move, minor bleeding, -4 penalty to all attacks"},
				[9] = {desc="Abdomen injured, major bleeding, 1/3 move and -2 penalty to all attacks "},
				[10] = {desc="Abdomen injured, no move or attack, major bleeding"},
				[11] = {desc="Spine broken, no move or attack, major bleeding, victim paralyzed"},
				[12] = {desc="Abdomen destroyed, victim reduced to 0 hit points with severe bleeding"},
				[13] = {desc="Abdomen destroyed, victim reduced to 0 hit points with severe bleeding, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Torso grazed, minor bleeding"},
				[5] = {desc="Torso struck, victim stunned 1 round and reduced to 2/3 move, minor bleeding"},
				[6] = {desc="Torso struck, stunned 1d4 rounds, minor bleeding"},
				[7] = {desc="Spine struck, minor bleeding, 2/3 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, stunned 1 round, major bleeding"},
				[9] = {desc="Ribs broken, minor bleeding, 1/3 move, -4 penalty to attacks"},
				[10] = {desc="Ribs broken, major bleeding, no move or attack"},
				[11] = {desc="Spine destroyed, victim reduced to 0 hit points with major bleeding"},
				[12] = {desc="Torso destroyed, victim killed"},
				[13] = {desc="Torso destroyed, victim killed, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Head grazed, stunned 1 round, minor bleeding "},
				[5] = {desc="Snout struck, minor bleeding, animal must save vs. death or retreat for 1d10 rounds"},
				[6] = {desc="Eye injured, stunned 1d3 rounds, -2 penalty to attacks"},
				[7] = {desc="Throat injured, major bleeding, 2/3 move, -4 penalty to all attacks"},
				[8] = {desc="Skull broken, animal reduced to 0 hit points, major bleeding"},
				[9] = {desc="Snout/face destroyed, minor bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks"},
				[10] = {desc="Head injured, reduced to 0 hp, major bleeding; 1/3 move and -4 penalty to all attacks for 1d3 months "},
				[11] = {desc="Throat destroyed, severe bleeding"},
				[12] = {desc="Head severed, immediate death"},
				[13] = {desc="Head severed, immediate death, tripled damage dice"},
			}
		}
	};
	aCritCharts["monster"] = {
		["bludgeoning"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim knocked down"},
				[5] = {desc="Knee struck, victim reduced to 2/3 move, -2 penalty to attacks with that appendage"},
				[6] = {desc="Foot/wrist broken, 2/3 move, -4 penalty to attacks with that appendage"},
				[7] = {desc="Limb injured, 2j/3 move, -2 penalty to all attacks"},
				[8] = {desc="Hip broken, minor bleeding, 1/3 move, no attacks with limb; wing hit forces crash landing"},
				[9] = {desc="Limb broken, 2/3 move, minor bleeding; wing hit forces immediate landing"},
				[10] = {desc="Knee shattered, 1/3move, -2 penalty to all attacks"},
				[11] = {desc="Hip/shoulder shattered, minor bleeding, 1/3 move, -4 penalty to all attacks; wing hit forces crash"},
				[12] = {desc="Leg/wing shattered, no move, -4 penalty to all attacks, major bleeding from compound fracture"},
				[13] = {desc="Leg/wing shattered, no move, -4 penalty to all attacks, major bleeding from compound fracture, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="No unusual effect"},
				[5] = {desc="No unusual effect"},
				[6] = {desc="Tip of tail struck; if prehensile, any items carried are dropped, -2 penalty to tail attacks due to pain"},
				[7] = {desc="Tail injured, lose any tail attacks"},
				[8] = {desc="Tail injured, lose any tail attacks"},
				[9] = {desc="Tail broken, lose any tail attacks, if creature uses tail for movement reduced to 1/2 move"},
				[10] = {desc="Tail broken, lose any tail attacks, if creature uses tail for movement reduced to 1/2 move"},
				[11] = {desc="Tail crushed, victim stunned 1-3 rounds, lose any tail attacks, no movement if monster uses tail for movement and -4 penalty to all attacks"},
				[12] = {desc="Tail crushed, pain reduces creature to 1/2 move and -2 penalty on any attack, minor bleeding; if animal uses tail for movement, no move or attack"},
				[13] = {desc="Tail crushed, pain reduces creature to xh move and -2 penalty on any attack, minor bleeding; if animal uses tail for movement, no move or attack, triple damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim stunned 1d4 rounds"},
				[5] = {desc="Abdomen struck, victim stunned 1 round and reduced to 2/3 move"},
				[6] = {desc="Abdomen struck, victim stunned 1d6 rounds, reduced to 2/3 move "},
				[7] = {desc="Abdomen injured, 1/2 move, -2 penalty to attacks "},
				[8] = {desc="Spine injured, 1/3 move, -4 penalty to attacks"},
				[9] = {desc="Abdomen injured, victim stunned 1d3 rounds, minor bleeding, 1/3 move and -2 penalty to attacks"},
				[10] = {desc="Abdomen injured, no move or attack, minor internal bleeding"},
				[11] = {desc="Spine crushed, no move or attack, major internal bleeding"},
				[12] = {desc="Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding"},
				[13] = {desc="Abdomen crushed, victim reduced to 0 hit points with severe internal bleeding, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Knockdown, stunned 1d4 rounds"},
				[5] = {desc="Torso struck, victim stunned 1 round and reduced to 2/3 move"},
				[6] = {desc="Torso struck, stunned 1d6 rounds, 2/3 move"},
				[7] = {desc="Spine struck, 1/2 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, minor internal bleeding, 1/3 move, -4 penalty to all attacks"},
				[9] = {desc="Ribs broken, minor internal bleeding, 1/2 move, -2 penalty to attacks"},
				[10] = {desc="Ribs broken, major internal bleeding, no move or attack"},
				[11] = {desc="Spine crushed, victim reduced to 0 hit points with severe internal bleeding"},
				[12] = {desc="Torso crushed, victim killed"},
				[13] = {desc="Torso crushed, victim killed, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Victim stunned 1d4 rounds"},
				[5] = {desc="Jaw struck, -2 penalty to any bite attacks"},
				[6] = {desc="Head struck, stunned 1 round, -2 penalty to attacks"},
				[7] = {desc="Jaw injured, stunned 1d4 rounds, 2/3 move, no bite attacks"},
				[8] = {desc="Skull broken, monster reduced to 1/4 normal hit points and unconscious 2dl0 turns"},
				[9] = {desc="Snout/face crushed, minor bleeding, 1/3 move, no bite attacks, -4 penalty to all other attacks"},
				[10] = {desc="Head injured, unconscious ldl0 turns, reduced to 1/2 move and -4 penalty to all attacks for 3d6 days"},
				[11] = {desc="Skull crushed, reduced to 0 hit points, major bleeding, Int, Wis, Cha all drop by 1/2 permanently"},
				[12] = {desc="Skull crushed, immediate death"},
				[13] = {desc="Skull crushed, immediate death, tripled damage dice"},
			}
		},
		["piercing"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Leg grazed, minor bleeding"},
				[5] = {desc="Knee struck, 2/3 move, minor bleeding"},
				[6] = {desc="Leg struck, minor bleeding, 2/3 move"},
				[7] = {desc="Foot/claw injured, 2/3 move, minor bleeding, -2 penalty to attacks with that limb"},
				[8] = {desc="Hip injured, major bleeding, 1/3 movement; wing hit forces crash landing"},
				[9] = {desc="Leg/wing severed at midpoint, 1/3 move, major bleeding; wing hit forces uncontrolled fall"},
				[10] = {desc="Knee destroyed, major bleeding, 1/3 move, -2 penalty to attacks with affected limb"},
				[11] = {desc="Hip/shoulder destroyed, major bleeding, no move, -4 penalty to attacks; wing hit forces crash landing"},
				[12] = {desc="Leg/wing severed at mid-thigh, no move or attack, severe bleeding"},
				[13] = {desc="Leg/wing severed at mid-thigh, no move or attack, severe bleeding, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="No unusual effect"},
				[5] = {desc="No unusual effect"},
				[6] = {desc="Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks"},
				[7] = {desc="Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks"},
				[8] = {desc="Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks"},
				[9] = {desc="Tail severed, major bleeding, no tail attacks; if creature uses tail for movement, 1/3 move"},
				[10] = {desc="Tail severed, major bleeding, no tail attacks; if creature uses tail for movement, 1/3 move"},
				[11] = {desc="Tail severed, victim stunned 1 round, lose tail attacks, major bleeding; 1/3 movement, -4 penalty to attacks if monster uses tail for movement"},
				[12] = {desc="Tail severed, stunned 1 round, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack"},
				[13] = {desc="Tail severed, stunned 1 round, major bleeding, 1/2 move and -2 penalty on any attack; if animal uses tail for movement, no move or attack, tripled damage dice"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Abdomen grazed, minor bleeding"},
				[5] = {desc="Abdomen struck, victim stunned 1 round, minor bleeding"},
				[6] = {desc="Abdomen struck, victim stunned 1d3 rounds, reduced to 2/3 move, minor bleeding"},
				[7] = {desc="Abdomen injured, 1/2 move, minor bleeding, -2 penalty to all attacks"},
				[8] = {desc="Spine injured, 1/3 move, minor bleeding, -4 penalty to all attacks"},
				[9] = {desc="Abdomen injured, major bleeding, 1/3 move and -2 penalty to attacks"},
				[10] = {desc="Abdomen injured, 1/3 move, -4 penalty to attacks, major bleeding"},
				[11] = {desc="Spine injured, no move or attack, major bleeding, victim stunned 1d6 rounds"},
				[12] = {desc="Abdomen destroyed, victim reduced to 0 hit points with severe bleeding"},
				[13] = {desc="Abdomen destroyed, victim reduced to 0 hit points with severe bleeding, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Torso grazed, minor bleeding"},
				[5] = {desc="Torso struck, victim stunned 1 round, minor bleeding"},
				[6] = {desc="Torso struck, stunned 1d3 rounds, minor bleeding"},
				[7] = {desc="Spine struck, minor bleeding, 2/3 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, major bleeding, 1/3 move, -4 penalty to attacks"},
				[9] = {desc="Ribs injured, major bleeding, 1/3 move, -4 penalty to attacks"},
				[10] = {desc="Ribs broken, severe bleeding, 1/3 move, no attack"},
				[11] = {desc="Spine broken, major bleeding, no move or attack"},
				[12] = {desc="Torso destroyed, victim killed"},
				[13] = {desc="Torso destroyed, victim killed, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Head grazed, minor bleeding"},
				[5] = {desc="Snout struck, minor bleeding, monster must save vs. death or retreat for 1 round"},
				[6] = {desc="Head struck, minor bleeding, -2 penalty to attacks"},
				[7] = {desc="Throat injured, major bleeding, 2/3 move, -2 penalty to all attacks"},
				[8] = {desc="Skull injured, monster reduced to 2/3 move, major bleeding, -2 penalty to all attacks"},
				[9] = {desc="Snout/face injured, major bleeding, 1/3 move, no bite attacks, -2 penalty to all other attacks"},
				[10] = {desc="Head injured, reduced to 0 hp, major bleeding; 1/3 move and -4 penalty to all attacks for 1d3 weeks"},
				[11] = {desc="Throat destroyed, severe bleeding"},
				[12] = {desc="Head severed, immediate death"},
				[13] = {desc="Head severed, immediate death, tripled damage dice"},
			}
		},
		["slashing"] = {
			[1] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Leg grazed, minor bleeding"},
				[5] = {desc="Knee struck, 2/3 move"},
				[6] = {desc="Leg struck, minor bleeding, 2/3 move"},
				[7] = {desc="Foot/claw injured, minor bleeding, -2 penalty to attacks with that limb"},
				[8] = {desc="Hip injured, minor bleeding, 1/3 movement; wing hit forces crash landing"},
				[9] = {desc="Leg/wing broken, 1/3 move, minor bleeding; wing hit forces crash landing"},
				[10] = {desc="Knee destroyed, major bleeding, 1/3 move, -2 penalty to attacks with affected limb"},
				[11] = {desc="Hip/shoulder destroyed, major bleeding, no move, -4 penalty to attacks; wing hit forces crash landing"},
				[12] = {desc="Leg/wing destroyed, no move or attack, major bleeding"},
				[13] = {desc="Leg/wing destroyed, no move or attack, major bleeding, tripled damage dice"},
			},
			[2] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="No unusual effect"},
				[5] = {desc="No unusual effect"},
				[6] = {desc="Tip of tail struck; if prehensile, any items carried are dropped, minor bleeding, -2 penalty to tail attacks"},
				[7] = {desc="Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks"},
				[8] = {desc="Tail injured, minor bleeding, monster suffers -2 penalty to all attacks due to pain; no tail attacks"},
				[9] = {desc="Tail broken, minor bleeding, no tail attacks; if creature uses tail for movement, 1/3 move"},
				[10] = {desc="Tail broken, minor bleeding, no tail attacks; if creature uses tail for movement, 1/3 move"},
				[11] = {desc="Tail destroyed, victim stunned 1 round, lose tail attacks, major bleeding; 1/3 movement, -4 penalty to attacks if monster uses tail for movement"},
				[12] = {desc="Tail destroyed, stunned 1d3 rounds, major bleeding, 1/3 move and -2 penalty on any attack; if monster uses tail for movement, no move/attack"},
				[13] = {desc="Tail destroyed, stunned 1d3 rounds, major bleeding, 1/3 move and -2 penalty on any attack; if monster uses tail for movement, no move/attack"},
			},
			[3] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Abdomen grazed, minor bleeding"},
				[5] = {desc="Abdomen struck, victim stunned 1 round, minor bleeding"}
				[6] = {desc="Abdomen struck, victim stunned 1d3 rounds, minor bleeding"},
				[7] = {desc="Abdomen injured, 2/3 move, minor bleeding, -2 penalty to all attacks"},
				[8] = {desc="Spine injured, 1/2 move, minor bleeding, -4 penalty to all attacks"},
				[9] = {desc="Abdomen injured, major bleeding, 1/3 move and -2 penalty to attacks"},
				[10] = {desc="Abdomen injured, ]A move, -4 penalty to attacks, major bleeding"},
				[11] = {desc="Spine injured, no move or attack, major bleeding, victim stunned 1d6 rounds"},
				[12] = {desc="Abdomen destroyed, victim reduced to 0 hit points with major bleeding"},
				[13] = {desc="Abdomen destroyed, victim reduced to 0 hit points with major bleeding, tripled damage dice"},
			}
			[4] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Torso grazed, minor bleeding"},
				[5] = {desc="Torso struck, victim stunned 1 round, minor bleeding"},
				[6] = {desc="Torso struck, stunned 1d3 rounds, minor bleeding"},
				[7] = {desc="Spine struck, minor bleeding, 2/3 move, -2 penalty to attacks"},
				[8] = {desc="Torso injured, minor bleeding, 1/3 move, -4 penalty to attacks"},
				[9] = {desc="Ribs injured, major bleeding, 1/3 move, -4 penalty to attacks"},
				[10] = {desc="Ribs broken, major bleeding, 1/3 move, no attack"},
				[11] = {desc="Spine broken, major bleeding, no move or attack"},
				[12] = {desc="Torso destroyed, victim killed"},
				[13] = {desc="Torso destroyed, victim killed, tripled damage dice"},
			},
			[5] = {
				[1] = {desc="No unusual effect"}
				[2] = {desc="No unusual effect"}
				[3] = {desc="No unusual effect"}
				[4] = {desc="Head grazed, minor bleeding"},
				[5] = {desc="Snout struck, minor bleeding, monster must save vs. death or retreat for 1 round"},
				[6] = {desc="Eye injured, stunned 1 round, -2 penalty to attacks"},
				[7] = {desc="Throat injured, major bleeding, 2/3 move, -2 penalty to all attacks"},
				[8] = {desc="Skull injured, monster reduced to 2/3 move, major bleeding, -2 penalty to all attacks"},
				[9] = {desc="Snout/face injured, major bleeding, 1/3 move, no bite attacks, -2 penalty to all other attacks"},
				[10] = {desc="Head injured, reduced to 0 hp, major bleeding; 1/3 move and -4 penalty to all attacks for 1d3 weeks"},
				[11] = {desc="Throat destroyed, severe bleeding"},
				[12] = {desc="Head destroyed, immediate death"},
				[13] = {desc="Head destroyed, immediate death, tripled ddamage dice"},
			}
		}
	};
	
end