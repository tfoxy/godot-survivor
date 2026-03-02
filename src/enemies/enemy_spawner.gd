extends Node2D
class_name EnemySpawner

const LevelConfigScript = preload("res://src/level_config.gd")

@export var fodder_scene: PackedScene
@export var worm_dot_scene: PackedScene
@export var bouncy_dot_scene: PackedScene # Bouncy settings
@export var bouncy_start_time: float = 180.0
@export var bouncy_interval: float = 5.0
@export var bouncy_spawn_count: int = 3
@export var bouncy_health: int = 25

# Pair settings
@export var pair_dot_scene: PackedScene
@export var mortar_dot_scene: PackedScene
@export var pair_start_time: float = 0.0
@export var pair_interval: float = 10.0
@export var pair_spawn_count: int = 1

@export var spawn_interval: float = 1.0
@export var spawn_distance_offset: float = 800.0
@export var min_spawn_interval: float = 0.2
@export var interval_reduction: float = 0.03

var spawn_timer: Timer
var total_time: float = 0.0
var fodder_stopped: bool = false
var next_worm_time: float = 60.0
var next_bouncy_time: float = 180.0
var next_pair_time: float = 0.0
var next_mortar_time: float = 0.0
var mortar_current_interval: float = 20.0

var worms_per_spawn: int = 1
var worm_scale: float = 1.0
var dots_per_worm: float = 120.0
var last_worm_count_increase: float = 0.0

# Queue for incremental spawning to avoid frame drops
var worm_queues: Array = []

func _ready() -> void:
	var config = Globals.selected_level
	if config == null:
		config = LevelConfigScript.new()
		Globals.selected_level = config
		
	spawn_interval = config.spawn_interval
	min_spawn_interval = config.min_spawn_interval
	interval_reduction = config.interval_reduction
	next_worm_time = config.worm_start_time
	next_bouncy_time = config.bouncy_start_time
	next_pair_time = config.pair_start_time
	next_mortar_time = config.mortar_start_time
	mortar_current_interval = config.mortar_interval
	worms_per_spawn = config.initial_worms_per_spawn
	dots_per_worm = config.initial_dots_per_worm
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _process(delta: float) -> void:
	total_time += delta
	var config = Globals.selected_level
	
	# Increase difficulty every scaling_interval
	if total_time - last_worm_count_increase >= config.scaling_interval:
		worms_per_spawn = int(worms_per_spawn * config.worm_count_multiplier)
		worm_scale *= config.worm_scale_multiplier
		dots_per_worm *= config.dots_per_worm_multiplier
		last_worm_count_increase = total_time
		print("Difficulty increased! Worms: ", worms_per_spawn, " Scale: ", worm_scale, " Dots: ", dots_per_worm)
	
	# Fodder spawning logic
	if config.spawn_fodder:
		if not fodder_stopped and total_time >= config.fodder_stop_time and total_time < config.fodder_resume_time:
			fodder_stopped = true
			spawn_timer.stop()
			print("Stopping fodder spawning")
		elif fodder_stopped and total_time >= config.fodder_resume_time:
			fodder_stopped = false
			spawn_timer.start()
			print("Resuming fodder spawning")
		
	# Worm spawning trigger
	if total_time >= next_worm_time:
		for i in range(worms_per_spawn):
			queue_worm_spawn()
		next_worm_time += config.worm_interval
	
	# Bouncy spawning trigger
	if config.spawn_bouncy and total_time >= next_bouncy_time:
		for i in range(config.bouncy_spawn_count):
			spawn_bouncy()
		next_bouncy_time += config.bouncy_interval
	
	# Pair spawning trigger
	if total_time >= next_pair_time and config.pair_start_time >= 0:
		for i in range(config.pair_spawn_count):
			spawn_pair()
		next_pair_time += config.pair_interval
	
	# Mortar spawning trigger
	if total_time >= next_mortar_time and config.mortar_start_time >= 0:
		for i in range(config.mortar_spawn_count):
			spawn_mortar()
		next_mortar_time += mortar_current_interval
		mortar_current_interval = max(5.0, mortar_current_interval * 0.9)
	
	# Handle incremental spawning (one dot per frame for each active queue)
	_process_spawn_queues()

