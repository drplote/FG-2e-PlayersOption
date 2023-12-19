function onInit()
    Comm.registerSlashHandler("qf", onRollQuickFlawSlashCommand);
    Comm.registerSlashHandler("getfucked", onRollQuickFlawSlashCommand);
end

function onRollQuickFlawSlashCommand(sCmd)
    local sText = "[Rolling for Quirk/Flaw] " .. getQuirkOrFlaw();
    ChatManagerPO.deliverChatMessage(sText);
end

function getGender(nRollValue)
    if not nRollValue then
        nRollValue = DiceManagerPO.getDieResult(2);
    end
    if nRollValue == 1 then
        return "Male";
    else
        return "Female";
    end
end

function getBodySide(nRollValue)
    if not nRollValue then
        nRollValue = DiceManagerPO.getDieResult(2);
    end
    if nRollValue == 1 then
        return "left";
    else
        return "right";
    end
end

function getLawChaos(nRollValue)
    if not nRollValue then
        nRollValue = DiceManagerPO.getDieResult(2);
    end
    if nRollValue == 1 then
        return "Lawful";
    else
        return "Chaotic";
    end
end

function getGoodEvil(nRollValue)
    if not nRollValue then
        nRollValue = DiceManagerPO.getDieResult(2);
    end
    if nRollValue == 1 then
        return "Good";
    else
        return "Evil";
    end
end

function getQuirkOrFlaw()
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 15 then
        return getMinorPhysicalFlaw6b();
    elseif nRollValue < 29 then
        return getMinorPhysicalFlaw6c();
    elseif nRollValue < 43 then
        return getMinorPhysicalFlaw6d();
    elseif nRollValue < 51 then
        return getMajorPhysicalFlaw();
    elseif nRollValue < 67 then
        return getMinorMentalQuirk();
    elseif nRollValue < 77 then
        return getMajorMentalQuirk();
    elseif nRollValue < 94 then
        return getMinorPersonalityQuirk();
    else
        return getMajorPersonalityQuirk();
    end
end

function getRandomClass(nRollValue)
    if not nRollValue then
        nRollValue = DiceManagerPO.getDieResult(20);
    end

    if nRollValue == 1 then
        return "Barbarian";
    elseif nRollValue == 2 then
        return "Bard";
    elseif nRollValue == 3 then
        return "Cleric";
    elseif nRollValue == 4 then
        return "Druid";
    elseif nRollValue == 5 then
        return "Fighter";
    elseif nRollValue == 6 then
        return "HackMaster";
    elseif nRollValue == 7 then
        return "Cavalier";
    elseif nRollValue == 8 then
        return "Paladin";
    elseif nRollValue == 9 then
        return "Ranger";
    elseif nRollValue == 10 then
        return "Magic User";
    elseif nRollValue == 11 then
        return "Battle Mage";
    elseif nRollValue == 12 then
        return "Dark Knight";
    elseif nRollValue == 13 then
        return "Illusionist";
    elseif nRollValue == 14 then
        return "Thief";
    elseif nRollValue == 15 then
        return "Assassin";
    elseif nRollValue == 16 then
        return "Monk";
    elseif nRollValue == 17 then
        return "Berserker";
    elseif nRollValue == 18 then
        return "Knight Errant";
    elseif nRollValue == 19 then
        return "Blood Mage";
    else
        return getRandomClass(DiceManagerPO.getDieResult(19)) .. " and " ..
                   getRandomClass(DiceManagerPO.getDieResult(19));
    end
end

function getAbilityScore(nRollValue)
    local nRollValue = DiceManagerPO.getDieResult(7);

    if nRollValue == 1 then
        return "Strength";
    elseif nRollValue == 2 then
        return "Dexterity";
    elseif nRollValue == 3 then
        return "Constitution";
    elseif nRollValue == 4 then
        return "Intelligence";
    elseif nRollValue == 5 then
        return "Wisdom";
    elseif nRollValue == 6 then
        return "Charisma";
    else
        return "Comeliness";
    end
end

