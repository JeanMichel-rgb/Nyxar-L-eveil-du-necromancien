extends Node2D

@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var mouse : bool = false
var pose_tour_finish = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "boulets_explosifs",
	"damage" = 0.5,
	"explosion_damages" = 2,
	"await_time" = 2,
	"vitesse" = 7,
	
	"zone" = 220,
	"améliorations" = {"1" = {"name" = "augmentation de la zone",
							"upgraded" = false,
							"price" = 75},
	"2" = {"name" = "1 chance sur 20 de créer un trou noir",
			"upgraded" = false,
			"price" = 250},
	"3" = {"name" = "augmentation des dégats d'explosion",
			"upgraded" = false,
			"price" = 120}}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		caracteristiques["zone"] = 270
	if caracteristiques["améliorations"]["3"]["upgraded"]:
		caracteristiques["explosion_damages"] = 6

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	await sleep() ; tower_pressed()
	$AnimatedSprite2D.animation = "tour"
	while true : 
		await sleep()
		await in_wave()

func in_wave():
	if Global.in_wave == true :
		found_monster()
		if possibility != null : 
			shoot()
			await sleep(caracteristiques["await_time"])
	await sleep()

func found_monster():
	$RayCast2D.target_position = Vector2(504.7,0)*parent.scene.scale.x
	possibility = null
	for monster in Global.pos_monsters : 
		if monster is Vector2 and monster != Vector2.ZERO:
			$RayCast2D.look_at(monster)
			if $RayCast2D.get_collider() != null and $RayCast2D.get_collider().is_in_group("monsters"):  
				if global_position.distance_to(monster) < caracteristiques["zone"]*parent.scene.scale.x :
						if possibility == null :
							possibility = monster
						elif global_position.distance_to(monster) < global_position.distance_to(possibility):
							possibility = monster

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func pose_tour():
	Global.placing_tower = true
	await sleep()
	position = get_parent().get_parent().get_local_mouse_position()
	while not Input.is_action_just_pressed("clique gauche") or await detect_tour() :
		await sleep()
		var collision = $Area2D.get_overlapping_areas()
		if collision != [] :
			$AnimatedSprite2D.animation = "poser pas possible"
		else :
			$AnimatedSprite2D.animation = "poser possible"
		position = get_parent().get_parent().get_local_mouse_position()
		parent.zone_tour(position, caracteristiques["zone"])
	Global.placing_tower = false
	pose_tour_finish = true
	fonctionne()

func detect_tour():
	var collision = $Area2D.get_overlapping_areas()
	if collision != [] :
		return true
	else :
		return false

func shoot():
	$RayCast2D.rotation = 0
	await rotate_tower()
	$AnimatedSprite2D.play("tir")
	var monster = $RayCast2D.get_collider()
	if monster != null and monster.is_in_group("monsters"):
		if Global.automatic_evolution:
			if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["shock"]:
				Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += monster.pv *monster.get_parent().resistance["shock"]
			else :
				Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += caracteristiques["damage"] *monster.get_parent().resistance["shock"]
		monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["shock"]
		var bombe
		if caracteristiques["améliorations"]["2"]["upgraded"] and randi_range(0,19) == 0:
			bombe = (load("res://scenes/trou_noir.tscn")as PackedScene).instantiate()
			bombe.parent = parent
		else :
			bombe = (load("res://scenes/explosion.tscn")as PackedScene).instantiate()
			bombe.damages = caracteristiques["explosion_damages"]
		bombe.position = possibility
		parent.scene.add_child(bombe)
	await sleep(0.2)
	$AnimatedSprite2D.animation = "tour"
	for i in randi_range(1, 10):
		await sleep()

func rotate_tower():
	#recuperer start et end
	var start = rotation
	look_at(possibility)
	var end = rotation
	rotation = start
	#calcul de l'angle
	var angle = start - end
	
	if abs(angle) > 180:
		angle = 360*(-(angle/abs(angle)))+angle
	
	for i in 10:
		angle /= 2
		rotation -= angle
		await sleep()
	rotation = end



func mouse_entered() -> void:
	mouse = true
	if pose_tour_finish :
		parent.zone_tour(position, caracteristiques["zone"])

func mouse_exited() -> void:
	mouse = false
	if pose_tour_finish :
		parent.scene.get_node("map/zone_tour").hide()

func tower_pressed():
	while true:
		if mouse and Input.is_action_just_pressed("clique gauche") and not Global.placing_tower and not parent.trash:
			parent.open_amélio(self)
		await sleep()
