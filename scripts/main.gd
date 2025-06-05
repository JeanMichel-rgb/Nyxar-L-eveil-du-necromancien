extends Node

const ratio  : float = 0.5625
@onready var window = get_window()
@onready var window_size = window.size
@onready var tower_name = get_node("scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/Tower_name")
@onready var tower_description = get_node("scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/descriptions")
@onready var tower_puissance = get_node("scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/puissance")
@onready var tower_vitesse = get_node("scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/vitesse")
@onready var tower_zone = get_node("scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/zone")
@onready var tower_prix = get_node( "scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/prix")
@onready var image_tour : Button = get_node("scene/menus/menu_tour_Path/PathFollow/menu_tour/Statistiques/bars_texts/image_tour")
@onready var scene : Node2D = $scene
@onready var collision_en_bas : Node2D = $scene/map/collision_en_bas
var tour_amélio : Node2D
var path_monster : Node2D
var prixtours : Dictionary = {
	"boulet" = 40,
	"boulets_explosifs" = 100,
	"mitrailleuse" = 450,
	"lazer_1" = 120,
	"lazer_2" = 250,
	"lazer_3" = 700,
	"lazer_constant" = 600,
	"hache" = 110,
	"griffes" = 400,
	"dieu_tournoyant" = 800,
	"mine_explosive" = 5,
	"mine_trou_noir" = 100,
	"neige" = 500,
	"ecrabouillator" = 1000,
	"pierre" = 750,
	"flammes" = 900} 
var tower_caracteristiques : Dictionary = {}
const sequence_infini_longueur : int = 0 #amélioration toutes les n+1 vagues
var setting_menu_state : String = "base"
var save_name_submit : bool = false
var save_name : String = ""
var actual_map_level : int = 0
var num_monster = -1
var map : String = "" # du type : level/index (ex : impossible/m3)
var niveau : String = ""
var menu_tour_open : bool = false
var menu_amelio_open : bool = false
var actual_wave : int = -1
var actual_sequence : int = 0
var trash : bool = false

func _ready() -> void:
	Engine.max_fps = 100
	logo()
	#connect signals
	$menu/histoire.connect("pressed", play)
	$menu/evolution.connect("pressed", play_evolution)
	$menu/map/suivant.connect("pressed", next_map_level)
	$"menu/map/précédent".connect("pressed", previous_map_level)
	scene.get_node("menus/menu_tour_Path/PathFollow/menu_tour/Area2D").mouse_entered.connect(set_menu_tour_state.bind(true))
	scene.get_node("menus/menu_tour_Path/PathFollow/menu_tour/Area2D").mouse_exited.connect(set_menu_tour_state.bind(false))
	for level in $menu/map/map_level.get_children():
		for map_index in level.get_children():
			map_index.pressed.connect(choose_map.bind(map_index))
	for level in $menu/levels.get_children():
		level.pressed.connect(choose_level.bind(level))
	for tower_type in scene.get_node("menus/menu_tour_Path/PathFollow/menu_tour/boutons").get_children():
		for tower in tower_type.get_children():
			tower.pressed.connect(create_tower.bind(String(tower.name)))
	$"scene/parametre/emplacements/1".pressed.connect(saves.bind("1"))
	$"scene/parametre/emplacements/2".pressed.connect(saves.bind("2"))
	$"scene/parametre/emplacements/3".pressed.connect(saves.bind("3"))
	$"menu/load/1".pressed.connect(saves.bind("1"))
	$"menu/load/2".pressed.connect(saves.bind("2"))
	$"menu/load/3".pressed.connect(saves.bind("3"))
	scene.get_node("menus/bande/bouton_poubelle/Button").connect("pressed", trash_pressed)
	#hide and show
	scene.hide()
	$menu.show()
	$menu/histoire.show()
	$menu/evolution.show()
	$menu/load.show()
	$"statistiques fin".hide()
	$menu/map.hide()
	$menu/levels.hide()
	$"menu_amélio".hide()
	$scene/parametre.hide()
	$scene/button_parametre.hide()
	$scene/parametre/MeshInstance2D2.hide()
	$scene/parametre/emplacements.hide()
	$scene/parametre/nom.hide()
	#get previous file
	if FileAccess.file_exists("user://savegame.data"):
		var file_read = FileAccess.open("user://savegame.data", FileAccess.READ)
		if file_read.get_length() >= 1:
			var saves : Dictionary = file_read.get_var()
			for i in 3:
				if saves[str(i+1)]["saved"]:
					get_node("menu/load/"+str(i+1)).text = saves[str(i+1)]["name"]
				else :
					get_node("menu/load/"+str(i+1)).text = "emplacement vide"
	date()
	setting_menu_state = "load"

func logo() -> void:
	$troumif_studio/AnimationPlayer.play("logo")
	await sleep(4)
	scene.get_node("parametre/son/musique").play()

func trash_pressed() -> void:
	trash = true
	Global.hide_gui = true

func set_menu_tour_state(is_open : bool) -> void:
	menu_tour_open = is_open

func choose_map(button_id) -> void:
	map = button_id.get_parent().name+"/"+button_id.name
	$menu/map.hide()
	$menu/levels.show()

func choose_level(button_id) -> void:
	niveau = button_id.name
	$menu.hide()
	Global.game_start = true
	start_game()

func start_game() -> void:
	scene.show()
	path_monster = get_node("scene/map/"+map+"/Path2D")
	scene.get_node("map/"+map).modulate = Color(1,1,1)
	if Global.automatic_evolution:
		if niveau == "facile":
			Global.metaux = 500
			Global.pv = 100
			Global.vitesse_ratio = 0.8
		if niveau == "normal":
			Global.metaux = 400
			Global.pv = 100
			Global.vitesse_ratio = .9
		if niveau == "expert":
			Global.metaux = 375
			Global.pv = 50
			Global.vitesse_ratio = .9
		if niveau == "demon":
			Global.metaux = 350
			Global.pv = 20
			Global.vitesse_ratio = .95
		if niveau == "impossible":
			Global.metaux = 300
			Global.pv = 1
			Global.vitesse_ratio = 1
	else :
		if niveau == "facile":
			Global.metaux = 20000
			Global.pv = 100
			Global.vitesse_ratio = 0.8
		if niveau == "normal":
			Global.metaux = 100
			Global.pv = 100
			Global.vitesse_ratio = .9
		if niveau == "expert":
			Global.metaux = 90
			Global.pv = 50
			Global.vitesse_ratio = .9
		if niveau == "demon":
			Global.metaux = 80
			Global.pv = 20
			Global.vitesse_ratio = .95
		if niveau == "impossible":
			Global.metaux = 80
			Global.pv = 1
			Global.vitesse_ratio = 1
	
	#disabled all maps collisions
	for maps in scene.get_node("map").get_children():
		if (maps.name == "facile" or
			maps.name == "normal" or
			maps.name == "expert" or
			maps.name == "demon" or
			maps.name == "impossible"):
			for map in maps.get_children():
				map.hide()
				for collision in map.get_node("path_collisions").get_children():
					collision.disabled = true
	scene.get_node("map/"+map).show()
	#reactivate map collisions
	for collision in scene.get_node("map/"+map+"/path_collisions").get_children():
		collision.disabled = false
	collision_en_bas.reparent(scene.get_node("map/"+map+"/path_collisions"))

func end_game () -> void:
	kill_game()
	restart_game()

func restart_game () -> void:
	kill_game()
	#reset visibility
	$"statistiques fin".hide()
	scene.hide()
	$scene/menus/livre_histoire.show()
	$menu/histoire.show()
	$menu/evolution.show()
	$menu/load.show()
	$menu.show()
	$menu/map.hide()
	$menu/levels.hide()
	$"menu_amélio".hide()
	$scene/button_parametre.hide()
	$scene/parametre.hide()
	$scene/parametre/MeshInstance2D2.hide()
	$scene/parametre/emplacements.hide()
	$scene/parametre/nom.hide()
	#reset date
	date()
	if FileAccess.file_exists("user://savegame.data"):
		var file_read = FileAccess.open("user://savegame.data", FileAccess.READ)
		if file_read.get_length() >= 1:
			var saves : Dictionary = file_read.get_var()
			for i in 3:
				if saves[str(i+1)]["saved"]:
					get_node("menu/load/"+str(i+1)).text = saves[str(i+1)]["name"]
				else :
					get_node("menu/load/"+str(i+1)).text = "emplacement vide"

