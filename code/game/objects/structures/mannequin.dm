
/////////////////////////////////////////////////////////MANNEQUINS//////////////////////////////////////////////////////////
//Basically statues that you can dress up.

#define MANNEQUIN_ICONS_SLOT		"slot_icon"
#define MANNEQUIN_ICONS_PRIMITIVE	"primitive_icon"
#define MANNEQUIN_ICONS_SPECIES		"species_icon"
#define MANNEQUIN_ICONS_CORGI		"corgi"
#define MANNEQUIN_ICONS_FAT			"fat_icon"
#define MANNEQUIN_DYNAMIC_LAYER		"dynamic_layer"

/obj/structure/mannequin
	name = "human man marble mannequin"
	desc = "You almost feel like it's going to come alive any second."
	icon = 'icons/obj/mannequin.dmi'
	icon_state="mannequin_marble_human"
	density = 1
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER
	flags = FPRINT | PROXMOVE
	var/trueForm = /mob/living/simple_animal/hostile/mannequin
	var/pedestal = /obj/item/trash/mannequin
	var/datum/species/species
	var/species_type = /datum/species/human
	var/fat = 0
	var/primitive = 0
	var/corgi = FALSE
	gender = MALE
	var/list/clothing = list()
	var/list/obj/item/held_items = list(null, null)
	var/hair_style
	var/beard_style
	var/hair_color = "#B9C1B8"
	var/clothing_offset_x = 0
	var/clothing_offset_y = 3*PIXEL_MULTIPLIER
	health = 90
	maxHealth = 90
	var/has_pedestal = TRUE
	var/timer = 80 //in seconds
	var/mob/living/captured
	var/intialTox = 0
	var/intialFire = 0
	var/intialBrute = 0
	var/intialOxy = 0
	var/dissolving = FALSE

	var/additional_damage = 0//tracking how much damage we took

	var/list/all_slot_icons = list()

	//for mappers, with love
	var/mapping_uniform = null
	var/mapping_shoes = null
	var/mapping_gloves = null
	var/mapping_ears = null
	var/mapping_suit = null
	var/mapping_glasses = null
	var/mapping_hat = null
	var/mapping_belt = null
	var/mapping_mask = null
	var/mapping_back = null
	var/mapping_id = null

	var/mapping_hand_right = null
	var/mapping_hand_left = null

	var/awakening = 0

	//mappers vars
	var/awake = 0//1 = Mannequin awakens on spawn. It won't leave a pedestal behind.
	var/trapped_prox = 0//1 = Mannequin awakens if you get near it.
	var/trapped_strip = 0//1= Mannequin awakens if you try to strip it or to wrench it.
	var/chaintrap_range = 0//= Range at which mannequin awakens nearby mannequins when it awakens.


/obj/structure/mannequin/New(turf/loc, var/f_style, var/h_style, var/list/items_to_wear, var/list/items_to_hold = list(null, null), var/mob_to_capture, var/forever)
	..()

	if (forever)
		timer = -1

	species = new species_type()

	clothing = list(
		SLOT_MANNEQUIN_ICLOTHING,
		SLOT_MANNEQUIN_FEET,
		SLOT_MANNEQUIN_GLOVES,
		SLOT_MANNEQUIN_EARS,
		SLOT_MANNEQUIN_OCLOTHING,
		SLOT_MANNEQUIN_EYES,
		SLOT_MANNEQUIN_BELT,
		SLOT_MANNEQUIN_MASK,
		SLOT_MANNEQUIN_HEAD,
		SLOT_MANNEQUIN_BACK,
		SLOT_MANNEQUIN_ID,
		)

	beard_style = f_style
	hair_style = h_style

	if (items_to_wear?.len)
		for (var/slot in clothing)
			var/obj/item/O = items_to_wear[slot]
			if (O)
				clothing[slot] = O
				O.forceMove(src)
				O.mannequin_equip(src,slot)

	for (var/i = 1 to held_items.len)
		var/obj/item/O = items_to_hold[i]
		if (O)
			held_items[i] = O
			O.forceMove(src)
			O.mannequin_equip(src,"hands",i)

	if (mob_to_capture)
		capture_mob(mob_to_capture)


	for(var/cloth_slot in clothing)
		all_slot_icons[cloth_slot] = get_slot_icons(cloth_slot)

	checkMappingWear()

	if(awake)
		Awaken()

/obj/structure/mannequin/Destroy()
	processing_objects.Remove(src)
	captured = null
	held_items.len = 0
	clothing.len = 0
	..()

/obj/structure/mannequin/process()
	timer--
	if (captured)
		captured.setToxLoss(intialTox)
		captured.adjustFireLoss(intialFire - captured.getFireLoss())
		captured.adjustBruteLoss(intialBrute - captured.getBruteLoss())
		captured.setOxyLoss(intialOxy)
		if (timer >= 5)
			captured.Paralyse(2)
	if (timer == 0)
		freeCaptive()
		qdel(src)

/obj/structure/mannequin/proc/capture_mob(var/mob/M)
	if(!isliving(M))
		return
	has_pedestal = FALSE
	var/mob/living/L = M
	if(L.locked_to)
		L.locked_to = 0
		L.anchored = 0
	if(L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src

	for(var/obj/item/I in L.held_items)
		L.drop_item(I)

	if(L.locked_to)
		L.unlock_from()

	L.sdisabilities |= MUTE
	L.delayNextAttack(timer)
	L.click_delayer.setDelay(timer)
	health = L.health*2
	maxHealth = L.maxHealth*2
	intialTox = L.getToxLoss()
	intialFire = L.getFireLoss()
	intialBrute = L.getBruteLoss()
	intialOxy = L.getOxyLoss()

	dir = L.dir

	L.forceMove(src)

	name = "statue of \a [name]"
	if(iscorgi(L))
		desc = "If it takes forever, I will wait for you..."
	else
		desc = "An incredibly lifelike marble carving."

	if(timer < 0)
		L.death(FALSE)
	else
		processing_objects.Add(src)

	M.forceMove(src)
	captured = M
	processing_objects.Add(src)

/obj/structure/mannequin/proc/dissolve()
	if(dissolving)
		return

	visible_message("<span class='notice'>The statue's surface begins cracking and dissolving!</span>")

	processing_objects.Remove(src) //Disable the statue's processing (otherwise it may heal the occupants or something like that)
	dissolving = TRUE

	//Kill and husk the occupants over the course of 6 seconds, then dump them out (they won't be cloneable but their brains will be OK)
	spawn(10)
		for(var/i=1 to 5)
			for(var/mob/living/L in contents)
				L.adjustBruteLoss(10)
				if (L.health <= 0)
					L.mutations |= M_NOCLONE

					if(ishuman(L) && !(M_HUSK in L.mutations))
						var/mob/living/carbon/human/H = L
						H.ChangeToHusk()
				sleep(10)

		breakDown()

/obj/structure/mannequin/HasProximity(var/atom/movable/AM)
	if(trapped_prox && isliving(AM))
		Awaken()
		return 1
	return 0


/obj/structure/mannequin/MouseDropFrom(var/atom/over_object)
	..()
	var/mob/user = usr
	if(user != over_object)
		return
	if(user.incapacitated())
		return
	if(user.lying)
		return
	if(!Adjacent(user))
		return
	if(isAI(user))
		return
	show_inv(user)


/obj/structure/mannequin/attack_hand(var/mob/living/user)
	if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.visible_message("<span class='danger'>[user.name] punches \the [src]!</span>", "<span class='danger'>You punch \the [src]!</span>")
		getDamage(rand(1,7) * (user.get_strength() - 1))
	else
		show_inv(user)


/obj/structure/mannequin/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H.name] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	var/damage = rand(1,7) * (H.get_strength() - 1)
	var/obj/item/clothing/shoes/S = H.shoes
	if(istype(S))
		damage += S.bonus_kick_damage

	getDamage(damage)



