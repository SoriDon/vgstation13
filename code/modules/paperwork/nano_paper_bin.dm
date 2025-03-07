/obj/item/weapon/paper_bin/nano
	name = "\improper nano paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "This machine dispenses nano paper."
	icon_state = "np_dispenser"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	var/resources = 30	// how much nano paper it contains
	var/max_resources = 30 // the maxium amount of paper it can contain, un-used for now
	autoignition_temperature = 1000 // Kelvin


/obj/item/weapon/paper_bin/nano/MouseDropFrom(atom/over_object)
	MouseDropPickUp(over_object)
	return ..()


/obj/item/weapon/paper_bin/nano/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/item/weapon/paper_bin/nano/attack_hand(mob/user as mob)
	if(resources > 0)
		resources--
		user.put_in_hands(new /obj/item/weapon/paper/nano(loc))
		to_chat(user, "<span class='notice'>\The [src] spits out a piece of nano paper.</span>")
		if(resources == 0)
			to_chat(user, "<span class=notice>The dispenser is now empty!")
	else
		to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
		update_icon()
	add_fingerprint(user)
	return


/obj/item/weapon/paper_bin/nano/attackby(var/obj/item/stack/sheet/plasteel/i as obj, mob/user as mob)
	if(!istype(i))
		return
	if(resources > 0)
		to_chat(user, "<span class=notice> The dispenser needs to be empty before it can be reloaded!")
		return

	to_chat(user, "<span class='notice'>You load the [i] in the dispenser</span>")
	i:amount--
	if(i:amount < 1)
		QDEL_NULL(i)
	resources += 30
	update_icon()


/obj/item/weapon/paper_bin/nano/examine(mob/user)
	..()
	if(resources)
		to_chat(user, "<span class='info'>There is [resources] nano paper left in the dispenser!</span>")
	else
		to_chat(user, "<span class='warning'>The nano paper dispenser is empty! add more plasteel to refil!</span>")


/obj/item/weapon/paper_bin/nano/update_icon()
	if(resources < 1)
		icon_state = "np_dispenser_empty"
	else
		icon_state = "np_dispenser"
