extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "lazer_3",
	"damage" = 20,
	"vitesse" = 6,
	"zone" = 1000,
	"recharge" = 10,
"améliorations" = {"1" = {"name" = "un petit appareil crée des explosions le long du lazer",
							"upgraded" = false,
							"price" = 200},
	"2" = {"name" = "les lazers sont brulants",
			"upgraded" = false,
			"price" = 200},
	"3" = null}}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		$explosif.show()
	else :
		$explosif.hide()

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()
	$explosif/robot.play("clignote")

func fonctionne():
	pose_tour_finish = true
	await sleep() ; tower_pressed()
	$AnimatedSprite2D.animation = "chargée"
	while true : 
		await sleep()
		await in_wave()

func in_wave():
	if Global.in_wave == true :
		found_monster()
		if possibility != null : 
			await shoot()
			await sleep(1)
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
	$explosif.hide()
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
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		explosif()
	var monsters = $lazer.get_overlapping_bodies()
	for monster in monsters :
		if monster.is_in_group("monsters"):
			if Global.automatic_evolution:
				if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["lazer"]:
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += monster.pv *monster.get_parent().resistance["lazer"]
				else :
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += caracteristiques["damage"] *monster.get_parent().resistance["lazer"]
			monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["lazer"]
			if caracteristiques["améliorations"]["2"]["upgraded"]:
				make_fire(monster)
	await sleep(0.25)
	$AnimatedSprite2D.animation = "rechargement"
	await sleep(3)
	$AnimatedSprite2D.animation = "chargée"
	for i in randi_range(5, 10):
		await sleep()

func explosif():
	var écran_base = Vector2(1152,648)
	var robot = $explosif/robot
	var start : Vector2 = position
	var end : Vector2 = Vector2.ZERO
	var max : Vector2 = Vector2.ZERO
	var distance : float = 0
	var pas : float = 40
	#calculate a normalized vector of tower's rotation
	var direction : Vector2 = Vector2.from_angle(rotation)
	var espacement : float = 120
	#calculate max of end
	if rotation <= PI/2.0:
		#down right
		max = écran_base - start
	elif rotation <= PI:
		#down left
		max.x = -start.x
		max.y = écran_base.y - start.y
	elif rotation <= 3*PI/2.0:
		#up left
		max = -start
	elif rotation <= 2*PI:
		#up right
		max.x = écran_base.x - start.x
		max.y = -start.y
	#calculate end
	if rotation <= PI:
		if direction.y * (max.x/direction.x) >= max.y:
			end = direction * (max.y/direction.y)
		else:
			end = direction * (max.x/direction.x)
	else:
		if direction.y * (max.x/direction.x) >= max.y:
			end = direction * (max.x/direction.x)
		else:
			end = direction * (max.y/direction.y)
	end += position
	#calculate distance between start and end
	distance = (start.distance_to(end))*10/4
	#do lazer's explosion animation
	var counter : int = distance/pas
	var explosif_counter = -1
	for i in counter :
		robot.position.x += pas
		if fmod(robot.position.x, espacement) == 0:
			explosif_counter += 1
			place_explosif(robot.position,explosif_counter)
		await sleep()
	for i in counter:
		robot.position.x -= pas
		if fmod(robot.position.x, espacement) == 0:
			explode(explosif_counter)
			explosif_counter -= 1
		await sleep()

func place_explosif(pos : Vector2, explosif_name : int):
	var bombe = (load("res://scenes/explosif_lazer.tscn")as PackedScene).instantiate()
	bombe.name = str(explosif_name)
	bombe.position = pos
	bombe.damages = 3
	$explosif.add_child(bombe)

func explode(explosif_name : int):
	for i in $explosif.get_children():
		if str(i.name) == str(explosif_name):
			i.explode()

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
	#set rotation as positive value between 0 and 2*PI
	rotation = fmod(rotation, 2*PI)
	if rotation < 0:
		rotation = 2*PI + rotation


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
