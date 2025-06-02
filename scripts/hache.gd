extends Node2D

@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "hache",
	"damage" = 1,
	"vitesse" = 9,
	"zone" = 50,
	"rotation" = 8,
	"améliorations" = {"1" = {"name" = "la hache est plus tranchante",
							"upgraded" = false,
							"price" = 200},
	"2" = {"name" = "débloque 1 nouvelle hache",
			"upgraded" = false,
			"price" = 100},
	"3" = {"name" = "la lame est empoisonée",
			"upgraded" = false,
			"price" = 400}}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		caracteristiques["damage"] = 2

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	await sleep() ; tower_pressed()
	$AnimatedSprite2D.position = Vector2(-21.429, -22.857)
	$AnimatedSprite2D.animation = "tour_base"
	while true:
		await sleep()
		rotation += deg_to_rad(caracteristiques["rotation"])
		if caracteristiques["améliorations"]["2"]["upgraded"]:
			if caracteristiques["améliorations"]["3"]["upgraded"]:
				$AnimatedSprite2D.animation = "tour_double_poison"
				$AnimatedSprite2D.position = Vector2(-104.35, -29.129)
				for area in $"dégats".get_children():
					for colision in area.get_children():
						if area == $"dégats/dégats_double_poison":
							colision.disabled = false
						else:
							colision.disabled = true
			else :
				$AnimatedSprite2D.animation = "tour_double"
				$AnimatedSprite2D.position = Vector2(-100.5, -26)
				for area in $"dégats".get_children():
					for colision in area.get_children():
						if area == $"dégats/dégats_double":
							colision.disabled = false
						else:
							colision.disabled = true
		elif caracteristiques["améliorations"]["3"]["upgraded"]:
			$AnimatedSprite2D.animation = "tour_poison"
			$AnimatedSprite2D.position = Vector2(-26.236, -26.057)
			for area in $"dégats".get_children():
				for colision in area.get_children():
					if area == $"dégats/dégats_poison":
						colision.disabled = false
					else:
						colision.disabled = true
		else :
			$AnimatedSprite2D.animation = "tour_base"
			$AnimatedSprite2D.position = Vector2(-21.95, -23.2)
			for area in $"dégats".get_children():
				for colision in area.get_children():
					if area == $"dégats/dégats_base":
						colision.disabled = false
					else:
						colision.disabled = true

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func pose_tour():
	$AnimatedSprite2D.position = Vector2(-62.857, -30)
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
	Global.placing_tower = false
	pose_tour_finish = true
	fonctionne()

func detect_tour():
	var collision = $Area2D.get_overlapping_areas()
	if collision != [] :
		return true
	else :
		return false

func damages(monster: Node2D) -> void:
	if monster.is_in_group("monsters") and pose_tour_finish:
		if Global.automatic_evolution:
			if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["notch"]:
				Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["notch"] += monster.pv *monster.get_parent().resistance["notch"]
			else :
				Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["notch"] += caracteristiques["damage"] *monster.get_parent().resistance["notch"]
		monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["notch"]
		if caracteristiques["améliorations"]["3"]["upgraded"]:
			monster.get_parent().poisoned = true

func mouse_entered() -> void:
	mouse = true

func mouse_exited() -> void:
	mouse = false

func tower_pressed():
	while true:
		if mouse and Input.is_action_just_pressed("clique gauche") and not Global.placing_tower and not parent.trash:
			parent.open_amélio(self)
		await sleep()
