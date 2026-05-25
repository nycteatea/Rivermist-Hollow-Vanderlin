GLOBAL_LIST_EMPTY(global_resurrunes)
GLOBAL_LIST_EMPTY(global_resurrune_markers)

#define RESURRECTION_TRAUMA_DURATION (90 MINUTES)
#define RESURRECTION_TRAUMA_RELIEF (5 MINUTES)
#define RESURRECTION_TRAUMA_PANIC_COOLDOWN (25 SECONDS)
#define RESURRECTION_TRAUMA_BOOZE_COOLDOWN (10 SECONDS)
#define RUNE_DEATH_COMPASS_DURATION (10 MINUTES)

//#define IS_RES_ELIGIBLE(source) ((source.InBadHealth() && !source.IsSleeping()) || (source.IsSleeping() && source.health < source.crit_threshold))


//For revive - your body DIDN'T rot, but it did suffer damage. Unlike being rotted, this one is only timed. Not forever.
/datum/status_effect/debuff/revived/rune
	id = "revived_rune"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/revived/rune
	effectedstats = list("strength" = -5, "perception" = -5, "intelligence" = -2, "endurance" = -5, "constitution" = -5, "speed" = -5, "fortune" = -1)
	duration = 15 MINUTES		//Should be long enough to stop someone from running back into battle. Plus, this stacks with body-rot debuff. RIP.

/atom/movable/screen/alert/status_effect/debuff/revived/rune
	name = "Rune Fatigue"
	desc = "You felt unfathomable forces course through you, restoring your body and your essance. Your body aches, and you can barely lift your arms, let alone fight."


/datum/status_effect/debuff/revived/rune/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_PACIFISM, "resurrection_rune")
	ADD_TRAIT(owner, TRAIT_NO_SELF_MAGIC, "resurrection_rune")


/datum/status_effect/debuff/revived/rune/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "resurrection_rune")
	REMOVE_TRAIT(owner, TRAIT_NO_SELF_MAGIC, "resurrection_rune")

/datum/status_effect/debuff/revived/rune/rough
	id = "revived_rune_rough"
	effectedstats = list("strength" = -8, "perception" = -8, "intelligence" = -5, "endurance" = -8, "constitution" = -8, "speed" = -8, "fortune" = -5)
	duration = 20 MINUTES

/datum/status_effect/debuff/revived/rune/light
	id = "revived_rune_light"
	effectedstats = list("strength" = -2, "perception" = -2, "intelligence" = -1, "endurance" = -2, "constitution" = -2, "speed" = -2)
	duration = 5 MINUTES

/datum/status_effect/debuff/resurrection_trauma
	id = "resurrection_trauma"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/debuff/resurrection_trauma
	duration = RESURRECTION_TRAUMA_DURATION
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	var/fear_mob_type = null
	var/fear_name = "that creature"
	var/next_panic_time = 0
	var/next_booze_relief_time = 0

/datum/status_effect/debuff/resurrection_trauma/on_creation(mob/living/new_owner, duration_override, feared_type, feared_name)
	fear_mob_type = feared_type
	if(feared_name)
		fear_name = feared_name
	return ..()

/datum/status_effect/debuff/resurrection_trauma/on_apply()
	. = ..()
	if(!.)
		return FALSE
	if(!ispath(fear_mob_type, /mob/living))
		return FALSE

	RegisterSignal(owner, COMSIG_CARBON_PRAY, PROC_REF(on_owner_prayed))
	RegisterSignal(owner, COMSIG_SEX_CLIMAX, PROC_REF(on_owner_climaxed))
	RegisterSignal(owner, COMSIG_CARBON_REAGENT_ADD, PROC_REF(on_reagent_added))
	return TRUE

/datum/status_effect/debuff/resurrection_trauma/on_remove()
	UnregisterSignal(owner, COMSIG_CARBON_PRAY)
	UnregisterSignal(owner, COMSIG_SEX_CLIMAX)
	UnregisterSignal(owner, COMSIG_CARBON_REAGENT_ADD)
	return ..()

