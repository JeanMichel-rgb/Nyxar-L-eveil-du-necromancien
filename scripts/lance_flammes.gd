extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var shooting : bool = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "flammes",
	"damage" = 1,
	"vitesse" = 10,
	"zone" = 150,
	"améliorations" = {"1" = {"name" = "augmenter les dégats du lance flamme",
							"upgraded" = false,
							"price" = 400},
	"2" = null,
	"3" = null}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		caracteristiques["damage"] = 1.5

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	await sleep() ; tower_pressed()
	animation()
	$AnimatedSprite2D.animation = "chargée"
	while true : 
		await sleep()
		await in_wave()

func in_wave():
	if Global.in_wave == true :
		found_monster()
		if possibility != null : 
			await shoot()
		else :
			shooting = false
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
		parent.zone_tour(position, caracteristiques["zone"])
		position = get_parent().get_parent().get_local_mouse_position()
	Global.placing_tower = false
	pose_tour_finish = true
	fonctionne()

func detect_tour():
	var collision = $Area2D.get_overlapping_areas()
	if collision != [] :
		return true
	else :
		return false

func animation():
	while true:
		if shooting:
			$AnimatedSprite2D.position = Vector2(137.5,5)
			$AnimatedSprite2D.animation = "tir1"
			await sleep(0.0625)
			$AnimatedSprite2D.position = Vector2(125,12.5)
			$AnimatedSprite2D.animation = "tir2"
			await sleep(0.0625)
			$AnimatedSprite2D.position = Vector2(132.5,15)
			$AnimatedSprite2D.animation = "tir3"
			await sleep(0.0625)
			$AnimatedSprite2D.position = Vector2(137.5,2.5)
			$AnimatedSprite2D.animation = "tir4"
			await sleep(0.0625)
			$AnimatedSprite2D.position = Vector2(150,10)
			$AnimatedSprite2D.animation = "tir5"
			await sleep(0.0625)
		else :
			$AnimatedSprite2D.position = Vector2(15,0)
			$AnimatedSprite2D.animation = "chargée"
			await sleep()

func shoot():
	shooting = true
	$RayCast2D.rotation = 0
	await rotate_tower()
	var monsters = $lazer.get_overlapping_bodies()
	for monster in monsters :
		if monster.is_in_group("monsters"):
			if Global.automatic_evolution:
				if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["fire"]:
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["fire"] += monster.pv *monster.get_parent().resistance["fire"]
				else :
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["fire"] += caracteristiques["damage"] *monster.get_parent().resistance["fire"]
			monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["fire"]
			make_fire(monster)
	for i in randi_range(5, 10):
		await sleep()

func make_fire(monster):
	var test_2 = 0
	for test in Global.feu.size():
		if Global.feu[test][0] == monster :
			Global.feu[test][1] = 5
			test_2 = 1
	if test_2 == 0 :
		Global.feu.append([])
		Global.feu[Global.feu.size()-1].append(monster)
		Global.feu[Global.feu.size()-1].append(5)

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
