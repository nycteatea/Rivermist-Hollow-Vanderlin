/datum/unit_test/body_storage_destroy_clears_organ_and_owner_refs
#ifdef FOCUS_GC_RUNTIME_REGRESSION_TEST
	focus = TRUE
#endif

/datum/unit_test/body_storage_destroy_clears_organ_and_owner_refs/Run()
	var/mob/living/carbon/human/organ_owner = allocate(/mob/living/carbon/human)
	var/obj/item/organ/genitals/penis/penis = allocate(/obj/item/organ/genitals/penis)

	TEST_ASSERT(penis.Insert(organ_owner), "Penis organ should insert into the test owner.")
	var/datum/component/body_storage/penis/storage = penis.GetComponent(/datum/component/body_storage/penis)
	TEST_ASSERT_NOTNULL(storage, "Inserted penis should have body storage.")

	qdel(penis)

	TEST_ASSERT(QDELETED(penis), "Penis organ should be qdeleted.")
	TEST_ASSERT_NULL(storage.organ_storing, "Body storage should not keep a strong reference to its qdeleted organ.")
	TEST_ASSERT_NULL(storage.owner, "Body storage should not keep a strong reference to the organ owner after deletion.")

/datum/unit_test/split_personality_backseat_destroy_clears_trauma_ref
#ifdef FOCUS_GC_RUNTIME_REGRESSION_TEST
	focus = TRUE
#endif

/datum/unit_test/split_personality_backseat_destroy_clears_trauma_ref/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/datum/brain_trauma/severe/split_personality/trauma = allocate(/datum/brain_trauma/severe/split_personality)
	var/mob/living/split_personality/backseat = allocate(/mob/living/split_personality, body, trauma)

	TEST_ASSERT_EQUAL(backseat.trauma, trauma, "Split personality backseat should keep the trauma reference before deletion.")
	TEST_ASSERT_EQUAL(backseat.body, body, "Split personality backseat should keep the body reference before deletion.")

	qdel(backseat)

	TEST_ASSERT(QDELETED(backseat), "Split personality backseat should be qdeleted.")
	TEST_ASSERT_NULL(backseat.trauma, "Split personality backseat should clear its trauma reference when deleted.")
	TEST_ASSERT_NULL(backseat.body, "Split personality backseat should clear its body reference when deleted.")

/datum/unit_test/minotaur_ground_slam_skips_targets_deleted_by_damage
#ifdef FOCUS_GC_RUNTIME_REGRESSION_TEST
	focus = TRUE
#endif

/mob/living/simple_animal/hostile/retaliate/unit_test_shockwave_deleted_victim
	name = "unit test shockwave victim"
	health = 1
	maxHealth = 1

/mob/living/simple_animal/hostile/retaliate/unit_test_shockwave_deleted_victim/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, damage_type, true_heal = FALSE)
	. = ..()
	qdel(src)

/datum/unit_test/minotaur_ground_slam_skips_targets_deleted_by_damage/Run()
	var/mob/living/simple_animal/hostile/retaliate/minotaur/boss = allocate(/mob/living/simple_animal/hostile/retaliate/minotaur)
	var/turf/victim_turf = get_step(get_turf(boss), EAST)
	TEST_ASSERT_NOTNULL(victim_turf, "Test map should have an adjacent turf for the shockwave victim.")
	var/mob/living/simple_animal/hostile/retaliate/unit_test_shockwave_deleted_victim/victim = allocate(/mob/living/simple_animal/hostile/retaliate/unit_test_shockwave_deleted_victim, victim_turf)
	var/datum/ai_controller/minotaur/controller = boss.ai_controller
	var/datum/ai_behavior/minotaur_ground_slam/slam = allocate(/datum/ai_behavior/minotaur_ground_slam)

	slam.shockwave_effect(controller, 1)

	TEST_ASSERT(QDELETED(victim), "Shockwave damage should delete the low-health victim without throwing it afterward.")
