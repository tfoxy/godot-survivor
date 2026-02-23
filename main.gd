extends Node2D
## Centers the game at the viewport so (0,0) is on-screen.
## Wires BulletManager to EnemySpawner so bullets fire when you run the scene.

@onready var _enemy_spawner: Node2D = $EnemySpawner
@onready var _bullet_manager: Node2D = $BulletManager

func _ready() -> void:
	# Wire BulletManager to EnemySpawner (guarantees connection when running)
	if _enemy_spawner.get("bullet_manager") != null:
		_enemy_spawner.bullet_manager = _bullet_manager
	# Defer so viewport size is correct (important for Web)
	await get_tree().process_frame
	var rect: Rect2 = get_viewport().get_visible_rect()
	position = rect.get_center()
