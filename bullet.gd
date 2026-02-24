extends Area2D
## Bullet script for Object Pooling. Use activate() to show and run, deactivate() to hide and stop.

const Globals = preload("res://globals.gd")

var _direction: Vector2
var _speed: float
var _active: bool = false
var manager: Node2D

func activate(_pos: Vector2, dir: Vector2, speed: float) -> void:
	_direction = dir.normalized()
	_speed = speed
	_active = true
	visible = true
	set_physics_process(true)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)


func make_inactive() -> void:
	_active = false
	visible = false
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func deactivate() -> void:
	if manager:
		manager.return_bullet(self)
	else:
		make_inactive()


func _physics_process(delta: float) -> void:
	if not _active:
		return
	position += _direction * _speed * delta

	var limit := Globals.GRID_EXTENT
	if position.x < -limit or position.x > limit \
			or position.y < -limit or position.y > limit:
		deactivate()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color.WHITE)
