/datum/unit_test/visible_message_reaches_behind_active_fov
#ifdef FOCUS_VISIBLE_MESSAGE_FOV_TEST
	focus = TRUE
#endif

/datum/unit_test/visible_message_reaches_behind_active_fov/Run()
	var/turf/speaker_turf = run_loc_floor_bottom_left
	var/turf/viewer_turf = get_step(speaker_turf, EAST)
	TEST_ASSERT_NOTNULL(viewer_turf, "Test map should have an adjacent turf for the viewer.")

	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human, speaker_turf)
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, viewer_turf)
	viewer.setDir(EAST)

	var/datum/component/field_of_vision/fov = viewer.GetComponent(/datum/component/field_of_vision)
	TEST_ASSERT_NOTNULL(fov, "Human viewers should have a field of vision component.")
	fov.generate_fov_holder(viewer, FOV_90_DEGREES, get_fov_angle(FOV_90_DEGREES), register = FALSE, delete_holder = TRUE)

	var/list/fov_viewers = list(viewer)
	SEND_SIGNAL(viewer, COMSIG_MOB_FOV_VIEWER, speaker, DEFAULT_MESSAGE_RANGE, fov_viewers)
	TEST_ASSERT(!(viewer in fov_viewers), "Test setup should place the speaker behind the viewer's active FOV cone.")

	var/message_signal = SEND_SIGNAL(viewer, COMSIG_MOB_VISIBLE_MESSAGE, speaker, "waves", DEFAULT_MESSAGE_RANGE, list())

	TEST_ASSERT(!(message_signal & COMPONENT_NO_VISIBLE_MESSAGE), "FOV should not completely suppress nearby visible messages.")
	TEST_ASSERT(!(message_signal & COMPONENT_VISIBLE_MESSAGE_BLIND), "FOV should not convert nearby visible messages into blind messages.")
