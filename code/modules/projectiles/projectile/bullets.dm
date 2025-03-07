/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	phase_type = PROJREACT_WINDOWS
	penetration = 5 //bullets can now by default move through up to 5 windows, or 2 reinforced windows, or 1 plasma window. (reinforced plasma windows still have enough dampening to completely block them)
	flag = "bullet"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	projectile_speed = 0.5
	var/embed = 1
	var/embed_message = TRUE

/obj/item/projectile/bullet/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)
		return 1
	return 0

/obj/item/projectile/bullet/dart
	name = "shotgun dart"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/bullet/blank
	name = "hot gas discharge"
	icon_state = null
	damage = 10
	damage_type = BURN
	kill_count = 1 //Limits the range to one tile
	embed = 0

/obj/item/projectile/bullet/weakbullet
	name = "weak bullet"
	icon_state = "bbshell"
	damage = 10
	stun = 3
	weaken = 5
	embed = 0
	projectile_speed = 0.5

/obj/item/projectile/bullet/weakbullet/booze
	name = "booze bullet"
	projectile_speed = 0.5

/obj/item/projectile/bullet/weakbullet/mech
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/weakbullet/booze/on_hit(var/atom/target, var/blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.dizziness += 20
		M:slurring += 20
		M.confused += 20
		M.eye_blurry += 20
		M.drowsyness += 20
		if(M.dizziness <= 150)
			M.Dizzy(150)
			M.dizziness = 150
		for(var/datum/reagent/ethanol/A in M.reagents.reagent_list)
			M.AdjustParalysis(2)
			M.dizziness += 10
			M:slurring += 10
			M.confused += 10
			M.eye_blurry += 10
			M.drowsyness += 10
			A.volume += 5 //Because we can
			M.dizziness += 10
		return 1
	return 0

/obj/item/projectile/bullet/shrapnel

	name = "shrapnel"
	damage = 45
	damage_type = BRUTE
	weaken = 1
	stun = 3

/obj/item/projectile/bullet/shrapnel/New()
	..()
	kill_count = rand(6,10)
	damage = rand(15,75)

/obj/item/projectile/bullet/shrapnel/small

	name = "small shrapnel"
	damage = 25

/obj/item/projectile/bullet/shrapnel/small/New()
	..()
	damage = rand(5,45)

/obj/item/projectile/bullet/shrapnel/small/plasma

	name = "small plasma shrapnel"
	damage_type = TOX
	color = "#BF5FFF"
	damage = 35

/obj/item/projectile/bullet/shrapnel/small/plasma/New()
	..()
	damage = rand(10,60)

/obj/item/projectile/bullet/midbullet
	damage = 20
	stun = 5
	weaken = 5
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	projectile_speed = 1

/obj/item/projectile/bullet/midbullet/lawgiver
	damage = 10
	stun = 0
	weaken = 0
	projectile_speed = 0.5

/obj/item/projectile/bullet/midbullet/assault
	damage = 20
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/midbullet2
	damage = 25
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/midbullet/bouncebullet
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = -1

/obj/item/projectile/bullet/midbullet/bouncebullet/lawgiver
	damage = 30
	stun = 0
	weaken = 0

/obj/item/projectile/bullet/fourtyfive
	damage = 35 //buffed up for antag usage
	agony = 2
	penetration = 3

/obj/item/projectile/bullet/fourtyfive/practice
	damage = 3
	agony = 1
	embed = 0
	penetration = 0

/obj/item/projectile/bullet/fourtyfive/rubber
	damage = 10
	stun = 5
	weaken = 5
	penetration = 1
	projectile_speed = 1

/obj/item/projectile/bullet/auto380 //new sec pistol ammo, reverse name because lol compiler
	damage = 15
	agony = 15
	penetration = 2

/obj/item/projectile/bullet/auto380/practice
	damage = 2
	agony = 0
	embed = 0
	penetration = 0

/obj/item/projectile/bullet/auto380/rubber
	damage = 8
	stun = 5
	weaken = 5
	embed = 0
	penetration = 0
	projectile_speed = 1

/obj/item/projectile/bullet/LR22
	damage = 10
	weaken = 3
	embed = 1
	penetration = 1
	projectile_speed = 1

/obj/item/projectile/bullet/stunshot
	name = "stunshot"
	icon_state = "sshell"
	damage = 5
	stun = 10
	weaken = 10
	stutter = 10

/obj/item/projectile/bullet/a762
	damage = 25


/obj/item/projectile/bullet/suffocationbullet
	name = "CO2 bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX

/obj/item/projectile/bullet/burstbullet
	name = "exploding bullet"
	embed = 0
	damage = 0

/obj/item/projectile/bullet/burstbullet/on_hit(var/atom/target, var/blocked = 0)
	..()
	explosion(target, 0,1,1,5, whodunnit = firer)
	qdel(src)

/obj/item/projectile/bullet/boombullet
	name = "small exploding bullet"
	embed = 0
	damage = 0
	penetration = -1

/obj/item/projectile/bullet/boombullet/to_bump(var/atom/target)
	..()
	explosion(target, 0,0,1,5)
	qdel(src)

#define SPUR_FULL_POWER 4
#define SPUR_HIGH_POWER 3
#define SPUR_MEDIUM_POWER 2
#define SPUR_LOW_POWER 1
#define SPUR_NO_POWER 0

/obj/item/projectile/spur
	name = "spur bullet"
	damage_type = BRUTE
	flag = "bullet"
	kill_count = 100
	layer = PROJECTILE_LAYER
	damage = 40
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "spur_high"
	animate_movement = 2
	custom_impact = 1
	linear_movement = 0
	fire_sound = 'sound/weapons/spur_high.ogg'

/obj/item/projectile/spur/OnFired()
	..()
	var/obj/item/weapon/gun/energy/polarstar/spur/quote = shot_from
	if(!quote || !istype(quote))
		return
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 40
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 30
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 20
			kill_count = 7

/obj/item/projectile/spur/polarstar
	name = "polar star bullet"
	damage = 20

/obj/item/projectile/spur/polarstar/OnFired()
	..()
	var/obj/item/weapon/gun/energy/polarstar/quote = shot_from
	if(!quote || !istype(quote))
		return
	switch(quote.firelevel)
		if(SPUR_FULL_POWER,SPUR_HIGH_POWER)
			icon_state = "spur_high"
			damage = 20
			kill_count = 20
		if(SPUR_MEDIUM_POWER)
			icon_state = "spur_medium"
			damage = 15
			kill_count = 13
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			icon_state = "spur_low"
			damage = 10
			kill_count = 7

/obj/item/projectile/spur/to_bump(atom/A as mob|obj|turf|area)

	if(loc)
		var/turf/T = loc
		var/impact_icon = null
		var/impact_sound = null
		var/PixelX = 0
		var/PixelY = 0

		switch(get_dir(src,A))
			if(NORTH)
				PixelY = 16
			if(SOUTH)
				PixelY = -16
			if(EAST)
				PixelX = 16
			if(WEST)
				PixelX = -16
		if(ismob(A))
			impact_icon = "spur_3"
			impact_sound = 'sound/weapons/spur_hitmob.ogg'
		else
			impact_icon = "spur_1"
			impact_sound = 'sound/weapons/spur_hitwall.ogg'

		var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,impact_icon)
		impact.pixel_x = PixelX
		impact.pixel_y = PixelY
		impact.layer = PROJECTILE_LAYER
		T.overlays += impact
		spawn(3)
			T.overlays -= impact
		playsound(loc, impact_sound, 30, 1)


	if(istype(A, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		if(M.mining_difficulty < MINE_DIFFICULTY_TOUGH)
			M.GetDrilled()
	if(istype(A, /obj/structure/boulder))
		qdel(A)

	return ..()

/obj/item/projectile/spur/process_step()
	if(kill_count <= 0)
		if(loc)
			var/turf/T = loc
			var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,"spur_2")
			impact.layer = PROJECTILE_LAYER
			T.overlays += impact
			spawn(3)
				T.overlays -= impact
	..()

#undef SPUR_FULL_POWER
#undef SPUR_HIGH_POWER
#undef SPUR_MEDIUM_POWER
#undef SPUR_LOW_POWER
#undef SPUR_NO_POWER


/obj/item/projectile/bullet/gatling
	name = "gatling bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "minigun"
	damage = 30
	fire_sound = 'sound/weapons/gatling_fire.ogg'

/obj/item/projectile/bullet/baton
	name = "stun baton"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "baton"
	damage = 10
	fire_sound = 'sound/weapons/railgun_lowpower.ogg'
	phase_type = null
	penetration = 0
	projectile_speed = 1
	stun = 10
	weaken = 10
	stutter = 10
	agony = 10
	var/rigged = null //if a rigged baton is loaded, it'll fire an explosive burst

/obj/item/projectile/bullet/baton/on_hit(var/atom/target, var/blocked = 0)
	..()
	playsound(target.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	playsound(target.loc, "swing_hit", 50, 1, -1)
	if(ishuman(target))
		var/mob/living/carbon/human/targethuman = target
		targethuman.forcesay(hit_appends)
	if(rigged) //vars taken from a standard cell explosion
		var/devastation_range = -1
		var/heavy_impact_range = 0.5
		var/light_impact_range = 1
		var/flash_range = light_impact_range
		explosion(target.loc, devastation_range, heavy_impact_range, light_impact_range, flash_range, whodunnit = firer)
	qdel(src)

/obj/item/projectile/bullet/osipr
	name = "\improper OSIPR bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "osipr"
	damage = 50
	stun = 2
	weaken = 2
	destroy = 1
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = 1
	fire_sound = 'sound/weapons/osipr_fire.ogg'

/obj/item/projectile/bullet/hecate
	name = "high penetration bullet"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "hecate"
	damage = 101//you're going to crit, lad
	armor_penetration = 75
	kill_count = 255//oh boy, we're crossing through the entire Z level!
	stun = 5
	weaken = 5
	stutter = 5
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = 20 //can hit 3 mobs at once, or go through a wall and hit 2 more mobs, or go through an rwall/blast door and hit 1 mob
	projectile_speed = 0.5
	fire_sound = 'sound/weapons/hecate_fire.ogg'

/obj/item/projectile/bullet/hecate/OnFired()
	..()
	for (var/mob/M in player_list)
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && (M_turf.z == starting.z))
				M.playsound_local(starting, 'sound/weapons/hecate_fire_far.ogg', 25, 1)
	for (var/mob/living/carbon/human/H in range(src,1))
		if(!H.earprot())
			H.Knockdown(2)
			H.Stun(2)
			H.ear_damage += rand(3, 5)
			H.ear_deaf = max(H.ear_deaf,15)
			to_chat(H, "<span class='warning'>Your ears ring!</span>")

/obj/item/projectile/bullet/a762x55
	name = "a762x55 round"
	damage = 65
	stun = 5
	weaken = 5
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS
	penetration = 10
	projectile_speed = 1

/obj/item/projectile/bullet/beegun
	name = "bee"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "beegun"
	damage = 0
	damage_type = TOX
	flag = "bio"
	projectile_speed = 1
	var/bee_type = /mob/living/simple_animal/bee/angry
	var/angery = 1

/obj/item/projectile/bullet/beegun/chillbug
	name = "chillbug"
	icon_state = "chillgun"
	projectile_speed = 0.5
	bee_type = /mob/living/simple_animal/bee/chillgun
	angery = 0

/obj/item/projectile/bullet/beegun/hornet
	name = "hornet"
	icon_state = "hornetgun"
	projectile_speed = 0.5
	bee_type = /mob/living/simple_animal/bee/hornetgun

/obj/item/projectile/bullet/beegun/ss_viscerator
	name = "viscerator"
	icon_state = "ss_visceratorgun"
	projectile_speed = 0.75
	bee_type = /mob/living/simple_animal/hostile/viscerator/syndiesquad

/obj/item/projectile/bullet/beegun/OnFired()
	..()
	if(isbee(bee_type)	)
		playsound(starting, 'sound/effects/bees.ogg', 75, 1)

/obj/item/projectile/bullet/beegun/to_bump(atom/A as mob|obj|turf|area)
	if (!A)
		return 0
	if((A == firer) && !reflected)
		loc = A.loc
		return 0
	if(bumped)
		return 0
	bumped = 1

	var/turf/T = get_turf(src)
	var/mob/living/simple_animal/bee/BEE = new bee_type(T,null)
	if(istype(A,/mob/living))
		var/mob/living/M = A
		visible_message("<span class='warning'>\the [M.name] is hit by \the [src.name] in the [parse_zone(def_zone)]!</span>")
		M.bullet_act(src, def_zone)
		admin_warn(M)
		BEE.forceMove(M.loc)
		BEE.target = M
		if(isbee(BEE))
			BEE.target_turf = M.loc
		BEE.AttackTarget(TRUE)//let's sting them once
		if (isbee(BEE) && BEE.bee_species.angery)
			BEE.MoveToTarget()//then let's immediately start running after them
		else
			BEE.target = null
			if(isbee(BEE))
				BEE.target_turf = null

	bullet_die()

/obj/item/projectile/bullet/APS //Armor-piercing sabot round. Metal rods become this when fired from a railgun.
	name = "armor-piercing sabot round"
	icon_state = "APS"
	damage = 10 //Default damage, actual damage is determined per-shot in railgun.dm
	kill_count = 20 //This will be increased when the round is fired, based on the strength of the shot
	stun = 0
	weaken = 0
	stutter = 0
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration = 0 //By default. Higher-power shots will have penetration.

/obj/item/projectile/bullet/APS/on_hit(var/atom/atarget, var/blocked = 0)
	if(istype(atarget, /mob/living) && damage >= 200)
		var/mob/living/M = atarget
		M.gib()
	else if(istype(atarget, /obj/machinery/singularity/narsie) && blessed && damage >= 200) //MINE IS THE ROD THAT SHALL PIERCE THE HEAVENS
		var/obj/machinery/singularity/narsie/N = atarget
		N.visible_message("<span class = 'danger'>\The [src] strikes \the [N], ripping through them and splattering blood around. This god can bleed!<span class = 'sinister'>...of course it can...it's a god of blood...and now you have its attention.</span></span>", range = 20)
		if (firer)
			N.acquire(firer)
			new /obj/effect/cult_ritual/confusion(firer.loc)
		bullet_die()
		return
	else
		..()

/obj/item/projectile/bullet/APS/OnFired()
	..()
	if(damage >= 100)
		projectile_speed = 0.66
		for (var/mob/M in player_list)
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && (M_turf.z == starting.z))
					M.playsound_local(starting, 'sound/weapons/hecate_fire_far.ogg', 25, 1)

