extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var pierre : Array = []
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "pierre",
	"damage" = 0,
	"zone" = 1000,
	"vitesse" = 3,
	"recharge" = 10,
	"améliorations" = {"1" = {"name" = "rends les enemis touchés vulnérables",
							"upgraded" = false,
							"price" = 500},
	"2" = null,
	"3" = null}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		if not $lazer.is_in_group("vulnérable"):
			$lazer.add_to_group("vulnérable")

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

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

func shoot():
	$RayCast2D.rotation = 0
	await rotate_tower()
	$lazer.set_collision_layer_value(5,true)
	$lazer.set_collision_mask_value(5,true)
	$AnimatedSprite2D.play("tir")
	for i in 32:
		await sleep(.1)
		var monsters = $lazer.get_overlapping_bodies()
		for monster in monsters :
			if monster.is_in_group("monsters") and Global.pierre.find(monster) == -1:
				Global.pierre.append(monster)
				if pierre.find(monster) == -1:
					pierre.append(monster)
		
	for monster in pierre:
		if Global.pierre.find(monster) != -1:
			Global.pierre.remove_at(Global.pierre.find(monster))
	pierre = []
	$lazer.set_collision_layer_value(5,false)
	$lazer.set_collision_mask_value(5,false)
	$AnimatedSprite2D.animation = "rechargement"
	await sleep(5)
	$AnimatedSprite2D.animation = "chargée"
	for i in randi_range(5, 10):
		await sleep()


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