func kill_game () -> void:
	scene.reparent(self, false)
	tower_caracteristiques = {}
	$"menu_amélio/argent".text = ""
	$"menu_amélio/amélio_name_".text = ""
	$"menu_amélio/activé_desactivé".text = ""
	for tower in $scene/map/Towers.get_children():
		tower.queue_free()
	if map != "":
		for monster in get_node("scene/map/"+map+"/Path2D").get_children():
			monster.queue_free()
	for grave in $scene/tombe.get_children():
		grave.queue_free()
	#reset variables
	$scene/menus/livre_histoire.vague = 0
	num_monster = -1
	map = ""
	niveau = ""
	setting_menu_state = "load"
	menu_tour_open = false
	menu_amelio_open = false
	actual_wave = -1
	actual_sequence = 0
	trash = false
	Global.metaux = 100
	Global.pv = 100
	Global.nb_monster_in_life = 0
	Global.automatic_evolution = false
	Global.game_start = false
	Global.in_wave = false
	Global.hide_gui = false
	Global.placing_tower = false
	Global.pos_monsters = []
	Global.pierre = []
	Global.feu = []
	Global.monsters_evolutions = {
	"type1" = {
		"name" = "type1",
		"speed" = 1,
		"health" = 3,
		"damages" = 5,
		"scale" = 1,
		"resistance" = {
			"shock" = 1,      #choc
			"notch" = 1,      #entaille
			"lazer" = 1,      #laser
			"poison" = 1,     #poison
			"fire" = 1,       #feu
			"explosion" = 1   #explosion
			}
		},
	"type2" = {
		"name" = "type2",
		"speed" = 2,
		"health" = 1,
		"damages" = 5,
		"scale" = 1,
		"resistance" = {
			"shock" = 1,      #choc
			"notch" = 1,      #entaille
			"lazer" = 1,      #laser
			"poison" = 1,     #poison
			"fire" = 1,       #feu
			"explosion" = 1   #explosion
			}
		},
	"type3" = {
		"name" = "type3",
		"speed" = .7,
		"health" = 10,
		"damages" = 5,
		"scale" = 1.2,
		"resistance" = {
			"shock" = 1,      #choc
			"notch" = 1,      #entaille
			"lazer" = 1,      #laser
			"poison" = 1,     #poison
			"fire" = 1,       #feu
			"explosion" = 1   #explosion
			}
		}
	}
	Global.damages_this_sequence = {
	"type1" = {
		"shock" = 0,      #choc
		"notch" = 0,      #entaille
		"lazer" = 0,      #laser
		"poison" = 0,     #poison
		"fire" = 0,       #feu
		"explosion" = 0   #explosion
		},
	"type2" = {
		"shock" = 0,      #choc
		"notch" = 0,      #entaille
		"lazer" = 0,      #laser
		"poison" = 0,     #poison
		"fire" = 0,       #feu
		"explosion" = 0   #explosion
		},
	"type3" = {
		"shock" = 0,      #choc
		"notch" = 0,      #entaille
		"lazer" = 0,      #laser
		"poison" = 0,     #poison
		"fire" = 0,       #feu
		"explosion" = 0   #explosion
		}
	}

func _process(delta: float) -> void:
	son()
	window.size.y = window.size.x * ratio
	set_menus()
	set_pv_argent_values()
	scene.scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$"menu_amélio".scale = scene.scale
	$camera.size = Vector2(1151,649) * scene.scale.x
	$"statistiques fin".scale =  Vector2(1,1) * (float(window.size.x) / float(1152))
	$troumif_studio.scale =  Vector2(1,1) * (float(window.size.x) / float(1152))
	var menu_steps : float = .04
	if menu_tour_open:
		await sleep(0.1)
		if menu_tour_open:
			scene.get_node("menus/menu_tour_Path/PathFollow").progress_ratio += menu_steps
	else :
		await sleep(0.1)
		if not menu_tour_open:
			scene.get_node("menus/menu_tour_Path/PathFollow").progress_ratio -= menu_steps
	if Global.hide_gui or Global.placing_tower :
		scene.get_node("menus").hide()
		scene.get_node("hide_button/hide_button").icon = load("res://td images/images_menu/bouton_allumé.png")
	else :
		scene.get_node("menus").show()
		scene.get_node("hide_button/hide_button").icon = load("res://td images/images_menu/bouton_éteint.png")
	if Global.in_wave:
		scene.get_node("menus/new_wave").icon = load("res://td images/images_menu/progress_wave.png")
	else :
		scene.get_node("menus/new_wave").icon = load("res://td images/images_menu/await_wave.png")
	trash_()

func son () -> void:
	scene.get_node("parametre/son/barre_son").value = scene.get_node("parametre/son/HScrollBar").value
	scene.get_node("parametre/son/musique").volume_db = scene.get_node("parametre/son/barre_son").value-50

func trash_ () -> void:
	if trash:
		scene.get_node("map/trash").show()
		scene.get_node("map/trash").global_position = scene.get_global_mouse_position()
		var tour = scene.get_node("map/trash/trash2").get_overlapping_areas()
		if tour != [] :
			scene.get_node("map/trash/prix vente").show()
			scene.get_node("map/trash/tower name").show()
			scene.get_node("map/trash/prix vente").text = ""
			scene.get_node("map/trash/tower name").text = ""
			for test in tour :
				if test.get_parent().get_parent() == scene.get_node("map/Towers"):
					var tower = test.get_parent()
					var type = tower.caracteristiques["type"]
					var apport : float = prixtours[type]
					if not (type == "mine_explosive" or type == "mine_trou_noir"):
						for i in 3:
							if tower.caracteristiques["améliorations"][str(i+1)] != null:
								if tower.caracteristiques["améliorations"][str(i+1)]["upgraded"]:
									apport += tower.caracteristiques["améliorations"][str(i+1)]["price"]
					apport *= 2
					apport = apport/3.0
					$"scene/map/trash/tower name".text = str(type)
					$"scene/map/trash/prix vente".text ="prix de vente : "+str(int(apport))+" métaux"
					if Input.is_action_just_pressed("clique gauche"): 
						Global.metaux += apport
						test.get_parent().queue_free()
						scene.get_node("map/zone_tour").hide()
				if Input.is_action_just_pressed("clique gauche") and $"scene/map/trash/tower name".text == "":
					trash = false
					Global.hide_gui = false
		else : 
			$"scene/map/trash/prix vente".hide()
			$"scene/map/trash/tower name".hide()
			if Input.is_action_just_pressed("clique gauche"):
				trash = false
				Global.hide_gui = false
	else : scene.get_node("map/trash").hide()

func set_pv_argent_values () -> void:
	scene.get_node("menus/bande/argent").text = str(int(Global.metaux))
	scene.get_node("menus/bande/pv").text = str(Global.pv)
	$"menu_amélio/argent_t".text = str(int(Global.metaux))