function getRandomRace()
    local nRollValue = DiceManagerPO.getDieResult(10);

    if nRollValue == 1 then
        return "Dwarf";
    elseif nRollValue == 2 then
        return "Elf";
    elseif nRollValue == 3 then
        return "Gnome";
    elseif nRollValue == 4 then
        return "Gnomeling";
    elseif nRollValue == 5 then
        return "Half-elf";
    elseif nRollValue == 6 then
        return "Halfling";
    elseif nRollValue == 7 then
        return "Half-orc";
    elseif nRollValue == 8 then
        return "Half-ogre";
    elseif nRollValue == 9 then
        return "Pixie Fairy";
    else
        return "Human";
    end
end

function getAnimalPhobia()
    local nRollValue = DiceManagerPO.getDieResult(20);

    if nRollValue < 3 then
        return "horse";
    elseif nRollValue < 5 then
        return "dog";
    elseif nRollValue < 7 then
        return "cat";
    elseif nRollValue < 9 then
        return "insect";
    elseif nRollValue < 11 then
        return "rodent";
    elseif nRollValue < 13 then
        return "snake";
    elseif nRollValue < 15 then
        return "birds";
    elseif nRollValue < 17 then
        return "fish";
    elseif nRollValue < 19 then
        return "worms";
    else
        return "cattle";
    end
end

function getAnimalAntipathy()
    local nRollValue = DiceManagerPO.getDieResult(20);

    if nRollValue < 3 then
        return "horse";
    elseif nRollValue < 5 then
        return "dog";
    elseif nRollValue < 7 then
        return "cat";
    elseif nRollValue < 9 then
        return "bird";
    elseif nRollValue < 11 then
        return "insect";
    elseif nRollValue < 13 then
        return "fish";
    elseif nRollValue < 15 then
        return "bat";
    elseif nRollValue < 17 then
        return "snake";
    elseif nRollValue < 19 then
        return "ape";
    else
        return "GM's choice (Your GM may choose from this table, or from any animal in the Hacklopedia of Beasts)";
    end
end

function getAllergen()
    local nRollValue = DiceManagerPO.getDieResult(20);

    if nRollValue < 3 then
        return "food (GM can determine specific food)";
    elseif nRollValue < 5 then
        return "cloth";
    elseif nRollValue < 7 then
        return "wood";
    elseif nRollValue < 10 then
        return "cats";
    elseif nRollValue < 11 then
        return "animals other than cats (all)";
    elseif nRollValue < 13 then
        return "gold";
    elseif nRollValue < 15 then
        return "metals other than gold (GM can determine specific metal)";
    elseif nRollValue < 17 then
        return "pollen";
    elseif nRollValue < 19 then
        return "dust";
    else
        return getAllergen() .. " and " .. getAllergen();
    end
end

function getMaiming()
    local nRollValue = DiceManagerPO.getDieResult(6);

    if nRollValue == 1 then
        return "Severe facial burn or scarring";
    elseif nRollValue == 2 then
        return "Misshapen head";
    elseif nRollValue == 3 then
        local nFingerResult = DiceManagerPO.getDieResult(6);
        if nFingerResult < 4 then
            return "Fingers webbed"
        else
            return "Extra finger on " .. getBodySide .. " hand.";
        end
    elseif nRollValue == 4 then
        return "Two missing facial features (nose and ear, nose and lips, etc.)";
    elseif nRollValue == 5 then
        return "Misshapen body";
    else
        return getMaiming() .. " and " .. getMaiming();
    end
end

function getDelusion(bIsMajor)
    local nRollValue = DiceManagerPO.getDieResult(6);

    if nRollValue > 4 or bIsMajor then
        return getMajorDelusion();
    else
        return getMinorDelusion();
    end
end

function getObsessiveCompulsive()
    local nRollValue = DiceManagerPO.getDieResult(20);
    if nRollValue < 20 then
        if DiceManagerPO.getDieResult(2) == 1 then
            return getObsession(nRollValue);
        else
            return getCompulsion(nRollValue);
        end
    else
        nRollValue = DiceManagerPO.getDieResult(19);
        return getObsession(nRollValue) .. " and " .. getCompulsion(nRollValue);
    end
end

