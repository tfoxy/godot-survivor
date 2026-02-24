extends CharacterBody2D
class_name Monster

@export var speed: float = 100.0

var player: Node2D

func _ready() -> void:
	$Hitbox.area_entered.connect(_on_area_entered)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if player != null and is_instance_valid(player):
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		if area.has_method("deactivate"):
			area.deactivate()
		queue_free()
	elif area.name == "Hitbox" and area.get_parent().is_in_group("player"):
		var main_scene = get_tree().current_scene
		if main_scene.has_method("game_over"):
			main_scene.game_over()
		InputManager.reset()
		get_tree().reload_current_scene()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color.WEB_GREEN)