func set_menus () -> void:
	#base menu
	$menu/histoire.scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$menu/histoire.position = get_viewport().size/2
	$menu/histoire.position -= $menu/histoire.size*$menu/histoire.scale.x/2
	
	$menu/evolution.scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$menu/evolution.position = get_viewport().size/2
	$menu/evolution.position -= $menu/histoire.size*$menu/histoire.scale.x/2
	
	$"menu/load/1".scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$"menu/load/1".position = get_viewport().size/2
	$"menu/load/1".position -= $"menu/load/1".size*$"menu/load/1".scale.x/2
	
	$"menu/load/2".scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$"menu/load/2".position = get_viewport().size/2
	$"menu/load/2".position -= $"menu/load/2".size*$"menu/load/2".scale.x/2
	
	$"menu/load/3".scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$"menu/load/3".position = get_viewport().size/2
	$"menu/load/3".position -= $"menu/load/3".size*$"menu/load/3".scale.x/2
	
	$"menu/load/Label".scale = Vector2(1,1) * (float(window.size.x) / float(1152))
	$"menu/load/Label".position = get_viewport().size/2
	$"menu/load/Label".position.x = 0
	$"menu/load/Label".size.x = window.size.x/$"menu/load/Label".scale.x
	
	$menu/histoire.position.x -= $menu/histoire.size.x*$menu/histoire.scale.x*.6
	$menu/evolution.position.x += $menu/histoire.size.x*$menu/histoire.scale.x*.6
	$"menu/load/1".position.x -= $"menu/load/1".size.x*$"menu/load/1".scale.x*1.1
	$"menu/load/2".position.x += 0
	$"menu/load/3".position.x += $"menu/load/3".size.x*$"menu/load/3".scale.x*1.1
	
	$"menu/load/1".position.y += window.size.y/4
	$"menu/load/2".position.y += window.size.y/4
	$"menu/load/3".position.y += window.size.y/4
	
	$menu/histoire.position.y -= window.size.y/8
	$menu/evolution.position.y -= window.size.y/8
	
	
	$menu/map/suivant.position = Vector2((((get_viewport().size.x)*9)/10)-40, (get_viewport().size.y/8))
	$"menu/map/précédent".position = Vector2((get_viewport().size.x)/10, (get_viewport().size.y/8))
	$menu/map/suivant.size.y = get_viewport().size.y*3/4
	$"menu/map/précédent".size.y = get_viewport().size.y*3/4
	#set map menu
	var size : Vector2 = Vector2((get_viewport().size.x-(get_viewport().size.x*3.5/10+80))/2, (get_viewport().size.y-(get_viewport().size.y*2.5/8))/2)
	for level in $menu/map/map_level.get_children():
		var level_name : String = level.name
		get_node("menu/map/map_level/"+level_name+"/m1").size = size
		get_node("menu/map/map_level/"+level_name+"/m2").size = size
		get_node("menu/map/map_level/"+level_name+"/m3").size = size
		get_node("menu/map/map_level/"+level_name+"/m4").size = size
		get_node("menu/map/map_level/"+level_name+"/m1").position = Vector2(get_viewport().size.x*3/20+40, get_viewport().size.y/8)
		get_node("menu/map/map_level/"+level_name+"/m2").position = Vector2(get_viewport().size.x*2/10+40+size.x, get_viewport().size.y/8)
		get_node("menu/map/map_level/"+level_name+"/m3").position = Vector2(get_viewport().size.x*3/20+40, get_viewport().size.y*1.5/8+size.y)
		get_node("menu/map/map_level/"+level_name+"/m4").position = Vector2(get_viewport().size.x*2/10+40+size.x, get_viewport().size.y*1.5/8+size.y)
		level.position.x = get_viewport().size.x * ($menu/map/map_level.get_children().find(level))
	size = Vector2(window.size.x/2, window.size.y/8)
	for level in $menu/levels.get_children():
		level.size = size
		level.position = Vector2((window.size.x-size.x)/2, window.size.y*($menu/levels.get_children().find(level)*2+$menu/levels.get_children().find(level)+1)/16)
	$menu/Background.position = window.size/2
	$menu/Background.scale = window.size

func play () -> void:
	var cinematique = (load("res://scenes/cinematique.tscn")as PackedScene).instantiate()
	add_child(cinematique)
	cinematique.get_node("AnimationPlayer").play("tombe")
	Global.automatic_evolution = false
	setting_menu_state = "load"
	$menu/histoire.hide()
	$menu/evolution.hide()
	$menu/load.hide()
	$menu/map.show()
	$scene/button_parametre.show()
	for i in 200:
		cinematique.position = window.size/2
		await sleep(.1)
	cinematique.queue_free()

func play_evolution () -> void:
	Global.automatic_evolution = true
	setting_menu_state = "load"
	$menu/histoire.hide()
	$menu/evolution.hide()
	$menu/load.hide()
	$menu/map.show()
	$scene/menus/livre_histoire.hide()
	$scene/button_parametre.show()

func next_map_level () -> void:
	if actual_map_level <= 3:
		actual_map_level += 1
		var m = actual_map_level
		var e = -(window.size.x * m)
		while $menu/map/map_level.position.x > e:
			await sleep()
			$menu/map/map_level.position.x -= window.size.x/36
		if m == actual_map_level:
			$menu/map/map_level.position.x = e

func previous_map_level () -> void:
	if actual_map_level >= 1:
		actual_map_level -= 1
		var m = actual_map_level
		var e = -(window.size.x * m)
		while $menu/map/map_level.position.x < e:
			await sleep()
			$menu/map/map_level.position.x += window.size.x/36
		if m == actual_map_level:
			$menu/map/map_level.position.x = e

func sleep(delta : float = 0.001) -> void:
	await get_tree().create_timer(delta).timeout

func date () -> void:
	if Global.automatic_evolution:
		const mois : Array = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre",]
		const durée_mois : Array = [31,28,31,30,31,30,31,31,30,31,30,31]
		var date  : int = 21+actual_wave + (actual_sequence*(sequence_infini_longueur+1))
		var moi_index : int = 3
		var année : int = 2484
		while date % (durée_mois[moi_index]+1) != date:
			date -= durée_mois[moi_index]
			moi_index += 1
			if moi_index == 12:
				moi_index = 0
				année += 1
		scene.get_node("menus/bande/date").text = str(date)+" "+str(mois[moi_index])+" "+str(année)
	else :
		const mois : Array = ["Avril","Mai","Juin"]
		const durée_mois : Array = [30,31,30]
		var date = 21 + actual_wave + (actual_sequence*7)
		var moi_index = 0
		while date % (durée_mois[moi_index]+1) != date:
			date -= durée_mois[moi_index]
			moi_index += 1
		scene.get_node("menus/bande/date").text = str(date)+" "+str(mois[moi_index])+" 2484"

#monster code 
func new_monster(his_name, await_time : float = 1, progress : float = 0 ) -> void:
	if Global.pv > 0 :
		num_monster += 1
		Global.nb_monster_in_life +=1
		var monster = preload("res://scenes/monster.tscn")
		monster = monster.instantiate()
		monster.my_name = his_name
		monster.num = num_monster
		Global.pos_monsters.append(0)
		path_monster.add_child(monster)
		monster.progress = progress
		await sleep(await_time)

func death_player () -> void:
	if Global.hide_gui : 
		Global.hide_gui = false
		scene.reparent(self, false)	
		tower_caracteristiques = {}
		$"menu_amélio/argent".text = ""
		$"menu_amélio/amélio_name_".text = ""
		$"menu_amélio/activé_desactivé".text = ""
		$"menu_amélio".hide()
	scene.hide()
	statistiques()
	kill_game()
	while not Input.is_action_just_pressed("clique gauche"):
		await sleep()
	end_game()

