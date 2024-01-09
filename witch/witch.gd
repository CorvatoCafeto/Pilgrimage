extends KinematicBody2D

onready var witch_sprite = $Sprite

const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 64 # pixels/sec
const JUMP_SPEED = 200
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1
const SHOOT_TIME_SHOW_WEAPON = 0.2
const FIREBALL = preload("res://fireball/Fireball.tscn")
const DASH_TIME = 1
const GRAVITY = 900
const LEFT = -1
const RIGHT = 1

var GRAVITY_VEC = Vector2(0, GRAVITY)
var BLINK_GRAVITY = 100  # Adjust this value as needed
var character_velocity = Vector2()
var onair_time = 0 #
var on_floor = false
var has_double_jumped = false
var is_cat = false
var dashing = false
var dash_acc = 0

func shoot():
	var fireball = FIREBALL.instance()
	fireball.set_fireball_direction(sign($Position2D.position.x))
	get_parent().add_child(fireball)
	fireball.global_position = $Position2D.global_position #use node for shoot position
	$sound_shoot.play()

func blink():
	character_velocity.x = $Sprite.flip_h ? -500 : 500
	dashing = true
	GRAVITY_VEC = Vector2(0, BLINK_GRAVITY)
	$sound_blink.play()

	if dashing:
		dash_acc += delta
	#if we dashed for longer than our DASH_TIME we stop and reset our accumulator
	if dash_acc >= DASH_TIME:    
		dashing = false
		character_velocity = Vector2(0, 0)
		dash_acc = 0
		GRAVITY_VEC = Vector2(0, GRAVITY)

func transform_to_cat(transform):
	is_cat = transform
	$CollisionShape2D.scale.y = transform ? 0.5 : 1
	$CollisionShape2D.scale.x = transform ? 0.5 : 1
	$sound_cat.play()

func flip_sprite_and_adjust_position(direction):
	$Sprite.flip_h = direction == RIGHT
	if sign($Position2D.position.x) != direction:
		$Position2D.position.x *= -1

func detect_floor():
	if is_on_floor():
		onair_time = 0
		has_double_jumped = false

func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta

	### MOVEMENT ###
	character_velocity += delta * GRAVITY_VEC
	character_velocity = move_and_slide(character_velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	detect_floor()

	if is_on_floor():
		onair_time = 0
		has_double_jumped = false
		#$witch_sprite.animation = "Idle"

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var horizontal_movement = 0
	if Input.is_action_pressed("left"):
		horizontal_movement += LEFT
		flip_sprite_and_adjust_position(LEFT)
	if Input.is_action_pressed("right"):
		horizontal_movement += RIGHT
		flip_sprite_and_adjust_position(RIGHT)
		
		
	horizontal_movement *= WALK_SPEED
	character_velocity.x = lerp(character_velocity.x, horizontal_movement, 0.1)

	# Jumping
	if Input.is_action_just_pressed("up") and (is_on_floor() or (Upgrades.BROOM and !has_double_jumped)):
		character_velocity.y = -JUMP_SPEED
		$sound_jump.play()
		has_double_jumped = !is_on_floor()

	if on_floor and Input.is_action_just_pressed("up"):
		character_velocity.y = -JUMP_SPEED
		$sound_jump.play()
	elif Upgrades.BROOM and !has_double_jumped and Input.is_action_just_pressed("up"):
		character_velocity.y = -JUMP_SPEED
		$sound_jump.play()
		has_double_jumped = true
		
	# Transforming
	if Upgrades.CAT and Input.is_action_just_pressed("down"):
		transform_to_cat(!is_cat)
		
	# Blinking
	if Upgrades.TUNIC and Input.is_action_just_pressed("blink"):
		blink()
			
	# Shooting
	if Upgrades.WAND and !is_cat and Input.is_action_just_pressed("fire"):
		shoot()

	### ANIMATION ###
	var new_anim = "Idle"
	if is_cat:
		new_anim = "Idle_cat"

	if on_floor:
		if character_velocity.x < -SIDING_CHANGE_SPEED:
			#witch_sprite.scale.x = -1
			new_anim = "Walking"
			if is_cat:
				new_anim = "Running_cat"

		if character_velocity.x > SIDING_CHANGE_SPEED:
			#witch_sprite.scale.x = 1
			new_anim = "Walking"
			if is_cat:
				new_anim = "Running_cat"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		#if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		#	witch_sprite.scale.x = -1
			#$witch_sprite.flip_h = true
		#if Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		#	witch_sprite.scale.x = 1
		#	$witch_sprite.flip_h = false

		if character_velocity.y < 0:
			new_anim = "Jumping"
			if is_cat:
				new_anim = "Jumping_cat"
		else:
			new_anim = "Falling"
			if is_cat:
				new_anim = "Falling_cat"

	if new_anim != anim:
		anim = new_anim
		$Sprite.play(anim)