function getObsession(nRollValue)
    if nRollValue == 1 then
        return "Obsession with members of the opposite sex";
    elseif nRollValue == 2 then
        return "Obsesssion with numbers";
    elseif nRollValue == 3 then
        return "Obsession with clothing";
    elseif nRollValue == 4 then
        return "Obsession with gold";
    elseif nRollValue == 5 then
        return "Obsession with horses";
    elseif nRollValue == 6 then
        return "Obsession with weapons";
    elseif nRollValue == 7 then
        return "Obsession with armor";
    elseif nRollValue == 8 then
        return "Obsession with magic";
    elseif nRollValue == 9 then
        return "Obsession with cleanliness";
    elseif nRollValue == 10 then
        return "Obsession with body image";
    elseif nRollValue == 11 then
        return "Obsession with hair";
    elseif nRollValue == 12 then
        return "Obsession with the sun";
    elseif nRollValue == 13 then
        return "Obsession with bugs";
    elseif nRollValue == 14 then
        return "Obsession with food";
    elseif nRollValue == 15 then
        return "Obsession with sounds";
    elseif nRollValue == 16 then
        return "Obsession with books or scrolls";
    elseif nRollValue == 17 then
        return "Obsession with jewels";
    elseif nRollValue == 18 then
        return "Obsession with rocks";
    else
        return "Obsession with smells";
    end
end

function getCompulsion(nRollValue)
    if nRollValue == 1 then
        return "Compulsion to kiss members of the opposite sex";
    elseif nRollValue == 2 then
        return "Compulsion to count everything";
    elseif nRollValue == 3 then
        return "Compulsion to buy clothing";
    elseif nRollValue == 4 then
        return "Compulsion to gather as much gold as possible";
    elseif nRollValue == 5 then
        return "Compulsion to scrub or brush horses";
    elseif nRollValue == 6 then
        return "Compulsion to own as many weapons as possible";
    elseif nRollValue == 7 then
        return "Compulsion to own as much armor as possible";
    elseif nRollValue == 8 then
        return "Compulsion to accumulate as many magic items as possible";
    elseif nRollValue == 9 then
        return "Compulsion to clean";
    elseif nRollValue == 10 then
        return "Compulsion to exercise";
    elseif nRollValue == 11 then
        return "Compulsion to comb hair";
    elseif nRollValue == 12 then
        return "Compulsion to stare at the sun";
    elseif nRollValue == 13 then
        return "Compulsion to eat bugs";
    elseif nRollValue == 14 then
        return "Compulsion to cook/eat";
    elseif nRollValue == 15 then
        return "Compulsion to discover source of unusual or unknown sounds";
    elseif nRollValue == 16 then
        return "Compulsion to accumulate as many books or scrolls as possible";
    elseif nRollValue == 17 then
        return "Compulsion to accumulate as many jewels as possible";
    elseif nRollValue == 18 then
        return "Compulsion to collect rocks";
    else
        return "Compulsion to discover source of any odd odors";
    end
end

