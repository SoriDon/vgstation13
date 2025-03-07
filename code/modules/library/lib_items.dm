/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */


/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "book-0"
	anchored = 1
	density = 1
	opacity = 1
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10

	health = 50
	var/tmp/busy = 0
	var/list/valid_types = list(/obj/item/weapon/book, \
								/obj/item/weapon/tome, \
								/obj/item/weapon/tome_legacy, \
								/obj/item/weapon/spellbook, \
								/obj/item/weapon/storage/bible, \
								/obj/item/dictionary)

/obj/structure/bookcase/cultify()
	return

/obj/structure/bookcase/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It contains [english_list(contents)].</span>")

/obj/structure/bookcase/initialize()
	for(var/obj/item/I in loc)
		if(is_type_in_list(I, valid_types))
			I.forceMove(src)
	update_icon()

/obj/structure/bookcase/proc/healthcheck()

	if(health <= 0)
		visible_message("<span class='warning'>\The [src] breaks apart!</span>")
		new /obj/item/stack/sheet/wood(get_turf(src), 3)
		qdel(src)

/obj/structure/bookcase/attackby(obj/item/O as obj, mob/user as mob)
	if(busy) //So that you can't mess with it while deconstructing
		return
	if(istype(O,/obj/item/weapon/storage/bag/bookbag))
		var/obj/item/weapon/storage/S = O
		for(var/obj/item/I in S.contents)
			if(is_type_in_list(I, valid_types))
				S.remove_from_storage(I, src)
		update_icon()
	else if(is_type_in_list(O, valid_types))
		user.drop_item(O, src)
		update_icon()
	else if(O.is_screwdriver(user) && user.a_intent == I_HELP) //They're probably trying to open the "maintenance panel" to deconstruct it. Let them know what's wrong.
		to_chat(user, "<span class='notice'>There are no screws on \the [src], it appears to be nailed together. You could probably disassemble it with just a crowbar.</span>")
		return
	else if(iscrowbar(O) && user.a_intent == I_HELP) //Only way to deconstruct, needs help intent
		O.playtoolsound(src, 75)
		user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		busy = 1

		if(do_after(user, src, 50))
			playsound(src, 'sound/items/Deconstruct.ogg', 75, 1)
			user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
			"<span class='notice'>You disassemble \the [src].</span>")
			busy = 0
			new /obj/item/stack/sheet/wood(get_turf(src), 5)
			qdel(src)
			return
		else
			busy = 0
		return
	else if(O.is_wrench(user))
		anchored = !anchored
		O.playtoolsound(src, 50)
		user.visible_message("<span class='warning'>[user] [anchored ? "":"un"]anchors \the [src] [anchored ? "to":"from"] the floor.</span>", \
		"<span class='notice'>You [anchored ? "":"un"]anchor the [src] [anchored ? "to":"from"] the floor.</span>")
	else if(istype(O, /obj/item/weapon/pen))
		set_tiny_label(user)
	else if(O.damtype == BRUTE || O.damtype == BURN)
		user.delayNextAttack(10) //We are attacking the bookshelf
		health -= O.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [O].</span>", \
		"<span class='warning'>You hit \the [src] with \the [O].</span>")
		healthcheck()
	else
		return ..() //Weapon checks for weapons without brute or burn damage type and grab check

//AAHHHHHHHHH HARDMAPPING
/obj/structure/bookcase/set_labeled()
	name = initial(name)
	..()

/obj/structure/bookcase/attack_hand(var/mob/user as mob)
	if(contents.len)
		var/obj/item/weapon/book/choice = input("Which book would you like to remove from \the [src]?") as null|obj in contents
		if(choice)
			if(user.incapacitated() || user.lying || !in_range(src, user))
				return
			user.put_in_hands(choice)
			update_icon()

/obj/structure/bookcase/attack_ghost(mob/dead/observer/user as mob)
	if(contents.len && in_range(user, src))
		var/obj/item/weapon/book/choice = input("Which book would you like to read?") as null|obj in contents
		if(choice)
			if(!istype(choice)) //spellbook, cult tome, or the one weird bible storage
				to_chat(user,"A mysterious force is keeping you from reading that.")
				return
			choice.read_a_motherfucking_book(user)

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/I in contents)
				qdel(I)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/I in contents)
				if(prob(50))
					qdel(I)
			qdel(src)
			return
		if(3.0)
			if(prob(50))
				qdel(src)
			return
	return

