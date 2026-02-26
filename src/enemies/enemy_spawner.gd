extends Node2D
class_name EnemySpawner

const Globals = preload("res://src/globals.gd")

@export var fodder_scene: PackedScene
@export var worm_dot_scene: PackedScene
@export var bouncy_dot_scene: PackedScene

@export var spawn_interval: float = 1.0
@export var spawn_distance_offset: float = 800.0
@export var min_spawn_interval: float = 0.2
@export var interval_reduction: float = 0.03

var spawn_timer: Timer
var total_time: float = 0.0
var fodder_stopped: bool = false
var next_worm_time: float = 60.0
var next_bouncy_time: float = 180.0

var worms_per_spawn: int = 1
var worm_scale: float = 1.0
var dots_per_worm: float = 120.0
var last_worm_count_increase: float = 0.0

# Queue for incremental spawning to avoid frame drops
var worm_queues: Array = []

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _process(delta: float) -> void:
	total_time += delta
	
	# Increase number of worms and their size every 80 seconds
	if total_time - last_worm_count_increase >= 80.0:
		worms_per_spawn *= 2
		worm_scale *= 1.05
		dots_per_worm *= 1.25
		last_worm_count_increase = total_time
		print("Worms per spawn increased to: ", worms_per_spawn, " scale to: ", worm_scale, " and dots to: ", dots_per_worm)
	
	# Fodder spawning logic: Stop at 30s, resume at 120s
	if not fodder_stopped and total_time >= 30.0 and total_time < 120.0:
		fodder_stopped = true
		spawn_timer.stop()
		print("Stopping fodder spawning")
	elif fodder_stopped and total_time >= 120.0:
		fodder_stopped = false
		spawn_timer.start()
		print("Resuming fodder spawning")
		
	# Worm spawning trigger
	if total_time >= next_worm_time:
		for i in range(worms_per_spawn):
			queue_worm_spawn()
		next_worm_time += 45.0
	
	# Bouncy spawning trigger
	if total_time >= next_bouncy_time:
		for i in range(3):
			spawn_bouncy()
		next_bouncy_time += 75.0
	
	# Handle incremental spawning (one dot per frame for each active queue)
	_process_spawn_queues()

func _process_spawn_queues() -> void:
	var finished_indices: Array = []
	for i in range(worm_queues.size()):
		var q = worm_queues[i]
		
		var worm = worm_dot_scene.instantiate() as WormDot
		var dot_index = q.total_dots - q.remaining_dots
		worm.position = q.start_pos - q.spawn_dir * (dot_index * q.spacing)
		worm.set_scale_factor(q.scale)
		get_parent().add_child(worm)
		
		if q.last_node != null:
			worm.set_follow_target(q.last_node)
		
		q.last_node = worm
		q.remaining_dots -= 1
		
		if q.remaining_dots <= 0:
			finished_indices.append(i)
	
	# Remove finished queues in reverse to maintain indices
	finished_indices.reverse()
	for idx in finished_indices:
		worm_queues.remove_at(idx)

func _on_spawn_timer_timeout() -> void:
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
		"last_node": null,
		"start_pos": start_pos,
		"spawn_dir": spawn_dir,
		"spacing": 16.0 * worm_scale,
		"scale": worm_scale
	})

func spawn_bouncy() -> void:
	if bouncy_dot_scene == null:
		return
	var spawn_pos = _get_random_spawn_pos()
	var enemy = bouncy_dot_scene.instantiate()
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
