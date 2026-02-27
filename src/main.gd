extends Node2D
const LevelConfigScript = preload("res://src/level_config.gd")
@onready var _player: Node2D = $Player
@onready var _bullet_manager: Node2D = $BulletManager

var fodder_dot_scene: PackedScene = preload("res://src/enemies/fodder_dot.tscn")
var worm_dot_scene: PackedScene = preload("res://src/enemies/worm_dot.tscn")
var bouncy_dot_scene: PackedScene = preload("res://src/enemies/bouncy_dot.tscn")
var enemy_spawner: EnemySpawner

var current_time: float = 0.0
var time_label: Label
var best_time_label: Label
var ui_layer: CanvasLayer

func _ready() -> void:
	if Globals.selected_level == null:
		Globals.selected_level = LevelConfigScript.new()
	
	Globals.GRID_EXTENT = Globals.selected_level.initial_grid_extent
	sync_grid_extent()
	
	if _player.get("bullet_manager") != null:
		_player.bullet_manager = _bullet_manager
	await get_tree().process_frame
	var rect: Rect2 = get_viewport().get_visible_rect()
	position = rect.get_center()

	# Connect virtual joystick to InputManager
	var joystick = get_node_or_null("JoystickLayer/VirtualJoystick")
	if joystick and joystick.has_signal("analogic_changed"):
		joystick.analogic_changed.connect(InputManager._on_joystick_changed)

	enemy_spawner = EnemySpawner.new()
	enemy_spawner.fodder_scene = fodder_dot_scene
	enemy_spawner.worm_dot_scene = worm_dot_scene
	enemy_spawner.bouncy_dot_scene = bouncy_dot_scene
	add_child(enemy_spawner)

	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	time_label = Label.new()
	time_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	time_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	time_label.add_theme_font_size_override("font_size", 32)
	time_label.offset_right = -20
	time_label.offset_top = 20
	ui_layer.add_child(time_label)
	
	best_time_label = Label.new()
	best_time_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	best_time_label.grow_horizontal = Control.GROW_DIRECTION_END
	best_time_label.add_theme_font_size_override("font_size", 32)
	best_time_label.offset_left = 20
	best_time_label.offset_top = 20
	ui_layer.add_child(best_time_label)
	
	var level_label = Label.new()
	level_label.text = Globals.selected_level.level_name
	level_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	level_label.grow_horizontal = Control.GROW_DIRECTION_END
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.offset_left = 20
	level_label.offset_top = 60
	ui_layer.add_child(level_label)
	
	_update_best_label()

	var grid_timer = Timer.new()
	grid_timer.wait_time = Globals.selected_level.grid_expansion_interval
	grid_timer.autostart = true
	grid_timer.timeout.connect(_on_grid_expansion)
	add_child(grid_timer)

func _on_grid_expansion() -> void:
	Globals.GRID_EXTENT *= Globals.selected_level.grid_expansion_multiplier
	print("Grid expanded to: ", Globals.GRID_EXTENT)
	sync_grid_extent()

func sync_grid_extent() -> void:
	if has_node("Grid"):
		var grid = get_node("Grid")
		if grid.has_method("update_extent"):
			grid.update_extent(Globals.GRID_EXTENT)
		else:
			grid.grid_extent = Globals.GRID_EXTENT
			grid.queue_redraw()
	
	if _player != null:
		if _player.has_method("update_grid_extent"):
			_player.update_grid_extent(Globals.GRID_EXTENT)
		elif "grid_extent" in _player:
			_player.grid_extent = Globals.GRID_EXTENT

func _process(delta: float) -> void:
	current_time += delta
	var minutes = int(current_time / 60.0)
	var seconds = int(current_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _update_best_label() -> void:
	var minutes = int(Globals.highest_time / 60.0)
	var seconds = int(Globals.highest_time) % 60
	best_time_label.text = "Best: %02d:%02d" % [minutes, seconds]

func game_over() -> void:
	if current_time > Globals.highest_time:
		Globals.highest_time = current_time
