extends Node2D

@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "neige",
	"zone" = 125,
	"damage" = 0,
	"vitesse" = 10,
	"améliorations" = {"1" = {"name" = "rends les ennemis dans sa zone vulnérables",
							"upgraded" = false,
							"price" = 700},
	"2" = {"name" = "rends les ennemis dans sa zone 2 fois plus lents",
			"upgraded" = false,
			"price" = 600},
	"3" = null}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		if not $"détect".is_in_group("vulnérable"):
			$"détect".add_to_group("vulnérable")
	if caracteristiques["améliorations"]["2"]["upgraded"]:
		$"détect2/CollisionShape2D".disabled = false
	else :
		$"détect2/CollisionShape2D".disabled = true

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	$AnimatedSprite2D.play("tour")
	while true:
		await sleep()
		await sleep() ; tower_pressed()

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func pose_tour():
	$AnimatedSprite2D.position = Vector2(1,1) * 2.857
	$AnimatedSprite2D.scale = Vector2(1,1) * 0.23
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
	$AnimatedSprite2D.position = Vector2.ZERO
	$AnimatedSprite2D.scale = Vector2(1,1) * 1.33
	fonctionne()

func detect_tour():
	var collision = $Area2D.get_overlapping_areas()
	if collision != [] :
		return true
	else :
		return false


func mouse_entered() -> void:
	mouse = true
	if pose_tour_finish :
		parent.zone_tour(position, caracteristiques["zone"])

func mouse_exited() -> void:
	mouse = false
	if pose_tour_finish :
		parent.scene.get_node("map/zone_tour").hide()

func tower_pressed():
	if mouse and Input.is_action_just_pressed("clique gauche") and not Global.placing_tower and not parent.trash:
		parent.open_amélio(self)