function getSuperstition(nRollValue)
    if not nRollValue then
        nRollValue = DiceManagerPO.getDieResult(20);
    end

    if nRollValue == 1 then
        return
            "Believes a certain color is unlucky (your GM will choose). Will not wear clothing of this color or enter structures painted this color. Will avoid animals of this color and those who wear this color.";
    elseif nRollValue == 2 then
        return
            "Believes a certain color is lucky (your GM will choose). Will only wear clothing of this color. Prefers animals of this color, those who wear this color and items of this color.";
    elseif nRollValue == 3 then
        return "Thinks the world is flat. He will avoid travelling in ocean-going vessels for fear of falling off.";
    elseif nRollValue == 4 then
        return
            "Thinks being near dead things is unlucky. Will avoid anything reminding him of death: cemeteries, graves, coffins, etc. Gets -2 to hit when encountering any undead.";
    elseif nRollValue == 5 then
        return
            "Believes haggling or price-shopping is unlucky. If this character buys something that has a reduced price for any reason, he will constantly worry about it breaking or being of inferior quality. Eventually he will discard the item in favor of one bought at full price or found.";
    elseif nRollValue == 6 then
        return
            "Has a lucky number ({1d20}). He will take insane risks on his lucky day. Performs 'rituals' using his number to gain luck.";
    elseif nRollValue == 7 then
        return
            "Believes he's lucky and anyone touching him will steal his luck. He will not lend or share items with others (such as rope, torches, weapon, etc.) The character will go ballistic if anyone touches any of his stuff.";
    elseif nRollValue == 8 then
        return
            "Believes a certain common animal is unlucky (GM will determine). This character will avoid contact with such an animal and will go so far as to leave the room or cross the street to get away from the animal's proximity";
    elseif nRollValue == 9 then
        return
            "Believes going left is unlucky. Will only take routes where it is assured he will not have to turn left. Believes left-handed people are evil. He will avoid taking a left turn in a dungeon.";
    elseif nRollValue == 10 then
        return
            "Doesn't believe in ghosts or undead of any type. If he sees one, he will attempt to disbelieve or ignore incorporeal spirits entirely. After defeating a corporeal undead, he will attempt to defraud it by pulling off its 'mask' or wiping away its 'makeup'.";
    elseif nRollValue == 11 then
        return
            "Believes Pixie Fairies are lucky, so he attempts to capture them to gain favors, refusing to release them unless they 'bless' him.";
    elseif nRollValue == 12 then
        return
            "Believes harm will befall him, his friends or his relatives if he steps on a crack. He will not step on a crack for any reason. His movement rate is cut in half if he is travelling over extremely cracked surfaces.";
    elseif nRollValue == 13 then
        return
            "Has an unlucky number ({1d20}). He will not venture forth on this day. He will avoid anyone with this number of letters in their name. Will avoid being in a room with this number of people.";
    elseif nRollValue == 14 then
        return
            "Believes he must make a donation to any cleric or church he passes. Failure will surely bring ill-luck down upon him and bring the particular god against him.";
    elseif nRollValue == 15 then
        return
            "Believes those in authority were chosen by the gods to be in their position. Will attempt to please and pander to anyone in authority he sees.";
    elseif nRollValue == 16 then
        return "Believes every time he hears a bell tinkling an angel gets its wings. Additionally, " ..
                   getSuperstition();
    elseif nRollValue == 17 then
        return "Believes adventuring with members of the opposite sex is bad luck. Will avoid this at all costs.";
    elseif nRollValue == 18 then
        return
            "Has a magic charm that he believes helps protect him. He will not do anything until he kisses the charm for good luck. If he loses it he will not be able to function until he finds a new lucky charm.";
    elseif nRollValue == 19 then
        return "Believes it's bad luck not to tip a beggar. Will always tip beggars in town.";
    else
        return getSuperstition(DiceManagerPO.getDieResult(19)) .. " Additionally, " ..
                   getSuperstition(DiceManagerPO.getDieResult(19));
    end
end

function getExtraPersonality()
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 5 then
        return "Young member of the opposite sex";
    elseif nRollValue < 9 then
        return "Elderly memgber of the opposite sex";
    elseif nRollValue < 13 then
        return "Young adult or middle-aged member of the opposite sex";
    elseif nRollValue < 17 then
        return "Young member of the same sex";
    elseif nRollValue < 21 then
        return "Elderly member of the same sex";
    elseif nRollValue < 25 then
        return "Young adult or middle-aged member of the same sex";
    elseif nRollValue < 29 then
        return "Extremely violent person";
    elseif nRollValue < 33 then
        return "Extremely cowardly person";
    elseif nRollValue < 37 then
        return "Extremely nasty person";
    elseif nRollValue < 41 then
        return "Noble";
    elseif nRollValue < 45 then
        return "Slave";
    elseif nRollValue < 49 then
        return "Beggar";
    elseif nRollValue < 53 then
        return "Royalty";
    elseif nRollValue < 57 then
        return "Dwarf";
    elseif nRollValue < 61 then
        return "Pixie Fairy";
    elseif nRollValue < 65 then
        return "Gnome Titan";
    elseif nRollValue < 69 then
        return "Elf";
    elseif nRollValue < 73 then
        return "Assassin";
    elseif nRollValue < 77 then
        return "Thief";
    elseif nRollValue < 81 then
        return "Extremely pious person";
    else
        return getExtraPersonality() .. " and " .. getExtraPersonality();
    end
end