/obj/structure/mannequin/attack_animal(var/mob/living/simple_animal/user)
	if(user.melee_damage_upper > 0)
		user.visible_message("<span class='danger'>\The [user] [user.attacktext] \the [src]!</span>", "<span class='danger'>You [user.attacktext] \the [src]!</span>")
		getDamage(rand(user.melee_damage_upper, user.melee_damage_upper))



/obj/structure/mannequin/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/mannequin/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(trapped_strip)
		Awaken()
		return FALSE
	. = ..()

/obj/structure/mannequin/attackby(var/obj/item/weapon/W,var/mob/user)
	if(W.is_wrench(user))
		return wrenchAnchor(user, W, 5 SECONDS)
	else if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		getDamage(W.force)
		user.visible_message("<span class='danger'>[user.name] [(W.attack_verb && W.attack_verb.len) ? "[pick(W.attack_verb)]" : "attacks" ] \the [src] with \the [W]!</span>", "<span class='danger'>You [(W.attack_verb && W.attack_verb.len) ? "[pick(W.attack_verb)]" : "attack" ] \the [src] with \the [W]!</span>")
	else
		attack_hand(user)

/obj/structure/mannequin/examine(mob/user)
	..()
	var/msg = ""

	for(var/obj/item/I in held_items)
		if(I.is_blood_stained())
			msg += "<span class='warning'>It's holding [bicon(I)] [I.a_stained()] [I.name] in its [get_index_limb_name(is_holding_item(I))]!</span>\n"
		else
			msg += "It's holding [bicon(I)] \a [I] in its [get_index_limb_name(is_holding_item(I))].\n"

	for(var/slot_cloth in clothing)
		var/obj/item/clothToExamine = clothing[slot_cloth]
		if(clothToExamine)

			var/slot_examine = ""
			switch(slot_cloth)
				if(SLOT_MANNEQUIN_HEAD)
					slot_examine = " on its head"
				if(SLOT_MANNEQUIN_BACK)
					slot_examine = " on its back"
				if(SLOT_MANNEQUIN_GLOVES)
					slot_examine = " on its hands"
				if(SLOT_MANNEQUIN_BELT)
					slot_examine = " about its waist"
				if(SLOT_MANNEQUIN_FEET)
					slot_examine = " on its feet"
				if(SLOT_MANNEQUIN_MASK)
					slot_examine = " on its face"
				if(SLOT_MANNEQUIN_EYES)
					slot_examine = " covering its eyes"
				if(SLOT_MANNEQUIN_EARS)
					slot_examine = " on its ears"

			if(clothToExamine.is_blood_stained())
				msg += "<span class='warning'>It's wearing [bicon(clothToExamine)] [clothToExamine.a_stained()] [clothToExamine][slot_examine]![clothToExamine.description_accessories()]</span>\n"
			else
				msg += "It's wearing [bicon(clothToExamine)] \a [clothToExamine][slot_examine].[clothToExamine.description_accessories()] \n"

	to_chat(user, msg)

/obj/structure/mannequin/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				getDamage(30)
			else
				getDamage(20)
		if (3)
			if (prob(50))
				getDamage(10)


/obj/structure/mannequin/bullet_act(var/obj/item/projectile/Proj)
	getDamage(Proj.damage)
	return ..()

/obj/structure/mannequin/blob_act()
	if (prob(75))
		breakDown()
	else
		getDamage(30)



/obj/structure/mannequin/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !Adjacent(usr) || !(iscarbon(usr) || isMoMMI(usr)))
		return
	var/mob/living/carbon/user = usr

	if(href_list["hands"])
		if(trapped_strip)
			to_chat(user,"<span class='danger'>\The [src] starts moving.</span>")
			Awaken()
			return
		var/obj/item/item_in_hand = usr.get_active_hand()
		var/hand_index = text2num(href_list["hands"])
		if(!item_in_hand)
			if(get_held_item_by_index(hand_index))
				var/obj/item/I = held_items[hand_index]
				I.mannequin_unequip(src)
				user.put_in_hands(I)
				held_items[hand_index] = null
				to_chat(user, "<span class='info'>You pick up \the [I] from \the [src].</span>")
		else
			if(get_held_item_by_index(hand_index))
				if(user.drop_item(item_in_hand,src))
					var/obj/item/I = held_items[hand_index]
					I.mannequin_unequip(src)
					user.put_in_hands(I)
					held_items[hand_index] = item_in_hand
					item_in_hand.mannequin_equip(src,"hands",hand_index)
					to_chat(user, "<span class='info'>You switch \the [item_in_hand] and \the [I] on the [src].</span>")
				else
					to_chat(user, "<span class='warning'>You can't drop that!</span>")
			else
				if(user.drop_item(item_in_hand,src))
					held_items[hand_index] = item_in_hand
					item_in_hand.mannequin_equip(src,"hands",hand_index)
					to_chat(user, "<span class='info'>You place \the [item_in_hand] on \the [src].</span>")
				else
					to_chat(user, "<span class='warning'>You can't drop that!</span>")

	else if(href_list["item"])
		if(trapped_strip)
			to_chat(user,"<span class='danger'>\The [src] starts moving.</span>")
			Awaken()
			return
		var/obj/item/item_in_hand = usr.get_active_hand()
		var/item_slot = href_list["item"]
		if(!item_in_hand)
			if(clothing[item_slot])
				var/obj/item/I = clothing[item_slot]
				I.mannequin_unequip(src)
				user.put_in_hands(I)
				clothing[item_slot] = null
				add_fingerprint(user)
				to_chat(user, "<span class='info'>You pick up \the [I] from \the [src].</span>")
		else
			if(clothing[item_slot])
				if(canEquip(user, item_slot,item_in_hand))
					if(user.drop_item(item_in_hand,src))
						var/obj/item/I = clothing[item_slot]
						I.mannequin_unequip(src)
						user.put_in_hands(I)
						clothing[item_slot] = item_in_hand
						item_in_hand.mannequin_equip(src,item_slot)
						add_fingerprint(user)
						to_chat(user, "<span class='info'>You switch \the [item_in_hand] and \the [I] on the [src].</span>")
					else
						to_chat(user, "<span class='warning'>You can't drop that!</span>")
				else
					return
			else
				if(canEquip(user, item_slot,item_in_hand))
					if(user.drop_item(item_in_hand,src))
						clothing[item_slot] = item_in_hand
						item_in_hand.mannequin_equip(src,item_slot)
						add_fingerprint(user)
						to_chat(user, "<span class='info'>You place \the [item_in_hand] on \the [src].</span>")
					else
						to_chat(user, "<span class='warning'>You can't drop that!</span>")
				else
					return

	else if(href_list["toggle_uniform_hood"])
		if(trapped_strip)
			to_chat(user,"<span class='danger'>\The [src] starts moving.</span>")
			Awaken()
			return
		if (clothing[SLOT_MANNEQUIN_ICLOTHING])
			var/obj/item/clothing/I = clothing[SLOT_MANNEQUIN_ICLOTHING]
			if (I.hood)
				I.toggle_hood(src,usr)

	else if(href_list["toggle_suit_hood"])
		if(trapped_strip)
			to_chat(user,"<span class='danger'>\The [src] starts moving.</span>")
			Awaken()
			return
		if (clothing[SLOT_MANNEQUIN_OCLOTHING])
			var/obj/item/clothing/I = clothing[SLOT_MANNEQUIN_OCLOTHING]
			if (I.hood)
				I.toggle_hood(src,usr)

	update_icon()
	show_inv(user)


/obj/structure/mannequin/proc/getDamage(var/damage)
	health -= damage
	additional_damage += damage
	healthCheck()
	if(health > 0 && (trapped_strip || trapped_prox))
		Awaken()