/obj/item/projectile/bullet/APS/cultify()
	return

/obj/item/projectile/bullet/stinger
	name = "alien stinger"
	damage = 15
	damage_type = TOX
	flag = "bio"
	fire_sound = 'sound/weapons/hivehand.ogg'

/obj/item/projectile/bullet/stinger/OnFired()
	var/choice = rand(1,4)
	switch(choice)
		if(1)
			stutter = 2
		if(2)
			eyeblur = 2
		if(3)
			agony = 2
		if(4)
			jittery = 2
	..()

/obj/item/projectile/bullet/vial
	name = "vial"
	icon_state = "vial"
	damage = 0
	penetration = 0
	embed = 0
	var/vial = null
	var/user = null
	var/hit_mob = 0

/obj/item/projectile/bullet/vial/Destroy()
	if(vial)
		QDEL_NULL(vial)
	if(user)
		user = null
	..()

/obj/item/projectile/bullet/vial/to_bump(atom/A as mob|obj|turf|area) //to allow vials to splash onto walls
	if(!A)
		return
	if(vial)
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = vial
		if(!V.is_open_container())
			V.flags |= OPENCONTAINER
		if(istype(A, /turf/simulated/wall))
			splash_sub(V.reagents, A, V.reagents.total_volume)
			bullet_die()
			return 1
	..()