function getMajorDelusion()
    local nRollValue = DiceManagerPO.getDieResult(10);
    if nRollValue == 1 then
        return "(Major Delusion) Character thinks he is an animal and behaves like one. Check with your GM.";
    elseif nRollValue == 2 then
        return "(Major Delusion) Character thinks he can fly, and often tries.";
    elseif nRollValue == 3 then
        return
            "(Major Delusion) Character thinks he is royalty and acts like it, ordering people around, perhaps trying to walk into a castle as if it were his own";
    elseif nRollValue == 4 then
        return
            "(Major Delusion) Character thinks he is in the middle of a battle when he is not. He attacks anyone that makes a quick movement or looks at him funny";
    elseif nRollValue == 5 then
        return
            "(Major Delusion) Character thinks his party members are monsters, screams and runs away, or tries to attack them";
    elseif nRollValue == 6 then
        return "(Major Delusion) Thinks scaled monsters are his friends and treats them as such";
    elseif nRollValue == 7 then
        return
            "(Major Delusion) Character thinks screaming will scare away monsters, so when he's in a dungeon, he screams loudly";
    elseif nRollValue == 8 then
        return
            "(Major Delusion) Character thinks he is invisible. He tries to pick pockets and do other things he thinks no one can see";
    elseif nRollValue == 9 then
        return "(Major Delusion) Character thinks he can walk on water, and often tries";
    else
        return "(Major Delusion) Character thinks he can tame monsters, and tries";
    end
end

function getMinorDelusion()
    local nRollValue = DiceManagerPO.getDieResult(10);
    if nRollValue == 1 then
        return "(Minor Delusion) Character thinks animals are people and often talks to them";
    elseif nRollValue == 2 then
        return "(Minor Delusion) Character thinks other people can fly and often asks them to";
    elseif nRollValue == 3 then
        return "(Minor Delusion) Thinks one of the party members is royalty and treats them as such";
    elseif nRollValue == 4 then
        return "(Minor Delusion) Character thinks he is a war hero and brags about accomplishments that aren't his";
    elseif nRollValue == 5 then
        return
            "(Minor Delusion) Character thinks bugs are crawling on himself and those around him so he swats at them and stomps on them";
    elseif nRollValue == 6 then
        return "(Minor Delusion) Character talks to an imaginary friend";
    elseif nRollValue == 7 then
        return "(Minor Delusion) Character thinsk a monster is following him and keeps whirling around to catch it";
    elseif nRollValue == 8 then
        return
            "(Minor Delusion) Character thinks his eyes are tricking him so he is constantly asking others what they see";
    elseif nRollValue == 9 then
        return "(Minor Delusion) Character thinks water is poisonous so he never bathes or drinks water";
    else
        return
            "(Minor Delusion) Character thinks he has a tame monster for a pet and acts as if his pet is real and present";
    end
end

function getMinorMentalQuirk() -- PHB Table 6F
    local sCategory = "Quirk, Minor (Mental): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 6 then
        return sCategory .. "Absent Minded";
    elseif nRollValue < 9 then
        return sCategory .. "Acrophobia (fear of heights)";
    elseif nRollValue < 12 then
        return sCategory .. "Agoraphobia (fear of open spaces)";
    elseif nRollValue < 18 then
        return sCategory .. "Alcoholic";
    elseif nRollValue < 23 then
        return sCategory .. "Animal Phobia (" .. getAnimalPhobia() .. ")";
    elseif nRollValue < 29 then
        return sCategory .. "Chronic Nightmares";
    elseif nRollValue < 33 then
        return sCategory .. "Claustrophobia (fear of closed spaces)";
    elseif nRollValue < 36 then
        return sCategory .. getDelusion();
    elseif nRollValue < 42 then
        return sCategory .. "Depression (Minor)";
    elseif nRollValue < 48 then
        return sCategory .. "Gambling Addiction";
    elseif nRollValue < 54 then
        return sCategory .. "Inappropriate Sense of Humor";
    elseif nRollValue < 57 then
        return sCategory .. "Kleptomaniac (compelled to steal)";
    elseif nRollValue < 60 then
        return sCategory .. "Obsessive Compulsive: " .. getObsessiveCompulsive();
    elseif nRollValue < 71 then
        return sCategory .. "Nagging Conscience";
    elseif nRollValue < 74 then
        return sCategory .. "Paranoid";
    elseif nRollValue < 80 then
        return sCategory .. "Short Term Memory Loss";
    elseif nRollValue < 83 then
        return sCategory .. "Superstitious (" .. getSuperstition() .. ")";
    elseif nRollValue < 91 then
        return sCategory .. "Temper";
    elseif nRollValue < 96 then
        return getMinorMentalQuirk() .. " and " .. getMajorMentalQuirk();
    else
        return getMinorMentalQuirk() .. " and " .. getMinorPersonalityQuirk();
    end
end

