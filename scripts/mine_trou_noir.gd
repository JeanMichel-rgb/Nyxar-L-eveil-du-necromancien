extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
@onready var scene = get_parent().get_parent().get_parent()
var monster = []
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "mine_trou_noir",
	}

func _process(delta: float) -> void:
	caracteristiques["position"] = position

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func pose_tour():
	$AnimatedSprite2D2.hide()
	$AnimatedSprite2D.scale = Vector2(1,1)
	Global.placing_tower = true
	await sleep()
	position = get_parent().get_parent().get_local_mouse_position()
	while not Input.is_action_just_pressed("clique gauche") or await detect_chemin() :
		await sleep()
		var collision = $Area2D.get_overlapping_areas()
		if collision != [] :
			$AnimatedSprite2D.animation = "poser possible"
		else :
			$AnimatedSprite2D.animation = "poser pas possible"
		position = get_parent().get_parent().get_local_mouse_position()
	Global.placing_tower = false
	fonctionne()

func fonctionne():
	$AnimatedSprite2D2.show()
	$AnimatedSprite2D.play("mine")
	$AnimatedSprite2D.scale = Vector2(0.5,0.5)
	
	while not monster != []:
		await sleep()
		$AnimatedSprite2D.rotation_degrees += 2
		$AnimatedSprite2D2.rotation_degrees -= 2
		monster = $Area2D2.get_overlapping_bodies()
	var trou_noir = (load("res://scenes/trou_noir.tscn")as PackedScene).instantiate()
	trou_noir.position = global_position
	trou_noir.parent = parent
	parent.scene.add_child(trou_noir)
	queue_free()

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func detect_chemin():
	var collision = $Area2D.get_overlapping_areas()
	if collision != [] :
		return false
	else :
		return true