/obj/item/projectile/bullet/vial/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	if(vial)
		var/obj/item/weapon/reagent_containers/glass/beaker/vial/V = vial
		if(!V.is_open_container())
			V.flags |= OPENCONTAINER
		if(!V.is_empty())
			hit_mob = 1
			atarget.visible_message("<span class='warning'>\The [V] shatters, dousing [atarget] in its contents!</span>",
								"<span class='warning'>\The [V] shatters, dousing you in its contents!</span>")

		splash_sub(V.reagents, atarget, V.reagents.total_volume)

		qdel(V)
		vial = null
		user = null

/obj/item/projectile/bullet/vial/OnDeath()
	if(!hit_mob)
		src.visible_message("<span class='warning'>The vial shatters!</span>")
	playsound(src, "shatter", 20, 1)

/obj/item/projectile/bullet/blastwave
	name = "blast wave"
	icon_state = null
	damage = 0
	penetration = -1
	embed = 0
	phase_type = PROJREACT_WALLS|PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS|PROJREACT_BLOB
	penetration_message = 0
	var/heavy_damage_range = 0
	var/medium_damage_range = 0
	var/light_damage_range = 0
	var/true_range = 0
	fire_sound = null//no need, we'll call explosion_effect() instead
	var/list/affected_turfs = list()
	var/list/cached_ex_act = list()
	var/list/heavy_turfs = list()
	var/list/medium_turfs = list()
	var/list/light_turfs = list()
	var/widening_rate = 5
	var/distance_traveled = 0
	var/radius = 0
	projectile_speed = 0//we try to quickly and immediately scan all the turfs, then add some delay when it comes to actually loop through them
	var/datum/sensed_explosion/explosion_datum
	var/time_spent = 0

