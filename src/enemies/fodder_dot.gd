extends Enemy
class_name FodderDot

func _setup_enemy() -> void:
	# Add any Fodder-specific initialization here
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color.WEB_GREEN)
