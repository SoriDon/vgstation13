/obj/item/candle
	name = "candle"
	desc = "A candle made out of wax, used for moody lighting and solar flares."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle"
	item_state = "candle"
	var/food_candle = "foodcandle"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/candles.dmi', "right_hand" = 'icons/mob/in-hand/right/candles.dmi')
	w_class = W_CLASS_TINY
	heat_production = 1000
	source_temperature = TEMPERATURE_FLAME
	light_color = LIGHT_COLOR_FIRE
	w_type = RECYK_WAX
	melt_temperature = MELTPOINT_WAX
	starting_materials = list(MAT_WAX = CC_PER_SHEET_WAX)
	color = COLOR_DEFAULT_CANDLE

	var/wax = 1800 // 30 minutes
	var/lit = 0
	var/trashtype = /obj/item/trash/candle
	var/image/wick
	var/flickering = 0

/obj/item/candle/New(turf/loc)
	..()
	wick = image(icon,src,"candle-wick")
	wick.appearance_flags = RESET_COLOR
	if(world.has_round_started())
		initialize()
	update_icon()

/obj/item/candle/initialize()
	..()
	if (lit)//pre-mapped lit candles
		lit = 0
		light("",TRUE)

/obj/item/candle/extinguish()
	..()
	if(lit)
		lit = 0
		update_icon()
		set_light(0)
		remove_particles(PS_CANDLE)
		remove_particles(PS_CANDLE2)

/obj/item/candle/update_icon()
	overlays.len = 0
	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = null
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = null
	if (wax == initial(wax))
		icon_state = "candle"
	else
		var/i
		if(wax > 1200)
			i = 1
		else if(wax > 600)
			i = 2
		else i = 3
		icon_state = "candle[i]"
	wick.icon_state = "[icon_state]-wick"
	overlays += wick
	set_blood_overlay()
	if (lit)
		var/image/I = image(icon,src,"[icon_state]_lit")
		I.appearance_flags = RESET_COLOR
		I.blend_mode = BLEND_ADD
		if (isturf(loc))
			I.plane = ABOVE_LIGHTING_PLANE
		else
			I.plane = ABOVE_HUD_PLANE // inventory
		overlays += I

		//dynamic in-hands
		var/image/left_I = image(inhand_states["left_hand"], src, "candle_lit")
		var/image/right_I = image(inhand_states["right_hand"], src, "candle_lit")
		left_I.appearance_flags = RESET_COLOR
		left_I.blend_mode = BLEND_ADD
		left_I.plane = ABOVE_LIGHTING_PLANE
		right_I.appearance_flags = RESET_COLOR
		right_I.blend_mode = BLEND_ADD
		right_I.plane = ABOVE_LIGHTING_PLANE
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = left_I
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = right_I
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_hands()

/obj/item/candle/dropped()
	..()
	update_icon()