/obj/structure/mannequin/proc/healthCheck()
	if (src.health <= 0)
		visible_message("\The [src] collapses.")
		breakDown()


/obj/structure/mannequin/proc/freeCaptive()
	if (!captured)
		return
	captured.sdisabilities &= ~MUTE
	captured.timestopped = 0
	captured.forceMove(loc)
	for(var/cloth in clothing)
		var/obj/O = clothing[cloth]
		if (O)
			switch(cloth)
				if(SLOT_MANNEQUIN_ICLOTHING)
					captured.equip_to_slot_or_drop(O, slot_w_uniform)
				if(SLOT_MANNEQUIN_FEET)
					captured.equip_to_slot_or_drop(O, slot_shoes)
				if(SLOT_MANNEQUIN_GLOVES)
					captured.equip_to_slot_or_drop(O, slot_gloves)
				if(SLOT_MANNEQUIN_EARS)
					captured.equip_to_slot_or_drop(O, slot_ears)
				if(SLOT_MANNEQUIN_OCLOTHING)
					captured.equip_to_slot_or_drop(O, slot_wear_suit)
				if(SLOT_MANNEQUIN_EYES)
					captured.equip_to_slot_or_drop(O, slot_glasses)
				if(SLOT_MANNEQUIN_BELT)
					captured.equip_to_slot_or_drop(O, slot_belt)
				if(SLOT_MANNEQUIN_MASK)
					captured.equip_to_slot_or_drop(O, slot_wear_mask)
				if(SLOT_MANNEQUIN_HEAD)
					if (iscorgi(captured))
						var/mob/living/simple_animal/corgi/corgi = captured
						O.forceMove(captured)
						corgi.inventory_back = O
						corgi.regenerate_icons()
					else
						captured.equip_to_slot_or_drop(O, slot_head)
				if(SLOT_MANNEQUIN_BACK)
					if (iscorgi(captured))
						var/mob/living/simple_animal/corgi/corgi = captured
						corgi.place_on_head(O)
					else
						captured.equip_to_slot_or_drop(O, slot_back)
				if(SLOT_MANNEQUIN_ID)
					captured.equip_to_slot_or_drop(O, slot_wear_id)
	clothing.len = 0

	for(var/index = 1 to held_items.len)
		var/obj/item/tool = held_items[index]
		if (!tool)
			continue
		captured.put_in_hands(tool)
	held_items.len = 0
	captured.dir = dir
	captured.apply_damage(additional_damage)

/obj/structure/mannequin/proc/breakDown()
	visible_message("<span class='warning'><b>[src]</b> collapses!</span>")
	new /obj/effect/decal/cleanable/dirt(loc)
	playsound(loc, 'sound/effects/stone_crumble.ogg', 100, 1)
	if (captured)
		if (dissolving)
			freeCaptive()
			qdel(src)
			return
		else
			captured.gib()
	for(var/cloth in clothing)
		if(clothing[cloth])
			var/obj/item/cloth_to_drop = clothing[cloth]
			cloth_to_drop.mannequin_unequip(src)
			cloth_to_drop.forceMove(loc)
			clothing[cloth] = null
	for(var/obj/item/item_to_drop in held_items)
		item_to_drop.mannequin_unequip(src)
		item_to_drop.forceMove(loc)
		held_items -= item_to_drop
	qdel(src)



////////////////HANDS STUFF//////////////////
/obj/structure/mannequin/proc/get_item_offset_by_index(index)//Will come to use when we get multi-handed mannequins
	return list()

/obj/structure/mannequin/proc/get_held_item_by_index(index)
	if(!is_valid_hand_index(index))
		return null

	return held_items[index]

/obj/structure/mannequin/proc/get_index_limb_name(var/index)
	switch(index)
		if(GRASP_LEFT_HAND)
			return "left hand"
		if(GRASP_RIGHT_HAND)
			return "right hand"

	return "hand"

/obj/structure/mannequin/proc/is_holding_item(item)
	return held_items.Find(item)

/obj/structure/mannequin/proc/get_direction_by_index(index)
	if(index % 2 == GRASP_RIGHT_HAND)
		return "right_hand"
	else
		return "left_hand"
////////////////HANDS STUFF END//////////////////

/obj/structure/mannequin/proc/show_inv(var/mob/user)
	var/dat

	if (corgi)
		dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_HEAD]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_HEAD])]</A>"
		dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_BACK]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_BACK])]</A>"
	else
		for(var/i = 1 to held_items.len)
			dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(get_held_item_by_index(i))]</A><BR>"

		dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_BACK]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_BACK])]</A>"
		dat += "<BR>"
		dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_HEAD]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_HEAD])]</A>"
		dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_MASK]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_MASK])]</A>"
		dat += "<BR><B>Eyes:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_EYES]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_EYES])]</A>"
		if(!primitive)
			dat += "<BR><B>Ears:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_EARS]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_EARS])]</A>"
		dat += "<BR>"
		if(!primitive)
			dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_OCLOTHING]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_OCLOTHING])]</A>"
			if (clothing[SLOT_MANNEQUIN_OCLOTHING])
				var/obj/item/I = clothing[SLOT_MANNEQUIN_OCLOTHING]
				if (istype(I, /obj/item/clothing))
					var/obj/item/clothing/C = I
					if (C.hood)
						dat += "<BR>[HTMLTAB]&#8627;<B>Hood:</B> <A href='?src=\ref[src];toggle_suit_hood=1'>Toggle</A>"
			dat += "<BR><B>Shoes:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_FEET]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_FEET])]</A>"
			dat += "<BR><B>Gloves:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_GLOVES]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_GLOVES])]</A>"
		dat += "<BR><B>Uniform:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_ICLOTHING]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_ICLOTHING])]</A>"
		if (clothing[SLOT_MANNEQUIN_ICLOTHING])
			var/obj/item/I = clothing[SLOT_MANNEQUIN_ICLOTHING]
			if (istype(I, /obj/item/clothing))
				var/obj/item/clothing/C = I
				if (C.hood)
					dat += "<BR>[HTMLTAB]&#8627;<B>Hood:</B> <A href='?src=\ref[src];toggle_uniform_hood=1'>Toggle</A>"
		if(!primitive)
			dat += "<BR><B>Belt:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_BELT]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_BELT])]</A>"
			dat += "<BR><B>ID:</B> <A href='?src=\ref[src];item=[SLOT_MANNEQUIN_ID]'>[makeStrippingButton(clothing[SLOT_MANNEQUIN_ID])]</A>"

	dat += "<BR>"
	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mannequin\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()