/datum/status_effect/debuff/resurrection_trauma/tick()
	if(world.time < next_panic_time)
		return
	if(!owner || owner.stat == DEAD)
		return

	for(var/mob/living/seen_creature in view(5, owner))
		if(seen_creature == owner)
			continue
		if(!istype(seen_creature, fear_mob_type))
			continue

		owner.emote("scream")
		owner.Immobilize(1.5 SECONDS)
		owner.add_stress(/datum/stress_event/traumatized)
		to_chat(owner, span_userdanger("You see [seen_creature] and freeze in terror!"))
		next_panic_time = world.time + RESURRECTION_TRAUMA_PANIC_COOLDOWN
		return

/datum/status_effect/debuff/resurrection_trauma/proc/ease_trauma(message)
	if(!owner)
		return

	remove_duration(RESURRECTION_TRAUMA_RELIEF)
	if(owner)
		to_chat(owner, span_notice(message))

/datum/status_effect/debuff/resurrection_trauma/proc/on_owner_prayed(datum/source, prayer)
	SIGNAL_HANDLER
	ease_trauma("Prayer steadies your nerves.")

/datum/status_effect/debuff/resurrection_trauma/proc/on_owner_climaxed(datum/source, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	SIGNAL_HANDLER
	ease_trauma("Pleasure briefly dulls the memory of death.")

/datum/status_effect/debuff/resurrection_trauma/proc/on_reagent_added(datum/source, datum/reagent/added_reagent, added_amount, method)
	SIGNAL_HANDLER
	if(world.time < next_booze_relief_time)
		return
	if(!(method & INGEST))
		return
	if(!istype(added_reagent, /datum/reagent/consumable/ethanol))
		return

	next_booze_relief_time = world.time + RESURRECTION_TRAUMA_BOOZE_COOLDOWN
	ease_trauma("The drink takes the sharpest edge off the memory.")

/atom/movable/screen/alert/status_effect/debuff/resurrection_trauma
	name = "Death Trauma"
	desc = "The creature that killed you still lingers in the back of your mind."

/atom/movable/screen/alert/status_effect/debuff/revived/rune/rough
	name = "Rune Fatigue (rough)"
	desc = "You felt an alien force course through you, restoring your body and your essance almost against your will. Your body aches, and you can barely lift your arms, let alone fight."
	icon_state = "beauty"

#define REVIVAL_FILTER "revival_glow"
///atom/movable/screen/alert/status_effect/debuff/rune_glow
//	name = "Revival Afterglow"
//	desc = "You have been reknit and transported by unfathomable forces. You need time to recover,"
//	icon_state = "revived"

/datum/status_effect/debuff/rune_glow
	var/outline_colour ="#b86cf7"
	id = "rune_revival"
	//alert_type = /atom/movable/screen/alert/status_effect/debuff/rune_glow
	duration = 30 SECONDS
	alert_type = null

/datum/status_effect/debuff/rune_glow/on_apply()
	. = ..()
	var/filter = owner.get_filter(REVIVAL_FILTER)
	owner.SetKnockdown(duration)
	owner.SetStun(duration)
	if (!filter)
		owner.add_filter(REVIVAL_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))

/datum/status_effect/debuff/rune_glow/on_remove()
	. = ..()
	to_chat(owner, span_warning("The revival sickness has eased a little..."))
	owner.remove_filter(REVIVAL_FILTER)

/obj/item/resurrection_compass
	name = "rune compass"
	desc = "A small enchanted compass that still remembers where the rune seized you."
	icon = 'icons/obj/quest_compass.dmi'
	icon_state = "icon"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_WRISTS

	var/datum/weakref/target_turf_ref
	var/current_distance_state
	var/current_arrow_state
	var/last_signal_text = "The compass has lost the trail."

/obj/item/resurrection_compass/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, RUNE_DEATH_COMPASS_DURATION)
	update_appearance()

/obj/item/resurrection_compass/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	target_turf_ref = null
	return ..()

/obj/item/resurrection_compass/examine(mob/user)
	. = ..()
	. += span_notice("The compass trembles with the rune's memory and points toward where you were taken from.")
	. += span_notice("Activate it in-hand if you want to let the trail fade.")
	var/z_hint = get_z_level_hint(user)
	if(z_hint)
		. += z_hint
	. += span_info(last_signal_text)

/obj/item/resurrection_compass/attack_self(mob/user)
	refresh_tracking(user)
	if(alert(user, "Let the compass fade away for good?", "Rune Compass", "Keep", "Dismiss") == "Dismiss")
		to_chat(user, span_notice("The compass goes still and crumbles into dust."))
		qdel(src)
		return ..()

	to_chat(user, span_info(last_signal_text))
	var/z_hint = get_z_level_hint(user)
	if(z_hint)
		to_chat(user, z_hint)
	return ..()

