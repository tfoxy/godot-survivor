extends CharacterBody2D
class_name Enemy

@export var speed: float = 100.0

var player: Node2D

func _ready() -> void:
	add_to_group("enemy")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	if has_node("Hitbox"):
		get_node("Hitbox").area_entered.connect(_on_hitbox_area_entered)
	
	_setup_enemy()

# To be overridden by subclasses
func _setup_enemy() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if player != null and is_instance_valid(player):
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		move_and_slide()

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
	InputManager.reset()
	get_tree().reload_current_scene()
