extends Enemy
class_name WormDot

var scale_factor: float = 1.0
var base_radius: float = 6.0

func _setup_enemy() -> void:
	# Worm dots are slightly smaller and yellow
	speed = 140.0 # Make them a bit faster for a better chain feel

func set_scale_factor(new_scale: float) -> void:
	scale_factor = new_scale
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
		$CollisionShape2D.shape.radius = base_radius * scale_factor
	queue_redraw()

func set_follow_target(node: Node2D) -> void:
	target = node
	if target != null:
		target.tree_exited.connect(_on_target_died)

func _on_target_died() -> void:
	target = player

func _draw() -> void:
	draw_circle(Vector2.ZERO, base_radius * scale_factor, Color.GOLD)