func _on_new_wave_pressed() -> void:
	if not Global.in_wave:
		scene.get_node("button_parametre").hide()
		#initialise
		var all_monster_are_attacking = false
		num_monster = -1
		Global.in_wave = true
		
		#region waves
		if not Global.automatic_evolution:
			
			#initialise
			actual_wave += 1
			await date()
			#update date
			
			#region launching
			#region sequence_1
			if actual_sequence == 0:
				if actual_wave == 0:
					for monster in 3:
						await new_monster("squelette_1", 2)
				
				elif actual_wave == 1:
					for monster in 4:
						await new_monster("squelette_2")
				
				elif actual_wave == 2:
					for i in 2:
						await new_monster("squelette_1")
						await new_monster("squelette_2")
					await sleep(2)
					await new_monster("squelette_3", 3)
					for i in 2:
						await new_monster("squelette_2")
						await new_monster("squelette_1")
				
				elif actual_wave == 3:
					await new_monster("squelette_1")
					await new_monster("squelette_2")
					await new_monster("squelette_3")
					await new_monster("squelette_2")
					await new_monster("squelette_1")
					await sleep(3)
					await new_monster("squelette_1")
					await new_monster("squelette_2")
					await new_monster("squelette_3")
					await new_monster("squelette_2")
					await new_monster("squelette_1")
				
				elif actual_wave == 4:
					for monster in 5:
						await new_monster("squelette_3", 2)
				
				elif actual_wave == 5:
					for i in 3:
						for monster in 3:
							await new_monster("squelette_2")
						for monster in 3:
							await new_monster("squelette_1")
						for monster in 3:
							await new_monster("squelette_3")
				
				elif actual_wave == 6:
					for monster in 5:
						await new_monster("squelette_2")
					await sleep(2)
					for monster in 5:
						await new_monster("squelette_3")
					await sleep(4)
					await new_monster("squelette_boss", 3)
					for i in 2:
						await new_monster("squelette_3")
					
					#change sequence
					actual_sequence += 1
					actual_wave = -1
			
			#endregion
			
			#region sequence_2
			
			if actual_sequence == 1:
				if actual_wave == 0:
					for i in 7:
						await new_monster("s2_1")
				
				elif actual_wave == 1:
					for i in 2 :
						await new_monster("s2_3", 2)
					await sleep(1)
					for i in 15 :
						await new_monster("s2_1")
				
				elif actual_wave == 2:
					for i in 20:
						await new_monster("s2_2", 2*(1-(float(i)/20.0)))
				
				elif actual_wave == 3:
					for k in 3:
						for i in 3:
							await new_monster("s2_3")
						for i in 2:
							await new_monster("s2_1")
						await new_monster("s2_2", 2)
				
				elif actual_wave == 4:
					for i in 6:
						await new_monster("s2_3", 2*(1-(float(i)/6.0)))
						await new_monster("s2_2", 2*(1-(float(i)/6.0)))
						await new_monster("s2_1", 2*(1-(float(i)/6.0)))
						await sleep(4*(1-(float(i)/6.0)))
				
				elif actual_wave == 5:
					for k in 2:
						for i in 2:
							await new_monster("s2_3")
						await sleep(1)
						for i in 3:
							await new_monster("s2_2")
						await sleep(1)
						for i in 4:
							await new_monster("s2_1")
						await sleep(3)
				
				elif actual_wave == 6:
					for i in 5:
						await new_monster("s2_2")
					for i in 4:
						await new_monster("s2_3")
					await sleep(3)
					await new_monster("s2_boss", 4)
					for i in 2:
						await new_monster("s2_3")
					for i in 2:
						await new_monster("s2_2")
					
					#change sequence
					actual_sequence += 1
					actual_wave = -1
			
			#endregion
			
			#region sequence_3
			if actual_sequence == 2:
				if actual_wave == 0:
					for i in 7:
						await new_monster("insecte_1")
				
				elif actual_wave == 1:
					await new_monster("insecte_3")
					for i in 3 :
						await new_monster("insecte_1")
						await new_monster("insecte_2")
				
				elif actual_wave == 2:
					for k in 2:
						for i in 3:
							await new_monster("insecte_3")
						for i in 3:
							await new_monster("insecte_1")
						for i in 3:
							await new_monster("insecte_2")
				
				elif actual_wave == 3:
					for i in 15:
						await new_monster("insecte_1")
				
				elif actual_wave == 4:
					for i in 15:
						await new_monster("insecte_2")
				
				elif actual_wave == 5:
					for i in 15:
						await new_monster("insecte_3")
				
				elif actual_wave == 6:
					await new_monster("insecte_3", 2)
					await new_monster("insecte_boss", 3)
					for k in 3:
						for i in 3:
							await new_monster("insecte_3", 0.5)
						for i in 3:
							await new_monster("insecte_1", 0.5)
						for i in 3:
							await new_monster("insecte_2", 0.5)
					
					#change sequence
					actual_sequence += 1
					actual_wave = -1
				
			#endregion
			
			#region sequence_4
			if actual_sequence == 3:
				if actual_wave == 0:
					for j in 3:
						await new_monster("soldat_2",1.1)
						for i in 4:
							await new_monster("soldat_1")
						await sleep(1)
				
				elif actual_wave == 1:
					for i in 2:
						await new_monster("soldat_2",1.1)
						for j in 4:
							await new_monster("soldat_1")
						await sleep(1)
						await new_monster("soldat_4",1.1)
						for j in 4:
							await new_monster("soldat_3")
						await sleep(1)
				
				elif actual_wave == 2:
					for i in 2:
						await new_monster("soldat_2",.5)
					for i in 2:
						await new_monster("soldat_4",.5)
					await sleep(1)
					for i in 3:
						await new_monster("soldat_1")
						await new_monster("soldat_3")
						await new_monster("soldat_3")
						await new_monster("soldat_1")
				
				elif actual_wave == 3:
					for i in 3:
						for j in i+1:
							await new_monster("soldat_2")
						for j in 2*(i+1):
							await new_monster("soldat_1")
						await sleep(2)
						for j in i+1:
							await new_monster("soldat_4")
						for j in 2*(i+1):
							await new_monster("soldat_3")
				
				elif actual_wave == 4:
					await new_monster("soldat_4")
					for i in 10:
						await new_monster("soldat_3")
					await sleep(3)
					for i in 3:
						await new_monster("soldat_2")
						for j in 3:
							await new_monster("soldat_1",.5)
						await sleep(1)
				
				elif actual_wave == 5:
					for t in 5 :
						await new_monster("soldat_2",0.5)
						for i in 3:
							await new_monster("soldat_1",0.5)
						await sleep(2)
						await new_monster("soldat_4",0.5)
						for i in 3:
							await new_monster("soldat_3",0.5)
						await sleep(2)
					
				elif actual_wave == 6:
					await new_monster("soldat_boss",.75)
					for i in 10:
						await new_monster("soldat_2",.5)
						for j in 2:
							await new_monster("soldat_1",.25)
						await sleep(.2)
						await new_monster("soldat_4",.5)
						for j in 2:
							await new_monster("soldat_3",.25)
						await sleep(.5)
					
					#change sequence
					actual_sequence += 1
					actual_wave = -1
			
			#endregion
			
			#region sequence_5
			if actual_sequence == 4:
				if actual_wave == 0:
					for i in 5:
						await new_monster("bot_1",1.5)
				
				elif actual_wave == 1:
					for i in 6:
						await new_monster("bot_1",1.5)
						await new_monster("bot_2",1.5)
				
				elif actual_wave == 2:
					for i in 5:
						await new_monster("bot_1",1.5)
						await new_monster("bot_2",1.5)
						await new_monster("bot_3",1.5)
				
				elif actual_wave == 3:
					for i in 5:
						await new_monster("bot_1",1.5)
						await new_monster("bot_1",1.5)
						await new_monster("bot_2",1.5)
						await new_monster("bot_2",1.5)
						await new_monster("bot_3",1.5)
						await new_monster("bot_3",1.5)
				
				elif actual_wave == 4:
					for i in 5:
						for j in 3:
							await new_monster("bot_1",1.5)
						for j in 3:
							await new_monster("bot_2",1.5)
						for j in 3:
							await new_monster("bot_3",1.5)
				
				elif actual_wave == 5:
					for i in 4:
						for j in 4:
							await new_monster("bot_1",1.5)
						for j in 4:
							await new_monster("bot_2",1.5)
						for j in 4:
							await new_monster("bot_3",1.5)
				
				elif actual_wave == 6:
					for j in 4:
						await new_monster("bot_1",1.5)
					for j in 4:
						await new_monster("bot_2",1.5)
					for j in 4:
						await new_monster("bot_3",1.5)
					await sleep(2)
					await new_monster("bot_boss")
					await sleep(3.5)
					for j in 4:
						await new_monster("bot_1",1.5)
					for j in 4:
						await new_monster("bot_2",1.5)
					for j in 4:
						await new_monster("bot_3",1.5)
					
					#change sequence
					actual_sequence += 1
					actual_wave = -1
			
			#endregion
			
			#region sequence_6
			if actual_sequence == 5:
				if actual_wave == 0:
					for i in 3:
						await new_monster("dragon_1")
				
				elif actual_wave == 1:
					for i in 3:
						await new_monster("dragon_1")
					await sleep(4)
					for i in 3:
						await new_monster("dragon_2")
				
				elif actual_wave == 2:
					for i in 3:
						await new_monster("dragon_1")
					await sleep(2)
					await new_monster("dragon_3")
				
				elif actual_wave == 3:
					for i in 3:
						await new_monster("dragon_3")
					await sleep(3)
					for i in 3:
						await new_monster("dragon_2")
					await sleep(2)
					for i in 3:
						await new_monster("dragon_1")
				
				elif actual_wave == 4:
					for i in 5:
						await new_monster("dragon_3")
					await sleep(3)
					for i in 5:
						await new_monster("dragon_2")
					await sleep(2)
					for i in 5:
						await new_monster("dragon_1")
				
				elif actual_wave == 5:
					await new_monster("squelette_1")
					await new_monster("squelette_2")
					await new_monster("squelette_3")
					await new_monster("s2_1")
					await new_monster("s2_2")
					await new_monster("s2_3")
					await new_monster("insecte_1")
					await new_monster("insecte_2")
					await new_monster("insecte_3")
					await new_monster("soldat_1")
					await new_monster("soldat_2")
					await new_monster("soldat_3")
					await new_monster("soldat_4")
					await new_monster("bot_1")
					await new_monster("bot_2")
					await new_monster("bot_3")
					await new_monster("dragon_1")
					await new_monster("dragon_2")
					await new_monster("dragon_3")
				
				elif actual_wave == 6:
					for i in 75:
						scene.get_node("map/"+map+"/chemin").modulate -= Color(0.01,0.01,0.01,0)
						scene.get_node("map/Towers").modulate -= Color(0.01,0.01,0.01,0)
						await sleep()
					for i in 5:
						await new_monster("dragon_3",.2)
					await sleep(1)
					for i in 5:
						await new_monster("dragon_1",.2)
					await sleep(.5)
					for i in 5:
						await new_monster("dragon_2",.2)
					await sleep(10)
					await new_monster("necromancien")
			
			#endregion
			#endregion
		
		#automatic evolution
		else :
			
			date()
			
			#region test
			if actual_wave == sequence_infini_longueur :
				actual_wave = -1
				actual_sequence += 1
				
				var dégat1 : String = ""
				var dégat2 : String = ""
				var dégat3 : String = ""
				#test damages
				for first_damage_type in Global.damages_this_sequence["type1"]:
					var t = 0
					for test_damage_type in Global.damages_this_sequence["type1"]:
						if Global.damages_this_sequence["type1"][first_damage_type] >= Global.damages_this_sequence["type1"][test_damage_type]:
							t += 1
					if t == 6:
						dégat1 = first_damage_type
				
				for first_damage_type in Global.damages_this_sequence["type2"]:
					var t = 0
					for test_damage_type in Global.damages_this_sequence["type2"]:
						if Global.damages_this_sequence["type2"][first_damage_type] >= Global.damages_this_sequence["type2"][test_damage_type]:
							t += 1
					if t == 6:
						dégat2 = first_damage_type
				
				for first_damage_type in Global.damages_this_sequence["type3"]:
					var t = 0
					for test_damage_type in Global.damages_this_sequence["type3"]:
						if Global.damages_this_sequence["type3"][first_damage_type] >= Global.damages_this_sequence["type3"][test_damage_type]:
							t += 1
					if t == 6:
						dégat3 = first_damage_type
				
				#region upgrade
				var health_boost_probability : float = .2
				var max_resistance_boost : float = .18
				if randf() < health_boost_probability or (dégat1 == "explosion" and Global.damages_this_sequence["type1"]["explosion"] == 0):
					#pv
					Global.monsters_evolutions["type1"]["health"] += randf_range(2,7)
				else :
					#resistance
					Global.monsters_evolutions["type1"]["resistance"][dégat1] -= randf_range(0,max_resistance_boost)
					Global.monsters_evolutions["type1"]["resistance"][dégat1] = clamp(Global.monsters_evolutions["type1"]["resistance"][dégat1],0.05,1)
				if randf() < health_boost_probability or (dégat2 == "explosion" and Global.damages_this_sequence["type2"]["explosion"] == 0):
					#pv
					Global.monsters_evolutions["type2"]["health"] += randf_range(1,5)
				else :
					#resistance
					Global.monsters_evolutions["type2"]["resistance"][dégat2] -= randf_range(0,max_resistance_boost)
					Global.monsters_evolutions["type2"]["resistance"][dégat2] = clamp(Global.monsters_evolutions["type2"]["resistance"][dégat2],0.05,1)
				if randf() < health_boost_probability or (dégat3 == "explosion" and Global.damages_this_sequence["type3"]["explosion"] == 0):
					#pv
					Global.monsters_evolutions["type3"]["health"] += randf_range(4,9)
				else :
					#resistance
					Global.monsters_evolutions["type3"]["resistance"][dégat3] -= randf_range(0,max_resistance_boost)
					Global.monsters_evolutions["type3"]["resistance"][dégat3] = clamp(Global.monsters_evolutions["type3"]["resistance"][dégat3],0.05,1)
				
				Global.damages_this_sequence = {
					"type1" = {
						"shock" = 0,      #choc
						"notch" = 0,      #entaille
						"lazer" = 0,      #laser
						"poison" = 0,     #poison
						"fire" = 0,       #feu
						"explosion" = 0   #explosion
						},
					"type2" = {
						"shock" = 0,      #choc
						"notch" = 0,      #entaille
						"lazer" = 0,      #laser
						"poison" = 0,     #poison
						"fire" = 0,       #feu
						"explosion" = 0   #explosion
						},
					"type3" = {
						"shock" = 0,      #choc
						"notch" = 0,      #entaille
						"lazer" = 0,      #laser
						"poison" = 0,     #poison
						"fire" = 0,       #feu
						"explosion" = 0   #explosion
						}
					}
			actual_wave += 1
				#endregion
			#endregion
			
			#region waves
			
			var wave_index : int = randi_range(0,21)
			
			if wave_index == 0:
					await new_monster("type1")
					await new_monster("type2")
					await new_monster("type3")
					await new_monster("type2")
					await new_monster("type1")
					await sleep(3)
					await new_monster("type1")
					await new_monster("type2")
					await new_monster("type3")
					await new_monster("type2")
					await new_monster("type1")
			
			elif wave_index == 1:
				for monster in 3:
					await new_monster("type2")
				for monster in 3:
					await new_monster("type1")
				for monster in 3:
					await new_monster("type3")
				await new_monster("type1", .8)
				await new_monster("type2", .8)
				await new_monster("type3", .8)
			
			elif wave_index == 2:
				for i in 2 :
					await new_monster("type3")
				await sleep(1)
				for i in 10 :
					await new_monster("type1")
			
			elif wave_index == 3:
				for i in 12:
						await new_monster("type1", (1-(float(i)/12.0)))
			
			elif wave_index == 4:
				for i in 12:
						await new_monster("type2", (1-(float(i)/12.0)))
			
			elif wave_index == 5:
				for i in 12:
						await new_monster("type3", (1-(float(i)/12.0)))
			
			elif wave_index == 6:
				for i in 4:
					await new_monster("type1", .8)
					await new_monster("type2", .8)
					await new_monster("type3", .8)
			
			elif wave_index == 7:
				for i in 4:
					await new_monster("type3")
				for i in 4:
					await new_monster("type1", .75)
				for i in 4:
					await new_monster("type2", .5)
			
			elif wave_index == 8:
				for i in 2:
					await new_monster("type1")
					await new_monster("type2")
					await new_monster("type3")
					await new_monster("type2")
					await new_monster("type1")
					await sleep(3)
					await new_monster("type1")
					await new_monster("type2")
					await new_monster("type3")
					await new_monster("type2")
					await new_monster("type1")
			
			elif wave_index == 9:
				for i in 2:
					for monster in 3:
						await new_monster("type2")
					for monster in 3:
						await new_monster("type1")
					for monster in 3:
						await new_monster("type3")
					await new_monster("type1", .8)
					await new_monster("type2", .8)
					await new_monster("type3", .8)
			
			elif wave_index == 10:
				for j in 2:
					for i in 2 :
						await new_monster("type3")
					await sleep(1)
					for i in 10 :
						await new_monster("type1")
			
			elif wave_index == 11:
				for j in 2:
					for i in 12:
							await new_monster("type1", (1-(float(i)/12.0)))
			
			elif wave_index == 12:
				for j in 2:
					for i in 12:
							await new_monster("type2", (1-(float(i)/12.0)))
			
			elif wave_index == 13:
				for j in 2:
					for i in 12:
							await new_monster("type3", (1-(float(i)/12.0)))
			
			elif wave_index == 14:
				for j in 2:
					for i in 4:
						await new_monster("type1", .8)
						await new_monster("type2", .8)
						await new_monster("type3", .8)
			
			elif wave_index == 15:
				for j in 2:
					for i in 4:
						await new_monster("type3")
					for i in 4:
						await new_monster("type1", .75)
					for i in 4:
						await new_monster("type2", .5)
			
			elif wave_index == 16:
				for i in 12:
					await new_monster("type1")
			
			elif wave_index == 17:
				for i in 12:
					await new_monster("type2")
			
			elif wave_index == 18:
				for i in 12:
					await new_monster("type3")
			
			elif wave_index == 19:
				for j in 2:
					for i in 12:
						await new_monster("type1")
			
			elif wave_index == 20:
				for j in 2:
					for i in 12:
						await new_monster("type2")
			
			elif wave_index == 21:
				for j in 2:
					for i in 12:
						await new_monster("type3")
			
			#endregion
		
		all_monster_are_attacking = false
		
		#await for the end of the wave
		while Global.nb_monster_in_life > 0 :
			await sleep()
			if Global.pv <= 0:
				death_player()
				return
		if actual_sequence == 5 and actual_wave == 6:
			for i in 75:
				scene.get_node("map/"+map+"/chemin").modulate += Color(0.01,0.01,0.01,0)
				scene.get_node("map/Towers").modulate += Color(0.01,0.01,0.01,0)
				await sleep()
			await sleep(1)
			death_player()
			return
		#endregion

		#finish the wave
		
		#region reward
		
		if not Global.automatic_evolution:
			if actual_sequence == 0:
				await reward(38)
			
			if actual_sequence == 1:
				await reward(70)
			
			if actual_sequence == 2:
				await reward(90)
			
			if actual_sequence == 3:
				await reward(90)
			
			if actual_sequence == 4:
				await reward(100)
			
			if actual_sequence == 5:
				await reward(100)
		else :
			await reward(90)
		
		#endregion
		
		Global.in_wave = false
		Global.feu = []
		scene.get_node("menus/livre_histoire").vague = actual_sequence*7+actual_wave+1
		scene.get_node("button_parametre").show()

