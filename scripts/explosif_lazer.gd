extends Node2D

var damages = 0.75
var monstres_touchés : Array = []
var timer_timeout : bool = false

func explode():
	$AnimatedSprite2D.hide()
	$AnimatedSprite2D2.show()
	$Area2D.show()
	await get_tree().create_timer(0.05).timeout
	$AnimatedSprite2D2.play("explosion")
	$Timer.start()
	while not timer_timeout:
		var ennemys = $Area2D.get_overlapping_bodies()
		for monster in ennemys : 
			if monster.is_in_group("monsters"):
				if monstres_touchés.find(monster) == -1:
					if Global.automatic_evolution:
						if monster.pv > 0 and monster.pv < damages *monster.get_parent().resistance["explosion"]:
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["explosion"] += monster.pv *monster.get_parent().resistance["explosion"]
						else :
							Global.damages_this_sequence[str(monster.get_parent().bases_statistics["name"])]["explosion"] += damages *monster.get_parent().resistance["explosion"]
					monster.pv -= damages *monster.get_parent().resistance["explosion"]
					monstres_touchés.append(monster)
		await get_tree().create_timer(.05).timeout
	queue_free()

func _ready() -> void:
	$AnimatedSprite2D.show()
	$AnimatedSprite2D2.hide()
	$Area2D.hide()
	$AnimatedSprite2D.play("mine")


func _on_timer_timeout() -> void:
	timer_timeout = true
