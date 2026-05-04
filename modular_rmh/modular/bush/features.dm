/datum/bodypart_feature/hair/body_hair
	name = "Body Hair"
	feature_slot = BODYPART_FEATURE_BODY_HAIR
	body_zone = BODY_ZONE_CHEST
	var/current_level = HAIRINESS_SHAVED
	var/target_level = HAIRINESS_SHAVED
	var/growth_enabled = FALSE
	var/list/accessory_by_level = list(
		/datum/sprite_accessory/body_hair/body/shaved,
		/datum/sprite_accessory/body_hair/body/shaved,
		/datum/sprite_accessory/body_hair/body/some_hair,
		/datum/sprite_accessory/body_hair/body/hairy,
		/datum/sprite_accessory/body_hair/body/very_hairy,
	)

/datum/bodypart_feature/hair/body_hair/set_accessory_type(new_accessory_type, colors, mob/living/carbon/owner)
	..()
	var/datum/sprite_accessory/body_hair/accessory = SPRITE_ACCESSORY(new_accessory_type)
	if(!accessory)
		return
	set_hairiness_level(accessory.hairiness_level, TRUE)

/datum/bodypart_feature/hair/body_hair/proc/get_accessory_for_level(level)
	level = clamp(level, HAIRINESS_MINIMUM, HAIRINESS_MAXIMUM)
	return accessory_by_level[level]

/datum/bodypart_feature/hair/body_hair/proc/set_hairiness_level(level, updates_target = FALSE)
	current_level = clamp(level, HAIRINESS_MINIMUM, HAIRINESS_MAXIMUM)
	if(updates_target)
		target_level = current_level
	accessory_type = get_accessory_for_level(current_level)
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/get_next_growth_level()
	if(current_level < HAIRINESS_SOME_HAIR)
		return min(target_level, HAIRINESS_SOME_HAIR)
	return min(current_level + 1, target_level)

/datum/bodypart_feature/hair/body_hair/proc/grow_one_level()
	if(current_level >= target_level)
		return FALSE
	set_hairiness_level(get_next_growth_level())
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/shave()
	if(current_level <= HAIRINESS_SHAVED)
		return FALSE
	set_hairiness_level(HAIRINESS_SHAVED)
	return TRUE

/datum/bodypart_feature/hair/body_hair/proc/get_organ_adjective()
	return hairiness_level_organ_adjective(current_level)

/datum/bodypart_feature/hair/body_hair/pubic
	name = "Pubic Hair"
	feature_slot = BODYPART_FEATURE_PUBIC_HAIR
	body_zone = BODY_ZONE_CHEST
	var/grooming_state = HAIR_GROOMING_NATURAL
	accessory_by_level = list(
		/datum/sprite_accessory/body_hair/pubic/shaved,
		/datum/sprite_accessory/body_hair/pubic/stubble,
		/datum/sprite_accessory/body_hair/pubic/some_hair,
		/datum/sprite_accessory/body_hair/pubic/hairy,
		/datum/sprite_accessory/body_hair/pubic/very_hairy,
	)

/datum/bodypart_feature/hair/body_hair/pubic/get_next_growth_level()
	return min(current_level + 1, target_level)

/datum/bodypart_feature/hair/body_hair/pubic/grow_one_level()
	if(!..())
		return FALSE
	if(current_level >= target_level)
		grooming_state = HAIR_GROOMING_NATURAL
	else if(grooming_state == HAIR_GROOMING_SHAVED)
		grooming_state = HAIR_GROOMING_TRIMMED
	return TRUE

/datum/bodypart_feature/hair/body_hair/pubic/shave()
	if(!..())
		return FALSE
	grooming_state = HAIR_GROOMING_SHAVED
	return TRUE

/mob/living/carbon/human
	var/next_body_hair_growth = 0

/mob/living/carbon/human/proc/handle_body_hair_growth()
	if(next_body_hair_growth > world.time)
		return
	next_body_hair_growth = world.time + BODY_HAIR_GROWTH_INTERVAL
	var/grew = FALSE
	var/datum/bodypart_feature/hair/body_hair/body_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_BODY_HAIR)
	if(body_hair_feature?.growth_enabled)
		grew |= body_hair_feature.grow_one_level()
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
	if(pubic_hair_feature?.growth_enabled)
		grew |= pubic_hair_feature.grow_one_level()
	if(grew)
		update_body_parts()

/mob/living/carbon/human/proc/get_pubic_hair_organ_adjective()
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
	return pubic_hair_feature?.get_organ_adjective()

/mob/living/carbon/human/proc/restore_head_hair_to_natural_target()
	var/datum/bodypart_feature/hair/head/head_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!head_hair?.natural_accessory_type || head_hair.accessory_type == head_hair.natural_accessory_type)
		return FALSE
	head_hair.accessory_type = head_hair.natural_accessory_type
	return TRUE