/obj/item/projectile/bullet/blastwave/OnFired()
	..()
	if(!heavy_damage_range || !medium_damage_range || !light_damage_range)
		bullet_die()
		return
	explosion_datum = new(starting.x, starting.y, starting.z, heavy_damage_range, medium_damage_range, light_damage_range, true_range)
	time_spent = start_watch()
	explosion_effect(starting, heavy_damage_range, medium_damage_range, light_damage_range)

/obj/item/projectile/bullet/blastwave/to_bump(var/atom/A)
	forceMove(get_step(loc,dir))//The projectile passes freely through everything. The actual explosion dampening is calculated later.

/obj/item/projectile/bullet/blastwave/process_step()
	..()
	if (!loc)
		return

	distance_traveled++

	if (distance_traveled > light_damage_range)
		bullet_die()
		return

	radius = round(distance_traveled/widening_rate)

	var/max_steps = distance_traveled + radius + 1

	var/turf/relative_epicenter = locate(override_starting_X,override_starting_Y,z)

	var/turf/T = loc
	for (var/turf/U in range(radius,T))
		if (!(U in affected_turfs))
			affected_turfs |= U
			var/steps = 0
			var/turf/Trajectory = U
			var/dist = cheap_pythag(U.x - override_starting_X, U.y - override_starting_Y)
			while((Trajectory != starting) && (steps <= max_steps))
				Trajectory = get_step_towards(Trajectory,relative_epicenter)
				dist += CalculateExplosionSingleBlock(Trajectory)
				steps++//failsafe in case of fuckery such as the projectile finding itself on a different Z level
			if (dist <= heavy_damage_range)
				heavy_turfs += U
			else if (dist <= medium_damage_range)
				medium_turfs += U
			else if (dist <= light_damage_range)
				light_turfs += U