func reward(quantitie : int ) -> void:
	for i in quantitie:
		await sleep()
		Global.metaux += 1

#towers
func create_tower(tower_name : String) -> void:
	if Global.metaux >= prixtours[tower_name] :
		Global.metaux -=  prixtours[tower_name]
		var tour = (load("res://scenes/"+tower_name+".tscn")as PackedScene).instantiate()
		scene.get_node("map/Towers").add_child(tour)
	else : 
		metaux_insuffisants()

func metaux_insuffisants () -> void:
	scene.get_node("menus/menu_tour_Path/PathFollow/menu_tour/insuffisants").show()
	await sleep(0.5)
	scene.get_node("menus/menu_tour_Path/PathFollow/menu_tour/insuffisants").hide()

#region code tour menu
func _on_boulet_mouse_entered() -> void:
	tower_name.text = "Boulet"
	tower_description.text = "Ses dégats sont minimes et sa portée est faible, mais
sa simplicité la rend peu coûteuse.
Elle est donc parfaite lorsque les ressources se font rares"
	tower_puissance.value = 1
	tower_vitesse.value = 7
	tower_zone.value = 2
	tower_prix.text = str(prixtours["boulet"])
	image_tour.icon = load("res://td images/tours/boulet/1.svg")

func _on_boulets_explosifs_mouse_entered() -> void:
	tower_name.text = "Boulet explosifs"
	tower_description.text = "Elle inflige peu de dégats à l'impact et sa portée est faible,
