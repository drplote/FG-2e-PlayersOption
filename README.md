# Player's Option rules for AD&D 2E
Hackmaster 4e ruleset for Fantasy Grounds

Extends the Fantasy Grounds 2e ruleset to support some of the rules from the "Player's Option" 2E books. Also includes some toggleable house rules that are similar to rules seen in Hackmaster 4th edition.

All rules are toggleable via Preferences, so you can pick and choose which of these you want.

## Player's Option Rules

The rules in this category either add automation for basic 2E rules, or adds rules for the 2E set of "Player's Option" books.

### Automate Weapon vs Armor Mods
This option automates the optional 2E rule that gives attack bonuses and penalties depending on the damage type of the weapon vs the armor type worn. These are the "Weapon Type vs Armor Modifiers" seen on Table 52 of the Revised 2E PHB. The 2E ruleset currently implements these as modifiers that you can select before you roll an attack. Toggling this option removes the need to do that manually as it will attempt to automate it by looking at the attacker's weapon and the target's armor. This option doesn't work if it can't determine those things (such as a generic NPC "orc" that might have an AC of 5 but doesn't actually have any worn armor in its inventory), or in the case where a weapon type can't be determined. If you actually equip armor on an NPC, it will use these modifiers, even though the actual creature's AC won't change due to the armor you equipped to it.

If an attacker's weapon does more than one damage type (such as a morningstar), it will assume the damage type most favorable to the attacker is hitting. If the defender is for some reason wearing more than one suit of armor, it will assume that the most favorable set of armor is being worn.

The damage type of the weapon is determined by looking at the text in the "damage" entries for the weapon. In particular, it is looking for the words "slashing", "piercing", or "bludgeoning", though with a small edit to the data file you could house-rule modifiers for damage types such as acid, lightning, etc.

The armor type is determined by doing a partial match on the armor's name. So if the armor your character has equipped is "Chain Mail", it will have no trouble matching this to the chain mail armor type. Likewise, it will have no problem with "+3 chain mail", "Chain mail +3", or even "Steve's Super Awesome Set of Chain Mail armor". As long as the words chain mail are there, it will be happy. If you typo it as "chian mail", you're out of luck. Likewise, if your armor is for some reason named "chain mail plate mail" or something else that would give two hits, the results are going to be kind of unpredictable. So don't do that.

Example #1: Joe the 1st level Fighter swings his Longsword at an orc. The GM pulled this orc straight out of the Monster Manual, so the NPC record for the orc doesn't have any equipped armor in its inventory. Joe's attack roll is normal. 

Example #2: This time, the GM decides that the orc probably has an AC of 6 because it's wearing chain mail. He copies the NPC record "orc" from the Monster Manual, drags some chain mail to its inventory, and equips it. This doesn't actually have an effect on the orc's AC, because the 2E ruleset currently doesn't support that. However, now when Joe the 1st level Fighter attacks the orc with his longsword, he gets a -2 to his attack roll because chain mail is more effective against slashing weapons.

## Sterno's House Rules

Originally, I set out to write a ruleset for Hackmaster 4e. After doing a lot of work on it, I decided I didnt really want to play Hackmaster 4e. I wanted to play AD&D 2e with just a few of the HM4 rules cherry-picked from it. Here they are!

### HP Kickers

All NPCs of size Small or larger receive a 20 hit point "kicker". Creatures that are Tiny receive a 10 hit point kicker. Creatures with 0 HD, regardless of size, receive no kicker. This only applies to creatures that need to roll hit points, and will apply upon them being added to the combat tracker. If their hit points are set to a fixed value, the kicker will not be added.

Example #1: The GM creates a special NPC orc chieftain who he decides has 32 hit points, and sets its "Hit Points" field to 32 when he creates a record for it. Upon adding it to the combat tracker, it will have 32 hit points, as he specified.

Example #2: The GM creates some orc lieutenants that he wants to have 3 HD, but doesn't specify their hit points. Upon dragging them to the combat tracker, they'll be generated with 20+3d8 hit points.

Example #3: The GM creates a custom dire rat that is size "Tiny", but has 2 HD. Upon being added to the combat tracker, it will have 10+2d8 hit points.

Example #4: The GM adds a standard "Giant Rat" from the Monster Manual to the combat tracker. It is size Tiny, but it is also 0 HD, which means it gets no kicker and is generated with it's standard 1d4 hp.

Note: This is only implemented for NPCs. If you want the PCs to get a kicker, you'll have to edit their hit point total manually.

### Penetration Dice

Hackmaster had a concept of penetration dice, where if you roll the maximum on a damage or healing roll, you'd roll again, add the result, and subtract 1. If that die was maximum, you'd roll it again, subtract 1 again, and so on. This option pairs well with the "HP Kickers" house rule. It's pretty lethal without that house rule.

Dice that penetrate will show up in the chat window roll as blue, and the extra dice rolled will show up as red (unless they too penetrate, and then they'll show up as blue). When the extra dice appear in the chat window, they'll already have had 1 subtracted from their roll (so it will be showing their modified value, not their "rolled" value). You really shouldn't need to worry about, as the total will be right, but I've noticed a lot of people questioning whether or not the -1 was actually occurring correctly when penetration dice are involved in VTTs.

You can manually roll penetrate die by typing /pen or /diep, followed by the dice you want to roll. For example, "/pen 4d8". 

Example #1: Joe the fighter swings at an ogre with his longsword and hits. He rolls 1d8 for damage and rolls an 8. Rolling again, he gets another 8. Rolling again, he gets a 5. The damage total would be 8 + (8-1) + (5-1) = 19. Not bad!

Example #2: Joe the fighter swings at the ogre again, hoping to finish it off. He rolls 1d8 for damage, rolls an 8 again, and starts thinking how nice it would be to have another hit like in example #1. Rolling again, however, he rolls a 1, and his celebration is cut short. His total damage is 8 + 0. His celebration is cut short as he doesn't actually get any bonus damage.

### Armor Damage (disabled: completed in my HM ruleset, not fully working in this extension yet)

Hackmaster 4th edition had system of armor damage that was more complicated than the one from the 2E Fighter's Handbook that's currently coded into the 2E ruleset. In the Hackmaster ruleset, armor damage is "staged" and after armor receives a certain amount of damage, it drops one AC level of effectiveness. It continues dropping in levels as it takes damage until it is eventually destroyed. Armor takes 1 (or possibly more, for some armors) point of damage for every die of damage rolled against it. It also soaks that much of the hit, preventing some of the damage from reaching the player.

This system works for PCs or for NPCs who have armor in their inventory an equipped. For PCs, everything works perfectly. For NPCs, since they currently aren't coded to base their AC off what's worn, if you equip armor to an NPC, it will properly track damage on the armor (useful if the players want to loot it later) and soak some damage from the hits as usual. However, the NPC's actual AC won't change as the armor degrades. I hope to add that as future improvement.

There are some special rules around how and when armor takes damage. If armor is magical, it will only take damage from weapon's or equal or higher magical bonus, or from magical damage. For instance, a +1 weapon cannot hurt +2 armor, but a fireball can.

Note: Using this optional rule requires setting up the armor records with information about how the armor should degrade.

Example #1: Joe the fighter is wearing some Chain Mail that has (8,6,4,2,1) for its Armor Regression. This means a brand new suit starts at AC 5, but once it taakes 8 points of damage it drops to AC 6. After 6 more points it drops to AC 7, 4 more to AC 8, 2 more to AC 9, and 1 more destroys it and drops it to AC 10. During a previous battle, he took 6 points of damage, which means it's a little beat up but is still giving him AC 5. And orc swings a morningstar at him and hits, rolling 2d4 for damage and getting a total of 5. Since two dice were rolled for damage, 2 points of that go to Joe's armor, while the remaining 3 points are deduced from Joe's hit points. Additionally, since that just brought his chain mail's total damage up to 8, matching it's first regression threshold, it drops one level of AC to AC 6.

Example #2: Joe the fighter has adventured more and found a +3 suit of Leather Armor. It doesn't have many hit points... the regression for leather armor is 2,1, but since it's magical, each + has the same hp as it's best AC level, so in this case it's 2,2,2,2,1. Another orc with a morningstar steps up and hits Joe for 2d4 damage, rolling a 7. 2 points of this are soaked by the armor, and the remaining 5 points are deduced from Joe's hit points. However, despite soaking 2 points of damage, the armor receives no damage because it is +3 and the morningstar was non-magical. A +3 weapon or better would have been needed to hurt it.

Example #3: The 10th level magic-user in Joe's party lets loose with a fireball a little too close to Joe in his undamaged +3 Leather Armor, and Joe is caught in the blast. The magic user's fireball does 10d6 damage, totally 31 points. Despite being magical, Joe's armor takes damage from this! It's hp regression is 2,2,2,2,1. Despite 10 damage dice being rolled, the armor can only soak 9 points of the damage before it is destroyed. Joe's leather armor is destroyed, Joe takes 22 damage to his hit points, and is now very pissed at the mage.

### Shield Damage (disabled: completed in my HM ruleset, not fully working in this extension yet)
Hackmaster 4th edition had the concept of shield hits and shield damage. The damage portion worked somewhat similar to the armor damage house rule, except that instead of soaking 1 point of damage per die, shields soak full damage. However, this only comes into play when a shield hit occurs. A shield hit occurs whenever a player is only missed because of their AC bonus from a shield. If so, the attacker rolls damage normally, but all the damage is first applied to the shield directly. If the shield is destroyed, any remaining damage is applied to the player.

For this rule to be worth the trouble, it is recommended you give shield a higher AC bonus. For example, in Hackmaster 4th edition, a Medium shield gave +3 AC, compared to just a +1 in 2E. A medium shield had a regression of 5,4,3, meaning it would drop by 1 AC after the first 5 points of damage, drop another AC with 4 more points of damage, and finally be destroyed after 3 more. Like magic armor, a magical shield only takes damage if the attack hitting it is an equal or higher magical equivalent (or if it's used to block magical damage, such as hiding behind a body shield to get protection from a dragon's breath).