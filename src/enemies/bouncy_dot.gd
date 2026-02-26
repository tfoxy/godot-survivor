extends "res://src/enemies/enemy.gd"
class_name BouncyDot

const Globals = preload("res://src/globals.gd")

var move_direction: Vector2 = Vector2.ZERO
var state: String = "INITIAL" # INITIAL, BOUNCING

var health: int = 100
var current_radius: float = 30.0

func _setup_enemy() -> void:
	speed = 150.0
	state = "INITIAL"
	# Make shapes unique so we don't resize every BouncyDot at once
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	if has_node("Hitbox/CollisionShape2D"):
		$Hitbox/CollisionShape2D.shape = $Hitbox/CollisionShape2D.shape.duplicate()

func _physics_process(_delta: float) -> void:
	if state == "INITIAL":
		# Move towards the player initially until first bounce
		if player != null and is_instance_valid(player):
			move_direction = position.direction_to(player.position)
			state = "BOUNCING"
	
	velocity = move_direction * speed
	move_and_slide()
	
	# Check for grid bounds to bounce (using position relative to Main)
	var limit = Globals.GRID_EXTENT
	var bounced = false
	
	if position.x <= -limit:
		position.x = - limit + 2
		bounced = true
	elif position.x >= limit:
		position.x = limit - 2
		bounced = true
		
	if position.y <= -limit:
		position.y = - limit + 2
		bounced = true
	elif position.y >= limit:
		position.y = limit - 2
		bounced = true
		
	if bounced:
		_recalculate_direction()

func _recalculate_direction() -> void:
	if player != null and is_instance_valid(player):
		move_direction = position.direction_to(player.position)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if not area.get("is_hostile"):
			health -= 1
			current_radius = 15.0 + (15.0 * health / 100.0)
			
			if has_node("CollisionShape2D"):
				$CollisionShape2D.shape.radius = current_radius
			if has_node("Hitbox/CollisionShape2D"):
				$Hitbox/CollisionShape2D.shape.radius = current_radius
			
			queue_redraw()
			
			if health <= 0:
				queue_free()
				return
			
			# Bounce the bullet
			area.set("is_hostile", true)
			if area.has_method("set_hostile"):
				area.set_hostile()
			if area.has_method("flip_direction"):
				area.flip_direction()
	
	elif area.name == "Hitbox" and area.get_parent().is_in_group("player"):
		_on_player_contact()

func _draw() -> void:
	# Bouncy dot is a pulsing purple circle?
	draw_circle(Vector2.ZERO, current_radius, Color.PURPLE)
	draw_circle(Vector2.ZERO, 15.0, Color.MAGENTA)