/mob/living/carbon/human/proc/restore_facial_hair_to_natural_target()
	var/datum/bodypart_feature/hair/facial/facial_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!facial_hair?.natural_accessory_type)
		return FALSE
	var/grew = FALSE
	if(facial_hair.accessory_type != facial_hair.natural_accessory_type)
		facial_hair.accessory_type = facial_hair.natural_accessory_type
		grew = TRUE
	if(has_stubble)
		has_stubble = FALSE
		grew = TRUE
	return grew

/mob/living/carbon/human/proc/remove_head_hair()
	var/datum/bodypart_feature/hair/head/head_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	if(!head_hair || head_hair.accessory_type == /datum/sprite_accessory/hair/head/bald)
		return FALSE
	head_hair.accessory_type = /datum/sprite_accessory/hair/head/bald
	return TRUE

/mob/living/carbon/human/proc/remove_facial_hair()
	var/datum/bodypart_feature/hair/facial/facial_hair = get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	if(!facial_hair)
		return FALSE
	var/removed = FALSE
	if(facial_hair.accessory_type != /datum/sprite_accessory/hair/facial/none)
		facial_hair.accessory_type = /datum/sprite_accessory/hair/facial/none
		removed = TRUE
	if(has_stubble)
		has_stubble = FALSE
		removed = TRUE
	return removed

/mob/living/carbon/human/proc/grow_hair_toward_natural_targets()
	var/grew = FALSE
	grew |= restore_head_hair_to_natural_target()
	grew |= restore_facial_hair_to_natural_target()
	var/datum/bodypart_feature/hair/body_hair/body_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_BODY_HAIR)
	if(body_hair_feature)
		grew |= body_hair_feature.grow_one_level()

	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
	if(pubic_hair_feature)
		grew |= pubic_hair_feature.grow_one_level()

	if(grew)
		update_body_parts()
	return grew

/mob/living/carbon/human/proc/grow_hair_at_zone(target_zone)
	var/grew = FALSE
	switch(target_zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL)
			grew = restore_head_hair_to_natural_target()
		if(BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NECK)
			grew = restore_facial_hair_to_natural_target()
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			var/datum/bodypart_feature/hair/body_hair/body_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_BODY_HAIR)
			grew = body_hair_feature?.grow_one_level()
		if(BODY_ZONE_PRECISE_GROIN)
			var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
			grew = pubic_hair_feature?.grow_one_level()
		else
			return FALSE
	if(grew)
		update_body_parts()
	return grew

/mob/living/carbon/human/proc/remove_hair_at_zone(target_zone)
	var/removed = FALSE
	switch(target_zone)
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL)
			removed = remove_head_hair()
		if(BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NECK)
			removed = remove_facial_hair()
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			var/datum/bodypart_feature/hair/body_hair/body_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_BODY_HAIR)
			removed = body_hair_feature?.shave()
		if(BODY_ZONE_PRECISE_GROIN)
			var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
			removed = pubic_hair_feature?.shave()
		else
			return FALSE
	if(removed)
		update_body_parts()
	return removed

/mob/living/carbon/human/proc/remove_all_hair()
	var/removed = FALSE
	removed |= remove_head_hair()
	removed |= remove_facial_hair()
	var/datum/bodypart_feature/hair/body_hair/body_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_BODY_HAIR)
	if(body_hair_feature)
		removed |= body_hair_feature.shave()
	var/datum/bodypart_feature/hair/body_hair/pubic/pubic_hair_feature = get_bodypart_feature_of_slot(BODYPART_FEATURE_PUBIC_HAIR)
	if(pubic_hair_feature)
		removed |= pubic_hair_feature.shave()
	if(removed)
		update_body_parts()
	return removed

/mob/living/carbon/human/proc/try_shave_body_hair(mob/user, obj/item/held_item, feature_slot, hair_name, body_zone, shave_time = 8 SECONDS)
	var/datum/bodypart_feature/hair/body_hair/hair_feature = get_bodypart_feature_of_slot(feature_slot)
	if(!hair_feature || hair_feature.current_level <= HAIRINESS_SHAVED)
		return FALSE
	if(!get_location_accessible(src, body_zone, skipundies = FALSE))
		to_chat(user, span_warning("[src == user ? "Your" : "[src]'s"] [hair_name] is covered."))
		return TRUE
	playsound(src, 'sound/foley/shaving.ogg', 100, TRUE, -1)
	if(user == src)
		user.visible_message(span_danger("[user] starts to shave [user.p_their()] [hair_name] with [held_item]."))
	else
		user.visible_message(span_danger("[user] starts to shave [src]'s [hair_name] with [held_item]."))
	if(!do_after(user, shave_time, src))
		return TRUE
	if(!hair_feature.shave())
		return TRUE
	update_body_parts()
	return TRUE
