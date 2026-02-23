extends Area2D
## Bullet script for Object Pooling. Use activate() to show and run, deactivate() to hide and stop.

var _direction: Vector2
var _speed: float
var _active: bool = false


func activate(pos: Vector2, dir: Vector2, speed: float) -> void:
	position = pos
	_direction = dir.normalized()
	_speed = speed
	_active = true
	visible = true
	set_physics_process(true)


func deactivate() -> void:
	_active = false
	visible = false
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _active:
		return
	position += _direction * _speed * delta
