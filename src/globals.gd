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
