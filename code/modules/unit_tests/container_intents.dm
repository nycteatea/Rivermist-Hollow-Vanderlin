/datum/unit_test/reagent_glass_defaults_to_feed_when_held
#ifdef FOCUS_CONTAINER_INTENT_TEST
	focus = TRUE
#endif

/datum/unit_test/reagent_glass_defaults_to_feed_when_held/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	TEST_ASSERT(user.possible_a_intents.len >= 3, "Test user should have enough unarmed intents to select slot 3.")

	user.rog_intent_change(3)
	TEST_ASSERT_EQUAL(user.r_index, 3, "Test setup should save slot 3 for the active hand.")

	var/obj/item/reagent_containers/glass/bottle/bottle = allocate(/obj/item/reagent_containers/glass/bottle)
	TEST_ASSERT(user.put_in_active_hand(bottle, forced = TRUE), "Test user should be able to hold the bottle.")

	var/splash_available = FALSE
	for(var/datum/intent/intent as anything in user.possible_a_intents)
		if(intent.type == INTENT_SPLASH)
			splash_available = TRUE
			break

	TEST_ASSERT_NOTNULL(user.a_intent, "Holding a bottle should select an active item intent.")
	TEST_ASSERT_EQUAL(user.a_intent.type, INTENT_POUR, "Glass reagent containers should default to feed when first held.")
	TEST_ASSERT(splash_available, "Glass reagent containers should keep splash as an available intent.")
	TEST_ASSERT_NOTNULL(user.used_intent, "Holding a bottle should update the used intent.")
	TEST_ASSERT_EQUAL(user.used_intent.type, INTENT_POUR, "The used intent should match the feed default.")
