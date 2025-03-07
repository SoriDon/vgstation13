/obj/item/organ/internal
	name = "organ"
	desc = "It looks like it probably just plopped out."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	w_class = W_CLASS_SMALL

	health = 100                              // Process() ticks before death.

	var/fresh = 3                             // Squirts of blood left in it.
	var/dead_icon                             // Icon used when the organ dies.
	var/robotic                               // Is the limb prosthetic?
	var/organ_tag                             // What slot does it go in?
	var/organ_type = /datum/organ/internal    // Used to spawn the relevant organ data when produced via a machine or spawn().
	var/datum/organ/internal/organ_data       // Stores info when removed.
	var/prosthetic_name = "prosthetic organ"  // Flavour string for robotic organ.
	var/prosthetic_icon                       // Icon for robotic organ.
	var/is_printed = FALSE                    // Used for heist.
	var/had_mind = FALSE                      // Owner had a mind at some point. (heist)
	var/stabilized = FALSE

	var/blood_data = list(
		"viruses" = null,
		"blood_DNA" = null,
		"blood_type" = "O+",
		"blood_colour" = DEFAULT_BLOOD,
		"resistances" = null,
		"trace_chem" = null,
		"virus2" = null,
		"immunity" = null,
		)

	var/static/list/safe_containers = list(
		/obj/item/device/mmi,
		/obj/item/bodybag/cryobag,
		/obj/structure/closet/crate/freezer,
		/obj/structure/closet/crate/medical,
		/obj/structure/closet/crate/secure/medsec,
		/obj/structure/closet/secure_closet/freezer,
		)

/obj/item/organ/internal/attack_self(mob/user as mob)

	// Convert it to an edible form, yum yum.
	if(!robotic && user.a_intent == I_HELP && user.zone_sel.selecting == "mouth")
		bitten(user)
		return

/obj/item/organ/internal/New()
	..()
	create_reagents(5)
	if(!robotic)
		processing_objects += src
	spawn(1)
		update()

/obj/item/organ/internal/Destroy()
	if(!robotic)
		processing_objects -= src
	QDEL_NULL(organ_data)
	..()

/obj/item/organ/internal/examine(var/mob/user, var/size = "")
	..()
	if(is_printed)
		user.simple_message("<span class='warning'>This organ has a barcode identifying it as printed from a bioprinter.</span>","<span class='warning'>It's got spaghetti sauce on it. Ew.</span>")
	else
		user.simple_message("<span class='info'>This organ has no barcode and looks natural.</span>","<span class='info'>Looks all-natural and organically-grown! Sweet.</span>")


/obj/item/organ/internal/process()

	if(robotic)
		processing_objects -= src
		return

	//TODO: ambient temperature?
	if(is_type_in_list(loc,safe_containers))
		return

	if(istype(loc,/obj/item/weapon/reagent_containers/glass/jar))
		var/obj/item/weapon/reagent_containers/glass/jar/J = loc
		if(J.safe_holder())
			return

	//We're stabilized somehow.
	if(stabilized)
		return


	if(fresh && prob(40))
		fresh--
		var/datum/reagent/blood/blud = new
		blud.data = copy_blood_data(blood_data)
		blood_splatter(src,blud,1)

	health -= rand(1,3)
	if(health <= 0)
		die()

/obj/item/organ/internal/proc/die()
	name = "dead [initial(name)]"
	if(dead_icon)
		icon_state = dead_icon
	var/icon/original = icon(icon, icon_state)
	original.GrayScale()
	icon = original
	health = 0
	processing_objects -= src
	//TODO: Inject an organ with peridaxon to make it alive again.

/obj/item/organ/internal/proc/revive()
	name = initial(name)
	icon_state = initial(icon_state)
	icon = initial(icon)
	health = 1
	processing_objects += src

/obj/item/organ/internal/proc/roboticize()


	robotic = (organ_data && organ_data.robotic) ? organ_data.robotic : 1

	if(prosthetic_name)
		name = prosthetic_name

	if(prosthetic_icon)
		icon_state = prosthetic_icon
	else
		//TODO: convert to greyscale.

/obj/item/organ/internal/proc/update()


	if(!organ_tag || !organ_type)
		return

	if(!organ_data)
		organ_data = new organ_type

	if(robotic)
		organ_data.robotic = robotic

	if(organ_data.robotic >= 2)
		roboticize()

// Brain is defined in brain_item.dm.
/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	prosthetic_name = "circulatory pump"
	prosthetic_icon = "heart-prosthetic"
	organ_tag = "heart"
	fresh = 6 // Juicy.
	dead_icon = "heart-off"
	organ_type = /datum/organ/internal/heart

/obj/item/organ/internal/heart/insectoid
	name = "insectoid heart"
	icon_state = "insectoid-heart-on"
	prosthetic_name = "circulatory pump"
	prosthetic_icon = "heart-prosthetic"
	organ_tag = "heart"
	fresh = 6
	dead_icon = "insectoid-heart-off"
	organ_type = /datum/organ/internal/heart

