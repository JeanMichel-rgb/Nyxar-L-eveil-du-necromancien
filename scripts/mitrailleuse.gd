extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "mitrailleuse",
	"damage" = .5,
	"await_time" = .05,
	"vitesse" = 9,
	"zone" = 250,
	"améliorations" = {"1" = {"name" = "augmentation de la zone",
			"upgraded" = false,
			"price" = 500},
	"2" = {"name" = "tir des lazers à la place de balles",
			"upgraded" = false,
			"price" = 500},
	"3" = {"name" = "débloque 2 nouveaux canons",
			"upgraded" = false,
			"price" = 600}}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		caracteristiques["zone"] = 600

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	await sleep() ; tower_pressed()
	while true : 
		await sleep()
		await in_wave()

func in_wave():
	if caracteristiques["améliorations"]["2"]["upgraded"]:
		if caracteristiques["améliorations"]["3"]["upgraded"]:
			$AnimatedSprite2D.animation = "tour_triple_lazer"
		else:
			$AnimatedSprite2D.animation = "tour_lazer"
	elif caracteristiques["améliorations"]["3"]["upgraded"]:
		$AnimatedSprite2D.animation = "tour_triple"
	else :
		$AnimatedSprite2D.animation = "tour_base"
	if Global.in_wave == true :
		found_monster()
		if possibility != null : 
			await shoot()
			await sleep(0.05)

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
	
	for i in 4:
		angle /= 2
		rotation -= angle
		await sleep()
	rotation = end

func shoot():
	$RayCast2D.rotation = 0

	await rotate_tower()
	if caracteristiques["améliorations"]["2"]["upgraded"]:
		if caracteristiques["améliorations"]["3"]["upgraded"]:
			$AnimatedSprite2D.play("tour_triple_lazer")
			var monsters = $lazer_triple.get_overlapping_bodies()
			for monster in monsters :
				if monster.is_in_group("monsters"):
					if Global.automatic_evolution:
						if monster.pv > 0 and monster.pv < caracteristiques["damage"]*3 *monster.get_parent().resistance["lazer"]:
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += monster.pv *monster.get_parent().resistance["lazer"]
						else :
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += caracteristiques["damage"]*3 *monster.get_parent().resistance["lazer"]
					monster.pv -= caracteristiques["damage"]*3 *monster.get_parent().resistance["lazer"]
			for i in 3:
				$AnimatedSprite2D.animation = ("tir_triple_lazer_"+str(i))
				await sleep()
			$AnimatedSprite2D.animation = "tour_triple_lazer"
		else:
			var monsters = $lazer.get_overlapping_bodies()
			for monster in monsters :
				if monster.is_in_group("monsters"):
					if Global.automatic_evolution:
						if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["lazer"]:
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += monster.pv *monster.get_parent().resistance["lazer"]
						else :
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += caracteristiques["damage"] *monster.get_parent().resistance["lazer"]
					monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["lazer"]
			for i in 3:
				$AnimatedSprite2D.animation = ("tir_lazer_"+str(i))
				await sleep()
			$AnimatedSprite2D.animation = "tour_lazer"
	elif caracteristiques["améliorations"]["3"]["upgraded"]:
		var monster = $RayCast2D.get_collider()
		if monster != null and monster.is_in_group("monsters"):
			if Global.automatic_evolution:
				if monster.pv > 0 and monster.pv < caracteristiques["damage"]*3 *monster.get_parent().resistance["shock"]:
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += monster.pv *monster.get_parent().resistance["shock"]
				else :
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += caracteristiques["damage"]*3 *monster.get_parent().resistance["shock"]
			monster.pv -= caracteristiques["damage"]*3 *monster.get_parent().resistance["shock"]
		$AnimatedSprite2D.animation = "tour_triple"
	else :
		$AnimatedSprite2D.play("tir")
		var monster = $RayCast2D.get_collider()
		if monster != null and monster.is_in_group("monsters"):
			if Global.automatic_evolution:
				if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["shock"]:
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += monster.pv *monster.get_parent().resistance["shock"]
				else :
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += caracteristiques["damage"] *monster.get_parent().resistance["shock"]
			monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["shock"]
		$AnimatedSprite2D.animation = "tour_base"

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
