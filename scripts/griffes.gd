extends Node2D

@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var a1 : bool = false
var a2 : bool = false
var a3 : bool = false
var augmentation_de_dégat : float = .02
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "griffes",
	"damage" = .07,
	"vitesse" = 10,
	"zone" = 50
,
	"rotation" = 8,
	"améliorations" = {"1" = {"name" = "augmentation des dégats qu'infligent les griffes",
							"upgraded" = false,
							"price" = 100},
	"2" = {"name" = "augmentation des dégats qu'infligent les griffes",
			"upgraded" = false,
			"price" = 100},
	"3" = {"name" = "augmentation des dégats qu'infligent les griffes",
			"upgraded" = false,
			"price" = 100}}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"] and not a1:
		caracteristiques["damage"] += augmentation_de_dégat
		a1 = true
	if caracteristiques["améliorations"]["2"]["upgraded"] and not a2:
		caracteristiques["damage"] += augmentation_de_dégat
		a2 = true
	if caracteristiques["améliorations"]["3"]["upgraded"] and not a3:
		caracteristiques["damage"] += augmentation_de_dégat
		a3 = true

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	$AnimatedSprite2D.animation = "tour"
	while true:
		await sleep()
		rotation += deg_to_rad(caracteristiques["rotation"])
		await damages()
		tower_pressed()

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
	Global.placing_tower = false
	pose_tour_finish = true
	fonctionne()

func detect_tour():
	var collision = $Area2D.get_overlapping_areas()
	if collision != [] :
		return true
	else :
		return false

func damages():
	for i in $"dégats".get_children():
		var monsters = i.get_overlapping_bodies()
		for monster in monsters:
			if monster.is_in_group("monsters"):
				if Global.automatic_evolution:
					if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["notch"]:
						Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["notch"] += monster.pv *monster.get_parent().resistance["notch"]
					else :
						Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["notch"] += caracteristiques["damage"] *monster.get_parent().resistance["notch"]
				monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["notch"]

func mouse_entered() -> void:
	mouse = true

func mouse_exited() -> void:
	mouse = false

func tower_pressed():
	if mouse and Input.is_action_just_pressed("clique gauche") and not Global.placing_tower and not parent.trash:
		parent.open_amélio(self)
	await sleep()
