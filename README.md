# Player's Option rules for AD&D 2E

Extends the Fantasy Grounds 2e ruleset to support some of the rules from the "Player's Option" 2E books. Also includes some toggleable house rules that are similar to rules seen in Hackmaster 4th edition.

All rules are toggleable via Preferences, so you can pick and choose which of these you want. They are split up in preferences under different headers. Note that in some cases (such as with critical hits), enabling these options might ignore other options you have selected from base 2E ruleset preferences.

## A note on customization

If you know your way around unpacking and repacking extensions, take a look at scripts/"data_common_po.lua". I tried to pull all hardcoded data (such as default race sizes, weapon types, crit tables, etc) there. 

## Player's Option Rules

The rules in this add rules for the 2E set of "Player's Option" books.

This area is still in heavy development and more options are planned, including a the C&T initiative system, spell crits, and fatigue.

### Combat & Tactics Critical Hits

Enabling this option will use the crit tables from Player's Option: Combat & Tactics. This will override whatever crit settings you specified in the core ruleset's preferences for critical hits. The toggle options include:

* Off - This option won't be used, and whatever you had set up in the base ruleset for crits will be used as normal.
* 18+, hit by 5 - This is how C&T crits are determined by rules as written. If a natural 18 or better is rolled, and the target is hit by at least 5, a crit occurs.
* As base, hit by 5 - Same as above, except now you need a nat 20 instead of an 18 or better (or less than a nat 20 if the weapon has a crit threshold defined as in the base ruleset).
* As base ruleset - Crits occur on a natural 20 (or less, if a crit threshold is defined on the weapon, as per the base ruleset), regardless of if that would have hit, or by how much.

Right now, when a crit is detected, a crit result is generated per the C&T tables and reported as text. Eventually I plan to add more automation to the crit effects, but right now other than displaying the crit effect message as part of the attack roll output, the only part that's automated is that when you roll damage, it will be either x2 or x3 damage dice, as per the C&T rules, and will roll a death save for you (which has no actual automation effect... it just saves you from doing it manually). Note that the following pieces of information are needed to generate a crit result, and in some cases I had to make assumptions:

#### Creature Type:
This is needed to determine which crit table to roll on for the target. Currently, this pulls from the monster's "type" entry looking for the words "humanoid", "animal", or "monster". Note that nothing in the Monster Manual actually has the type of "monster"... I end up using this as the default if "humanoid" or "animal" isn't found. It isn't perfect though... say you critically hit a skeleton. It's not type "humanoid" in the Monster Manual, as it's undead... however, it definitely seems like it should roll on the "humanoid" table and not the "monster" table (where things like having a tail are assumed). I've create two tables, "aDefaultCreatureTypesByName" and "aDefaultCreatureTypesByType, in "data_common_po.lua", which you could edit to add monster names and the creature type you'd like them to be treated as for crits. I do plan to go through and add many monsters from the MM that might need correction (skeleton is already done!), but right now you might get some creatures treated as "monster" when you think they'd better fit into another category. Sorry! If you'd like to volunteer some time and provide some mappings for me, I'll be sure to add them to the extension! Currently the only mappings are the name "skeleton" to type humanoid, and the type "giant" to type "humanoid".

#### Creature Size:
Target creature size is needed to determine critical hit severity. This is parsed from the "size" entry in the pc or npc's record. If no valid value is found (because it's empty, or gibberish), it will default to medium for NPCs, or default to a size based on the selected race of a PC (or, if that still fails becasue it's a race that isn't recognized from the PHB, medium for a PC).

