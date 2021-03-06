extends KinematicBody2D


signal player_hit(body)
signal player_area_hit(area)
signal enemy_hit(body)

const GRAVITY = 900.0
const JUMP_SPEED = 520
const BEGINNING_CAMERA_OFFSET = 0.84

var run_speed := 200
var _velocity := Vector2()
var shake_intensity := 0.0
var is_airborne := false
var double_jump_enabled := false
var jump_count := 0
var melee_enabled := false
var prev_anim : String
var current_melee_collision : CollisionShape2D = melee_collision_right
var projectile_enabled := false

onready var player_sprite := $AnimatedSprite
onready var player_shape := $PlayerShape
onready var player_shape_slide := $PlayerShapeSlide
onready var melee_collision_right := $MeleeAreaRight/MeleeAreaRightShape
onready var melee_collision_left := $MeleeAreaLeft/MeleeAreaLeftShape
onready var fireball_projectile := preload("res://src/Fireball.tscn")
onready var fireball_position := $FireballPosition
onready var fireball_player := $FireballSound
onready var player_cam := $PlayerCam
onready var shake_timer := $ShakeTime
onready var jump_player := $JumpSound
onready var cogwheels := $Cogwheels


func _ready():
	player_cam.offset_h = BEGINNING_CAMERA_OFFSET
	melee_collision_left.disabled = true
	melee_collision_right.disabled = true


func _process(_delta):
	camera_shake()


func _physics_process(delta):
	_velocity.y += GRAVITY * delta
	
	if melee_enabled and Input.is_action_just_pressed("melee"):
		attack_melee(player_sprite.animation if player_sprite.animation != "melee" else "idle")
	
	if projectile_enabled and Input.is_action_just_pressed("projectile"):
		attack_projectile(player_sprite.animation if player_sprite.animation != "projectile" else "idle")
	
	if Input.is_action_pressed("move_right"):
		player_sprite.flip_h = false
		_velocity.x = run_speed
		current_melee_collision = melee_collision_right
		if sign(fireball_position.position.x) == -1:
			fireball_position.position.x *= -1
	elif Input.is_action_pressed("move_left"):
		player_sprite.flip_h = true
		_velocity.x = -run_speed
		current_melee_collision = melee_collision_left
		if sign(fireball_position.position.x) == 1:
			fireball_position.position.x *= -1
	elif player_sprite.animation == "slide":
		if player_sprite.flip_h == true:
			_velocity.x = -run_speed
		else:
			_velocity.x = run_speed
	else:
		_velocity.x = 0
	
	if Input.is_action_just_pressed("slide"):
		player_slide(player_sprite.animation if player_sprite.animation != "slide" else "idle")
	
	if player_sprite.animation == "melee":
		pass
	elif player_sprite.animation == "projectile":
		pass
	elif player_sprite.animation == "slide":
		pass
	elif is_on_floor():
		player_sprite.animation = "run" if abs(_velocity.x) > 0 else "idle"
	else:
		player_sprite.animation = "idle" if _velocity.y > 0 else "jump"
	if _velocity.x or _velocity.y != 0:
		player_sprite.play()
	else:
		player_sprite.stop()
	
	check_landing()
	
	if !double_jump_enabled and is_on_floor() and Input.is_action_just_pressed("jump"):
		_velocity.y = -JUMP_SPEED
		jump_player.play()
	if double_jump_enabled and Input.is_action_just_pressed("jump"):
		if jump_count < 1:
			jump_count+=1
			_velocity.y = -JUMP_SPEED
			jump_player.play()
	if is_on_floor():
		jump_count = 0
	
	_velocity = move_and_slide(_velocity, Vector2.UP)


func player_slide(current_anim):
	prev_anim = current_anim
	player_shape.disabled = true
	player_shape_slide.disabled = false
	player_sprite.animation = "slide"
	player_sprite.play()


func attack_melee(current_anim):
	prev_anim = current_anim
	current_melee_collision.disabled = false
	player_sprite.animation = "melee"
	player_sprite.play()

func attack_projectile(current_anim):
	prev_anim = current_anim
	var fireball = fireball_projectile.instance()
	fireball.position = fireball_position.global_position
	player_sprite.animation = "projectile"
	player_sprite.play()
	fireball_player.play()
	get_parent().add_child(fireball)
	fireball.set_fireball_direction(sign(fireball_position.position.x))
	fireball.connect("enemy_hit_projectile", self, "on_enemy_hit_projectile")


func _on_AnimatedSprite_animation_finished():
	if player_sprite.animation == "melee":
		player_sprite.animation = prev_anim
		melee_collision_left.disabled = true
		melee_collision_right.disabled = true
	if player_sprite.animation == "projectile":
		player_sprite.animation = prev_anim
	if player_sprite.animation == "slide":
		player_sprite.animation = prev_anim
		player_shape_slide.disabled = true
		player_shape.disabled = false


func explode_cogwheels():
	$Cogwheels.one_shot = true
	$Cogwheels.emitting = true


func check_landing():
	if not is_on_floor():
		is_airborne = true
	
	if is_on_floor() and is_airborne:
		is_airborne = false
		start_shake(0.25)


func start_shake(duration):
	shake_timer.wait_time = duration
	shake_timer.start()
	shake_intensity = 3.0


func camera_shake():
	player_cam.offset = Vector2(rand_range(-1.0, 1.0) * shake_intensity, rand_range(-1.0, 1.0) * shake_intensity)


func _on_PlayerArea_body_shape_entered(_body_id, body, _body_shape, _area_shape):
	emit_signal("player_hit", body)


func _on_PlayerArea_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	emit_signal("player_area_hit", area)


func _on_melee_collision_entered(_body_id, body, _body_shape, _area_shape):
	if body.is_in_group("enemies"):
		emit_signal("enemy_hit", body)


func on_enemy_hit_projectile(body):
	emit_signal("enemy_hit", body)


func _on_ShakeTime_timeout():
	shake_intensity = 0


func enable_double_jump():
	double_jump_enabled = true
	player_cam.limit_top = -320
	player_cam.limit_bottom = 620
	player_cam.drag_margin_top = 0.5
	player_cam.drag_margin_v_enabled = true


func enable_melee():
	melee_enabled = true


func enable_projectile():
	projectile_enabled = true