/obj/structure/mannequin/proc/canEquip(var/mob/user, var/item_slot, var/obj/item/itemToCheck)
	if((fat && ((item_slot == SLOT_MANNEQUIN_ICLOTHING) || (item_slot == SLOT_MANNEQUIN_OCLOTHING))) || ((species.anatomy_flags & IS_BULKY) && ((item_slot == SLOT_MANNEQUIN_ICLOTHING) || (item_slot == SLOT_MANNEQUIN_OCLOTHING) || (item_slot == SLOT_MANNEQUIN_FEET) || (item_slot == SLOT_MANNEQUIN_GLOVES) || (item_slot == SLOT_MANNEQUIN_MASK))))
		if(!(itemToCheck.clothing_flags & ONESIZEFITSALL))
			if(user)
				to_chat(user, "<span class='warning'>\The [src] is too large for \the [itemToCheck]</span>")
			return FALSE

	if (corgi)
		switch(item_slot)
			if(SLOT_MANNEQUIN_HEAD)
				if(itemToCheck.type in valid_corgi_hats)
					return TRUE
			if(SLOT_MANNEQUIN_BACK)
				if(itemToCheck.type in valid_corgi_backpacks)
					return TRUE
		if(user)
			to_chat(user, "<span class='warning'>\The [itemToCheck] doesn't fit there.</span>")
		return FALSE

	var/inv_slot

	switch(item_slot)//human slot defines are bitflags, so mannequins require their own string-based slot defines to avoid bugs when using lists.
		if(SLOT_MANNEQUIN_ICLOTHING)
			inv_slot = SLOT_ICLOTHING
		if(SLOT_MANNEQUIN_FEET)
			inv_slot = SLOT_FEET
		if(SLOT_MANNEQUIN_GLOVES)
			inv_slot = SLOT_GLOVES
		if(SLOT_MANNEQUIN_EARS)
			inv_slot = SLOT_EARS
		if(SLOT_MANNEQUIN_OCLOTHING)
			inv_slot = SLOT_OCLOTHING
		if(SLOT_MANNEQUIN_EYES)
			inv_slot = SLOT_EYES
		if(SLOT_MANNEQUIN_BELT)
			inv_slot = SLOT_BELT
		if(SLOT_MANNEQUIN_MASK)
			inv_slot = SLOT_MASK
		if(SLOT_MANNEQUIN_HEAD)
			inv_slot = SLOT_HEAD
		if(SLOT_MANNEQUIN_BACK)
			inv_slot = SLOT_BACK
		if(SLOT_MANNEQUIN_ID)
			inv_slot = SLOT_ID

	if(itemToCheck.slot_flags & inv_slot)
		return TRUE

	if(user)
		to_chat(user, "<span class='warning'>\The [itemToCheck] doesn't fit there.</span>")
	return FALSE

/obj/structure/mannequin/update_icon()
	..()
	overlays.len = 0
	var/mutable_appearance/mannequin_overlay = mutable_appearance()
	var/vox_suffix = ""
	if(species && species.name == "Vox")
		vox_suffix = "_0"
	if(hair_style)
		var/datum/sprite_accessory/hair_style_sprite = hair_styles_list[hair_style]
		var/mutable_appearance/hair_style_overlay = mutable_appearance('icons/mob/hair_styles.dmi', "[hair_style_sprite.icon_state][vox_suffix]_s")
		if(hair_style_sprite.additional_accessories)
			hair_style_overlay.overlays += mutable_appearance('icons/mob/hair_styles.dmi', "[hair_style_sprite.icon_state]_acc")
		var/color_blend_matrix = COLOR_MATRIX_ADD(hair_color)
		if(species && species.name != "Human")
			color_blend_matrix = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), hair_color)
		hair_style_overlay.color = color_blend_matrix
		mannequin_overlay.overlays += hair_style_overlay
	if(beard_style)
		var/datum/sprite_accessory/beard_style_sprite = facial_hair_styles_list[beard_style]
		var/mutable_appearance/beard_style_overlay = mutable_appearance('icons/mob/hair_styles.dmi', "[beard_style_sprite.icon_state]_s")
		if(beard_style_sprite.additional_accessories)
			beard_style_overlay.overlays += mutable_appearance('icons/mob/hair_styles.dmi', "[beard_style_sprite.icon_state]_acc")
		var/color_blend_matrix = COLOR_MATRIX_ADD(hair_color)
		if(species && species.name != "Human")
			color_blend_matrix = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), hair_color)
		beard_style_overlay.color = color_blend_matrix
		mannequin_overlay.overlays += beard_style_overlay
	for(var/cloth_slot in clothing)
		update_icon_slot(mannequin_overlay, cloth_slot)
	for(var/i in 1 to held_items.len)
		update_icon_hand(mannequin_overlay, i)
	if(icon != 'icons/obj/mannequin_64x64.dmi')
		if(has_pedestal)
			icon = 'icons/obj/mannequin.dmi'
			mannequin_overlay.pixel_x = clothing_offset_x
			mannequin_overlay.pixel_y = clothing_offset_y
		else
			icon = 'icons/mob/mannequin.dmi'
	else
		mannequin_overlay.pixel_x = clothing_offset_x
		mannequin_overlay.pixel_y = clothing_offset_y
	overlays += mannequin_overlay

/obj/structure/mannequin/proc/update_icon_slot(mutable_appearance/mannequin_overlay, slot)
	var/obj/item/clothing/clothToUpdate = clothing[slot]
	if(clothToUpdate)
		var/t_state = clothToUpdate.icon_state
		var/mutable_appearance/slot_overlay
		var/list/slotIcon = all_slot_icons[slot]

		switch(slot)
			if(SLOT_MANNEQUIN_ICLOTHING,SLOT_MANNEQUIN_OCLOTHING)
				if(clothToUpdate._color)
					t_state = clothToUpdate._color
				if(fat || species.anatomy_flags & IS_BULKY)
					if(clothToUpdate.clothing_flags&ONESIZEFITSALL)
						slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_FAT], "[t_state]_s")
				else if(primitive)
					t_state = clothToUpdate.item_state || clothToUpdate.icon_state
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_PRIMITIVE], "[t_state]")
				else
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_SLOT], "[t_state][(slot == SLOT_MANNEQUIN_ICLOTHING) ? "_s" : ""]")
			else
				if(primitive)
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_PRIMITIVE], t_state)
				else if (corgi)
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_CORGI], t_state)
				else if(clothToUpdate.icon_override)
					slot_overlay = mutable_appearance(clothToUpdate.icon_override, t_state)
				else
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_SLOT], t_state)

		var/icon/species_icon
		if(species.name in clothToUpdate.species_fit)
			species_icon = slotIcon[MANNEQUIN_ICONS_SPECIES]
			if(species_icon)
				slot_overlay.icon = species_icon

		if(clothToUpdate.icon_override)
			slot_overlay.icon = clothToUpdate.icon_override

		if(clothToUpdate.clothing_flags & COLORS_OVERLAY)
			slot_overlay.color = clothToUpdate.color

		mannequin_overlay.overlays += slot_overlay

		if(clothToUpdate.dynamic_overlay)
			if(clothToUpdate.dynamic_overlay["[slotIcon[MANNEQUIN_DYNAMIC_LAYER]]"])
				var/mutable_appearance/dyn_overlay = clothToUpdate.dynamic_overlay["[slotIcon[MANNEQUIN_DYNAMIC_LAYER]]"]

				if(species_icon)
					dyn_overlay = replace_overlays_icon(dyn_overlay, species_icon)

				mannequin_overlay.overlays += dyn_overlay

		if(clothToUpdate.blood_DNA && clothToUpdate.blood_DNA.len)
			var/bloodsies_state = get_bloodsies_state(clothToUpdate,slot)
			if(bloodsies_state)
				var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', bloodsies_state)
				bloodsies.color	 = clothToUpdate.blood_color
				mannequin_overlay.overlays += bloodsies

		clothToUpdate.generate_accessory_overlays(mannequin_overlay, species)

		if(istype(clothToUpdate,/obj/item/clothing/head))
			var/obj/item/clothing/head/hat = clothToUpdate
			var/i = 1
			for(var/obj/item/clothing/head/above = hat.on_top; above; above = above.on_top)
				if(primitive)
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_PRIMITIVE], above.icon_state)
				else if (corgi)
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_CORGI], above.icon_state)
				else if(clothToUpdate.icon_override)
					slot_overlay = mutable_appearance(above.icon_override, above.icon_state)
				else
					slot_overlay = mutable_appearance(slotIcon[MANNEQUIN_ICONS_SLOT], above.icon_state)

				if(species.name in above.species_fit)
					if(species_icon)
						slot_overlay.icon = species_icon

				slot_overlay.pixel_y = (2 * i) * PIXEL_MULTIPLIER
				mannequin_overlay.overlays += slot_overlay

				if(above.dynamic_overlay)
					if(above.dynamic_overlay["[slotIcon[MANNEQUIN_DYNAMIC_LAYER]]"])
						var/mutable_appearance/dyn_overlay = above.dynamic_overlay["[slotIcon[MANNEQUIN_DYNAMIC_LAYER]]"]
						if(species_icon)
							dyn_overlay = replace_overlays_icon(dyn_overlay, species_icon)
						dyn_overlay.pixel_y = (2 * i) * PIXEL_MULTIPLIER
						mannequin_overlay.overlays += dyn_overlay

				if(above.blood_DNA && above.blood_DNA.len)
					var/bloodsies_state = get_bloodsies_state(above,slot)
					if(bloodsies_state)
						var/mutable_appearance/bloodsies = mutable_appearance('icons/effects/blood.dmi', bloodsies_state)
						bloodsies.color	= above.blood_color
						bloodsies.pixel_y = (2 * i) * PIXEL_MULTIPLIER
						mannequin_overlay.overlays += bloodsies
				//above.generate_accessory_overlays(O, species)
				i++