/obj/item/organ/internal/heart/vox
	name = "vox heart"
	icon_state = "vox-heart-on"
	dead_icon = "vox-heart-off"

/obj/item/organ/internal/heart/cell
	name = "biocharger"
	icon_state = "heart-cell"
	prosthetic_name = null
	prosthetic_icon = null
	organ_type = /datum/organ/internal/heart/cell
	robotic=2

/obj/item/organ/internal/heart/cell/get_cell()
	if(organ_data)
		var/datum/organ/internal/heart/cell/C = organ_data
		return C.cell

/obj/item/organ/internal/heart/cell/attack_self(mob/user)
	if(get_cell())
		var/datum/organ/internal/heart/cell/C = organ_data
		to_chat(user, "<span class = 'notice'>You remove \the [C.cell] from \the [src].</span>")
		user.put_in_hands(C.cell)
		C.cell = null

/obj/item/organ/internal/heart/cell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/cell) && !get_cell() && organ_data && user.drop_item(I, src))
		var/datum/organ/internal/heart/cell/C = organ_data
		to_chat(user, "<span class = 'notice'>You place \the [I] into \the [src].</span>")
		C.cell = I
		return
	..()

/obj/item/organ/internal/lungs
	name = "human lungs"
	icon_state = "lungs"
	prosthetic_name = "gas exchange system"
	prosthetic_icon = "lungs-prosthetic"
	organ_tag = "lungs"
	organ_type = /datum/organ/internal/lungs

/obj/item/organ/internal/lungs/insectoid
	name = "insectoid lungs"
	icon_state = "book-lungs"
	prosthetic_name = "gas exchange system"
	prosthetic_icon = "lungs-prosthetic"
	organ_tag = "lungs"
	organ_type = /datum/organ/internal/lungs/insectoid

/obj/item/organ/internal/lungs/vox
	name = "vox lungs"
	icon_state = "vox-lungs"
	prosthetic_name = "vox gas exchange system"
	organ_type = /datum/organ/internal/lungs/vox

/obj/item/organ/internal/lungs/plasmaman
	name = "weird pink lungs"
	icon_state = "plasmaman-lungs"
	prosthetic_name = "plasmaman gas exchange system"
	organ_type = /datum/organ/internal/lungs/plasmaman

/obj/item/organ/internal/lungs/filter
	name = "advanced lungs"
	icon_state = "filter-lungs"
	prosthetic_name = null
	prosthetic_icon = null
	organ_type = /datum/organ/internal/lungs/filter
	robotic=2

/obj/item/organ/internal/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	prosthetic_name = "prosthetic kidneys"
	prosthetic_icon = "kidneys-prosthetic"
	organ_tag = "kidneys"
	organ_type = /datum/organ/internal/kidney

/obj/item/organ/internal/kidneys/filter
	name = "toxin filters"
	icon_state = "advanced-kidneys"
	prosthetic_name = null
	prosthetic_icon = null
	organ_type = /datum/organ/internal/kidney/filter
	robotic=2

/obj/item/organ/internal/eyes
	name = "eyeballs"
	icon_state = "eyes"
	prosthetic_name = "visual prosthesis"
	prosthetic_icon = "eyes-prosthetic"
	organ_tag = "eyes"
	organ_type = /datum/organ/internal/eyes
	w_class = W_CLASS_TINY
	var/eye_colour
	var/emitter = FALSE

/obj/item/organ/internal/eyes/tajaran
	name = "tajaran eyeballs"
	icon_state = "eyes-tajaran"
	prosthetic_name = "tajaran visual prosthesis"
	organ_type = /datum/organ/internal/eyes/tajaran

/obj/item/organ/internal/eyes/muton
	name = "muton eyeballs"
	icon_state = "eyes-muton"
	prosthetic_name = "muton visual prosthesis"
	organ_type = /datum/organ/internal/eyes/muton

/obj/item/organ/internal/eyes/grey
	name = "grey eyeballs"
	icon_state = "eyes-grey"
	prosthetic_name = "grey visual prosthesis"
	organ_type = /datum/organ/internal/eyes/grey

/obj/item/organ/internal/eyes/compound
	name = "compound eyes"
	icon_state = "eye-compound"
	prosthetic_name = "visual prosthetis"
	prosthetic_name = "eyes-prosthetic"
	organ_tag = "eyes"
	organ_type = /datum/organ/internal/eyes/compound

/obj/item/organ/internal/eyes/vox
	name = "vox eyeballs"
	icon_state = "eyes-vox"
	prosthetic_name = "vox visual prosthesis"
	organ_type = /datum/organ/internal/eyes/vox

/obj/item/organ/internal/eyes/monstrous
	name = "monstrous eyeballs"