func _process_spawn_queues() -> void:
	var finished_indices: Array = []
	for i in range(worm_queues.size()):
		var q = worm_queues[i]
		
		var worm = worm_dot_scene.instantiate()
		var dot_index = q.spawned_count
		worm.position = q.start_pos - q.spawn_dir * (dot_index * q.spacing)
		if worm.has_method("set_scale_factor"):
			worm.set_scale_factor(q.scale)
		get_parent().add_child(worm)
		
		if q.last_node != null and worm.has_method("set_follow_target"):
			worm.set_follow_target(q.last_node)
		
		q.last_node = worm
		q.spawned_count += 1
		
		if not q.infinite:
			q.remaining_dots -= 1
			if q.remaining_dots <= 0:
				finished_indices.append(i)
	
	# Remove finished queues in reverse to maintain indices
	finished_indices.reverse()
	for idx in finished_indices:
		worm_queues.remove_at(idx)

func _on_spawn_timer_timeout() -> void:
	if Globals.selected_level and not Globals.selected_level.spawn_fodder:
		return
	if fodder_stopped or fodder_scene == null:
		return
		
	spawn_fodder()
	
	if spawn_timer.wait_time > min_spawn_interval:
		spawn_timer.wait_time -= interval_reduction

func spawn_fodder() -> void:
	var spawn_pos = _get_random_spawn_pos()
	var enemy = fodder_scene.instantiate()
	enemy.position = spawn_pos
	get_parent().add_child(enemy)

func queue_worm_spawn() -> void:
	if worm_dot_scene == null:
		return
		
	var dist = Globals.GRID_EXTENT + spawn_distance_offset
	var side = randi() % 4
	var offset_val = (randf() * 2.0 - 1.0) * dist
	var start_pos: Vector2
	var spawn_dir: Vector2
	
	if side == 0: # Left
		start_pos = Vector2(-dist, offset_val)
		spawn_dir = Vector2(1, 0)
	elif side == 1: # Right
		start_pos = Vector2(dist, offset_val)
		spawn_dir = Vector2(-1, 0)
	elif side == 2: # Top
		start_pos = Vector2(offset_val, -dist)
		spawn_dir = Vector2(0, 1)
	else: # Bottom
		start_pos = Vector2(offset_val, dist)
		spawn_dir = Vector2(0, -1)
	
	# Perpendicular to the edge means the line goes "outwards" relative to entry direction
	# but the head enters head-first. So if head enters from left (side 0), 
	# it starts at -dist and the tail segments are at -dist - spacing.
	# So the 'spawn_dir' for the LINE generation should be the entry direction.
	
	var total_dots = int(dots_per_worm)
	worm_queues.append({
		"remaining_dots": total_dots,
		"total_dots": total_dots,
		"spawned_count": 0,
		"last_node": null,
		"start_pos": start_pos,
		"spawn_dir": spawn_dir,
		"spacing": 16.0 * worm_scale,
		"scale": worm_scale,
		"infinite": Globals.selected_level.infinite_worm if Globals.selected_level else false
	})

func spawn_bouncy() -> void:
	if bouncy_dot_scene == null:
		return
	var spawn_pos = _get_random_spawn_pos()
	var enemy = bouncy_dot_scene.instantiate()
	enemy.position = spawn_pos
	get_parent().add_child(enemy)

func spawn_pair() -> void:
	if pair_dot_scene == null:
		return
	var spawn_pos = _get_random_spawn_pos()
	var enemy = pair_dot_scene.instantiate()
	enemy.position = spawn_pos
	get_parent().add_child(enemy)

func spawn_mortar() -> void:
	if mortar_dot_scene == null:
		return
	
	# "Spawns at the opposite point in the grid from the player"
	# Calculate opposite point: direction from player to center, project to border
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0: return
	
	# Use LOCAL position relative to grid center (Main node origin)
	var player_pos = players[0].position
	if player_pos.length_squared() < 100.0:
		# Random direction if player is too close to center
		player_pos = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		
	var dir_to_center = - player_pos.normalized()
	
	# Project to grid border
	# Use exact GRID_EXTENT for border (minus a small margin to ensure it's inside)
	var dist = Globals.GRID_EXTENT - 20.0
	
	# Intersection with axis-aligned box
	var t_x = abs(dist / dir_to_center.x) if dir_to_center.x != 0 else INF
	var t_y = abs(dist / dir_to_center.y) if dir_to_center.y != 0 else INF
	var t = min(t_x, t_y)
	var spawn_pos = dir_to_center * t
	
	var enemy = mortar_dot_scene.instantiate()
	enemy.position = spawn_pos
	get_parent().add_child(enemy)

func _get_random_spawn_pos() -> Vector2:
	var dist = Globals.GRID_EXTENT + spawn_distance_offset
	var side = randi() % 4
	var offset_val = (randf() * 2.0 - 1.0) * dist
	
	if side == 0: return Vector2(-dist, offset_val)
	elif side == 1: return Vector2(dist, offset_val)
	elif side == 2: return Vector2(offset_val, -dist)
	else: return Vector2(offset_val, dist)
