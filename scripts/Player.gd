extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@export var gravity = 1000.0
@export var walk_speed = 200
@export var jump_speed = -500
@export var dash_speed = 600
@export var dash_duration = 0.15
@export var double_tap_window = 0.25
@export var dash_cooldown = 0.8
@export var max_jumps = 2

var _dash_timer := 0.0
var _dash_direction := 0
var _tap_clock := 0.0
var _last_tap_time := {"left": -1.0, "right": -1.0}
var _dash_cooldown_timer := 0.0
var _jumps_left := 0

func _physics_process(delta):
	_update_timers(delta)
	velocity.y += gravity * delta

	if is_on_floor():
		_jumps_left = max_jumps - 1

	_handle_dash_input()
	if _apply_dash(delta):
		return

	_handle_jump_input()
	_handle_horizontal_input()
	_update_animation()
	move_and_slide()

func _start_slide(direction: int) -> void:
	_dash_direction = direction
	_dash_timer = dash_duration
	_dash_cooldown_timer = dash_cooldown

func _update_timers(delta: float) -> void:
	_tap_clock += delta
	_dash_cooldown_timer = max(_dash_cooldown_timer - delta, 0.0)

func _handle_dash_input() -> void:
	if Input.is_action_just_pressed("ui_left"):
		if _dash_cooldown_timer == 0.0 and _tap_clock - _last_tap_time["left"] <= double_tap_window:
			_start_slide(-1)
		_last_tap_time["left"] = _tap_clock
	elif Input.is_action_just_pressed("ui_right"):
		if _dash_cooldown_timer == 0.0 and _tap_clock - _last_tap_time["right"] <= double_tap_window:
			_start_slide(1)
		_last_tap_time["right"] = _tap_clock

func _apply_dash(delta: float) -> bool:
	if _dash_timer <= 0.0:
		return false
	_dash_timer -= delta
	velocity.x = _dash_direction * dash_speed
	velocity.y = 0
	sprite.flip_h = _dash_direction < 0
	sprite.play("slide")
	move_and_slide()
	return true

func _handle_jump_input() -> void:
	if not Input.is_action_just_pressed("ui_up"):
		return
	if is_on_floor():
		velocity.y = jump_speed
		_jumps_left = max_jumps - 1
	elif _jumps_left > 0:
		velocity.y = jump_speed
		_jumps_left -= 1

func _handle_horizontal_input() -> void:
	var speed = walk_speed
	if Input.is_action_pressed("ui_down") and is_on_floor():
		speed = 100

	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		sprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
		sprite.flip_h = false
	else:
		velocity.x = 0

func _update_animation() -> void:
	if _dash_timer > 0.0:
		return
	if Input.is_action_pressed("ui_down") and is_on_floor():
		sprite.play("crouch")
		return
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		elif velocity.y > 0:
			sprite.play("fall")
		return
	if abs(velocity.x) > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