function getMajorMentalQuirk() -- PHB Table 6G
    local sCategory = "Quirk, Major (Mental): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 5 then
        return sCategory .. getDelusion(true);
    elseif nRollValue < 8 then
        return sCategory .. "Depression (Major)";
    elseif nRollValue < 14 then
        return sCategory .. "Enmity towards Class( " .. getRandomClass() .. ")";
    elseif nRollValue < 20 then
        return sCategory .. "Enmity towards Monster";
    elseif nRollValue < 26 then
        return sCategory .. "Enmity towards Race( " .. getRandomRace() .. ")";
    elseif nRollValue < 30 then
        return sCategory .. "HackFrenzy";
    elseif nRollValue < 34 then
        return sCategory .. "HackLust";
    elseif nRollValue < 42 then
        return sCategory .. "Psychotic Aversion to Class( " .. getRandomClass() .. ")";
    elseif nRollValue < 51 then
        return sCategory .. "Psychotic Aversion to Monster";
    elseif nRollValue < 59 then
        return sCategory .. "Psychotic Aversion to Race( " .. getRandomRace() .. ")";
    elseif nRollValue < 66 then
        return sCategory .. "Pyromaniac";
    elseif nRollValue < 73 then
        return sCategory .. "Sadistic";
    elseif nRollValue < 81 then
        return sCategory .. "Wuss-of-Heart";
    elseif nRollValue < 91 then
        return getMajorMentalQuirk() .. " and " .. getMinorMentalQuirk();
    else
        return getMajorMentalQuirk() .. " and " .. getMinorPersonalityQuirk();
    end
end

function getMinorPersonalityQuirk() -- PHB Table 6H
    local sCategory = "Quirk, Minor (Personality): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 9 then
        return sCategory .. "Chronic Liar";
    elseif nRollValue < 18 then
        return sCategory .. "Clingy";
    elseif nRollValue < 31 then
        return sCategory .. "Glutton";
    elseif nRollValue < 36 then
        return sCategory .. "Greedy";
    elseif nRollValue < 43 then
        return sCategory .. "Gullible";
    elseif nRollValue < 49 then
        return sCategory .. "Jerk";
    elseif nRollValue < 56 then
        return sCategory .. "Loud Boor";
    elseif nRollValue < 68 then
        return sCategory .. "Misguided";
    elseif nRollValue < 73 then
        return sCategory .. "Obnoxious";
    elseif nRollValue < 77 then
        return sCategory .. "Pack Rat";
    elseif nRollValue < 83 then
        return sCategory .. "Self Absorbed";
    elseif nRollValue < 89 then
        return sCategory .. "Socially Awkward";
    elseif nRollValue < 96 then
        return sCategory .. "Value Privacy (Reclusive)";
    else
        return getMinorPersonalityQuirk() .. " and " .. getMajorMentalQuirk();
    end
end

function getMajorPersonalityQuirk() -- PHB Table 6I
    local sCategory = "Quirk, Major (Personality): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 36 then
        return sCategory .. "Multiple Personalities";
    elseif nRollValue < 71 then
        return sCategory .. "Truthful";
    elseif nRollValue < 86 then
        return getMinorPersonalityQuirk() .. " and " .. getMinorPersonalityQuirk();
    else
        return getMajorMentalQuirk() .. " and " .. getMajorMentalQuirk();
    end
end

function getMinorPhysicalFlaw6b() -- PHB Table 6B
    local sCategory = "Flaws, Minor (Physical): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 10 then
        return sCategory .. "Albino";
    elseif nRollValue < 15 then
        return sCategory .. "Animal Antipathy (" .. getAnimalAntipathy() .. ")";
    elseif nRollValue < 24 then
        return sCategory .. "Anosmia (loss of the sense of taste)";
    elseif nRollValue < 27 then
        return sCategory .. "Asthmatic";
    elseif nRollValue < 36 then
        return sCategory .. "Color Blind";
    elseif nRollValue < 41 then
        return sCategory .. "Chronic Nose Bleeds";
    elseif nRollValue < 50 then
        return sCategory .. "Excessive Drooling";
    elseif nRollValue < 59 then
        return sCategory .. "Flatulent";
    elseif nRollValue < 62 then
        return sCategory .. "Hearing Impaired";
    elseif nRollValue < 71 then
        return sCategory .. "Lisp";
    elseif nRollValue < 86 then
        return getMinorPhysicalFlaw6b() .. " and " .. getMinorPhysicalFlaw6c();
    else
        return getMinorPhysicalFlaw6b() .. " and " .. getMinorPhysicalFlaw6d();
    end
