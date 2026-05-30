/datum/unit_test/dye_bin_accepts_sewrepair_items

/datum/unit_test/dye_bin_accepts_sewrepair_items/Run()
	var/obj/structure/dye_bin/dye_bin = allocate(/obj/structure/dye_bin)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/shirt/shirt = allocate(/obj/item/clothing/shirt)

	TEST_ASSERT(user.put_in_hands(shirt, forced = TRUE), "Test user could not hold the shirt.")

	dye_bin.attackby(shirt, user, list())

	TEST_ASSERT_EQUAL(dye_bin.inserted, shirt, "Dye bin rejected an item with sewrepair.")
	TEST_ASSERT_EQUAL(shirt.loc, dye_bin, "Dye bin did not move the inserted shirt into itself.")
