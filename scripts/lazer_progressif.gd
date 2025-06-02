extends Node2D
@onready var parent = get_parent().get_parent().get_parent().get_parent()
var possibility
var pose_tour_finish = false
var mouse : bool = false
var time : float = 0
var caracteristiques : Dictionary = {
	"position" = Vector2.ZERO,
	"type" = "lazer_constant",
	"damage" = .15,
	"vitesse" = 1,
	"zone" = 1000,
	"recharge" = 10,
	"améliorations" = {"1" = {"name" = "augmenter les dégats du lazer",
							"upgraded" = false,
							"price" = 400},
	"2" = {"name" = "se recharge plus rapidement",
		"upgraded" = false,
		"price" = 400},
	"3" = null}
}

func _process(delta: float) -> void:
	caracteristiques["position"] = position
	if caracteristiques["améliorations"]["1"]["upgraded"]:
		caracteristiques["damage"] = .2

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
			if caracteristiques["améliorations"]["2"]["upgraded"]:
				await sleep(time * 1.5)
			else :
				await sleep(time * 2)
	await sleep()

func found_monster():
	$tourelle/RayCast2D.target_position = Vector2(504.7,0)*parent.scene.scale.x
	possibility = null
	for monster in Global.pos_monsters.size() : 
		if Global.pos_monsters[monster] is Vector2 and Global.pos_monsters[monster] != Vector2.ZERO:
			$tourelle/RayCast2D.look_at(Global.pos_monsters[monster])
			if $tourelle/RayCast2D.get_collider() != null and $tourelle/RayCast2D.get_collider().is_in_group("monsters"):  
				if position.distance_to(Global.pos_monsters[monster]) < caracteristiques["zone"]*parent.scene.scale.x :
						if possibility == null :
							possibility = monster
						elif position.distance_to(Global.pos_monsters[monster]) <= position.distance_to(Global.pos_monsters[possibility]):
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

func shoot():
	$tourelle/RayCast2D.rotation = 0
	await rotate_tower()
	var monster = $tourelle/RayCast2D.get_collider()
	time = 0
	var m_m = false #monstre mort
	while Global.pos_monsters[possibility] != Vector2.ZERO and not m_m and not monster == null and time < 10:
		if not monster == null:
			var rapidité : float = 8
			if caracteristiques["améliorations"]["1"]["upgraded"]:
				rapidité = 4
			$tourelle.look_at(Global.pos_monsters[possibility])
			$tourelle/lazer_mesh.global_scale.x = (global_position.distance_to(Global.pos_monsters[possibility]))-45
			$tourelle/lazer_mesh.position = Vector2(float($tourelle/lazer_mesh.scale.x)/2.0+90, 0)
			var d = caracteristiques["damage"] *monster.get_parent().resistance["lazer"]
			if monster.pv-d <= 0 : m_m = true
			if Global.automatic_evolution:
				if monster.pv > 0 and monster.pv < caracteristiques["damage"]:
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += monster.pv
				else :
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["lazer"] += d
			monster.pv -= d
			await sleep()
	for i in 10:
		
		$tourelle/lazer_mesh.scale.x /= 2
		$tourelle/lazer_mesh.position = Vector2(float($tourelle/lazer_mesh.scale.x)/2.0+90, 0)
		await sleep()
	$tourelle/lazer_mesh.scale.x = 0

func rotate_tower():
	#recuperer start et end
	var start = $tourelle.rotation
	$tourelle.look_at(Global.pos_monsters[possibility])
	var end = $tourelle.rotation
	$tourelle.rotation = start
	#calcul de l'angle
	var angle = start - end
	
	if abs(angle) > 180:
		angle = 360*(-(angle/abs(angle)))+angle
	
	for i in 10:
		angle /= 2
		$tourelle.rotation -= angle
		await sleep()
	$tourelle.rotation = end

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
	time += .1
