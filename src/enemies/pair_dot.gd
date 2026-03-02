extends Node2D

@export var speed: float = 120.0
@export var survivor_speed: float = 270.0
@export var pair_distance: float = 260.0

var dot_a: Area2D
var dot_b: Area2D
var line_area: Area2D
var line_shape: CollisionShape2D

var player: Node2D
var is_dot_a_dead: bool = false
var is_dot_b_dead: bool = false
var is_independent: bool = false

var growth_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	_setup_nodes()

func _setup_nodes() -> void:
	# Dot A
	dot_a = Area2D.new()
	dot_a.name = "DotA"
	dot_a.position = Vector2(-pair_distance / 2.0, 0)
	dot_a.collision_layer = 1 << 2
	dot_a.collision_mask = (1 << 1) | (1 << 0) # Bullet (L2) and Player (L1)
	var shape_a = CollisionShape2D.new()
	var circle_a = CircleShape2D.new()
	circle_a.radius = 12.0
	shape_a.shape = circle_a
	dot_a.add_child(shape_a)
	add_child(dot_a)
	dot_a.area_entered.connect(_on_dot_a_hit)
	
	# Dot B
	dot_b = Area2D.new()
	dot_b.name = "DotB"
	dot_b.position = Vector2(pair_distance / 2.0, 0)
	dot_b.collision_layer = 1 << 2
	dot_b.collision_mask = (1 << 1) | (1 << 0)
	var shape_b = CollisionShape2D.new()
	var circle_b = CircleShape2D.new()
	circle_b.radius = 12.0
	shape_b.shape = circle_b
	dot_b.add_child(shape_b)
	add_child(dot_b)
	dot_b.area_entered.connect(_on_dot_b_hit)
	
	# Line Area
	line_area = Area2D.new()
	line_area.name = "Line"
	line_area.collision_layer = 1 << 2
	line_area.collision_mask = (1 << 1) | (1 << 0)
	line_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(pair_distance, 4.0)
	line_shape.shape = rect
	line_area.add_child(line_shape)
	add_child(line_area)
	line_area.area_entered.connect(_on_line_hit)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			return
		
	var target_pos = player.global_position
	var move_speed = survivor_speed if is_independent else speed
	
	var dir = (target_pos - global_position).normalized()
	global_position += dir * move_speed * delta
	
	if not is_independent:
		# Rotate so the line (which is on the X-axis) is perpendicular to 'dir'
		# dir.angle() is the angle pointing TOWARDS the player.
		# Adding PI/2.0 (90 degrees) makes the X-axis perpendicular to that direction.
		rotation = dir.angle() + PI / 2.0
		
		# Growing logic
		growth_timer += delta
		if growth_timer >= 0.5:
			growth_timer -= 0.5
			pair_distance *= 1.01
			_update_pair_layout()

func _update_pair_layout() -> void:
	var half_dist = pair_distance / 2.0
	if is_instance_valid(dot_a):
		dot_a.position = Vector2(-half_dist, 0)
	if is_instance_valid(dot_b):
		dot_b.position = Vector2(half_dist, 0)
	if is_instance_valid(line_shape):
		# Update collision shape for the line (hitbox)
		var rect = line_shape.shape as RectangleShape2D
		if rect:
			rect.size = Vector2(pair_distance, 4.0)
	queue_redraw()

func _on_dot_a_hit(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if not is_independent:
			_handle_dot_death(true)
		else:
			queue_free() # Final dot dies
		if area.has_method("deactivate"): area.deactivate()
	elif area.name == "Hitbox" and (area.get_parent().is_in_group("player") or area.is_in_group("player")):
		_on_player_contact()

func _on_dot_b_hit(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if not is_independent:
			_handle_dot_death(false)
		else:
			queue_free() # Final dot dies
		if area.has_method("deactivate"): area.deactivate()
	elif area.name == "Hitbox" and (area.get_parent().is_in_group("player") or area.is_in_group("player")):
		_on_player_contact()

func _on_line_hit(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		# Line destroys bullets but doesn't die
		if area.has_method("deactivate"): area.deactivate()
	elif area.name == "Hitbox" and (area.get_parent().is_in_group("player") or area.is_in_group("player")):
		_on_player_contact()

func _handle_dot_death(is_a: bool) -> void:
	if is_independent:
		queue_free()
		return

	var survivor = dot_b if is_a else dot_a
	var dead_dot = dot_a if is_a else dot_b
	
	is_dot_a_dead = is_a
	is_dot_b_dead = not is_a
	
	# Transfer survivor to center
	var old_survivor_pos = survivor.global_position
	global_position = old_survivor_pos
	survivor.position = Vector2.ZERO
	
	# Cleanup
	dead_dot.queue_free()
	if is_instance_valid(line_area):
		line_area.queue_free()
	
	is_independent = true
	queue_redraw()

func _on_player_contact() -> void:
	var main_scene = get_tree().current_scene
	if main_scene.has_method("game_over"):
		main_scene.game_over()
	InputManager.reset()
	get_tree().reload_current_scene()

func _draw() -> void:
	var half_dist = pair_distance / 2.0
	
	if not is_independent:
		# Draw line
		draw_line(Vector2(-half_dist, 0), Vector2(half_dist, 0), Color.BLUE_VIOLET, 4.0)
		# Draw both dots
		draw_circle(Vector2(-half_dist, 0), 12.0, Color.DEEP_SKY_BLUE)
		draw_circle(Vector2(half_dist, 0), 12.0, Color.DEEP_SKY_BLUE)
	else:
		# Independent mode: Parent is now centered on the survivor dot
		draw_circle(Vector2.ZERO, 12.0, Color.ORANGE_RED) # Change color to indicate rage!