/obj/structure/bookcase/Destroy()

	for(var/obj/item/I in contents)
		if(is_type_in_list(I, valid_types))
			I.forceMove(get_turf(src))
	..()

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"

/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

/obj/structure/bookcase/manuals/medical/New()
	..()
	new /obj/item/weapon/book/manual/medical_cloning(src)
	new /obj/item/weapon/book/manual/chemistry_manual(src)
	new /obj/item/weapon/book/manual/virology_guide(src)
	new /obj/item/weapon/book/manual/virology_encyclopedia(src)
	update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

/obj/structure/bookcase/manuals/engineering/New()
	..()
	new /obj/item/weapon/book/manual/engineering_construction(src)
	new /obj/item/weapon/book/manual/engineering_particle_accelerator(src)
	new /obj/item/weapon/book/manual/engineering_hacking(src)
	new /obj/item/weapon/book/manual/engineering_guide(src)
	new /obj/item/weapon/book/manual/engineering_singularity_safety(src)
	new /obj/item/weapon/book/manual/robotics_cyborgs(src)
	update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/New()
	..()
	new /obj/item/weapon/book/manual/research_and_development(src)
	update_icon()


/*
 * Book
 */
/obj/item/weapon/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	flags = FPRINT
	attack_verb = list("bashes", "whacks", "educates")

	autoignition_temperature = AUTOIGNITION_PAPER

	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/wiki_page       // Title of the book's wiki page.
	var/forbidden = 0     // Prevent ordering of this book. (0=no, 1=yes, 2=emag only)
	var/obj/item/store	// What's in the book?
	var/runestun = 0	//Does it have a stun talisman in it?
	var/occult = 0 //Does this book contain forbidden and occult writings?

	var/book_desc = ""

	var/book_width = 600
	var/book_height = 800

