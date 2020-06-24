aArmorVsDamageTypeModifiers = {};
aHitLocations = {};
aHumanoidHitLocations = {};
aMonsterHitLocations = {};
aAnimalHitLocations = {};
aRaceSizes = {};

function onInit()
    initializeArmorVsDamageTypeModifiers();
	initializeHitLocations();
	initializeRaceSizes();
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
	aHumanoidHitLocations = {
		[1]  = {desc="right leg"},
		[2]  = {desc="right leg"},
		[3]  = {desc="left leg"},
		[4]  = {desc="left leg"},
		[5]  = {desc="abdomen"},
		[6]  = {desc="torso"},
		[7]  = {desc="torso"},
		[8]  = {desc="right arm"},
		[9]  = {desc="left arm"},
		[10] = {desc="head"}
	};
	
	aAnimalHitLocations = {
		[1]  = {desc="right foreleg/wing"},
		[2]  = {desc="left foreleg/wing"},
		[3]  = {desc="right hind leg"},
		[4]  = {desc="left hind leg"},
		[5]  = {desc="tail"},
		[6]  = {desc="abdomen"},
		[7]  = {desc="abdomen"},
		[8]  = {desc="torso"},
		[9]  = {desc="torso"},
		[10] = {desc="head"}
	};
	
	aMonsterHitLocations = {
		[1]  = {desc="right foreleg/claw/wing"},
		[2]  = {desc="left foreleg/claw/wing"},
		[3]  = {desc="right hind leg"},
		[4]  = {desc="left hind leg"},
		[5]  = {desc="tail"},
		[6]  = {desc="abdomen"},
		[7]  = {desc="abdomen"},
		[8]  = {desc="torso"},
		[9]  = {desc="torso"},
		[10] = {desc="head"}
	};
	
	aHitLocations = {
		["animal"] = aAnimalHitLocations,
		["monster"] = aMonsterHitLocations,
		["humanoid"] = aHumanoidHitLocations
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