/obj/structure/mannequin/proc/update_icon_hand(mutable_appearance/hand_overlay, index)
	var/obj/item/heldItem = get_held_item_by_index(index)

	if(heldItem)
		var/t_state = heldItem.item_state || heldItem.icon_state
		var/t_inhand_state = heldItem.inhand_states[get_direction_by_index(index)]
		var/icon/check_dimensions = new(t_inhand_state)
		var/mutable_appearance/held_item_overlay = mutable_appearance(t_inhand_state, t_state)
		held_item_overlay.pixel_x = -1*(check_dimensions.Width() - WORLD_ICON_SIZE)/2
		held_item_overlay.pixel_y = -1*(check_dimensions.Height() - WORLD_ICON_SIZE)/2

		var/list/offsets = get_item_offset_by_index(index)

		held_item_overlay.pixel_x += offsets["x"]
		held_item_overlay.pixel_y += offsets["y"]

		if(heldItem.dynamic_overlay && heldItem.dynamic_overlay["[HAND_LAYER]-[index]"])
			var/mutable_appearance/dyn_overlay = heldItem.dynamic_overlay["[HAND_LAYER]-[index]"]
			held_item_overlay.overlays += dyn_overlay

		hand_overlay.overlays += held_item_overlay

/obj/structure/mannequin/proc/get_slot_icons(var/slot)
	var/list/slotIcon = list()

	var/datum/species/default_icons = new()

	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.uniform_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = 'icons/mob/monkey.dmi'
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.uniform_icons
			slotIcon[MANNEQUIN_ICONS_FAT] = species.fat_uniform_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = UNIFORM_LAYER
		if(SLOT_MANNEQUIN_FEET)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.shoes_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.shoes_icons
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.shoes_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = SHOES_LAYER
		if(SLOT_MANNEQUIN_GLOVES)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.gloves_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.gloves_icons
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.gloves_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = GLOVES_LAYER
		if(SLOT_MANNEQUIN_EARS)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.ears_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.ears_icons
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.ears_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = EARS_LAYER
		if(SLOT_MANNEQUIN_OCLOTHING)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.wear_suit_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.wear_suit_icons
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.wear_suit_icons
			slotIcon[MANNEQUIN_ICONS_FAT] = species.fat_wear_suit_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = SUIT_LAYER
		if(SLOT_MANNEQUIN_EYES)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.glasses_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = 'icons/mob/monkey_eyes.dmi'
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.glasses_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = GLASSES_LAYER
		if(SLOT_MANNEQUIN_BELT)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.belt_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.belt_icons
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.belt_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = BELT_LAYER
		if(SLOT_MANNEQUIN_MASK)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.wear_mask_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = 'icons/mob/monkey.dmi'
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.wear_mask_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = FACEMASK_LAYER
		if(SLOT_MANNEQUIN_HEAD)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.head_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = 'icons/mob/monkey_head.dmi'
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.head_icons
			slotIcon[MANNEQUIN_ICONS_CORGI] = 'icons/mob/corgi_head.dmi'
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = HEAD_LAYER
		if(SLOT_MANNEQUIN_BACK)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.back_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.back_icons
			slotIcon[MANNEQUIN_ICONS_SPECIES] = species.back_icons
			slotIcon[MANNEQUIN_ICONS_CORGI] = 'icons/mob/corgi_back.dmi'
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = BACK_LAYER
		if(SLOT_MANNEQUIN_ID)
			slotIcon[MANNEQUIN_ICONS_SLOT] = default_icons.id_icons
			slotIcon[MANNEQUIN_ICONS_PRIMITIVE] = default_icons.id_icons
			slotIcon[MANNEQUIN_DYNAMIC_LAYER] = ID_LAYER

	qdel(default_icons)

	return slotIcon

/obj/structure/mannequin/proc/get_bloodsies_state(var/slot, var/obj/item/clothToWear)
	switch(slot)
		if(SLOT_MANNEQUIN_ICLOTHING)
			return "uniformblood"
		if(SLOT_MANNEQUIN_FEET)
			return "shoeblood"
		if(SLOT_MANNEQUIN_GLOVES)
			return "bloodyhands"
		if(SLOT_MANNEQUIN_OCLOTHING)
			var/obj/item/clothing/suit/C = clothToWear
			return "[C.blood_overlay_type]blood"
		if(SLOT_MANNEQUIN_MASK)
			return "maskblood"
		if(SLOT_MANNEQUIN_HEAD)
			return "helmetblood"
		else
			return null

/obj/structure/mannequin/proc/checkMappingWear()

	var/list/mapped_clothing = list(
		SLOT_MANNEQUIN_ICLOTHING = mapping_uniform,
		SLOT_MANNEQUIN_FEET = mapping_shoes,
		SLOT_MANNEQUIN_GLOVES = mapping_gloves,
		SLOT_MANNEQUIN_EARS = mapping_ears,
		SLOT_MANNEQUIN_OCLOTHING = mapping_suit,
		SLOT_MANNEQUIN_EYES = mapping_glasses,
		SLOT_MANNEQUIN_BELT = mapping_belt,
		SLOT_MANNEQUIN_MASK = mapping_mask,
		SLOT_MANNEQUIN_HEAD = mapping_hat,
		SLOT_MANNEQUIN_BACK = mapping_back,
		SLOT_MANNEQUIN_ID = mapping_id,
		)

	for(var/mapped_slot in mapped_clothing)
		var/mapped_cloth = mapped_clothing[mapped_slot]
		if(mapped_cloth)
			var/obj/item/clothToWear = new mapped_cloth(src)
			if(canEquip(null, mapped_slot, clothToWear))
				clothing[mapped_slot] = clothToWear
				clothToWear.mannequin_equip(src,mapped_slot)
			else
				qdel(clothToWear)

	if(mapping_hand_right)
		var/obj/item/clothToWear = new mapping_hand_right(src)
		held_items[GRASP_RIGHT_HAND] = clothToWear
		clothToWear.mannequin_equip(src,"hands",GRASP_RIGHT_HAND)
	if(mapping_hand_left)
		var/obj/item/clothToWear = new mapping_hand_left(src)
		held_items[GRASP_LEFT_HAND] = clothToWear
		clothToWear.mannequin_equip(src,"hands",GRASP_LEFT_HAND)

	update_icon()


/obj/structure/mannequin/proc/spin()
	INVOKE_EVENT(src, /event/before_move)
	change_dir(turn(dir, 90))
	INVOKE_EVENT(src, /event/after_move)

/obj/structure/mannequin/verb/rotate_mannequin()
	set name = "Rotate Mannequin"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(anchored)
		return

	if(usr.isUnconscious() || usr.restrained())
		return

	spin()


/obj/structure/mannequin/woman
	name = "human woman marble mannequin"
	icon_state="mannequin_marble_human_woman"
	gender = FEMALE

