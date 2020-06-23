aArmorVsDamageTypeModifiers = {}

function onInit()
    initializeArmorVsDamageTypeModifiers();
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