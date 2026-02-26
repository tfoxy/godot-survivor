extends Node2D
class_name EnemySpawner

const Globals = preload("res://src/globals.gd")

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 2.0
@export var spawn_distance_offset: float = 400.0
@export var min_spawn_interval: float = 0.1
@export var interval_reduction: float = 0.1

var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout() -> void:
	if enemy_scenes.is_empty():
		return
		
	spawn_enemy()
	
	if spawn_timer.wait_time > min_spawn_interval:
		spawn_timer.wait_time -= interval_reduction

func spawn_enemy() -> void:
	var dist = Globals.GRID_EXTENT + spawn_distance_offset
	var side = randi() % 4
	var offset_val = (randf() * 2.0 - 1.0) * dist
	var spawn_pos: Vector2
	
	if side == 0: spawn_pos = Vector2(-dist, offset_val)
	elif side == 1: spawn_pos = Vector2(dist, offset_val)
	elif side == 2: spawn_pos = Vector2(offset_val, -dist)
	else: spawn_pos = Vector2(offset_val, dist)
	
	var scene_to_spawn = enemy_scenes.pick_random()
	var enemy = scene_to_spawn.instantiate()
	enemy.position = spawn_pos
	# Add to the same parent as the spawner, or the scene tree root
	get_parent().add_child(enemy)
