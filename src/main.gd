extends Node2D

const Globals = preload("res://src/globals.gd")
@onready var _player: Node2D = $Player
@onready var _bullet_manager: Node2D = $BulletManager

var monster_scene: PackedScene = preload("res://src/monster.tscn")
var monster_timer: Timer

var current_time: float = 0.0
var time_label: Label
var best_time_label: Label
var ui_layer: CanvasLayer

func _ready() -> void:
	if _player.get("bullet_manager") != null:
		_player.bullet_manager = _bullet_manager
	await get_tree().process_frame
	var rect: Rect2 = get_viewport().get_visible_rect()
	position = rect.get_center()

	# Connect virtual joystick to InputManager
	var joystick = get_node_or_null("JoystickLayer/VirtualJoystick")
	if joystick and joystick.has_signal("analogic_changed"):
		joystick.analogic_changed.connect(InputManager._on_joystick_changed)

	monster_timer = Timer.new()
	monster_timer.wait_time = 2.0
	monster_timer.autostart = true
	monster_timer.timeout.connect(_on_monster_timer_timeout)
	add_child(monster_timer)

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
	
	_update_best_label()

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

func _on_monster_timer_timeout() -> void:
	var dist = Globals.GRID_EXTENT + 400.0
	var side = randi() % 4
	var offset_val = (randf() * 2.0 - 1.0) * dist
	var spawn_pos: Vector2
	if side == 0: spawn_pos = Vector2(-dist, offset_val)
	elif side == 1: spawn_pos = Vector2(dist, offset_val)
	elif side == 2: spawn_pos = Vector2(offset_val, -dist)
	else: spawn_pos = Vector2(offset_val, dist)
	
	var monster = monster_scene.instantiate()
	monster.position = spawn_pos
	add_child(monster)
	
	if monster_timer.wait_time > 0.1:
		monster_timer.wait_time -= 0.1
