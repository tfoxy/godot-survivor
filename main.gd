extends Node2D

const Globals = preload("res://globals.gd")
@onready var _player: Node2D = $Player
@onready var _bullet_manager: Node2D = $BulletManager

var monster_scene: PackedScene = preload("res://monster.tscn")

func _ready() -> void:
	if _player.get("bullet_manager") != null:
		_player.bullet_manager = _bullet_manager
	await get_tree().process_frame
	var rect: Rect2 = get_viewport().get_visible_rect()
	position = rect.get_center()

	var monster_timer = Timer.new()
	monster_timer.wait_time = 2.0
	monster_timer.autostart = true
	monster_timer.timeout.connect(_on_monster_timer_timeout)
	add_child(monster_timer)

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