mais l'impact crée une explosion."
	tower_puissance.value = 2
	tower_vitesse.value = 7
	tower_zone.value = 2
	tower_prix.text = str(prixtours["boulets_explosifs"])
	image_tour.icon = load("res://td images/tours/boulets_explosifs/1.svg")

func _on_mitrailleuse_mouse_entered() -> void:
	tower_name.text = "Mitrailleuse"
	tower_description.text = "Elle inflige peu de dégats  et sa portée est faible, mais sa
cadence de tir fait d'elle la plus forte des tours boulet"
	tower_puissance.value = 1
	tower_vitesse.value = 9
	tower_zone.value = 3
	tower_prix.text = str(prixtours["mitrailleuse"])
	image_tour.icon = load("res://td images/tours/mitraillette/1.svg")

func _on_lazer_1_mouse_entered() -> void:
	tower_name.text = "Lazer 1 "
	tower_description.text = "Elle génère un lazer qui traverse le terrain et inflige des dégats
moyen à tous ceux qui sont sur sa trajectoire. Elle a un temps
de recharge élevé"
	tower_puissance.value = 4
	tower_vitesse.value = 4
	tower_zone.value = 7
	tower_prix.text = str(prixtours["lazer_1"])
	image_tour.icon = load("res://td images/tours/Lazer 1/r 1.svg")

func _on_lazer_2_mouse_entered() -> void:
	tower_name.text = "Lazer 2"
	tower_description.text = "Elle génère un lazer qui traverse le terrain et inflige des
dégats moyen à tous ceux qui sont sur sa trajectoire. Elle a un
temps de recharge élevé"
	tower_puissance.value = 12
	tower_vitesse.value = 5
	tower_zone.value = 7
	tower_prix.text = str(prixtours["lazer_2"])
	image_tour.icon = load("res://td images/tours/Lazer 2/r1.svg")

func _on_lazer_3_mouse_entered() -> void:
	tower_name.text = "Lazer 3"
	tower_description.text = "Elle génère un lazer qui traverse le terrain et inflige des
dégats élevé à tous ceux qui sont sur sa trajectoire. Elle a un
temps de recharge élevé"
	tower_puissance.value = 25
	tower_vitesse.value = 6
	tower_zone.value = 7
	tower_prix.text = str(prixtours["lazer_3"])
	image_tour.icon = load("res://td images/tours/Lazer 3/r1.svg")

func _on_hache_mouse_entered() -> void:
	tower_name.text = "Hache"
	tower_description.text = ""
	tower_puissance.value = 1
	tower_vitesse.value = 9
	tower_zone.value = 1
	tower_prix.text = str(prixtours["hache"])
	image_tour.icon = load("res://td images/tours/hache/hache 1.svg")

func _on_griffes_mouse_entered() -> void:
	tower_name.text = "Griffes"
	tower_description.text = ""
	tower_puissance.value = 1
	tower_vitesse.value = 10
	tower_zone.value = 1
	tower_prix.text = str(prixtours["griffes"])
	image_tour.icon = load("res://td images/tours/griffes/griffes.svg")

func _on_dieu_tournoyant_mouse_entered() -> void:
	tower_name.text = "Dieu Tournoyant"
	tower_description.text = ""
	tower_puissance.value = 10
	tower_vitesse.value = 9
	tower_zone.value = 1
	tower_prix.text = str(prixtours["dieu_tournoyant"])
	image_tour.icon = load("res://td images/tours/dieu tournoyant/dieu tournoyant.svg")

func _on_neige_mouse_entered() -> void:
	tower_name.text = "Neige"
	tower_description.text = ""
	tower_puissance.value = 0
	tower_vitesse.value = 10
	tower_zone.value = 2
	tower_prix.text = str(prixtours["neige"])
	image_tour.icon = load("res://td images/tours/neige/1.svg")

func _on_ecrabouillator_mouse_entered() -> void:
	tower_name.text = "Ecrabouillator 3000"
	tower_description.text = ""
	tower_puissance.value = 75
	tower_vitesse.value = 1
	tower_zone.value = 6
	tower_prix.text = str(prixtours["ecrabouillator"])
	image_tour.icon = load("res://td images/tours/ecrabouillator/ecrabouillator.svg")

func _on_pierre_mouse_entered() -> void:
	tower_name.text = "Pierre"
	tower_description.text = ""
	tower_puissance.value = 0
	tower_vitesse.value = 3
	tower_zone.value = 7
	tower_prix.text = str(prixtours["pierre"])
	image_tour.icon = load("res://td images/tours/Pierre/r1.svg")

func _on_flammes_mouse_entered() -> void:
	tower_name.text = "Lance Flammes"
	tower_description.text = ""
	tower_puissance.value = 5
	tower_vitesse.value = 10
	tower_zone.value = 1
	tower_prix.text = str(prixtours["flammes"])
	image_tour.icon = load("res://td images/tours/flammes/flamme.svg")