/obj/item/projectile/bullet/blastwave/teleport_act()
	override_starting_X = clamp(override_starting_X,1,world.maxx)
	override_starting_Y = clamp(override_starting_Y,1,world.maxy)

/obj/item/projectile/bullet/blastwave/bullet_die()
	//the bullet moved all the way, now to explode dem turfs
	spawn()
		for (var/turf/T in heavy_turfs)
			blast_turf(T,1)
		for (var/turf/T in medium_turfs)
			blast_turf(T,2)
		for (var/turf/T in light_turfs)
			blast_turf(T,3)

		time_spent = stop_watch(time_spent)
		if (explosion_datum)
			explosion_datum.ready(time_spent)
	..()

/obj/item/projectile/bullet/blastwave/proc/blast_turf(var/turf/T,var/severity)
	explosion_datum.paint(T,severity)
	for(var/atom/movable/A in T.contents)
		if(!istype(A, /obj/item/organ/external/head))
			A.ex_act(severity)
	for (var/direction in cardinal)
		var/turf/U = get_step(T,direction)
		if (istype(U, /turf/simulated/floor) && !(U in affected_turfs))
			var/turf/simulated/floor/F = U
			switch (severity)
				if (1)
					F.break_tile()
				if (2)
					if (prob(50))
						F.break_tile()
				if (3)
					if (prob(25))
						F.break_tile()
	T.ex_act(severity)

/obj/item/projectile/bullet/blastwave/ex_act()
	return

/obj/item/projectile/bullet/fire_plume
	name = "fire plume"
	icon_state = null
	damage = 0
	penetration = -1
	embed = 0
	phase_type = PROJREACT_MOBS|PROJREACT_BLOB|PROJREACT_OBJS
	bounce_sound = null
	custom_impact = 1
	penetration_message = 0
	var/effect_type = /obj/effect/fire_blast
	var/has_O2_in_mix = 0
	var/datum/gas_mixture/gas_jet = null
	var/max_range = 10
	var/stepped_range = 0
	var/burn_strength = 0
	var/has_reacted = 0
	var/burn_damage = 0
	var/jet_pressure = 0
	var/original_total_moles = 0

/obj/item/projectile/bullet/fire_plume/OnFired()
	..()
	if(!gas_jet)
		bullet_die()
	else
		original_total_moles = gas_jet.total_moles()

