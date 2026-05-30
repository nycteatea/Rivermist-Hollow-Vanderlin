/datum/unit_test/ai_idle_recalculate_wakes_when_tracked_cell_has_client
#ifdef FOCUS_AI_IDLE_DETECTION_TEST
	focus = TRUE
#endif

/datum/unit_test/ai_idle_recalculate_wakes_when_tracked_cell_has_client/Run()
	var/mob/living/simple_animal/hostile/hostile_mob = allocate(/mob/living/simple_animal/hostile)
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = hostile_mob.ai_controller
	if(!controller)
		controller = allocate(/datum/ai_controller, hostile_mob)

	controller.set_ai_status(AI_STATUS_IDLE)

	var/datum/spatial_grid_cell/watched_cell = controller.our_cells.member_cells[1]
	TEST_ASSERT_NOTNULL(watched_cell, "AI controller did not register any watched spatial cells.")

	var/list/old_client_contents = watched_cell.client_contents
	watched_cell.client_contents = list(viewer)
	controller.recalculate_idle()
	watched_cell.client_contents = old_client_contents

	TEST_ASSERT_EQUAL(controller.ai_status, AI_STATUS_ON, "Idle AI should wake when a recalculated watched cell already contains a client mob.")
