extends CharacterBody2D

@export var patrol_range: float = 140.0
@export var speed: float = 80.0
@export var spawn_grace: float = 0.6
@export var gravity: float = 1000.0
@export var max_fall_speed: float = 1200.0

const WIN_SCENE_PATH: String = "res://scenes/Win.tscn"
const LOSE_SCENE_PATH: String = "res://scenes/Lose.tscn"

var _direction: int = -1
var _origin_x: float = 0.0
var _origin_y: float = 0.0
var _resolved: bool = false
var _grace_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var loop_player: AudioStreamPlayer2D = $LoopPlayer
@onready var hit_player: AudioStreamPlayer2D = $HitPlayer

func _ready() -> void:
	_origin_x = global_position.x
	_origin_y = global_position.y
	_grace_timer = spawn_grace
	if loop_player.stream is AudioStreamOggVorbis:
		loop_player.stream.loop = true
	sprite.play("walk")
	if not loop_player.playing:
		loop_player.play()

func _physics_process(delta: float) -> void:
	velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
	velocity.x = float(_direction) * speed
	move_and_slide()

	var offset := global_position.x - _origin_x
	if abs(offset) > patrol_range or is_on_wall():
		_direction *= -1
		offset = clamp(offset, -patrol_range, patrol_range)
	velocity.x = float(_direction) * speed

	sprite.flip_h = _direction < 0

	if _grace_timer > 0.0:
		_grace_timer = max(_grace_timer - delta, 0.0)
		return

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		if col == null:
			continue
		var collider := col.get_collider()
		if collider == null:
			continue
		if not (collider is CharacterBody2D):
			continue
		if _resolved:
			return
		if collider.has_method("is_dashing") and collider.is_dashing():
			_die()
			return
		if collider.has_method("hit_by_zombie"):
			collider.hit_by_zombie(global_position)
		if not hit_player.playing:
			hit_player.play()
		_resolved = true
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_file(LOSE_SCENE_PATH)

func _die() -> void:
	if _resolved:
		return
	_resolved = true
	loop_player.stop()
	hit_player.play()
	sprite.play("idle")
	collision_layer = 0
	collision_mask = 0
	await get_tree().create_timer(0.35).timeout
	get_tree().change_scene_to_file(WIN_SCENE_PATH)
