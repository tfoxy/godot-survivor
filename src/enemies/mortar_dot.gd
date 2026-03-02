extends Area2D

@export var mortar_interval: float = 3.0
@export var impact_radius: float = 80.0
@export var fill_time: float = 2.0

var player: Node2D
var timer: float = 0.0
var age: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	# Layer 3 = Enemies
	collision_layer = 1 << 2
	# Scan Player (L1) and Bullets (L2)
	collision_mask = (1 << 0) | (1 << 1)
	
	area_entered.connect(_on_hitbox_area_entered)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	# Initial shot
	_fire_mortar()

func _physics_process(delta: float) -> void:
	timer += delta
	age += delta
	if timer >= mortar_interval:
		timer -= mortar_interval
		_fire_mortar()

func _fire_mortar() -> void:
	if not is_instance_valid(player): return
	
	# Number of circles increases by 1 every 4 seconds of dot survival
	var circle_count = 5 + int(age / mortar_interval)
	
	# Spawn indicators near the player
	for i in range(circle_count):
		var offset = Vector2(randf_range(-500, 500), randf_range(-500, 500))
		var impact_pos = player.global_position + offset
		_spawn_indicator(impact_pos)

func _spawn_indicator(pos: Vector2) -> void:
	var indicator = MortarIndicator.new()
	indicator.radius = impact_radius
	indicator.duration = fill_time
	# IMPORTANT: Add to parent FIRST so global_position works correctly
	get_parent().add_child(indicator)
	indicator.global_position = pos

func handle_hit() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if area.has_method("deactivate"): area.deactivate()
		handle_hit()

func _draw() -> void:
	# Make the mortar dot visible
	draw_circle(Vector2.ZERO, 20.0, Color.GOLD)
	draw_circle(Vector2.ZERO, 15.0, Color.BLACK)
	draw_circle(Vector2.ZERO, 8.0, Color.GOLD)

# Inner class for the mortar indicator logic
class MortarIndicator extends Node2D:
	var radius: float = 80.0
	var duration: float = 2.0
	var elapsed: float = 0.0
	var player: Node2D
	
	func _ready() -> void:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
		
		if elapsed >= duration:
			_explode()
			queue_free()
			
	func _explode() -> void:
		if is_instance_valid(player):
			var dist = global_position.distance_to(player.global_position)
			if dist < radius:
				# Player hit
				var main_scene = get_tree().current_scene
				if main_scene.has_method("game_over"):
					main_scene.game_over()
				InputManager.reset()
				get_tree().reload_current_scene()
				
	func _draw() -> void:
		# Draw outer border - made thicker for visibility at high zoom
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color.GOLD, 12.0)
		
		# Draw filling circle
		var fill_percent = elapsed / duration
		draw_circle(Vector2.ZERO, radius * fill_percent, Color(1, 0.84, 0, 0.4))
