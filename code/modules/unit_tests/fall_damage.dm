/datum/unit_test/minor_fall_damage_immunity_cancels_human_two_level_fall
#ifdef FOCUS_FALL_DAMAGE_TEST
	focus = TRUE
#endif

/datum/unit_test/minor_fall_damage_immunity_cancels_human_two_level_fall/Run()
	var/mob/living/carbon/human/faller = allocate(/mob/living/carbon/human)
	var/turf/impact_turf = get_step(run_loc_floor_bottom_left, EAST)
	TEST_ASSERT_NOTNULL(impact_turf, "Test map should have an adjacent impact turf.")

	ADD_TRAIT(faller, TRAIT_NOFALLDAMAGE1, TRAIT_GENERIC)

	var/impact_flags = faller.ZImpactDamage(impact_turf, 2)

	TEST_ASSERT(impact_flags & ZIMPACT_CANCEL_DAMAGE, "Minor fall immunity should cancel human fall damage for a two-level fall.")
	TEST_ASSERT_EQUAL(faller.getBruteLoss(), 0, "Minor fall immunity should prevent human brute damage from a two-level fall.")

/datum/unit_test/minor_fall_damage_immunity_allows_human_three_level_fall_damage
#ifdef FOCUS_FALL_DAMAGE_TEST
	focus = TRUE
#endif

/datum/unit_test/minor_fall_damage_immunity_allows_human_three_level_fall_damage/Run()
	var/mob/living/carbon/human/faller = allocate(/mob/living/carbon/human)
	var/turf/impact_turf = get_step(run_loc_floor_bottom_left, EAST)
	TEST_ASSERT_NOTNULL(impact_turf, "Test map should have an adjacent impact turf.")

	ADD_TRAIT(faller, TRAIT_NOFALLDAMAGE1, TRAIT_GENERIC)

	var/impact_flags = faller.ZImpactDamage(impact_turf, 3)

	TEST_ASSERT(!(impact_flags & ZIMPACT_CANCEL_DAMAGE), "Minor fall immunity should not cancel human fall damage past two levels.")