/obj/item/projectile/bullet/fire_plume/proc/create_puff()
	if(gas_jet)
		var/total_moles = gas_jet.total_moles
		if(total_moles)
			var/o2_concentration = gas_jet[GAS_OXYGEN] / total_moles
			var/n2_concentration = gas_jet[GAS_NITROGEN] / total_moles
			var/co2_concentration = gas_jet[GAS_CARBON] / total_moles
			var/plasma_concentration = gas_jet[GAS_PLASMA] / total_moles
			var/n2o_concentration = gas_jet[GAS_SLEEPING] / total_moles

			var/datum/gas_mixture/gas_dispersal = gas_jet.remove(original_total_moles/10)

			var/gas_type = null

			if(o2_concentration > 0.5)
				gas_type = "oxygen"
			if(n2_concentration > 0.5)
				gas_type = "nitrogen"
			if(co2_concentration > 0.5)
				gas_type = "CO2"
			if(plasma_concentration > 0.5)
				gas_type = "plasma"
			if(n2o_concentration && n2o_concentration > 0.5)
				gas_type = "N2O"

			new /obj/effect/gas_puff(get_turf(src.loc), gas_dispersal, gas_type)

/obj/item/projectile/bullet/fire_plume/proc/calculate_burn_strength(var/turf/T = null)
	if(!gas_jet)
		return

	var/jet_total_moles = gas_jet.total_moles
	if(jet_total_moles)
		var/toxin_concentration = gas_jet[GAS_PLASMA] / jet_total_moles
		if(!(toxin_concentration > 0.01))
			create_puff()
			return
	else
		return

	if(!has_O2_in_mix && T)
		var/turf/location = get_turf(src)
		var/datum/gas_mixture/turf_gases = location.return_air()
		var/turf_total_moles = turf_gases.total_moles
		if(turf_total_moles)
			var/o2_concentration = turf_gases[GAS_OXYGEN] / turf_total_moles
			if(!(o2_concentration > 0.01))
				create_puff()
				return
		else
			create_puff()
			return
		var/datum/gas_mixture/temp_gas_jet = new()
		temp_gas_jet.copy_from(gas_jet)
		temp_gas_jet.merge(turf_gases)
		if(temp_gas_jet.temperature < 373.15)
			temp_gas_jet.temperature = 383.15
			temp_gas_jet.update_values()
		for(var/i = 1; i <= 20; i++)
			temp_gas_jet.react()
		burn_strength = temp_gas_jet.temperature

	else
		if(!has_reacted)
			if(gas_jet.temperature < 373.15)
				gas_jet.temperature = 383.15
				gas_jet.update_values()
			for(var/i = 1; i <= 20; i++)
				gas_jet.react()
			has_reacted = 1
		burn_strength = gas_jet.temperature

	var/initial_burn_damage = burn_strength/100
	burn_damage = ((((-(10 * (0.9**((initial_burn_damage/10) * 5))) + 10) * 0.4) * 20)/5) //Exponential decay function 20*(y=(-(10*(0.9^(x/10)))+10)*0.4)
	//assuming the target stays in the fire for its duration, the total burn damage will be roughly 5 * burn_damage
	new effect_type(get_turf(src.loc), burn_damage, stepped_range, 1, jet_pressure, burn_strength, 1 SECONDS, firer.loc)

/obj/item/projectile/bullet/fire_plume/process_step()
	..()
	if(stepped_range <= max_range)
		stepped_range++
	else
		bullet_die()
		return
	var/turf/T = get_turf(src)
	for(var/obj/effect/E in T)
		if(istype(E, /obj/effect/blob))
			stepped_range += 3
			if(istype(E, /obj/effect/blob/shield)) //The fire can't penetrate through dense blob shields
				calculate_burn_strength(get_turf(src))
				bullet_die()
				return
	calculate_burn_strength(get_turf(src))

/obj/item/projectile/bullet/fire_plume/ex_act()
	return

/obj/item/projectile/bullet/fire_plume/dragonsbreath //for the shotgun shells
	has_O2_in_mix = 0
	max_range = 5
	burn_strength = 0
	burn_damage = 10
	jet_pressure = 0
	gas_jet = null
	effect_type = /obj/effect/fire_blast/dragonbreath

/obj/item/projectile/bullet/fire_plume/dragonsbreath/New()
	..()
	var/datum/gas_mixture/firemix = new /datum/gas_mixture
	firemix.adjust_gas(GAS_PLASMA, 666)
	gas_jet = firemix
	jet_pressure = firemix.return_pressure()
	gas_jet.temperature = 383.15
	burn_strength = gas_jet.temperature


