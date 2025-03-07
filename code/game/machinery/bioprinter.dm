//These machines are mostly just here for debugging/spawning. Skeletons of the feature to come.

/obj/machinery/bioprinter
	name = "bioprinter"
	desc = "A machine that grows replacement organs using meat and metal."
	icon = 'icons/obj/surgery.dmi'

	icon_state = "bioprinter"

	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 50

	light_color = LIGHT_COLOR_CYAN
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

	var/prints_prosthetics
	var/stored_matter = 200
	var/loaded_dna //Blood sample for DNA hashing.
	var/list/products = list(
		"heart"            = list(/obj/item/organ/internal/heart,  50),
		"insectoid heart"  = list(/obj/item/organ/internal/heart/insectoid, 50),
		"vox heart" 	   = list(/obj/item/organ/internal/heart/vox, 50),
		"human lungs"      = list(/obj/item/organ/internal/lungs,  30),
		"vox lungs"        = list(/obj/item/organ/internal/lungs/vox,  30),
		"plasmaman lungs"  = list(/obj/item/organ/internal/lungs/plasmaman,  30),
		"book lungs"       = list(/obj/item/organ/internal/lungs/insectoid, 30),
		"kidneys"          = list(/obj/item/organ/internal/kidneys,20),
		"human eyes"       = list(/obj/item/organ/internal/eyes,   30),
		"grey eyes"        = list(/obj/item/organ/internal/eyes/grey,   30),
		"vox eyes"         = list(/obj/item/organ/internal/eyes/vox,   30),
		"compound eyes"    = list(/obj/item/organ/internal/eyes/compound, 30),
		"liver"            = list(/obj/item/organ/internal/liver,  50),
		"diona liver"      = list(/obj/item/organ/internal/liver/diona,  50),
		"tooth"	           = list(/obj/item/stack/teeth, 10)
	)

/obj/machinery/bioprinter/New()
	..()
	if(map.nameShort == "deff")
		icon = 'maps/defficiency/medbay.dmi'

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/bioprinter,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/matter_bin,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/console_screen\
	)

	RefreshParts()

/obj/machinery/bioprinter/prosthetics
	name = "prosthetics fabricator"
	desc = "A machine that prints prosthetic organs."
	prints_prosthetics = 1

/obj/machinery/bioprinter/attack_hand(mob/user)
	if(!ishigherbeing(user) && !issilicon(user))
		return

	var/choice = input("What would you like to print?") as null|anything in products
	if(!choice)
		return

	if(stored_matter >= products[choice][2])

		stored_matter -= products[choice][2]
		var/new_organ = products[choice][1]
		var/printed_organ = new new_organ(get_turf(src))
		if(istype(printed_organ, /obj/item/organ/internal))
			var/obj/item/organ/internal/O = printed_organ
			O.is_printed = TRUE // Heist stuff.

			if(prints_prosthetics)
				O.robotic = 2
			//else if(loaded_dna)
				//visible_message("<span class='notice'>The printer would be using the DNA sample if it was coded.</span>")
				//TODO: Copy DNA hash or donor reference over to new organ.

		visible_message("<span class='notice'>\The [src] spits out a brand new organ.</span>")
	else
		visible_message("<span class='warning'>\The [src]'s error light flickers. It can't make new organs out of thin air, fill it up first.</span>")

/obj/machinery/bioprinter/attackby(obj/item/weapon/W, mob/user)

	// DNA sample from syringe.
	if(!prints_prosthetics && istype(W, /obj/item/weapon/reagent_containers/syringe))
		//Finish the feature first, muh immulsions
//		to_chat(user, "<span class='notice'>You inject the blood sample into \the [src], but it simply drains away through a tube in the back.</span>.")
		return
	// Meat for biomass.
	else if(!prints_prosthetics && istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		if(user.drop_item(W))
			visible_message("<span class='notice'>\The [src] processes \the [W].</span>")
			stored_matter += 50
			qdel(W)
			return
	// Steel for matter.
	else if(prints_prosthetics && istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		if(user.drop_item(M))
			visible_message("<span class='notice'>\The [src] processes \the [W].</span>")
			stored_matter += M.amount * 10
			qdel(M)
			return
	else if(W.is_wrench(user))
		user.visible_message("<span class='notice'>[user] begins to [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You begin to [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You hear a ratchet.</span>")
		W.playtoolsound(src, 50)
		if(do_after(user, src, 30))
			user.visible_message("<span class='notice'>[user] begins to [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You [anchored? "unfasten" : "fasten"] \the [src].</span>", "<span class='notice'>You hear a ratchet.</span>")
			if(anchored)
				src.anchored = 0
			else
				src.anchored = 1
	else
		return..()
