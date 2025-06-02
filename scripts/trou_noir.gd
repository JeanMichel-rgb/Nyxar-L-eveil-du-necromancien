extends Node2D

var parent

func _ready() -> void:
	position /= get_parent().scale.x
	$AnimatedSprite2D.scale = Vector2(1,1) * .01
	for i in 10:
		$AnimatedSprite2D.scale += Vector2(1,1) * .08
		await sleep()
	await sleep(4)
	for i in 10:
		$AnimatedSprite2D.scale -= Vector2(1,1) * .08
		await sleep()
	queue_free()

func _process(delta: float) -> void:
	rotation += deg_to_rad(-5)
	if parent.actual_sequence != 5 or parent.actual_wave != 6:
		var monsters = $Area2D.get_overlapping_bodies()
		for monster in monsters:
			if monster.is_in_group("monsters"):
				monster.get_parent().progress = 0

func sleep(delta : float = 0.001):
	await get_tree().create_timer(delta).timeout
