extends Node2D
class_name BulletManager
## Object pool for bullets. Pre-instantiates 2000 bullets; get_bullet() returns an inactive one for reuse.
## Use return_bullet(bullet) to recycle and emit bullet_returned.

const POOL_SIZE: int = 2000
const BULLET_SCENE: PackedScene = preload("res://bullet.tscn")

signal bullet_returned(bullet: Area2D)

var _available_bullets: Array[Area2D] = []


func _ready() -> void:
	_fill_pool()


func _fill_pool() -> void:
	_available_bullets.clear()
	for i in POOL_SIZE:
		var bullet: Area2D = BULLET_SCENE.instantiate() as Area2D
		add_child(bullet)
		bullet.manager = self
		bullet.make_inactive()
		_available_bullets.append(bullet)


## Returns an inactive bullet from the pool, or null if none available.
func get_bullet() -> Area2D:
	if _available_bullets.is_empty():
		return null
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