func lazer_progressif() -> void:
	tower_name.text = "Lazer Constant"
	tower_description.text = "Génère un lazer qui cible un ennemi jusqu'à la mort.
								Le temps de recharge est en fonction des dégats
								infligés"
	tower_puissance.value = 5
	tower_vitesse.value = 1
	tower_zone.value = 7
	tower_prix.text = str(prixtours["lazer_constant"])
	image_tour.icon = load("res://td images/tours/new/tour complete.svg")

func _on_mine_explosive_mouse_entered() -> void:
	tower_name.text = "mine_explosive"
	tower_description.text = "Explose au contact d'ennemis"
	tower_puissance.value = 3
	tower_vitesse.value = 0
	tower_zone.value = 1
	tower_prix.text = str(prixtours["mine_explosive"])
	image_tour.icon = load("res://td images/tours/mine/mine 1.svg")

func _on_mine_trou_noir_mouse_entered() -> void:
	tower_name.text = "mine_trou_noir"
	tower_description.text = "Génère un trou noir au contact d'ennemis. Il les téléportes
	au départ du chemin. Au bout de quelques
	secondes, il disparait"
	tower_puissance.value = 0
	tower_vitesse.value = 0
	tower_zone.value = 1
	tower_prix.text = str(prixtours["mine_trou_noir"])
	image_tour.icon = load("res://td images/tours/mine/mine 2.svg")
#endregion

func zone_tour(tour_position : Vector2, taille : float ) -> void:
	scene.get_node("map/zone_tour").position = tour_position
	scene.get_node("map/zone_tour").scale = Vector2(1,1) * taille * 2
	scene.get_node("map/zone_tour").show()

func _hide_button() -> void:
	Global.hide_gui = !Global.hide_gui

#region code menu amélio

func open_amélio(id_tour_amélio : Node2D ) -> void:
	
	if not (menu_tour_open or scene.get_node("menus/livre_histoire").mouse):
		Global.hide_gui = true
		scene.reparent($camera, false)
		tower_caracteristiques = id_tour_amélio.caracteristiques
		tour_amélio = id_tour_amélio
		$"menu_amélio/argent_t".text = str(Global.metaux)
		$"menu_amélio".show()
		$"menu_amélio/Statistiques/bars_texts/Tower_name".text = tower_caracteristiques["type"]
		update()

func upgrade_button_1_1() -> void:
	if Global.metaux >= tower_caracteristiques["améliorations"]["1"]["price"] :
		if not tower_caracteristiques["améliorations"]["1"]["upgraded"]:
			Global.metaux -=  tower_caracteristiques["améliorations"]["1"]["price"]
			tower_caracteristiques["améliorations"]["1"]["upgraded"] = true
			$"menu_amélio/activé_desactivé".text = "activé"
	else :
		amélio_métaux_insuffisants()
	update()

func upgrade_button_2_1() -> void:
	if Global.metaux >= tower_caracteristiques["améliorations"]["2"]["price"] :
		if not tower_caracteristiques["améliorations"]["2"]["upgraded"]:
			Global.metaux -=  tower_caracteristiques["améliorations"]["2"]["price"]
			tower_caracteristiques["améliorations"]["2"]["upgraded"] = true
			$"menu_amélio/activé_desactivé".text = "activé"
	else :
		amélio_métaux_insuffisants()
	update()

func upgrade_button_3_1() -> void:
	if Global.metaux >= tower_caracteristiques["améliorations"]["3"]["price"] :
		if not tower_caracteristiques["améliorations"]["3"]["upgraded"]:
			Global.metaux -=  tower_caracteristiques["améliorations"]["3"]["price"]
			tower_caracteristiques["améliorations"]["3"]["upgraded"] = true
			$"menu_amélio/activé_desactivé".text = "activé"
	else :
		amélio_métaux_insuffisants()
	update()

func _on_close_pressed() -> void:
	Global.hide_gui = false
	scene.reparent(self, false)
	tower_caracteristiques = {}
	$"menu_amélio/argent".text = ""
	$"menu_amélio/amélio_name_".text = ""
	$"menu_amélio/activé_desactivé".text = ""
	$"menu_amélio".hide()

func amélio_métaux_insuffisants () -> void:
	$"menu_amélio/insuffisants".show()
	await sleep(0.5)
	$"menu_amélio/insuffisants".hide()

func update () -> void:
	tour_amélio.caracteristiques = tower_caracteristiques
	await sleep()
	$"menu_amélio/Statistiques/bars_texts/puissance".value = tour_amélio.caracteristiques["damage"]
	$"menu_amélio/Statistiques/bars_texts/zone".value = tour_amélio.caracteristiques["zone"]
	$"menu_amélio/Statistiques/bars_texts/vitesse".value = tour_amélio.caracteristiques["vitesse"]
	for i in 3:
		if tower_caracteristiques["améliorations"][str(i+1)] == null:
			get_node("menu_amélio/Button"+str(i+1)).hide()
		else :
			get_node("menu_amélio/Button"+str(i+1)).show()
			get_node("menu_amélio/Button"+str(i+1)).text = tower_caracteristiques["améliorations"][str(i+1)]["name"]
			if tower_caracteristiques["améliorations"][str(i+1)]["upgraded"]:
				get_node("menu_amélio/Button"+str(i+1)).modulate = Color(0,1,0)
			else:
				get_node("menu_amélio/Button"+str(i+1)).modulate = Color(1,0,0)

func _on_button_1_mouse_entered() -> void:
	$"menu_amélio/argent".text = str(tower_caracteristiques["améliorations"]["1"]["price"])
	if tower_caracteristiques["améliorations"]["1"]["upgraded"]:
		$"menu_amélio/activé_desactivé".text = "activé"
	else :
		$"menu_amélio/activé_desactivé".text = "désactivé"
	$"menu_amélio/amélio_name_".text = tower_caracteristiques["améliorations"]["1"]["name"]

func _on_button_2_mouse_entered() -> void:
	$"menu_amélio/argent".text = str(tower_caracteristiques["améliorations"]["2"]["price"])
	if tower_caracteristiques["améliorations"]["2"]["upgraded"]:
		$"menu_amélio/activé_desactivé".text = "activé"
	else :
		$"menu_amélio/activé_desactivé".text = "désactivé"
	$"menu_amélio/amélio_name_".text = tower_caracteristiques["améliorations"]["2"]["name"]

func _on_button_3_mouse_entered() -> void:
	$"menu_amélio/argent".text = str(tower_caracteristiques["améliorations"]["3"]["price"])
	if tower_caracteristiques["améliorations"]["3"]["upgraded"]:
		$"menu_amélio/activé_desactivé".text = "activé"
	else :
		$"menu_amélio/activé_desactivé".text = "désactivé"
	$"menu_amélio/amélio_name_".text = tower_caracteristiques["améliorations"]["3"]["name"]
#endregion

#region parametres

func parametre() -> void:
	if not save_name_submit:
		#get previous file
		if FileAccess.file_exists("user://savegame.data"):
			var file_read = FileAccess.open("user://savegame.data", FileAccess.READ)
			if file_read.get_length() >= 1:
				var saves : Dictionary = file_read.get_var()
				for i in 3:
					if saves[str(i+1)]["saved"]:
						scene.get_node("parametre/emplacements/"+str(i+1)).text = saves[str(i+1)]["name"]
					else :
						scene.get_node("parametre/emplacements/"+str(i+1)).text = "emplacement vide"
		
		$scene/parametre.show()
		$scene/parametre/MeshInstance2D2.hide()
		$scene/parametre/emplacements.hide()
		$scene/parametre/nom.hide()
		
		setting_menu_state = "base"
		Global.placing_tower = true

func quitter_parametres() -> void:
	if not save_name_submit:
		$scene/parametre.hide()
		$scene/parametre/MeshInstance2D2.hide()
		$scene/parametre/emplacements.hide()
		$scene/parametre/nom.hide()
		Global.placing_tower = false

func _on_save_pressed() -> void:
	if not save_name_submit:
		setting_menu_state = "save"
		$scene/parametre/MeshInstance2D2.show()
		$scene/parametre/emplacements.show()
		$scene/parametre/nom.show()
		$scene/parametre/nom.text = "SAUVEGARDER"