/obj/item/projectile/bullet/mahoganut
	name = "mahogany nut"
	icon_state = "nut"
	damage = 30
	bounce_type = PROJREACT_WALLS|PROJREACT_WINDOWS
	bounces = 1
	fire_sound = 'sound/weapons/gunshot_1.ogg'
	bounce_sound = null
	projectile_speed = 1.33
	kill_count = 100
	embed = 0
	rotate = 0

/obj/item/projectile/bullet/leaf
	name = "leaf"
	icon_state = "leaf"
	damage = 10
	fire_sound = null
	penetration = 0
	embed = 0
	rotate = 0

/obj/item/projectile/bullet/liquid_blob
	name = "blob of liquid"
	icon_state = "liquid_blob"
	damage = 0
	penetration = 0
	embed = 0
	flags = FPRINT | NOREACT
	custom_impact = 1
	rotate = 0
	var/hard = 0
	var/radius = 1//big glob of liquid, splashes a bit on surroundings
	var/atom/splashed_atom = null

/obj/item/projectile/bullet/liquid_blob/New(atom/T, var/hardness = null, var/mixed_color=null, var/mixed_alpha=255, var/_rad=1)
	..(T)
	hard = hardness
	if(hard)
		damage = 30
		create_reagents(10)
	else
		create_reagents(50)
	icon += mixed_color
	alpha = mixed_alpha
	radius = _rad

/obj/item/projectile/bullet/liquid_blob/to_bump(var/atom/A)
	splashed_atom = A//doesn't matter if it's actually the atom we end up splashing since we only use that var on bullet_die()
	. = ..()
	if (. && A)
		if ((special_collision == PROJECTILE_COLLISION_DEFAULT) || (special_collision == PROJECTILE_COLLISION_BLOCKED))
			if(istype(A, /mob))
				if(hard)
					var/splash_verb = pick("dousing","completely soaking","drenching","splashing")
					A.visible_message("<span class='warning'>\The [src] smashes into [A], [splash_verb] \him!</span>",
											"<span class='warning'>\The [src] smashes into you, [splash_verb] you!</span>")
				else
					var/splash_verb = pick("douses","completely soaks","drenches","splashes")
					A.visible_message("<span class='warning'>\The [src] [splash_verb] [A]!</span>",
											"<span class='warning'>\The [src] [splash_verb] you!</span>")


/obj/item/projectile/bullet/liquid_blob/bullet_die()
	if(reagents.total_volume)
		var/turf/T = get_turf(splashed_atom)
		if (!T.density && T.Adjacent(src))
			loc = T
		playsound(loc, 'sound/effects/slosh.ogg', 20, 1)
		reagents.splashplosion(radius)
	..()

/obj/item/projectile/bullet/pellet
	name = "buckshot pellet"
	icon_state = "buckshot"
	damage = 10
	penetration = 0
	rotate = 0

/obj/item/projectile/bullet/buckshot
	name = "buckshot pellet"
	icon_state = "buckshot"
	var/variance_angle = 20
	var/total_amount_to_fire = 9
	var/type_to_fire = /obj/item/projectile/bullet/pellet

/obj/item/projectile/bullet/buckshot/OnFired()
	for(var/I = 1; I <=total_amount_to_fire; I++)
		var/obj/item/projectile/P = new type_to_fire(src.loc)
		P.firer = firer
		P.launch_at(original, tar_zone = src.def_zone, from = src.shot_from, variance_angle = src.variance_angle)
	bullet_die() // otherwise the buckshot bullet is an extra projectile in addition to the pellets.

/obj/item/projectile/bullet/buckshot/admin
	name = "admin buckshot pellet"
	type_to_fire = /obj/item/projectile/bullet/hecate

/obj/item/projectile/bullet/invisible
	name = "invisible bullet"
	icon_state = null
	damage = 25
	fire_sound = null
	embed = 0

/obj/item/projectile/bullet/invisible/on_hit(var/atom/target, var/blocked = 0) //silence the target for a few seconds on hit
	if (..(target, blocked))
		var/mob/living/L = target
		if(!L.silent || (L.silent && L.silent < 5))
			L.silent = 5
		return 1
	return 0

/obj/item/projectile/bullet/sabonana
	name = "armor-piercing discarding sabonana"
	icon_state = "sabonana_peel"
	damage = 30
	penetration = 10
	var/peel_drop_chance = 4
	var/peel_dropped = FALSE
	fire_sound = 'sound/misc/slip.ogg'

