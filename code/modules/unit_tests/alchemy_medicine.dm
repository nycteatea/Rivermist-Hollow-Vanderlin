/datum/unit_test/health_potion_heals_moderate_toxin_damage
#ifdef FOCUS_ALCHEMY_MEDICINE_TEST
	focus = TRUE
#endif

/datum/unit_test/health_potion_heals_moderate_toxin_damage/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.adjustToxLoss(20, updating_health = FALSE, forced = TRUE)
	var/starting_tox = patient.getToxLoss()
	TEST_ASSERT(starting_tox > 0, "Test setup should give the patient toxin damage.")

	var/datum/reagent/medicine/healthpot/potion = allocate(/datum/reagent/medicine/healthpot)
	potion.volume = 5
	potion.on_mob_life(patient, 1)

	var/healed_tox = starting_tox - patient.getToxLoss()
	TEST_ASSERT(healed_tox >= 4, "Health potions should heal a moderate amount of toxin damage.")

/datum/unit_test/antidote_has_single_recipe_and_merchant_pack
#ifdef FOCUS_ALCHEMY_MEDICINE_TEST
	focus = TRUE
#endif

/datum/unit_test/antidote_has_single_recipe_and_merchant_pack/Run()
	var/antidote_recipe_count = 0
	for(var/recipe_type in subtypesof(/datum/alch_cauldron_recipe))
		var/datum/alch_cauldron_recipe/recipe = new recipe_type()
		if(recipe.output_reagents && recipe.output_reagents[/datum/reagent/medicine/antidote])
			antidote_recipe_count++
		qdel(recipe)

	TEST_ASSERT_EQUAL(antidote_recipe_count, 1, "Exactly one alchemy cauldron recipe should produce antidote.")

	var/antidote_pack_count = 0
	var/antidote_pack_type = text2path("/datum/supply_pack/tools/medical/antidote")
	for(var/datum/supply_pack/pack_type as anything in subtypesof(/datum/supply_pack))
		var/contains = initial(pack_type.contains)
		if(islist(contains))
			if(/obj/item/reagent_containers/glass/bottle/antidote in contains)
				antidote_pack_count++
		else if(contains == /obj/item/reagent_containers/glass/bottle/antidote)
			antidote_pack_count++

	TEST_ASSERT_EQUAL(antidote_pack_count, 1, "Exactly one merchant supply pack should sell bottled antidote.")
	TEST_ASSERT_NOTNULL(antidote_pack_type, "The antidote supply pack type should exist.")

	var/antidote_pack_listed = FALSE
	for(var/faction_type in subtypesof(/datum/world_faction))
		var/datum/world_faction/faction = new faction_type()
		if((antidote_pack_type in faction.essential_packs) || (antidote_pack_type in faction.common_pool) || (antidote_pack_type in faction.uncommon_pool) || (antidote_pack_type in faction.rare_pool) || (antidote_pack_type in faction.exotic_pool))
			antidote_pack_listed = TRUE
		qdel(faction)
		if(antidote_pack_listed)
			break

	TEST_ASSERT(antidote_pack_listed, "The antidote supply pack should be reachable from a world faction merchant pool.")
