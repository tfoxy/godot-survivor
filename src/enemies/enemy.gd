extends Area2D
class_name Enemy

@export var speed: float = 100.0
var velocity: Vector2 = Vector2.ZERO

var player: Node2D
var target: Node2D

func _ready() -> void:
	add_to_group("enemy")
	
	# Performance: Configure layers and masks
	# Layer 1 = Player, Layer 2 = Bullets, Layer 3 = Enemies
	collision_layer = 1 << 2 # Layer 3
	# Scan Player (L1), Bullets (L2), and other Enemies (L3) for separation
	collision_mask = (1 << 0) | (1 << 1) | (1 << 2)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		target = player
	
	# Connect our own area_entered signal
	area_entered.connect(_on_hitbox_area_entered)
	
	_setup_enemy()

# To be overridden by subclasses
func _setup_enemy() -> void:
	pass

var _sep_timer: float = 0.0
var _push_vector: Vector2 = Vector2.ZERO
@export var avoidance_radius: float = 40.0
@export var max_push: float = 200.0

func get_separation_vector(delta: float) -> Vector2:
	# Optimized separation logic: Update push vector periodically, not every frame
	_sep_timer += delta
	if _sep_timer > 0.1: # 10 times per second
		_sep_timer = 0.0
		_push_vector = Vector2.ZERO
		var overlaps = get_overlapping_areas()
		var count = 0
		var avoid_sq = avoidance_radius * avoidance_radius
		
		for neighbor in overlaps:
			if neighbor.is_in_group("enemy") and neighbor != self:
				var diff = global_position - neighbor.global_position
				var dist_sq = diff.length_squared()
				
				if dist_sq < avoid_sq:
					if dist_sq < 1.0: # Prevent division by near-zero
						diff = Vector2(randf() - 0.5, randf() - 0.5).normalized()
						dist_sq = 1.0
					
					# Force decreases with distance, capped to avoid "teleporting"
					var force = (diff / dist_sq) * 500.0
					_push_vector += force
					count += 1
					if count > 8: break
		
		# Cap the total push vector
		if _push_vector.length() > max_push:
			_push_vector = _push_vector.normalized() * max_push
			
	return _push_vector

func _physics_process(delta: float) -> void:
	var follow_target = target if (target != null and is_instance_valid(target)) else player
	
	# Following logic
	var move_vec = Vector2.ZERO
	if follow_target != null and is_instance_valid(follow_target):
		move_vec = global_position.direction_to(follow_target.global_position)
	
	velocity = (move_vec * speed) + get_separation_vector(delta)
	global_position += velocity * delta

func handle_hit() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if area.has_method("deactivate"):
			area.deactivate()
		handle_hit()
	elif area.name == "Hitbox" and area.get_parent().is_in_group("player"):
		_on_player_contact()

func _on_player_contact() -> void:
	var main_scene = get_tree().current_scene
	if main_scene.has_method("game_over"):
		main_scene.game_over()