func _on_load_pressed() -> void:
	if not save_name_submit:
		setting_menu_state = "load"
		$scene/parametre/MeshInstance2D2.show()
		$scene/parametre/emplacements.show()
		$scene/parametre/nom.show()
		$scene/parametre/nom.text = "CHARGER"

func _on_restart_pressed() -> void:
	restart_game()

func saves(button_name : String ) -> void:
	if not save_name_submit:
		if setting_menu_state == "save":
			
			#region actual game
			
			var actual_game : Dictionary = {
											"name" = "",
											"saved" = true,
											"variables" = {},
											"tower" = [],
											"graves" = []
											}
			
			actual_game["variables"] = {
				"map" = map,
				"niveau" = niveau,
				"actual_wave" = actual_wave,
				"actual_sequence" = actual_sequence,
				"automatic_evolution" = Global.automatic_evolution,
				"game_start" = Global.game_start,
				"metaux" = Global.metaux,
				"pv" = Global.pv,
				"monsters_evolutions" = Global.monsters_evolutions,
				"damages_this_sequence" = Global.damages_this_sequence
			}
			
			for tower in scene.get_node("map/Towers").get_children():
				var actual_tower : Dictionary = tower.caracteristiques
				actual_game["tower"].append(actual_tower)
			
			for grave in $scene/tombe.get_children():
				actual_game["graves"].append({"advance" = grave.advance,
												"grave_type" = grave.grave_type,
												"position" = grave.position})
			
			$"scene/parametre/ecran noir pour titre s".show()
			while not save_name_submit:
				await sleep()
			actual_game["name"] = save_name
			scene.get_node("parametre/emplacements/"+button_name).text = actual_game["name"]
			save_name = ""
			save_name_submit = false
			$"scene/parametre/ecran noir pour titre s".hide()
			
			#endregion
			
			var saves : Dictionary = {
				"1" = {
					"name" = "",
					"saved" = false,
					"variables" = {},
					"tower" = [],
					"graves" = []
				},
				
				"2" = {
					"name" = "",
					"saved" = false,
					"variables" = {},
					"tower" = [],
					"graves" = []
				},
				
				"3" = {
					"name" = "",
					"saved" = false,
					"variables" = {},
					"tower" = [],
					"graves" = []
				}
			}
			
			#get previous file
			if FileAccess.file_exists("user://savegame.data"):
				var file_read = FileAccess.open("user://savegame.data", FileAccess.READ)
				
				if file_read.get_length() >= 1:
					saves = file_read.get_var()
			
			#set new file
			var file_write = FileAccess.open("user://savegame.data", FileAccess.WRITE)
			
			saves[button_name] = actual_game
			
			file_write.store_var(saves)
			file_write.close()
		
		elif setting_menu_state == "load":
			if FileAccess.file_exists("user://savegame.data"):
				var file = FileAccess.open("user://savegame.data", FileAccess.READ)
				if file.get_length() >= 1:
					#load
					var save : Dictionary = file.get_var()
					save = save[button_name]
					if save["saved"]:
						
						#reset game
						kill_game()
						#reset visibility
						scene.show()
						$"statistiques fin".hide()
						$scene/menus/livre_histoire.show()
						$menu/histoire.hide()
						$menu/evolution.hide()
						$menu/load.hide()
						$menu.hide()
						$menu/map.hide()
						$menu/levels.hide()
						$"menu_amélio".hide()
						$scene/button_parametre.show()
						$scene/parametre.hide()
						$scene/parametre/MeshInstance2D2.hide()
						$scene/parametre/emplacements.hide()
						$scene/parametre/nom.hide()
						
						Global.loading_game = true
						$scene/map/facile/m1/path_collisions
						#set variables
						map = save["variables"]["map"]
						path_monster = get_node("scene/map/"+map+"/Path2D")
						collision_en_bas.reparent(get_node("scene/map/"+map+"/path_collisions"))
						niveau = save["variables"]["niveau"]
						actual_wave = save["variables"]["actual_wave"]
						actual_sequence = save["variables"]["actual_sequence"]
						Global.automatic_evolution = save["variables"]["automatic_evolution"]
						Global.game_start = save["variables"]["game_start"]
						Global.metaux = save["variables"]["metaux"]
						Global.pv = save["variables"]["pv"]
						Global.monsters_evolutions = save["variables"]["monsters_evolutions"]
						Global.damages_this_sequence = save["variables"]["damages_this_sequence"]
						
						#set towers
						for tower in save["tower"]:
							var tour = (load("res://scenes/"+tower["type"]+".tscn")as PackedScene).instantiate()
							tour.position = tower["position"]
							tour.caracteristiques = tower
							scene.get_node("map/Towers").add_child(tour)
						#set graves
						for grave in save["graves"]:
							var tombe = (load("res://scenes/tombe.tscn")as PackedScene).instantiate()
							tombe.advance = grave["advance"]
							tombe.grave_type = grave["grave_type"]
							tombe.position = grave["position"]
							$scene/tombe.add_child(tombe)
						
						#disabled all maps collisions
						for maps in scene.get_node("map").get_children():
							if (maps.name == "facile" or
								maps.name == "normal" or
								maps.name == "expert" or
								maps.name == "demon" or
								maps.name == "impossible"):
								for map in maps.get_children():
									map.hide()
									for collision in map.get_node("path_collisions").get_children():
										collision.disabled = true
						scene.get_node("map/"+map).show()
						#reactivate map collisions
						for collision in scene.get_node("map/"+map+"/path_collisions").get_children():
							collision.disabled = false
						collision_en_bas.reparent(scene.get_node("map/"+map+"/path_collisions"))
						date()
						if Global.automatic_evolution:
							scene.get_node("menus/livre_histoire").hide()
						else:
							scene.get_node("menus/livre_histoire").show()
						scene.get_node("menus/livre_histoire").vague = actual_sequence*7+actual_wave+1
						scene.get_node("map/"+map+"/chemin").modulate = Color.WHITE
						scene.get_node("map/Towers").modulate = Color.WHITE
						
						Global.loading_game = false

func _on_save_name_text_submitted(new_text: String) -> void:
	save_name = new_text
	save_name_submit = true
	$"scene/parametre/ecran noir pour titre s/save_name".text = ""
#endregion 

func statistiques () -> void:
	if Global.pv < 0 :
		Global.pv = 0
	var multiplicateur
	var multiplicateur_2
	var vies_perdues
	$"statistiques fin".show()
	$"statistiques fin/a remplir/map_level".text = map
	$"statistiques fin/a remplir/niveau_level".text = niveau
	$"statistiques fin/a remplir/vague".text = str((actual_sequence)*7+actual_wave+1)
	if niveau == "facile":
		$"statistiques fin/a remplir/vies_perdues".text =  str(100-Global.pv)
		multiplicateur = 1
		vies_perdues = 100-Global.pv
	if niveau == "normal":
		$"statistiques fin/a remplir/vies_perdues".text =  str(100-Global.pv)
		multiplicateur = 1.2
		vies_perdues = 100-Global.pv
	if niveau == "expert":
		$"statistiques fin/a remplir/vies_perdues".text =  str(80-Global.pv)
		multiplicateur = 1.4
		vies_perdues = 80-Global.pv
	if niveau == "demon":
		$"statistiques fin/a remplir/vies_perdues".text =  str(20-Global.pv)
		multiplicateur = 1.6
		vies_perdues = 20-Global.pv
	if niveau == "impossible":
		$"statistiques fin/a remplir/vies_perdues".text =  str(1-Global.pv)
		multiplicateur = 1.8
		vies_perdues = 1-Global.pv

	if map.find("facile") != -1 :
		multiplicateur_2 = 1
	if map.find("normal") != -1 :
		multiplicateur_2 = 1.2
	if map.find("expert") != -1 :
		multiplicateur_2 = 1.4
	if map.find("demon") != -1 :
		multiplicateur_2 = 1.6
	if map.find("impossible") != -1 :
		multiplicateur_2 = 1.8
	$"statistiques fin/a remplir/score".text = str(round(((multiplicateur*multiplicateur_2*((actual_sequence+1)*7+actual_wave+1))-vies_perdues*3/((actual_sequence+1)*7)+actual_wave+1)*10)/10)