end

function getMinorPhysicalFlaw6c(bAlreadyRolledHigh) -- PHB Table 6C
    local sCategory = "Flaws, Minor (Physical): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 8 then
        return sCategory .. "Loss of " .. getBodySide() .. " ear";
    elseif nRollValue < 14 then
        return sCategory .. "Loss of " .. getBodySide() .. " eye"
    elseif nRollValue < 22 then
        return sCategory .. "Male Pattern Baldness";
    elseif nRollValue < 27 then
        return sCategory .. "Migraines";
    elseif nRollValue < 35 then
        return sCategory .. "Missing Finger on " .. getBodySide() .. " hand";
    elseif nRollValue < 43 then
        return sCategory .. "Nervous Tic";
    elseif nRollValue < 48 then
        return sCategory .. "Facial Scar";
    elseif nRollValue < 55 then
        return sCategory .. "Sleep Chatter";
    elseif nRollValue < 62 then
        return sCategory .. "Sound Sleeper";
    elseif nRollValue < 71 then
        return sCategory .. "Strange Body Odor";
    elseif nRollValue < 86 then
        return getMinorPhysicalFlaw6c() .. " and " .. getMajorPhysicalFlaw();
    elseif bAlreadyRolledHigh then
        return getMinorPhysicalFlaw6c(true) .. " and " .. getMajorPhysicalFlaw();
    else
        return getMinorPhysicalFlaw6c(true) .. " and " .. getMinorPhysicalFlaw6c(true);
    end
end

function getMinorPhysicalFlaw6d() -- PHB Table 6D
    local sCategory = "Flaws, Minor (Physical): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 11 then
        return sCategory .. "Stutter";
    elseif nRollValue < 31 then
        return sCategory .. "Tone Deaf";
    elseif nRollValue < 46 then
        return sCategory .. "Vision Impaired (Far Sighted)";
    elseif nRollValue < 56 then
        return sCategory .. "Blind in " .. getBodySide() .. " eye";
    elseif nRollValue < 71 then
        return sCategory .. "Vision Impaired (Near Sighted)";
    elseif nRollValue < 91 then
        return getMinorPhysicalFlaw6b() .. " and " .. getMinorPhysicalFlaw6c();
    else
        return getMajorPhysicalFlaw();
    end
end

function getMajorPhysicalFlaw() -- PHB Table 6E
    local sCategory = "Flaws, Major (Physical): ";
    local nRollValue = DiceManagerPO.getDieResult(100);

    if nRollValue < 7 then
        return sCategory .. "Accident Prone";
    elseif nRollValue < 13 then
        return sCategory .. "Acute Allergies (" .. getAllergen() .. ")";
    elseif nRollValue < 18 then
        return sCategory .. "Amputee, " .. getBodySide() .. " arm";
    elseif nRollValue < 21 then
        return sCategory .. "Amputee, Double, Arm";
    elseif nRollValue < 24 then
        return sCategory .. "Amputee, Double, Leg";
    elseif nRollValue < 29 then
        return sCategory .. "Amputee, " .. getBodySide() .. " leg"
    elseif nRollValue < 32 then
        return sCategory .. "Blind";
    elseif nRollValue < 41 then
        return sCategory .. "Deaf";
    elseif nRollValue < 46 then
        return sCategory .. "Hemophiliac";
    elseif nRollValue < 51 then
        return sCategory .. "Low Threshold for Pain (LTP)";
    elseif nRollValue < 57 then
        return sCategory .. "Maimed: " .. getMaiming();
    elseif nRollValue < 63 then
        return sCategory .. "Mute";
    elseif nRollValue < 68 then
        return sCategory .. "Narcolepsy";
    elseif nRollValue < 74 then
        return sCategory .. "No Depth Perception";
    elseif nRollValue < 79 then
        return sCategory .. "Seizure, Disorders (Epilepsy)";
    elseif nRollValue < 85 then
        return sCategory .. "Sleep Walker";
    elseif nRollValue < 91 then
        return sCategory .. "Trick Knee";
    else
        return getMajorPhysicalFlaw() .. " and " .. getMinorPhysicalFlaw6b();
    end
end
