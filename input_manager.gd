extends Node
## Centralized input handler for keyboard, gamepad, and touch (virtual joystick).
## Registered as an AutoLoad singleton named "InputManager".
## Access the unified movement direction via InputManager.move_dir.

## The normalized movement direction aggregated from all input sources.
var move_dir: Vector2 = Vector2.ZERO

## Raw value coming from the VirtualJoystickPlus (updated via signal).
var _joystick_value: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	var dir := Vector2.ZERO

	# --- Keyboard ---
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1.0

	# --- Gamepad (left stick) ---
	var joy_axis_left := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	# Apply a small dead-zone to avoid drift
	if joy_axis_left.length() > 0.15:
		dir += joy_axis_left

	# --- Gamepad (right stick) ---
	var joy_axis_right := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	# Apply a small dead-zone to avoid drift
	if joy_axis_right.length() > 0.15:
		dir += joy_axis_right

	# --- Gamepad (D-pad) ---
	if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT):
		dir.x -= 1.0
	if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT):
		dir.x += 1.0
	if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_UP):
		dir.y -= 1.0
	if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_DOWN):
		dir.y += 1.0

	# --- Touch (Virtual Joystick) ---
	dir += _joystick_value

	# Normalize so diagonal movement isn't faster, but clamp to allow
	# partial analog input from stick / joystick.
	move_dir = dir.limit_length(1.0)


## Connected to VirtualJoystickPlus.analogic_changed signal.
func _on_joystick_changed(
		value: Vector2,
		_distance: float,
		_angle: float,
		_angle_cw: float,
		_angle_ccw: float
	) -> void:
	_joystick_value = value
