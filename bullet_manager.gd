extends Node2D
class_name BulletManager

const INITIAL_POOL_SIZE: int = 100
const BULLET_SCENE: PackedScene = preload("res://bullet.tscn")

signal bullet_returned(bullet: Area2D)

var _available_bullets: Array[Area2D] = []


func _ready() -> void:
	_fill_pool(INITIAL_POOL_SIZE)


func _fill_pool(amount: int) -> void:
	for i in amount:
		var bullet: Area2D = _create_new_bullet()
		_available_bullets.append(bullet)

func _create_new_bullet() -> Area2D:
	var bullet: Area2D = BULLET_SCENE.instantiate() as Area2D
	add_child(bullet)
	bullet.manager = self
	bullet.make_inactive()
	return bullet


## Returns an inactive bullet from the pool, creating a new one if none available.
func get_bullet() -> Area2D:
	if _available_bullets.is_empty():
		var new_bullet: Area2D = _create_new_bullet()
		return new_bullet
	var bullet: Area2D = _available_bullets.pop_back()
	return bullet


## Recycles a bullet (deactivates it) and emits bullet_returned. Call when the bullet is done.
func return_bullet(bullet: Area2D) -> void:
	if bullet == null:
		return
	if not _available_bullets.has(bullet):
		if bullet.has_method("make_inactive"):
			bullet.make_inactive()
		else:
			bullet.deactivate()
		_available_bullets.append(bullet)
		bullet_returned.emit(bullet)
