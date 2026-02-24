extends Node2D
## Fires radial bullet patterns on a timer. Assign BulletManager in the inspector (e.g. sibling ../BulletManager).

const Globals = preload("res://globals.gd")
const BulletManagerScript = preload("res://bullet_manager.gd")

@export var bullet_manager_path: NodePath
var bullet_manager: BulletManagerScript
@onready var timer: Timer = $Timer

@export var bullet_count: int = 12
@export var radius: float = 40.0
@export var bullet_speed: float = 300.0
@export var move_speed: float = 250.0
@export var bullet_cooldown: float = 2
@export var player_size: float = 8.0


@export var grid_extent: float = Globals.GRID_EXTENT


func _physics_process(delta: float) -> void:
	var move_dir: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_dir.y += 1.0
	if move_dir != Vector2.ZERO:
		position += move_dir.normalized() * move_speed * delta
	
	position.x = clamp(position.x, -grid_extent + player_size, grid_extent - player_size)
	position.y = clamp(position.y, -grid_extent + player_size, grid_extent - player_size)

func _ready() -> void:
	if bullet_manager_path:
		bullet_manager = get_node(bullet_manager_path) as BulletManagerScript
	timer.wait_time = bullet_cooldown
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


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
	fire_radial_pattern(bullet_count, radius)


func _draw() -> void:
	draw_circle(Vector2.ZERO, player_size, Color.ORANGE_RED)