//	icon_state = "eyes"
	prosthetic_name = "monstrous visual prosthesis"
	organ_type = /datum/organ/internal/eyes/monstrous

/obj/item/organ/internal/eyes/mushroom
	name = "mushroom eyeballs"
	icon_state = "eyes-tajaran"
	prosthetic_name = "mushroom visual prosthesis"
	organ_type = /datum/organ/internal/eyes/mushroom

/obj/item/organ/internal/eyes/adv_1
	name = "advanced prosthesis eyeballs"
	robotic = 2
	prosthetic_name = null
	prosthetic_icon = null
	icon_state = "eyes-adv_1"
	organ_type = /datum/organ/internal/eyes/adv_1

/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	prosthetic_name = "artificial metabolizer"
	prosthetic_icon = "liver-prosthetic"
	organ_tag = "liver"
	organ_type = /datum/organ/internal/liver

/obj/item/organ/internal/liver/diona
	name = "diona liver"
	icon_state = "liver-diona"
	organ_type = /datum/organ/internal/liver/diona

/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	organ_tag = "appendix"
	w_class = W_CLASS_TINY

//These are here so they can be printed out via the fabricator.
/obj/item/organ/internal/heart/prosthetic
	robotic = 2

/obj/item/organ/internal/lungs/prosthetic
	robotic = 2

/obj/item/organ/internal/kidneys/prosthetic
	robotic = 2

/obj/item/organ/internal/eyes/prosthetic
	robotic = 2

/obj/item/organ/internal/liver/prosthetic
	robotic = 2

/obj/item/organ/internal/appendix
	name = "appendix"

/obj/item/organ/internal/proc/removed(var/mob/living/target,var/mob/living/user)
	if(!target)
		return

	blood_data = target.get_blood_data()

	if(user && organ_data.vital)
		user.attack_log += "\[[time_stamp()]\]<font color='red'> removed a vital organ ([src]) from [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> had a vital organ ([src]) removed by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		msg_admin_attack("[user.name] ([user.ckey]) removed a vital organ ([src]) from [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		target.death()

	had_mind=!isnull(target.mind)

/obj/item/organ/internal/appendix/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/inflamed = 0
	for(var/datum/disease/appendicitis/appendicitis in target.viruses)
		inflamed = 1
		appendicitis.cure()
		target.resistances += appendicitis

	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"

/obj/item/organ/internal/eyes/removed(var/mob/living/target,var/mob/living/user)

	if(!eye_colour)
		eye_colour = list(0,0,0)

	..() //Make sure target is set so we can steal their eye colour for later.
	var/mob/living/carbon/human/H = target
	if(istype(H))
		eye_colour = list(
			H.my_appearance.r_eyes ? H.my_appearance.r_eyes : 0,
			H.my_appearance.g_eyes ? H.my_appearance.g_eyes : 0,
			H.my_appearance.b_eyes ? H.my_appearance.b_eyes : 0
			)
		var/image/I = image(icon,src,"[icon_state]-pupils")
		I.color = "#[num2hex(eye_colour[1])][num2hex(eye_colour[2])][num2hex(eye_colour[3])]"
		overlays += I
		// Leave bloody red pits behind!
		H.my_appearance.r_eyes = 128
		H.my_appearance.g_eyes = 0
		H.my_appearance.b_eyes = 0
		H.update_body()

		for (var/ID in H.virus2)
			var/datum/disease2/disease/D = H.virus2[ID]
			for(var/datum/disease2/effect/emitter/e in D.effects)
				if (e.announced)
					emitter = TRUE

/obj/item/organ/internal/proc/replaced(var/mob/living/target)
	return

/obj/item/organ/internal/eyes/replaced(var/mob/living/target)

	// Apply our eye colour to the target.
	var/mob/living/carbon/human/H = target
	if(istype(H) && eye_colour)
		H.my_appearance.r_eyes = eye_colour[1]
		H.my_appearance.g_eyes = eye_colour[2]
		H.my_appearance.b_eyes = eye_colour[3]
		H.update_body()

/obj/item/organ/internal/proc/bitten(mob/user)


	if(robotic)
		return

	to_chat(user, "<span class='notice'>You take an experimental bite out of \the [src].</span>")
	var/datum/reagent/blood/blud = new
	blud.data = copy_blood_data(blood_data)
	blood_splatter(src,blud,1)


	user.drop_from_inventory(src)
	var/obj/item/weapon/reagent_containers/food/snacks/organ/O = new(get_turf(src))
	O.name = name
	O.icon_state = dead_icon ? dead_icon : icon_state

	// Pass over the blood.
	reagents.trans_to(O, reagents.total_volume)

	if(fingerprints)
		O.fingerprints = fingerprints.Copy()
	if(fingerprintshidden)
		O.fingerprintshidden = fingerprintshidden.Copy()
	if(fingerprintslast)
		O.fingerprintslast = fingerprintslast

	user.put_in_active_hand(O)
	qdel(src)
