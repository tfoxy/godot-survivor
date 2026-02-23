extends Node2D
## Draws a world-space grid and background for movement reference.

@export var grid_size: float = 50.0
@export var grid_extent: float = 800.0
@export var line_color: Color = Color(0.25, 0.25, 0.3, 0.6)
@export var background_color: Color = Color(0.18, 0.18, 0.2, 1.0)
@export var axis_color: Color = Color(0.4, 0.4, 0.5, 0.8)


func _draw() -> void:
	var half: float = grid_extent
	# Background quad
	draw_rect(Rect2(-half, -half, half * 2.0, half * 2.0), background_color)
	# Grid lines
	var x: float = -half
	while x <= half:
		var color: Color = axis_color if is_zero_approx(x) else line_color
		draw_line(Vector2(x, -half), Vector2(x, half), color)
		x += grid_size
	var y: float = -half
	while y <= half:
		var color: Color = axis_color if is_zero_approx(y) else line_color
		draw_line(Vector2(-half, y), Vector2(half, y), color)
		y += grid_size