/obj/structure/mannequin/fat
	name = "fat human marble mannequin"
	icon_state="mannequin_marble_fat_human"
	fat = 1

/obj/structure/mannequin/vox
	name = "vox marble mannequin"
	icon_state="mannequin_marble_vox"
	species_type = /datum/species/vox

/obj/structure/mannequin/monkey
	name = "monkey marble mannequin"
	icon_state="mannequin_marble_monkey"
	primitive = 1
	clothing_offset_y = -5*PIXEL_MULTIPLIER

/obj/structure/mannequin/corgi
	name = "corgi marble mannequin"
	icon_state="mannequin_marble_corgi"
	corgi = 1

/obj/structure/mannequin/wood
	name = "human man wooden mannequin"
	desc = "This should look great in a visual arts workshop."
	icon_state="mannequin_wooden_human"
	hair_color = "#705036"
	health = 30
	maxHealth = 30
	trueForm = /mob/living/simple_animal/hostile/mannequin/wood
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 2.5

/obj/structure/mannequin/wood/New(turf/loc, var/f_style, var/h_style, var/list/items_to_wear, var/list/items_to_hold, var/mob_to_capture)
	..()
	if (mob_to_capture)
		if(iscorgi(mob_to_capture))
			desc = "If it takes forever, I will wait for you..."
		else
			desc = "An incredibly lifelike wooden carving."

/obj/structure/mannequin/wood/breakDown()
	new /obj/item/stack/sheet/wood(loc, 5)//You get half the materials used to make a block bac)
	..()

/obj/structure/mannequin/wood/dissolve()
	return

/obj/structure/mannequin/wood/woman
	name = "human woman wooden mannequin"
	icon_state="mannequin_wooden_human_woman"
	gender = FEMALE

/obj/structure/mannequin/wood/fat
	name = "fat human wooden mannequin"
	icon_state="mannequin_wooden_fat_human"
	fat = 1

/obj/structure/mannequin/wood/vox
	name = "vox wooden mannequin"
	icon_state="mannequin_wooden_vox"
	species_type = /datum/species/vox

/obj/structure/mannequin/wood/monkey
	name = "monkey wooden mannequin"
	icon_state="mannequin_wooden_monkey"
	primitive = 1
	clothing_offset_y = -5*PIXEL_MULTIPLIER

/obj/structure/mannequin/wood/corgi
	name = "corgi wooden mannequin"
	icon_state="mannequin_wooden_corgi"
	corgi = 1

/obj/structure/mannequin/animationBolt(var/mob/firer)
	if(captured && ismob(captured))
		var/mob/M = captured
		M.sdisabilities &= ~MUTE
	Awaken(firer)

/obj/structure/mannequin/proc/Awaken(var/mob/firer)
	if(awakening)
		return
	awakening = 1
	for(var/obj/structure/mannequin/M in range(src,chaintrap_range))
		M.Awaken()
	if (has_pedestal)
		var/obj/item/trash/mannequin/newPedestal = new pedestal(loc)
		newPedestal.dir = dir
	var/mob/living/simple_animal/hostile/mannequin/livingMannequin = new trueForm(loc)
	livingMannequin.name = name
	livingMannequin.icon_state = icon_state
	livingMannequin.health = health
	livingMannequin.maxHealth = maxHealth
	livingMannequin.dir = dir
	livingMannequin.additional_damage = additional_damage
	livingMannequin.timer = timer
	if (captured)
		livingMannequin.captured_mob = captured
		captured.forceMove(livingMannequin)
		captured = null
	var/mutable_appearance/transferred_overlays = mutable_appearance('icons/effects/32x32.dmi',"blank")
	transferred_overlays.overlays |= overlays
	if(has_pedestal)
		transferred_overlays.pixel_x = -clothing_offset_x
		transferred_overlays.pixel_y = -clothing_offset_y
	livingMannequin.overlays += transferred_overlays
	for(var/slot in clothing)
		if(clothing[slot])
			var/obj/item/cloth = clothing[slot]
			cloth.mannequin_unequip(src)
			cloth.forceMove(livingMannequin)
			cloth.mannequin_equip(livingMannequin,slot)
			livingMannequin.clothing[slot] = cloth
			clothing[slot] = null
	if (held_items?.len)
		for(var/index = 1 to held_items.len)
			var/obj/item/tool = get_held_item_by_index(index)
			if (!tool)
				continue
			tool.mannequin_unequip(src)
			tool.forceMove(livingMannequin)
			tool.mannequin_equip(livingMannequin,"hands",index)
			livingMannequin.held_items[index] = tool
			held_items -= tool

			//If we're holding a weapon stronger than our base damage, let's use it instead
			if(tool.force >= livingMannequin.melee_damage_lower)
				livingMannequin.melee_damage_lower = tool.force
				livingMannequin.melee_damage_upper = tool.force
				livingMannequin.equipped_melee_weapon = tool

			if (livingMannequin.equipped_melee_weapon)
				livingMannequin.attacktext = "swings \the [livingMannequin.equipped_melee_weapon] at"
				visible_message("<span class='warning'>\The [src] grips \the [livingMannequin.equipped_melee_weapon].</span>")
				if(livingMannequin.equipped_melee_weapon.hitsound)
					livingMannequin.attack_sound = livingMannequin.equipped_melee_weapon.hitsound

			if (istype(tool, /obj/item/weapon/gun))
				livingMannequin.equipGun(tool)
	if(firer)
		livingMannequin.faction = "\ref[firer]"
	qdel(src)

/////////////////////////////////////////////////////////BLOCKS//////////////////////////////////////////////////////////
//Use a chisel on those to sculpt them into mannequins.

/obj/structure/block
	name = "marble block"
	desc = "Grab your chisel and get to work!"
	anchored = 0
	density = 1
	icon = 'icons/obj/mannequin.dmi'
	icon_state = "marble"
	var/time_to_sculpt = 200
	var/list/available_sculptures = list(
		"human man"		=	/obj/structure/mannequin,
		"human woman"	=	/obj/structure/mannequin/woman,
		"fat human"	=	/obj/structure/mannequin/fat,
		"monkey"	=	/obj/structure/mannequin/monkey,
		"vox"		=	/obj/structure/mannequin/vox,
		"corgi"		=	/obj/structure/mannequin/corgi,
		)

/obj/structure/block/attackby(var/obj/item/weapon/W,var/mob/user)
	if(W.is_wrench(user))
		return wrenchAnchor(user, W, 5 SECONDS)
	else if(istype(W, /obj/item/weapon/chisel))
		var/beard_style
		var/hair_style
		var/chosen_gender = MALE
		var/chosen_species_name = "Human"
		var/chosen_sculpture = input("Choose a sculpture type.", "[name]") as null|anything in available_sculptures
		if(!chosen_sculpture || !Adjacent(user))
			return
		if (chosen_sculpture == "human woman")
			chosen_gender = FEMALE
		if (chosen_sculpture == "vox")
			chosen_species_name = "Vox"
		if (chosen_sculpture != "monkey" && chosen_sculpture != "corgi")
			var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, chosen_species_name)
			if(species_hair.len)
				hair_style = input(user, "Select a hair style", "Scuplting Hair") as null|anything in species_hair

			if (chosen_gender != FEMALE)
				var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, chosen_gender, chosen_species_name)
				if(species_facial_hair.len)
					beard_style = input(user, "Select a beard style", "Sculpting Beard") as null|anything in species_facial_hair
		if(!Adjacent(user))
			return
		user.visible_message("[user.name] starts sculpting \the [src] with a passion!","You start sculpting \the [src] with a passion!","You hear a repeated knocking sound.")
		var/turf/T=get_turf(src)

		if(do_after(user, src, time_to_sculpt))
			new /obj/effect/decal/cleanable/dirt(T)
			var/mannequin_type = available_sculptures[chosen_sculpture]
			var/obj/structure/mannequin/M = new mannequin_type(T,beard_style,hair_style)
			M.anchored = anchored
			M.add_fingerprint(user)
			user.visible_message("[user.name] finishes \the [M].","You finish \the [M].")
			qdel(src)
		return 1
	else
		..()