#### Weapon Type:
The damage type of the weapon is needed to determine which crit table to roll on. I try to determine the damage type of the weapon by looking at all of the possible damage types on the action that was used to roll the attack. If, for example, you attack with a morningstar from the PHB, this will look at the damage entries and see that it has bludgeoning and piercing damage. If multiple damage types (of the bludgeoning, piercing, and slashing types) are found, it will randomly select one to roll the critical hit against. If none of those damage types are found (because they weren't set, or maybe the weapon only does fire damage) no critical hit will be rolled. 

**A planned near-future improvement is to allow this to be specified in the "properties" section of a weapon item, and it will look there first before digging into the damage entries.**

#### Weapon Size:
Weapon size is needed to determine critical hit severity. Since this isn't currently recorded in the base 2E ruleset, it will first try to look at the "properties" field on the attack action for text in the format "Size: s", where "s" could be "Tiny, Small, Medium, Large, Huge, Gargantuan" (or just the first letter of those). If it sees nothing recognizable there, it will look for an item in the creature's inventory that the attack action may have come from, and if it finds one, looks at the properties of that weapon in the same manner.

Failing all that (which will fail, if you haven't specifically entered values yourself for those actions or items), I need to make a best guess. Here's how I do it:

I've created a table, "aDefaultWeaponSizes", in data_common_po.lua for this that matches weapon name to size. It covers all the PHB weapons and does a loose text match, such that an entry of "long sword" would match "long sword +1", "+2 long sword", "bob's fancy silver long sword", etc. If you created some brand weapon item, though, I have no idea what size it is, so as a guess I just treat it as the same size as the attacking character. I figure chances are good a halfling with an unknown weapon has a small weapon, a human with an unknown weapon has a medium weapon, an ogre with an unknown weapon has a large weapon, etc. This also goes for the attacks of a lot of stock NPCs from the Monster Manual. For example, an orc has an attack called "Attack". Since that doesn't match any PHB weapon, I just assume the weapon size is the same as the orc... Medium.

One exception is if an attack is named "claw", "bite", "kick", "punch", "slam", or "tail". In that case, I assume it's a natural attack of the creature and treat it as two size categories smaller than the creature. So a medium creature's claw attack would be a tiny weapon. A large creature's claw attack would be small (claw the size of daggers!). The Combat & Tactics rules didn't give any guidance on what size natural attacks should be, but this felt about right to me. If you have other ideas on how to size these or other keywords that should be included for natural attacks, please let me know!


## Automation Improvements

### Automate Weapon vs Armor Mods
This option automates the optional 2E rule that gives attack bonuses and penalties depending on the damage type of the weapon vs the armor type worn. These are the "Weapon Type vs Armor Modifiers" seen on Table 52 of the Revised 2E PHB. The 2E ruleset currently implements these as modifiers that you can select before you roll an attack. Toggling this option removes the need to do that manually as it will attempt to automate it by looking at the attacker's weapon and the target's armor. This option doesn't work if it can't determine those things (such as a generic NPC "orc" that might have an AC of 5 but doesn't actually have any worn armor in its inventory), or in the case where a weapon type can't be determined. If you actually equip armor on an NPC, it will use these modifiers, even though the actual creature's AC won't change due to the armor you equipped to it.

If an attacker's weapon does more than one damage type (such as a morningstar), it will assume the damage type most favorable to the attacker is hitting. If the defender is for some reason wearing more than one suit of armor, it will assume that the most favorable set of armor is being worn.

#### Weapon Type Determination

I try to determine the damage type of the weapon by looking at all of the possible damage types on the action that was used to roll the attack. If, for example, you attack with a morningstar from the PHB, this will look at the damage entries and see that it has bludgeoning and piercing damage. It is looking for the keywords "slashing", "bludgeoning", and "piercing". With edits to data_common_po.lua, however, you could easily add modifiers against more damage types if you wished, such as fire or acid.

**A planned near-future improvement is to allow this to be specified in the "properties" section of a weapon item, and it will look there first before digging into the damage entries.**

#### Armor Type Determination

The armor type is determined by doing a partial match on the armor's name. So if the armor your character has equipped is "Chain Mail", it will have no trouble matching this to the chain mail armor type. Likewise, it will have no problem with "+3 chain mail", "Chain mail +3", or even "Steve's Super Awesome Set of Chain Mail armor". As long as the words chain mail are there, it will be happy. If you typo it as "chian mail", you're out of luck. Likewise, if your armor is for some reason named "chain mail plate mail" or something else that would give two hits, the results are going to be kind of unpredictable. So don't do that.

Example #1: Joe the 1st level Fighter swings his Longsword at an orc. The GM pulled this orc straight out of the Monster Manual, so the NPC record for the orc doesn't have any equipped armor in its inventory. Joe's attack roll is normal. 

Example #2: This time, the GM decides that the orc probably has an AC of 6 because it's wearing chain mail. He copies the NPC record "orc" from the Monster Manual, drags some chain mail to its inventory, and equips it. This doesn't actually have an effect on the orc's AC, because the 2E ruleset currently doesn't support that. However, now when Joe the 1st level Fighter attacks the orc with his longsword, he gets a -2 to his attack roll because chain mail is more effective against slashing weapons.

**A planned near-future improvement is to allow you to specify these modifiers in the "properties" section of the armor item.**

### Stricter Resistance Rules
In the current implementation of the 2E ruleset, if a creature (such as a skeleton) resists slashing and piercing damage, they'll take half damage from any slashing or piercing attack... even if other damage types are involved. So, for instance, if a cleric bashes the skeleton with a morningstar, which is a bludgeoning/piercing weapon, the skeleton will only take half damage. I believe the intent in AD&D was that the most favorable damage type to the attacker was used when multiple damage types are involved. Enabling this option would require the target to resist all damage types of the attack to take half damage, not just one of them. A side effect of this that you may or may not like is that if you made a magical flaming longsword that does "slashing, fire" damage, the skeleton wouldn't resist any because while it resists slashing, it doesn't resist fire. You might disagree with me that it should work this way, and that's cool! That's why all these options are toggleable!

### Generate Hit Locations

Toggling this option on simply adds some text in the chat window during a hit to indicate where the attacker hit. It has no real effect other than adding some additional flavor to combat. It determines the hit location using the same rules as critical hit location from the Player's Option: Combat & Tactics book. Note that this option being off doesn't effect critical hits; those are required for the Player's Option critical hits to work and generate a hit location even if this option is diabled.

### Set Unrolled PC Init to 99

Normally when a new round starts, players get a random initiative roll, which they then almost always just reroll anyway. I prefer to have it set them to a 99 initiative so that it's clearer they haven't rolled for their specific action yet. NPCs still use the default behavior of the 2e ruleset.

## Hackmaster-style House Rules

Originally, I set out to write a ruleset for Hackmaster 4e. After doing a lot of work on it, I decided I didnt really want to play Hackmaster 4e. I wanted to play AD&D 2e with just a few of the HM4 rules cherry-picked from it. Here they are!

### HP Kickers

All NPCs of size Small or larger receive a 20 hit point "kicker". Creatures that are Tiny receive a 10 hit point kicker. Creatures with 0 HD, regardless of size, receive no kicker. This only applies to creatures that need to roll hit points, and will apply upon them being added to the combat tracker. If their hit points are set to a fixed value, the kicker will not be added.

Example #1: The GM creates a special NPC orc chieftain who he decides has 32 hit points, and sets its "Hit Points" field to 32 when he creates a record for it. Upon adding it to the combat tracker, it will have 32 hit points, as he specified.

Example #2: The GM creates some orc lieutenants that he wants to have 3 HD, but doesn't specify their hit points. Upon dragging them to the combat tracker, they'll be generated with 20+3d8 hit points.

Example #3: The GM creates a custom dire rat that is size "Tiny", but has 2 HD. Upon being added to the combat tracker, it will have 10+2d8 hit points.

Example #4: The GM adds a standard "Giant Rat" from the Monster Manual to the combat tracker. It is size Tiny, but it is also 0 HD, which means it gets no kicker and is generated with it's standard 1d4 hp.

Note: This is only implemented for NPCs. If you want the PCs to get a kicker, you'll have to edit their hit point total manually.

**A planned near-future improvement is additional options to make the kicker sized-based.**

### Penetration Dice

Hackmaster had a concept of penetration dice, where if you roll the maximum on a damage or healing roll, you'd roll again, add the result, and subtract 1. If that die was maximum, you'd roll it again, subtract 1 again, and so on. This option pairs well with the "HP Kickers" house rule. It's pretty lethal without that house rule.

Dice that penetrate will show up in the chat window roll as blue, and the extra dice rolled will show up as red (unless they too penetrate, and then they'll show up as blue). When the extra dice appear in the chat window, they'll already have had 1 subtracted from their roll (so it will be showing their modified value, not their "rolled" value). You really shouldn't need to worry about, as the total will be right, but I've noticed a lot of people questioning whether or not the -1 was actually occurring correctly when penetration dice are involved in VTTs.

You can manually roll penetrate die by typing /pen or /diep, followed by the dice you want to roll. For example, "/pen 4d8". 

Example #1: Joe the fighter swings at an ogre with his longsword and hits. He rolls 1d8 for damage and rolls an 8. Rolling again, he gets another 8. Rolling again, he gets a 5. The damage total would be 8 + (8-1) + (5-1) = 19. Not bad!

Example #2: Joe the fighter swings at the ogre again, hoping to finish it off. He rolls 1d8 for damage, rolls an 8 again, and starts thinking how nice it would be to have another hit like in example #1. Rolling again, however, he rolls a 1, and his celebration is cut short. His total damage is 8 + 0. His celebration is cut short as he doesn't actually get any bonus damage.

### Armor Damage 

Hackmaster 4th edition had system of armor damage that was more complicated than the one from the 2E Fighter's Handbook that's currently coded into the 2E ruleset. In the Hackmaster ruleset, armor damage is "staged" and after armor receives a certain amount of damage, it drops one AC level of effectiveness. It continues dropping in levels as it takes damage until it is eventually destroyed. Armor takes 1 (or possibly more, for some armors) point of damage for every die of damage rolled against it. It also soaks that much of the hit, preventing some of the damage from reaching the player.

This system works for PCs or for NPCs who have armor in their inventory an equipped. For PCs, everything works perfectly. For NPCs, since they currently aren't coded to base their AC off what's worn, if you equip armor to an NPC, it will properly track damage on the armor (useful if the players want to loot it later) and soak some damage from the hits as usual. However, the NPC's actual AC won't change as the armor degrades. I hope to add that as future improvement.

There are some special rules around how and when armor takes damage. If armor is magical, it will only take damage from weapon's or equal or higher magical bonus, or from magical damage. For instance, a +1 weapon cannot hurt +2 armor, but a fireball can.

Note: Using this optional rule requires setting up the armor records with information about how the armor should degrade, though I did include default values for all of the armor whose names match those in the AD&D 2E PHB.

You can specify how much damage the armor should soak per damage die by entering "DR: n" in the armor's "Properties" text area, where n is the amount to soak per die. If not provided, it defaults to 1. 

You can specify how many hit points the armor has at each level of protection by entering "HP: `[n1, n2, n3, n4, etc]`" in the "Properties" text area, where n1 is the amount of damage the armor takes before it drops its first point of AC, n2 is the amount it takes before dropping the 2nd point of AC, etc.

Example #1: Joe the fighter is wearing some Chain Mail that has (8,6,4,2,1) for its Armor Regression. This means a brand new suit starts at AC 5, but once it taakes 8 points of damage it drops to AC 6. After 6 more points it drops to AC 7, 4 more to AC 8, 2 more to AC 9, and 1 more destroys it and drops it to AC 10. During a previous battle, he took 6 points of damage, which means it's a little beat up but is still giving him AC 5. And orc swings a morningstar at him and hits, rolling 2d4 for damage and getting a total of 5. Since two dice were rolled for damage, 2 points of that go to Joe's armor, while the remaining 3 points are deduced from Joe's hit points. Additionally, since that just brought his chain mail's total damage up to 8, matching it's first regression threshold, it drops one level of AC to AC 6.

Example #2: Joe the fighter has adventured more and found a +3 suit of Leather Armor. It doesn't have many hit points... the regression for leather armor is 2,1, but since it's magical, each + has the same hp as it's best AC level, so in this case it's 2,2,2,2,1. Another orc with a morningstar steps up and hits Joe for 2d4 damage, rolling a 7. 2 points of this are soaked by the armor, and the remaining 5 points are deduced from Joe's hit points. However, despite soaking 2 points of damage, the armor receives no damage because it is +3 and the morningstar was non-magical. A +3 weapon or better would have been needed to hurt it.

Example #3: The 10th level magic-user in Joe's party lets loose with a fireball a little too close to Joe in his undamaged +3 Leather Armor, and Joe is caught in the blast. The magic user's fireball does 10d6 damage, totally 31 points. Despite being magical, Joe's armor takes damage from this! It's hp regression is 2,2,2,2,1. Despite 10 damage dice being rolled, the armor can only soak 9 points of the damage before it is destroyed. Joe's leather armor is destroyed, Joe takes 22 damage to his hit points, and is now very pissed at the mage.

### Shield Hits & Damage 
Hackmaster 4th edition had the concept of shield hits and shield damage. The damage portion worked somewhat similar to the armor damage house rule, except that instead of soaking 1 point of damage per die, shields soak full damage. However, this only comes into play when a shield hit occurs. A shield hit occurs whenever a player is only missed because of their AC bonus from a shield. If so, the attacker rolls damage normally, but all the damage is first applied to the shield directly. If the shield is destroyed, any remaining damage is applied to the player.

For this rule to be worth the trouble, it is recommended you give shield a higher AC bonus. For example, in Hackmaster 4th edition, a Medium shield gave +3 AC, compared to just a +1 in 2E. A medium shield had a regression of 5,4,3, meaning it would drop by 1 AC after the first 5 points of damage, drop another AC with 4 more points of damage, and finally be destroyed after 3 more. Like magic armor, a magical shield only takes damage if the attack hitting it is an equal or higher magical equivalent (or if it's used to block magical damage, such as hiding behind a body shield to get protection from a dragon's breath).

You can specify a shield's hit points the same way as for armor above. If you haven't specified it yourself, it assumes you're using AD&D 2e PHB shields, which only provide 1 AC, and gives them the same number of hit points for that 1 AC that would have been spread out amongst all the levels for a Hackmaster shield. For instance, in Hackmaster a Medium Shield gives +3 AC and has HP of `[5,4,3]`. In 2e, it gives +1 AC, so I defaulted it to act like it has HP: `[12]`.

### Hackmaster Stat Scaling

This options toggles between using the 2E attribute bonuses and the Hackmaster attribute bonuses (to-hit modifiers, damage modifiers, reaction adjustments, etc). It also has the side effect of enabling the Hackmaster/1e style rules for armor bulk affecting movement, though this only comes up if you actually put a "Bulk: b" entry in the armor's "Properties" text field, where valid values of b are "non", "fairly", and "bulky". Should default to non if no bulk is provided, effectively ignoring this rule.

### Reaction Adjustment Affects Init

This option applies the Dexterity Reaction Adjustment value to any rolled initiative. I've noticed that you might have to toggle this with the character sheet open for it to update properly when you enable or disable the option. Be aware of it though I hope to fix that issue in the future.

### Threshold of Pain

Automates the Hackmaster threshold of pain check, which occurs when someone has taken half of their maximum hit points of damage in a single hit. Automatically rolls a saving throw vs death (with Magical Defense Adjustment from Wisdom) and applies unconsciousness for a duration in rounds equal to the amount you fail the roll by. Currently kind of annoying since you could be knocking skeletons and other things out that TOP shouldn't apply to, so a future plan is to add in another option which does the roll but doesn't apply unconsciousness (you can do it manually), and also create a way to specify that a character or NPC should be immune to TOP checks.
