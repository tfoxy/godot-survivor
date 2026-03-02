extends Node

const MIN_RATIO = 9.0 / 16.0
const MAX_RATIO = 16.0 / 9.0

const LevelConfigScript = preload("res://src/level_config.gd")

var GRID_EXTENT: float = 800.0
var highest_time: float = 0.0
var selected_level: Resource = null

func _ready() -> void:
	# Enforce aspect ratio limits on startup and when window is resized
	get_viewport().size_changed.connect(_on_window_resized)
	get_tree().node_added.connect(_on_node_added)
	_on_window_resized()

func _on_node_added(node: Node) -> void:
	# When a new Camera2D node enters the tree (like when Main.tscn loads),
	# we want to ensure its zoom is set correctly.
	if node is Camera2D:
		_on_window_resized()

func _on_window_resized() -> void:
	var window = get_window()
	var window_size = Vector2(window.size)
	var current_ratio = window_size.x / window_size.y
	
	if current_ratio > MAX_RATIO:
		# Too wide: add pillarbox (keep 16:9)
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		window.content_scale_size = Vector2i(1280, 720)
	elif current_ratio < MIN_RATIO:
		# Too tall: add letterbox (keep 9:16)
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		window.content_scale_size = Vector2i(720, 1280)
	else:
		# In range: expand the view
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
		# Use 1280x720 as base for consistency
		window.content_scale_size = Vector2i(1280, 720)

	# Adjust camera zoom to maintain constant viewable area (s)
	# (w * h) / (zoom^2) = s  =>  zoom = sqrt((w * h) / s)
	# We MUST use the logical size of the viewport (which handles engine scaling),
	# not the pixel resolution (viewport.size).
	
	var viewport = get_viewport()
	if viewport:
		var camera = viewport.get_camera_2d()
		if camera:
			# Use the visible rect size (logical units)
			var logical_size = viewport.get_visible_rect().size
			var vw = logical_size.x
			var vh = logical_size.y
			
			# Constant area 's'.
			# 1280 * 720 = 921600.
			# Let's use the user's current 's' value. 
			var s = (1280.0 * 720.0) * 2
			var zoom_factor = sqrt((float(vw) * vh) / s)
			camera.zoom = Vector2(zoom_factor, zoom_factor)
