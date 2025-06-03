extends Node2D

var grave_type : String
var advance : float
@onready var parent = get_parent().get_parent().get_parent()

func _ready() -> void:
	if parent.name != "main":
		parent = parent.get_parent()
	
	respawn_boss()
	
	$AnimatedSprite2D.play("default")
	
	if grave_type == "squelette_boss":
		modulate = Color(1,0,1)
	
	if grave_type == "s2_boss":
		modulate = Color(0,5,0)
	
	if grave_type == "insecte_boss":
		modulate = Color(.7,0,0)
	
	if grave_type == "soldat_boss":
		modulate = Color(0,0,1)
	
	if grave_type == "bot_boss":
		modulate = Color(2,0,0)


func respawn_boss():
	while parent.actual_sequence != 5 or parent.actual_wave != 6:
		await get_tree().create_timer(1).timeout
	var touch
	var necromancien : bool = false
	var necromancien_id : Node2D = null
	while not necromancien :
		touch = $Area2D.get_overlapping_bodies()
		if touch != []:
			for i in touch:
				if i.get_parent().bases_statistics["name"] == "necromancien":
					necromancien = true
					necromancien_id = i
		await get_tree().create_timer(0.1).timeout
	while necromancien and not necromancien_id == null:
		for i in ["squelette_boss","s2_boss","insecte_boss","soldat_boss","bot_boss"].find(grave_type)+1:
			await get_tree().create_timer(0.016).timeout
		touch = $Area2D.get_overlapping_bodies()
		if touch == []:
			necromancien = false
	if not necromancien_id == null:
		parent.new_monster(grave_type+"_revive", 1, advance)
	queue_free()
