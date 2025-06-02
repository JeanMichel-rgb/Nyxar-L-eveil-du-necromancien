extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var timer_timeout = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "ecrabouillator",
	"damage" = 50,
	"vitesse" = 1,
	"zone" = 750,
	"recharge" = 10,
	"améliorations" = {"1" = {"name" = "l'impact paralyse temporairement les ennemis",
							"upgraded" = false,
							"price" = 100},
	"2" = {"name" = "faible probabilité qu'un trou noir apparaisse à l'impact",
			"upgraded" = false,
			"price" = 250},
	"3" = null}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	$trou_noir.scale = Vector2(1,1)
	await sleep() ; tower_pressed()
	while true : 
		await sleep()
		await in_wave()

func in_wave():
	if caracteristiques["améliorations"]["2"]["upgraded"]:
		$AnimatedSprite2D.animation = "trou_noir"
		$AnimatedSprite2D.position = Vector2(1.635,-0.77)
	else :
		$AnimatedSprite2D.animation = "tour"
		$AnimatedSprite2D.position = Vector2.ZERO
	
	if Global.in_wave == true :
		found_monster()
		if possibility != null : 
			await shoot()
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
	$trou_noir.scale = Vector2(1,1)
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
	await sleep()
	if caracteristiques["améliorations"]["2"]["upgraded"] and randi_range(0,4) == 0:
		$AnimationPlayer.play("tir_trou_noir")
		await sleep(1.2)
		$Timer.start()
		while not timer_timeout:
			var monsters = $"zone dégats".get_overlapping_bodies()
			for monster in monsters :
				if monster != null:
					if monster.is_in_group("monsters"):
						await sleep()
						if parent.actual_sequence != 5 or parent.actual_wave != 6:
							monster.get_parent().progress = 0
						if caracteristiques["améliorations"]["1"]["upgraded"]:
							monster.get_parent().paralysis()
			await sleep()
		timer_timeout = false
	else :
		$AnimationPlayer.play("tir")
		await sleep(1.2)
		var monsters = $"zone dégats".get_overlapping_bodies()
		for monster in monsters :
			if monster != null:
				if monster.is_in_group("monsters"):
					if Global.automatic_evolution:
						if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["shock"]:
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += monster.pv *monster.get_parent().resistance["shock"]
						else :
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += caracteristiques["damage"] *monster.get_parent().resistance["shock"]
					monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["shock"]
					if caracteristiques["améliorations"]["1"]["upgraded"]:
							monster.get_parent().paralysis()
	await sleep(1)
	$AnimationPlayer.play("recharge")
	await sleep(8)
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

func _on_timer_timeout() -> void:
	timer_timeout = true
