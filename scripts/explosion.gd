extends Node2D

var damages = 3

func _ready() -> void:
	position /= get_parent().scale.x
	await get_tree().create_timer(0.05).timeout
	$AnimatedSprite2D.play("explosion")
	var ennemys = $Area2D.get_overlapping_bodies()
	for monster in ennemys : 
		if monster.is_in_group("monsters"):
			if Global.automatic_evolution:
				if monster.pv > 0 and monster.pv < damages *monster.get_parent().resistance["explosion"]:
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["explosion"] += monster.pv *monster.get_parent().resistance["explosion"]
				else :
					Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["explosion"] += damages *monster.get_parent().resistance["explosion"]
			monster.pv -= damages *monster.get_parent().resistance["explosion"]
	await get_tree().create_timer(0.7).timeout
	queue_free()