/obj/item/candle/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if (lit && source_temperature)
		if (istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			C.light("<span class='notice'>[user] lights [C] with [src].</span>")
		else if (istype(W,/obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/fag = W
			fag.light("<span class='notice'>[user] lights \the [fag] using \the [src]'s flame.</span>")
	if(source_temperature && (W.is_hot() || W.sharpness_flags & (HOT_EDGE)))
		light("<span class='notice'>[user] lights [src] with [W].</span>")

/obj/item/candle/proc/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>", var/quiet = 0)
	if(!lit)
		lit = 1
		if(!quiet)
			visible_message(flavor_text)
		set_light(CANDLE_LUM)
		add_particles(PS_CANDLE)
		add_particles(PS_CANDLE2)
		processing_objects.Add(src)
		update_icon()
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()

/obj/item/candle/proc/flicker(var/amount = rand(5, 15))
	if(flickering)
		return
	flickering = 1
	if(lit)
		for(var/i = 0; i < amount; i++)
			if(prob(95))
				if(prob(30))
					extinguish()
				else
					var/candleflick = pick(0.5, 0.7, 0.9, 1, 1.3, 1.5, 2)
					set_light(candleflick * CANDLE_LUM)
			else
				set_light(5 * CANDLE_LUM)
				if(source_temperature == 0) //only holocandles don't have source temp, using this so I don't add a new var
					wax = 0.8 * wax //jury rigged so the wax reduction doesn't nuke the holocandles if flickered
				visible_message("<span class='warning'>\The [src]'s flame starts roaring unnaturally!</span>")
			update_icon()
			sleep(rand(5,8))
			set_light(CANDLE_LUM)
			lit = 1
			update_icon()
			flickering = 0

/obj/item/candle/spook(mob/dead/observer/ghost)
	if(..(ghost, TRUE))
		flicker()

/obj/item/candle/attack_ghost(mob/user)
	if(!can_spook())
		return
	add_hiddenprint(user)
	flicker(1)
	investigation_log(I_GHOST, "|| was made to flicker by [key_name(user)][user.locked_to ? ", who was haunting [user.locked_to]" : ""]")

/obj/item/candle/process()
	if(!lit)
		return
	wax--
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(env.molar_density(GAS_OXYGEN) < (5 / CELL_VOLUME))
		extinguish()
		processing_objects.Remove(src)
		update_icon()
		return
	if(!wax)
		new trashtype(src.loc, src)
		if(istype(src.loc, /mob))
			src.dropped()
		qdel(src)
		return
	update_icon()
	if(istype(T)) //Start a fire if possible
		T.hotspot_expose(source_temperature, 5, surfaces = 0)

/obj/item/candle/attack_self(mob/user as mob)
	if(lit)
		extinguish()
		to_chat(user, "<span class='warning'>You pinch \the [src]'s wick.</span>")
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_hands()

/obj/item/candle/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/weapon/match/is_hot()
	if(lit)
		return source_temperature
	return 0

/obj/item/candle/Crossed(var/obj/Proj)
	if(..())
		return 1
	if(isbeam(Proj))
		var/obj/item/projectile/beam/P = Proj//could be a laser beam or an emitter beam, both feature the get_damage() proc, for now...
		if(P.get_damage() != 0)
			light("", 1)

/obj/item/candle/afterattack(obj/target, mob/user , flag, params)
	if(flag == 0)
		return 0
	if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/snack = target
		var/list/params_list = params2list(params)
		var/image/I = image(icon,snack,food_candle)
		I.color = color
		I.pixel_x = clamp(text2num(params_list["icon-x"]) - WORLD_ICON_SIZE/2 - pixel_x,-WORLD_ICON_SIZE/2,WORLD_ICON_SIZE/2)
		I.pixel_y = clamp(text2num(params_list["icon-y"]) - WORLD_ICON_SIZE/2 - pixel_y,-WORLD_ICON_SIZE/2,WORLD_ICON_SIZE/2)
		snack.candles += I
		if (lit && snack.candles_state == CANDLES_UNLIT)
			to_chat(user, "<span class='notice'>You place \the [name] on top of \the [target], lighting up the other candles in the process.</span>")
			snack.candles_state = CANDLES_LIT
		else if (!lit && snack.candles_state == CANDLES_LIT)
			to_chat(user, "<span class='notice'>You light \the [name] using the other lit candles and add it on top of \the [target].</span>")
		else
			to_chat(user, "<span class='notice'>You place \the [name] on top of \the [target].</span>")
			if (snack.candles_state == CANDLES_NONE)
				if (lit)
					snack.candles_state = CANDLES_LIT
				else
					snack.candles_state = CANDLES_UNLIT
		snack.update_icon()
		qdel(src)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/holocandle
	name = "holo candle"
	desc = "A small disk projecting the image of a candle, used for futuristic lighting. It has a multitool port on it for changing colors."
	icon_state = "holocandle_base"
	icon = 'icons/obj/candle.dmi'
	w_class = W_CLASS_TINY
	light_color = LIGHT_COLOR_FIRE
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	starting_materials = list(MAT_IRON = 50)

	var/wax = "red"
	var/lit = 0
	var/flickering = 0

/obj/item/holocandle/New()
	..()
	update_icon()

/obj/item/holocandle/emp_act()
	lit = 0
	set_light(0)
	update_icon()

/obj/item/holocandle/update_icon()
	overlays.len = 0
	switch(wax)
		if("red")
			light_color = LIGHT_COLOR_FIRE
		if("blue")
			light_color = LIGHT_COLOR_BLUE
		if("purple")
			light_color = LIGHT_COLOR_PURPLE
		if("green")
			light_color = LIGHT_COLOR_GREEN
		if("yellow")
			light_color = LIGHT_COLOR_YELLOW
	var/image/I_stick = image(icon,src,"holocandle_[wax]")
	if (lit)
		var/image/I_flame = image(icon,src,"holocandle_lit")
		I_stick.overlays += I_flame
	I_stick.blend_mode = BLEND_ADD
	I_stick.alpha = 200
	if (isturf(loc))
		I_stick.plane = ABOVE_LIGHTING_PLANE
	else
		I_stick.plane = ABOVE_HUD_PLANE
	overlays += I_stick

/obj/item/holocandle/attack_self(mob/user)
	lit = !lit
	update_icon()
	playsound(src, 'sound/machines/dial_tick.ogg', 10, 1)
	light("<span class='notice'>[user] flips \the [src]'s switch.</span>")

/obj/item/holocandle/attackby(obj/item/weapon/W, mob/user)
	var/list/choices = list("red","blue","purple","green","yellow")
	if(W.is_multitool(user))
		wax = input("What color would do you want?","Color Selection") as anything in choices
		update_icon()
	..()

/obj/item/holocandle/proc/light(var/flavor_text = "<span class='notice'>[usr] lights [src].</span>", var/quiet = 0)
	if(lit)
		set_light(CANDLE_LUM,2,light_color)
	else
		set_light(0)
	update_icon()
	visible_message(flavor_text)
