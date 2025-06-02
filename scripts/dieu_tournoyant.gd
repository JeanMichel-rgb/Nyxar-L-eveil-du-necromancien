extends Node2D

@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "dieu_tournoyant",
	"damage" = 6,
	"vitesse" = 10,
	"zone" = 50,
	"rotation" = 8,
	"améliorations" = {"1" = {"name" = "les pics sont brûlants",
							"upgraded" = false,
							"price" = 200},
	"2" = null,
	"3" = null}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position

func _ready() -> void:
	if Global.loading_game : fonctionne()
	else  : pose_tour()

func fonctionne():
	pose_tour_finish = true
	$AnimatedSprite2D.animation = "tir"
	while true:
		await sleep()
		rotation += deg_to_rad(caracteristiques["rotation"])
		tower_pressed()

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout

func pose_tour():
	$AnimatedSprite2D.position = Vector2(27, -9)
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
	$AnimatedSprite2D.position = Vector2(139,-27)
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
			if monster.pv > 0 and monster.pv < caracteristiques["damage"] *monster.get_parent().resistance["shock"]:
				Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += monster.pv *monster.get_parent().resistance["shock"]
			else :
				Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["shock"] += caracteristiques["damage"] *monster.get_parent().resistance["shock"]
		monster.pv -= caracteristiques["damage"] *monster.get_parent().resistance["shock"]
		if caracteristiques["améliorations"]["1"]["upgraded"]:
			make_fire(monster)

func make_fire(monster):
	var test_2 = 0
	for test in Global.feu.size():
		if Global.feu[test][0] == monster :
			Global.feu[test][1] = 5
			test_2 = 1
	if test_2 == 0 :
		Global.feu.append([])
		Global.feu[-1].append(monster)
		Global.feu[-1].append(5)

func mouse_entered() -> void:
	mouse = true

func mouse_exited() -> void:
	mouse = false

func tower_pressed():
	if mouse and Input.is_action_just_pressed("clique gauche") and not Global.placing_tower and not parent.trash:
		parent.open_amélio(self)