/obj/structure/block/wood
	name = "wooden block"
	icon_state = "wooden"
	time_to_sculpt = 100
	available_sculptures = list(
		"human man"		=	/obj/structure/mannequin/wood,
		"human woman"	=	/obj/structure/mannequin/wood/woman,
		"fat human"	=	/obj/structure/mannequin/wood/fat,
		"monkey"	=	/obj/structure/mannequin/wood/monkey,
		"vox"		=	/obj/structure/mannequin/wood/vox,
		"corgi"		=	/obj/structure/mannequin/wood/corgi,
		)
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 5







/////////////////////////////////////////////////////////CYBER MANNEQUIN//////////////////////////////////////////////////////////
//Mannequin meets Display Case.

/obj/structure/mannequin/cyber
	name = "human cyber mannequin"
	desc = "Holy shit."
	icon = 'icons/obj/mannequin_64x64.dmi'
	icon_state="mannequin_cyber_human"
	trueForm = /mob/living/simple_animal/hostile/mannequin/cyber
	pedestal = /obj/item/trash/mannequin/large
	pixel_x = -1*(WORLD_ICON_SIZE/2)
	clothing_offset_x = 16*PIXEL_MULTIPLIER
	clothing_offset_y = 7*PIXEL_MULTIPLIER
	health = 150
	maxHealth = 150
	var/shield = 50
	var/maxShield = 50
	var/destroyed = 0
	var/locked = 0

/obj/structure/mannequin/cyber/New()
	..()
	update_icon()

/obj/structure/mannequin/cyber/breakDown()
	new /obj/item/stack/sheet/metal(loc, 5)//You get half the materials used to make a mannequin frame back)
	var/parts_list = list(
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/r_leg,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/l_arm,
		)

	for(var/part in parts_list)
		if(prob(40))//And 40% chance to get each robot limb back.
			new part(loc)

	if(prob(40))
		var/obj/item/weapon/circuitboard/airlock/C = new(loc)
		C.one_access=!(req_access && req_access.len>0)
		if(!C.one_access)
			C.conf_access=req_access
		else
			C.conf_access=req_one_access

	qdel(src)

/obj/structure/mannequin/cyber/dissolve()
	return

/obj/structure/mannequin/cyber/ex_act(severity)
	switch(severity)
		if (1)
			if(destroyed)
				qdel(src)
			else
				destroyed = 1
				new /obj/item/weapon/shard(loc)
				playsound(src, "shatter", 100, 1)
				shield = 0
				update_icon()
		if (2)
			if (prob(50))
				getDamage(30)
			else
				getDamage(20)
		if (3)
			if (prob(50))
				getDamage(10)

/obj/structure/mannequin/cyber/getDamage(var/damage)
	if(destroyed || !locked)
		health -= damage
	else
		shield -= damage
	healthCheck()
	if((destroyed || !locked) && health > 0 && (trapped_strip || trapped_prox))
		Awaken()

/obj/structure/mannequin/cyber/blob_act()
	if(!destroyed && locked)
		getDamage(30)
	else if (prob(75))
		breakDown()
	else
		getDamage(30)

/obj/structure/mannequin/cyber/healthCheck()
	if(!destroyed	)
		if(shield <= 0)
			destroyed = 1
			locked = 0
			new /obj/item/weapon/shard(loc)
			playsound(src, "shatter", 100, 1)
			update_icon()
		else
			playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)

	if(health <= 0)
		visible_message("\The [src] collapses.")
		breakDown()

