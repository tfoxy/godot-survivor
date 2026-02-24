extends Node2D

@onready var _player: Node2D = $Player
@onready var _bullet_manager: Node2D = $BulletManager

func _ready() -> void:
	if _player.get("bullet_manager") != null:
		_player.bullet_manager = _bullet_manager
	await get_tree().process_frame
	var rect: Rect2 = get_viewport().get_visible_rect()
	position = rect.get_center()