/obj/item/resurrection_compass/process()
	var/mob/living/carrier = recursive_loc_check(src, /mob/living)
	refresh_tracking(carrier)

/obj/item/resurrection_compass/update_overlays()
	. = ..()
	if(current_distance_state)
		. += mutable_appearance(icon, current_distance_state)
	if(current_arrow_state)
		. += mutable_appearance(icon, current_arrow_state)

/obj/item/resurrection_compass/proc/set_target_turf(turf/target_turf)
	if(target_turf)
		target_turf_ref = WEAKREF(target_turf)
	else
		target_turf_ref = null
	refresh_tracking()

/obj/item/resurrection_compass/proc/resolve_target_turf()
	var/turf/tracked_turf = target_turf_ref?.resolve()
	if(!tracked_turf || QDELETED(tracked_turf))
		target_turf_ref = null
		return null
	return tracked_turf

/obj/item/resurrection_compass/proc/refresh_tracking(mob/user)
	var/turf/reference_turf = user ? get_turf(user) : get_turf(src)
	var/turf/target_turf = resolve_target_turf()
	if(!reference_turf || !target_turf)
		reset_compass("The compass has lost the trail.")
		return FALSE

	last_signal_text = get_signal_text(reference_turf, target_turf)
	current_distance_state = get_distance_state(reference_turf, target_turf)
	current_arrow_state = null
	if(target_turf != reference_turf)
		current_arrow_state = get_arrow_state(get_dir(reference_turf, target_turf))

	icon_state = "icon"
	update_appearance()
	return TRUE

/obj/item/resurrection_compass/proc/reset_compass(status_text)
	last_signal_text = status_text
	current_distance_state = null
	current_arrow_state = null
	icon_state = "icon"
	update_appearance()

/obj/item/resurrection_compass/proc/get_signal_text(turf/reference_turf, turf/target_turf)
	if(!reference_turf || !target_turf)
		return "The compass has lost the trail."
	if(reference_turf == target_turf)
		return "The compass spins in place. This is where the rune seized you."
	if(reference_turf.z != target_turf.z)
		return "The compass strains toward a trail on another level."

	var/distance = get_dist(reference_turf, target_turf)
	if(distance >= 100)
		return "The needle pulls only faintly. The trail is far away."
	if(distance >= 30)
		return "The compass tugs steadily toward a distant trail."
	return "The needle jerks hard. The trail is close."

/obj/item/resurrection_compass/proc/get_distance_state(turf/reference_turf, turf/target_turf)
	if(!reference_turf || !target_turf)
		return null
	if(reference_turf.z != target_turf.z)
		return "dist_ind_1"

	var/distance = get_dist(reference_turf, target_turf)
	if(distance >= 100)
		return "dist_ind_2"
	if(distance >= 30)
		return "dist_ind_3"
	return "dist_ind_4"

/obj/item/resurrection_compass/proc/get_arrow_state(direction)
	switch(direction)
		if(NORTHWEST)
			return "1"
		if(NORTHEAST)
			return "2"
		if(SOUTHWEST)
			return "3"
		if(SOUTHEAST)
			return "4"
		if(NORTH)
			return "5"
		if(SOUTH)
			return "6"
		if(WEST)
			return "7"
		if(EAST)
			return "8"
	return null

/obj/item/resurrection_compass/proc/get_z_level_hint(mob/user)
	if(!user)
		return null

	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = resolve_target_turf()
	if(!user_turf || !target_turf)
		return null
	if(target_turf.z == user_turf.z)
		return null

	if(target_turf.z > user_turf.z)
		return span_notice("The needle tilts upward - the trail lies <b>above</b> you.")
	return span_notice("The needle tilts downward - the trail lies <b>below</b> you.")

#undef REVIVAL_FILTER

/mob/living/carbon/human
	var/rune_linked = RUNE_LINK_NONE

#undef RUNE_DEATH_COMPASS_DURATION
#undef RESURRECTION_TRAUMA_DURATION
#undef RESURRECTION_TRAUMA_RELIEF
#undef RESURRECTION_TRAUMA_PANIC_COOLDOWN
#undef RESURRECTION_TRAUMA_BOOZE_COOLDOWN
