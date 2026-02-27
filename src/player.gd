extends Node2D
## Fires radial bullet patterns on a timer. Assign BulletManager in the inspector (e.g. sibling ../BulletManager).

const BulletManagerScript = preload("res://src/bullet_manager.gd")

@export var bullet_manager_path: NodePath
var bullet_manager: BulletManagerScript
@onready var timer: Timer = $Timer

@export var player_size: float = 8
@export var move_speed: float = 250
@export var bullet_count: int = 8
@export var bullet_speed: float = 300
@export var bullet_cooldown: float = 2
@export var bullet_distance: float = player_size * 2


@export var grid_extent: float = Globals.GRID_EXTENT

func update_grid_extent(new_extent: float) -> void:
	grid_extent = new_extent
	# Instantly clamp player to new bounds if they were outside (though grid is expanding, so this is just safety)
	position.x = clamp(position.x, -grid_extent + player_size, grid_extent - player_size)
	position.y = clamp(position.y, -grid_extent + player_size, grid_extent - player_size)


func _physics_process(delta: float) -> void:
	var move_dir: Vector2 = InputManager.move_dir
	if move_dir != Vector2.ZERO:
		position += move_dir * move_speed * delta
	
	position.x = clamp(position.x, -grid_extent + player_size, grid_extent - player_size)
	position.y = clamp(position.y, -grid_extent + player_size, grid_extent - player_size)

func _ready() -> void:
	if bullet_manager_path:
		bullet_manager = get_node(bullet_manager_path) as BulletManagerScript
	timer.wait_time = bullet_cooldown
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	var reduction_timer = Timer.new()
	reduction_timer.wait_time = 20.0
	reduction_timer.autostart = true
	reduction_timer.timeout.connect(_on_cooldown_reduction)
	add_child(reduction_timer)
	
	var count_timer = Timer.new()
	count_timer.wait_time = 60.0
	count_timer.autostart = true
	count_timer.timeout.connect(_on_count_increase)
	add_child(count_timer)
	
	if has_node("Hitbox"):
		$Hitbox.area_entered.connect(_on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("hostile_bullet"):
		var main_scene = get_tree().current_scene
		if main_scene.has_method("game_over"):
			main_scene.game_over()
		InputManager.reset()
		get_tree().reload_current_scene()

func _on_cooldown_reduction() -> void:
	bullet_cooldown *= 0.9
	timer.wait_time = bullet_cooldown
	print("Bullet cooldown reduced to: ", bullet_cooldown)

func _on_count_increase() -> void:
	bullet_count = int(bullet_count * 1.5)
	print("Bullet count increased to: ", bullet_count)


func fire_radial_pattern(bullet_count_val: int, radius_val: float) -> void:
	if bullet_manager == null:
		return
	var angle_step: float = TAU / float(bullet_count_val)
	for i in bullet_count_val:
		var angle: float = i * angle_step
		var dir: Vector2 = Vector2.from_angle(angle)
		var spawn_pos: Vector2 = global_position + dir * radius_val
		var bullet: Area2D = bullet_manager.get_bullet()
		if bullet == null:
			continue
		bullet.global_position = spawn_pos
		bullet.activate(spawn_pos, dir, bullet_speed)


func _on_timer_timeout() -> void:
	fire_radial_pattern(bullet_count, bullet_distance)


func _draw() -> void:
	draw_circle(Vector2.ZERO, player_size, Color.ORANGE_RED)