/obj/structure/mannequin/cyber/attackby(var/obj/item/weapon/W,var/mob/user)
	if(istype(W, /obj/item/weapon/card/id))
		if(destroyed)
			to_chat(user, "<span class='warning'>There is no longer any lock to toggle.</span>")
		else
			var/obj/item/weapon/card/id/I=W
			if(!check_access(I))
				to_chat(user, "<span class='rose'>Access denied.</span>")
				return
			locked = !locked
			if(!locked)
				to_chat(user, "[bicon(src)] <span class='notice'>\The [src] clicks as locks release, and it slowly opens for you.</span>")
			else
				to_chat(user, "[bicon(src)] <span class='notice'>You close \the [src] and swipe your card, locking it.</span>")
			update_icon()
	else if(iscrowbar(W) && (!locked || destroyed))
		user.visible_message("[user.name] pries \the [src] apart.", \
			"You pry \the [src] apart.", \
			"You hear something pop.")
		var/turf/T=get_turf(src)
		W.playtoolsound(T, 50)

		if(do_after(user, src, 100))
			var/obj/item/weapon/circuitboard/airlock/C = new(src)
			C.one_access=!(req_access && req_access.len>0)

			if(!C.one_access)
				C.conf_access=req_access
			else
				C.conf_access=req_one_access

			if(!destroyed)
				new /obj/item/stack/sheet/glass/glass(T, 1)

			C.forceMove(T)

			var/obj/structure/mannequin_frame/new_frame = new(T)
			new_frame.icon_state = "mannequin_cyber_human"
			new_frame.overlays |= mutable_appearance(icon, "lightout")
			new_frame.construct = new /datum/construction/mannequin(new_frame)
			qdel(src)

	else if(iswelder(W) && user.a_intent == I_HELP)
		if(locked)
			to_chat(user, "<span class='warning'>You need to open the shield before you can fix the mannequin.</span>")
		else
			if(health >= maxHealth)
				to_chat(user, "<span class='warning'>Nothing to fix here!</span>")
				return
			var/obj/item/tool/weldingtool/WT = W
			if(WT.remove_fuel(5))
				WT.playtoolsound(loc, 50)
				health = min(health + 20, maxHealth)
				to_chat(user, "<span class='notice'>You fix some of the dents on \the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
				return

	else if(iswelder(W) && user.a_intent == I_HELP)
		if(locked)
			to_chat(user, "<span class='warning'>You need to open the shield before you can fix the mannequin.</span>")
		else
			if(health >= maxHealth)
				to_chat(user, "<span class='warning'>Nothing to fix here!</span>")
				return
			var/obj/item/tool/weldingtool/WT = W
			if(WT.remove_fuel(5))
				WT.playtoolsound(loc, 50)
				health = min(health + 20, maxHealth)
				to_chat(user, "<span class='notice'>You fix some of the dents on \the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>Need more welding fuel!</span>")
				return

	else if(istype(W, /obj/item/device/silicate_sprayer))
		if(!locked)
			to_chat(user, "<span class='warning'>You need to lock the shield before you can fix it.</span>")
		else
			if(shield >= maxShield)
				to_chat(user, "<span class='warning'>Nothing to fix here!</span>")
				return
			var/obj/item/device/silicate_sprayer/SS = W
			if(SS.get_amount() >= 5)
				SS.remove_silicate(5)
				playsound(loc, 'sound/effects/refill.ogg', 50, 1)
				shield = min(shield + 20, maxShield)
				to_chat(user, "<span class='notice'>You fix some of the dents on \the [src]'s shield!</span>")
			else
				to_chat(user, "<span class='warning'>Need more silicate!</span>")
				return

	else if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		getDamage(W.force)
		user.visible_message("<span class='danger'>[user.name] [(W.attack_verb && W.attack_verb.len) ? "[pick(W.attack_verb)]" : "attacks" ] \the [src] with \the [W]!</span>", "<span class='danger'>You [(W.attack_verb && W.attack_verb.len) ? "[pick(W.attack_verb)]" : "attack" ] \the [src] with \the [W]!</span>")
	else
		return ..()

/obj/structure/mannequin/cyber/update_icon()
	overlays.len = 0
	..()
	if(destroyed)
		overlays |= mutable_appearance(icon, "mannequin_cover_broken")
	else if(locked)
		overlays |= mutable_appearance(icon, "mannequin_cover")


/obj/structure/mannequin/cyber/attack_hand(var/mob/living/user)
	if(destroyed)
		show_inv(user)
	else if(locked)
		if(user.a_intent == I_HURT)
			user.delayNextAttack(8)
			user.visible_message("<span class='danger'>[user.name] punches \the [src]!</span>", "<span class='danger'>You punch \the [src]!</span>", "You hear glass crack.")
			getDamage(rand(1,7) * (user.get_strength() - 1))
		else
			to_chat(user,"<span class='notice'>You gently run your hands over \the [src] in appreciation of its contents.</span>")
	else
		..()


/obj/structure/mannequin/cyber/kick_act(mob/living/carbon/human/H)
	if(locked)
		playsound(src, 'sound/effects/glassknock.ogg', 100, 1)
	..()


/obj/structure/mannequin/cyber/examine(mob/user)
	..()
	if(destroyed)
		to_chat(user, "Its glass shield has been shattered.")

/obj/structure/mannequin/cyber/broken
	health = 100
	destroyed = 1

/obj/structure/mannequin/cyber/animationBolt(var/mob/firer)
	if(destroyed || !locked)
		Awaken(firer)

/obj/structure/mannequin/cyber/Awaken(var/mob/firer)
	destroyed = 0
	locked = 0
	update_icon()
	..()

/////////////////////////////////////////////////////////MANNEQUIN FRAME//////////////////////////////////////////////////////////
//Used to build cyber mannequins.

/obj/structure/mannequin_frame
	name = "human cyber mannequin frame"
	desc = "Lots of work just to display some clothes."
	icon = 'icons/obj/mannequin_64x64.dmi'
	icon_state="mannequin_cyber_human_frame"
	pixel_x = -1*(WORLD_ICON_SIZE/2)
	anchored = 0
	density = 0
	var/datum/construction/construct

/obj/structure/mannequin_frame/New()
	..()
	construct = new /datum/construction/mannequin_frame(src)

/obj/structure/mannequin_frame/attackby(var/obj/item/W, var/mob/user)
	if(!construct || !construct.action(W, user))
		..()

/datum/construction/mannequin_frame/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
	holder.overlays += mutable_appearance(holder.icon, used_atom.icon_state)
	QDEL_NULL (used_atom)
	return 1

/datum/construction/mannequin_frame/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mannequin_frame
	steps = list(
				list(Co_KEY=/obj/item/robot_parts/head),
				list(Co_KEY=/obj/item/robot_parts/chest),
				list(Co_KEY=/obj/item/robot_parts/r_leg),
				list(Co_KEY=/obj/item/robot_parts/l_leg),
				list(Co_KEY=/obj/item/robot_parts/r_arm),
				list(Co_KEY=/obj/item/robot_parts/l_arm)
				)

/datum/construction/mannequin_frame/spawn_result(mob/user as mob)
	var/obj/structure/mannequin_frame/const_holder = holder
	const_holder.construct = new /datum/construction/mannequin(const_holder)
	const_holder.overlays.len = 0
	const_holder.icon_state = "mannequin_cyber_human"
	const_holder.overlays |= mutable_appearance(const_holder.icon, "lightout")
	qdel(src)

/datum/construction/mannequin

/datum/construction/mannequin
	result = /obj/structure/mannequin/cyber
	var/base_icon = "station_map_frame"

	steps = list(
		list(
			Co_DESC="The frame needs a glass shield.",
			Co_KEY=/obj/item/stack/sheet/glass/glass,
			Co_AMOUNT = 1,
			Co_VIS_MSG = "{USER} install{s} the glass shield to {HOLDER}.",
			Co_DELAY = 20
			),
		list(
			Co_DESC="The frame needs an airlock circuitboard.",
			Co_KEY=/obj/item/weapon/circuitboard/airlock,
			Co_AMOUNT = 1,
			Co_VIS_MSG = "{USER} install{s} the circuitboard into {HOLDER}.",
			)
		)

/datum/construction/mannequin/custom_action(step, atom/used_atom, mob/user)
	if(!..())
		return 0

	if(istype(used_atom, /obj/item/weapon/circuitboard/airlock))
		var/obj/item/weapon/circuitboard/airlock/circuit = used_atom
		var/obj/structure/mannequin_frame/const_holder = holder
		if(circuit.one_access)
			const_holder.req_access = null
			const_holder.req_one_access = circuit.conf_access
		else
			const_holder.req_access = circuit.conf_access
			const_holder.req_one_access = null

		const_holder.icon_state = "mannequin_cyber_human"
		const_holder.overlays -= mutable_appearance(const_holder.icon, "lightout")

	return 1

/datum/construction/mannequin/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/mannequin/spawn_result(mob/user as mob)
	if(result)
//		testing("[user] finished a [result]!")

		var/obj/structure/mannequin_frame/const_holder = holder
		var/obj/structure/mannequin/cyber/C = new result(get_turf(holder))
		C.anchored = 0
		C.req_access = const_holder.req_access
		C.req_one_access = const_holder.req_one_access

		QDEL_NULL (holder)

	feedback_inc("cyber_mannequin_created",1)

//////////////////////////////////////////CULT MANNEQUIN/////////////////////////////

/obj/structure/mannequin/cultify()
	var/obj/structure/mannequin/cult/C = new (loc)
	C.dir = dir
	C.anchored = anchored
	for(var/cloth in clothing)
		if(clothing[cloth])
			var/obj/item/cloth_to_drop = clothing[cloth]
			cloth_to_drop.forceMove(C)
			C.clothing[cloth] = cloth_to_drop
	for(var/i = 1 to held_items.len)
		var/obj/item_to_drop = held_items[i]
		if(item_to_drop)
			item_to_drop.forceMove(C)
			C.held_items[i] = item_to_drop
	C.update_icon()
	qdel(src)


/obj/structure/mannequin/cult
	name = "cult mannequin"
	desc = "Has Nar-Sie been taking sculpting classes?"
	icon = 'icons/obj/mannequin_64x64.dmi'
	icon_state="mannequin_cult"
	pedestal = /obj/item/trash/mannequin/cult
	pixel_x = -1*(WORLD_ICON_SIZE/2)
	clothing_offset_x = 16*PIXEL_MULTIPLIER
	clothing_offset_y = 7*PIXEL_MULTIPLIER
	health = 100
	maxHealth = 100
	density = 1
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER
	flags = FPRINT | PROXMOVE
	trueForm = /mob/living/simple_animal/hostile/mannequin/cult
	species_type = /datum/species/human

	trapped_strip = 1
	chaintrap_range = 3

	var/monsters_to_spawn = 2

/obj/structure/mannequin/cult/Awaken(var/mob/firer)
	if(awakening)
		return
	var/list/possible_floors = list()
	for (var/turf/simulated/floor/F in orange(1,get_turf(src)))
		possible_floors.Add(F)
	for (var/i = 1 to monsters_to_spawn)
		if (possible_floors.len <= 0)
			break
		var/turf/T = pick(possible_floors)
		if (T)
			possible_floors.Remove(T)
			new /obj/effect/cult_ritual/backup_spawn(T)
	..()

/obj/structure/mannequin/cult/cultify()
	return

#undef MANNEQUIN_ICONS_SLOT
#undef MANNEQUIN_ICONS_PRIMITIVE
#undef MANNEQUIN_ICONS_SPECIES
#undef MANNEQUIN_ICONS_FAT
#undef MANNEQUIN_DYNAMIC_LAYER
