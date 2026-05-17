/datum/unit_test/erp_preferences_recover_from_missing_storage
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_recover_from_missing_storage/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.erp_preferences = null

	var/datum/erp_preference/boolean/allow_mob_breeding/boolean_pref = new
	TEST_ASSERT_EQUAL(boolean_pref.get_value(prefs), boolean_pref.default_value, "Boolean ERP preferences should use defaults when storage is missing.")

	var/datum/erp_preference/bitflag/horny_mob_types/bitflag_pref = new
	TEST_ASSERT_EQUAL(bitflag_pref.get_value(prefs), bitflag_pref.default_value, "Bitflag ERP preferences should use defaults when storage is missing.")

	var/datum/kink/bondage/kink = new
	var/kink_ui = prefs.show_kink_ui(kink)
	TEST_ASSERT_NOTNULL(kink_ui, "Kink preference UI should render when ERP storage is missing.")
	TEST_ASSERT(islist(prefs.erp_preferences), "Rendering kink preferences should initialize ERP storage.")
	TEST_ASSERT(islist(prefs.erp_preferences["kinks"]), "Rendering kink preferences should initialize kink storage.")
	TEST_ASSERT_EQUAL(prefs.erp_preferences["kinks"][kink.name]["enabled"], FALSE, "Missing kink data should use the configured default enabled state.")
	TEST_ASSERT_EQUAL(prefs.erp_preferences["kinks"][kink.name]["intensity"], 1, "Missing kink data should use the configured default intensity.")

/datum/unit_test/erp_preferences_setup_defaults
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_setup_defaults/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.erp_preferences = null

	prefs.setup_default_erp_preferences()

	TEST_ASSERT(islist(prefs.erp_preferences), "Default setup should initialize ERP storage.")
	TEST_ASSERT((/datum/erp_preference/boolean/allow_mob_breeding in prefs.erp_preferences), "Default setup should populate concrete ERP preferences.")
	var/datum/erp_preference/bitflag/horny_mob_types/bitflag_pref = new
	TEST_ASSERT_EQUAL(prefs.erp_preferences[bitflag_pref.type], bitflag_pref.default_value, "Default setup should populate concrete bitflag ERP preferences.")
	TEST_ASSERT(!(/datum/erp_preference/bitflag in prefs.erp_preferences), "Default setup should not populate abstract ERP preferences.")

/datum/unit_test/erp_preferences_nonmatching_horny_mobs_are_nonlethal_by_default
#ifdef FOCUS_ERP_PREFERENCES_TEST
	focus = TRUE
#endif

/datum/unit_test/erp_preferences_nonmatching_horny_mobs_are_nonlethal_by_default/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.erp_preferences = null

	prefs.setup_default_erp_preferences()

	var/datum/erp_preference/boolean/nonmatching_horny_mobs_are_nonlethal/nonlethal_pref = new
	TEST_ASSERT((nonlethal_pref.type in prefs.erp_preferences), "Default setup should populate the nonmatching horny mob handling preference.")
	TEST_ASSERT_EQUAL(nonlethal_pref.get_value(prefs), TRUE, "Nonmatching horny mobs should use nonlethal handling by default.")

	nonlethal_pref.set_value(prefs, FALSE)
	TEST_ASSERT_EQUAL(nonlethal_pref.get_value(prefs), FALSE, "Nonmatching horny mob handling should be player-configurable.")