/obj/item/weapon/book/New()
	..()
	if(wiki_page)
		dat = {"
		<html>
			<body style="margin:5px;padding:0px;overflow:hidden">
				<iframe width='100%' height='100%' frameborder="0" style="overflow:hidden;height:100%;width:100%" src="http://ss13.moe/wiki/index.php?title=[wiki_page]&printable=yes"></iframe>
			</body>
		</html>
		"}

/obj/item/weapon/book/cultify()
	new /obj/item/weapon/tome_legacy(loc)
	..()

/obj/item/weapon/book/proc/read_a_motherfucking_book(mob/user)
	if(carved)
		to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
		return
	if (!isobserver(user))
		playsound(user, "pageturn", 50, 1, -5)
	if(src.dat)
		user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=[name];size=[book_width]x[book_height]")
		if(!isobserver(user))
			user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
		onclose(user, "book")
	else if(occult)
		to_chat(user, "<span class='sinister'>As you read the book, your mind is assaulted by foul, arcane energies!</span>")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/weapon/book/attack_self(var/mob/user as mob)
	if(store)
		to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
		store.forceMove(get_turf(src))
		store = null
		return
	if(runestun)
		var/mob/living/carbon/human/M = user
		M.flash_eyes(visual = 1)
		if (!(M_HULK in user.mutations))
			M.silent += 15
		M.Knockdown(25)
		M.Stun(25)
		runestun = 0
	if(occult)
		var/mob/living/carbon/human/M = user
		M.flash_eyes(visual = 1)
		M.Knockdown(15)
		M.Stun(15)
		var/datum/organ/internal/eyes/eyes = M.internal_organs_by_name["eyes"]
		eyes.damage += rand(30,60)
		M.adjustBrainLoss(rand(50,100))
		M.hallucination = max(0, M.hallucination + rand(60,90))
	read_a_motherfucking_book(user)

/obj/item/weapon/book/examine(mob/user)
	if(isobserver(user) && in_range(src,user) && occult == 0)
		read_a_motherfucking_book(user)
	else
		..()

/obj/item/weapon/book/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!carved && W.is_sharp() && W.sharpness_flags & SHARP_BLADE)
		to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
		if(do_after(user, src, 30 / W.sharpness))
			to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
			carved = 1
			occult = 0 //A book cannot be an occult book if it has no pages
			return
	if(carved)
		if(!store)
			if(W.w_class < W_CLASS_MEDIUM)
				if(user.drop_item(W, src))
					store = W
					to_chat(user, "<span class='notice'>You put [W] in [title].</span>")
					return
			else
				to_chat(user, "<span class='notice'>[W] won't fit in [title].</span>")
				return
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return
	if(istype(W, /obj/item/weapon/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Short Description", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if(!newtitle)
					to_chat(usr, "The title is invalid.")
					return
				else
					src.name = newtitle
					src.title = newtitle
			if("Contents")
				var/content = sanitize(input(usr, "Write your book's contents (HTML NOT allowed):") as message|null)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return
				else
					src.dat += content
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return
				else
					src.author = newauthor
			if("Short Description")
				var/newdesc = reject_bad_text(stripped_input(usr, "Write a new short description:"))
				if(!newdesc)
					to_chat(usr, "The description is invalid.")
					return
				else
					src.book_desc = newdesc
			else
				return
	else if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		if(!scanner.computer)
			to_chat(user, "[W]'s screen flashes: 'No associated computer found!'")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer.'")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = src.name
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == src.name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book has been checked in.'")
							return
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'")
				if(3)
					scanner.book = src
					for(var/obj/item/weapon/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'")
							return
					scanner.computer.inventory.Add(src)
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'")

	else if(istype(W, /obj/item/weapon/paper/talisman))
		var/obj/item/weapon/paper/talisman/talisman = W
		if(runestun)
			to_chat(user, "<span class='notice'>There is already a talisman between the pages.</span>")
			return
		if(occult)
			to_chat(user, "<span class='sinister'>You feel as if it would be a bad idea to add a talisman to this particular book.</span>")
			return
		if(talisman.imbue == "runestun")
			to_chat(user, "<span class='notice'>You slide the talisman between the pages.</span>")
			qdel(talisman)
			runestun = 1
	else if(W.is_hot())
		if(do_after(user, src, 2 SECONDS))
			visible_message("<span class='warning'>[user] lights [src] on fire with \the [W]!</span>")
			ignite()
	else
		..()

/*
 * Traitor Ooccult Books
 */


/obj/item/weapon/book/occult
	name = "The King in Yellow"
	title = "The King in Yellow"
	occult = 1
	var/possible_names = list("The King in Yellow", "The Locksmith's Dream", "The Tantra of Worms", "Infinite Jest", "The Legacy of Totalitarianism in a Tundra", "The Rose of Hypatia",
	"Gravity's Rainbow", "Aristotle's Poetics", "The Geminiad", "My Diary", "The War of the Roads", "The Courier's Tragedy", "The Burning of the Unburnt God", "Love's Labour's Won",
	"The Necronomicon", "The Funniest Joke in the World", "Woody Got Wood", "Peggy's Revenge", "House of Leaves", "A True and Accurate History of the Shadowless Kings", "The Book of Nod",
	"Atlas Shrugged", "The Serenity of the Black Wood", "The World Does Not Weep")

/obj/item/weapon/book/occult/New()
	..()
	name = pick(possible_names)
	title = name
	icon_state = "book[rand(1, 9)]"

/*
 * Barcode Scanner
 */
/obj/item/weapon/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	flags = FPRINT
	var/obj/machinery/computer/library/checkout/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/weapon/book/book	 //  Currently scanned book
	var/mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

/obj/item/weapon/barcodescanner/attack_self(mob/user as mob)
	mode += 1
	if(mode > 3)
		mode = 0
	to_chat(user, "[src] Status Display:")
	var/modedesc
	switch(mode)
		if(0)
			modedesc = "Scan book to local buffer."
		if(1)
			modedesc = "Scan book to local buffer and set associated computer buffer to match."
		if(2)
			modedesc = "Scan book to local buffer, attempt to check in scanned book."
		if(3)
			modedesc = "Scan book to local buffer, attempt to add book to general inventory."
		else
			modedesc = "ERROR"
	to_chat(user, " - Mode [mode] : [modedesc]")
	if(src.computer)
		to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
	else
		to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
	to_chat(user, "\n")

/obj/item/weapon/barcodescanner/Destroy()
	book = null
	..()

/obj/structure/closet/secure_closet/library
	name = "library cabinet"
	desc = "Contains a variety of useful items for a library-dweller."
	req_access = list(access_library)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"
	is_wooden = TRUE
	starting_materials = list(MAT_WOOD = 2*CC_PER_SHEET_WOOD)
	w_type = RECYK_WOOD
	autoignition_temperature = AUTOIGNITION_WOOD


/obj/structure/closet/secure_closet/library/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/storage/lawyer/bluejacket,
		/obj/item/clothing/under/suit_jacket/really_black,
		/obj/item/clothing/under/suit_jacket/female,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/accessory/tie/blue,
		/obj/item/clothing/accessory/tie/red,
		/obj/item/clothing/head/det_hat,
		/obj/item/clothing/head/flatcap
	)