/obj/item/projectile/bullet/sabonana/process_step()
	..()
	if(!peel_dropped)
		if(prob(peel_drop_chance))
			return drop_peel()
		peel_drop_chance *= 2

/obj/item/projectile/bullet/sabonana/proc/drop_peel()
	new /obj/item/weapon/bananapeel(get_turf(src))
	icon_state = "sabonana"
	damage *= 2
	peel_dropped = TRUE

/obj/item/projectile/bullet/buckshot/bullet_storm
	name = "tiny pellet"
	total_amount_to_fire = 100
	custom_impact = 1
	embed_message = FALSE
	variance_angle = 50

/obj/item/projectile/bullet/faggot
	name = "high-speed faggot"
	icon = 'icons/obj/food.dmi'
	icon_state = "faggot"
	damage = 10

/obj/item/projectile/bullet/syringe
	name = "syringe"
	icon_state = "syringe"
	damage = 0
	nodamage = 1
	phase_type = null
	penetration = 0
	fire_sound = 'sound/items/syringeproj.ogg'
	travel_range = 6
	custom_impact = TRUE
	decay_type = /obj/item/weapon/reagent_containers/syringe/broken
	var/capacity = 15
	var/stealthy = FALSE

/obj/item/projectile/bullet/syringe/New(atom/A, var/obj/item/weapon/reagent_containers/syringe/source_syringe)
	..()
	if(source_syringe)
		create_reagents(source_syringe.reagents.total_volume)
		source_syringe.reagents.trans_to(src, source_syringe.reagents.total_volume)
		name = source_syringe.name
	else
		create_reagents(capacity)

/obj/item/projectile/bullet/syringe/on_hit(atom/A as mob|obj|turf|area)
	if(!A)
		return
	if(!..())
		return FALSE
	if(ismob(A))
		var/mob/M = A
		var/blocked
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && (H.species.chem_flags & NO_INJECT))
				H.visible_message("<span class='warning'>\The [src] bounces harmlessly off of \the [H].</span>", "<span class='notice'>\The [src] bounces off you harmlessly and breaks as it hits the ground.</span>")
				return

			blocked = istype(H.wear_suit, /obj/item/clothing/suit/space)
		//Syringe gun attack logging by Yvarov
		var/R
		if(reagents.total_volume)
			for(var/datum/reagent/E in reagents.reagent_list)
				R += E.id + " ("
				R += num2text(E.volume) + "),"
			M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with \a <b>[src]</b> ([R]) [blocked ? "\[BLOCKED\]" : ""]"
			firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with \a <b>[src]</b> ([R]) [blocked ? "\[BLOCKED\]" : ""]"
			msg_admin_attack("[firer] ([firer.ckey]) shot [M] ([M.ckey]) with \a [src] ([R]) [blocked ? "\[BLOCKED\]" : ""] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)")

		if(!blocked || stealthy)
			reagents.trans_to(M, reagents.total_volume)
			if(!stealthy)
				M.visible_message("<span class='danger'>\The [M] is hit by \the [src]!</span>")
			else
				to_chat(M, "<span class='danger'>You feel a slight prick.</span>")

		else
			var/mob/living/carbon/human/H = M
			H.visible_message("<span class='danger'>\The [H] is hit by \the [src], but \his [H.wear_suit] blocked it!</span>") // Fuck you validhunters.

/obj/item/projectile/bullet/syringe/dart
	stealthy = TRUE

/obj/item/projectile/bullet/syringe/candycane
	name = "Candycane"
	icon_state = "candycane"
	nodamage = 0
	damage = 20
	capacity = 15
	decay_type = null
	custom_impact = null

/obj/item/projectile/bullet/syringe/candycane/New()
	..()
	reagents.add_reagent(DIABEETUSOL, 4)
	reagents.add_reagent(SUGAR, 5)

/obj/item/projectile/bullet/rocksalt
	name = "rock-salt slug"
	icon_state = "rsshell"
	damage = 10
	agony = 20
	penetration = 1

/obj/item/projectile/bullet/rocksalt/New()
	..()
	create_reagents(10)
	reagents.add_reagent(HOLYSALTS, 5)
	reagents.add_reagent(HOLYWATER, 5)

/obj/item/projectile/bullet/rocksalt/on_hit(var/atom/atarget, var/blocked = 0)
	..()
	if(!blocked && ishuman(atarget))
		reagents.trans_to(atarget, reagents.total_volume)
	else
		reagents.reaction(atarget)