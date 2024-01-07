Torch = "LIGHT: 10/15 FFFFF3E1"; -- Temporarily removed "flicker 25" from it for performance reasons
BullseyeLantern = "LIGHT: 40/60 FFF9FEFF";
HoodedLantern = "LIGHT: 20/30 FFF9FEFF";
Candle = "LIGHT: 5 FFFFFCC3"; -- Temporarily removed "flicker 25" from it for performance reasons
LightSpell = "LIGHT: 20/20 FFFFFFFF";
ContinualLightSpell = "LIGHT: 60/60 FFFFFFFF";
DarknessSpell = "LIGHT: 15 darkness";
ContinualDarknessSpell = "LIGHT: 60 darkness";

DefaultGlowColor = "FFFFFFFF";
WeaponGlow = "LIGHT: 5 %s";
Blue = "FF6F90FF";
Red = "FFFF0000";
Green = "FF00FF00";
Yellow = "FFFFFF00";
Orange = "FFFF7D00";
Purple = "FFF364FF";
White = "FFFFFFFF";

DefaultDistance = 60;
Infravision = "VISION: %s infravision";
Blindsight = "VISION: %s blindsight";
Truesight = "VISION: %s truesight";

function onInit()
end

function removeAllLights(nodeActor)
    if not nodeActor then
        return;
    end

    EffectManagerPO.removeEffectsThatMatch(nodeActor, "LIGHT:");
end

function addInfravision(nodeActor, nDistance)
    addVision(nodeActor, Infravision, nDistance);
end

function addBlindsight(nodeActor, nDistance)
    addVision(nodeActor, Blindsight, nDistance);
end

function addTruesight(nodeActor, nDistance)
    addVision(nodeActor, Truesight, nDistance);
end

function addVision(nodeActor, sVisionType, nDistance)
    if not nodeActor or not sVisionType then
        return;
    end

    if not nDistance then
        nDistance = DefaultDistance;
    end

    EffectManagerPO.requestAddEffect(nodeActor, string.format(sVisionType, nDistance));
end

function addLight(nodeActor, sEffect)
    if not nodeActor or not sEffect then
        return;
    end

    EffectManagerPO.requestAddEffect(nodeActor, sEffect);
end

function addWeaponGlow(nodeActor, sGlowColor)
    if not nodeActor then
        return;
    end

    if not sGlowColor then
        sGlowColor = DefaultGlowColor;
    end

    EffectManagerPO.requestAddEffect(nodeActor, string.format(WeaponGlow, sGlowColor));
end
