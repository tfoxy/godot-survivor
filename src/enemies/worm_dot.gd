extends "res://src/enemies/enemy.gd"
class_name WormDot

func _setup_enemy() -> void:
	# Worm dots are slightly smaller and yellow
	speed = 140.0 # Make them a bit faster for a better chain feel

func set_follow_target(node: Node2D) -> void:
	target = node
	if target != null:
		target.tree_exited.connect(_on_target_died)

func _on_target_died() -> void:
	target = player

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color.GOLD)
