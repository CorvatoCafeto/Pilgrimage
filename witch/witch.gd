extends KinematicBody2D

onready var witch_sprite = $Sprite

var sound_jump = preload("res://witch/sfx/jump.wav")
var sound_morph = preload("res://witch/sfx/cat.wav")
var sound_shoot = preload("res://fireball/fireball.wav")
var sound_blink = preload("res://witch/sfx/blink.wav")

const FLOOR_DIRECTION = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_AIRBORNE_TIME = 0.1
const WALKING_SPEED = 64 # pixels/sec
const JUMPING_SPEED = 200
const SIDE_CHANGE_SPEED = 10
const PROJECTILE_SPEED = 1
const SHOOT_TIME_SHOW_WEAPON = 0.2
const FIREBALL_SCENE = preload("res://fireball/Fireball.tscn")
const BLINK_DURATION = 1
const GRAVITY = 900
const DIRECTION_LEFT = -1
const DIRECTION_RIGHT = 1

var gravity_vector = Vector2(0, GRAVITY)
var blink_gravity = 100  # Adjust this value as needed
var character_velocity = Vector2()
var airborne_time = 0
var is_on_floor = false
var has_double_jumped = false
var is_transformed_to_cat = false
var is_blinking = false
var blink_duration = 0
var anim = ""

func shoot():
	var fireball = FIREBALL_SCENE.instance()
	fireball.set_fireball_direction(sign($Position2D.position.x))
	get_parent().add_child(fireball)
	fireball.global_position = $Position2D.global_position #use node for shoot position
	$AudioStreamPlayer.stream = sound_shoot
	$AudioStreamPlayer.play()

func stop_blinking():
	is_blinking = false
	character_velocity = Vector2(0, 0)
	blink_duration = 0
	gravity_vector = Vector2(0, GRAVITY)

func blink():
	character_velocity.x = (-500 if $Sprite.flip_h else 500)
	is_blinking = true
	gravity_vector = Vector2(0, blink_gravity)
	$AudioStreamPlayer.stream = sound_blink
	$AudioStreamPlayer.play()

func transform_to_cat(transform):
	is_transformed_to_cat = transform
	$CollisionShape2D.scale.y = 0.5 if transform else 1
	$CollisionShape2D.scale.x = 0.5 if transform else 1
	$AudioStreamPlayer.stream = sound_morph
	$AudioStreamPlayer.play()

func flip_sprite_and_adjust_position(direction):
	$Sprite.flip_h = direction == DIRECTION_LEFT
	if sign($Position2D.position.x) != direction:
		$Position2D.position.x *= -1

func detect_floor():
	if is_on_floor():
		airborne_time = 0
		has_double_jumped = false

func _physics_process(delta):
	#increment counters

	airborne_time += delta
#	shoot_time += delta

	### MOVEMENT ###
	character_velocity += delta * gravity_vector
	character_velocity = move_and_slide(character_velocity, FLOOR_DIRECTION, SLOPE_SLIDE_STOP)
	detect_floor()

	if is_on_floor():
		airborne_time = 0
		has_double_jumped = false
		#$witch_sprite.animation = "Idle"

	is_on_floor = airborne_time < MIN_AIRBORNE_TIME

	### CONTROL ###

	# Horizontal Movement
	var horizontal_movement = 0
	if Input.is_action_pressed("left"):
		horizontal_movement += DIRECTION_LEFT
		flip_sprite_and_adjust_position(DIRECTION_LEFT)
	if Input.is_action_pressed("right"):
		horizontal_movement += DIRECTION_RIGHT
		flip_sprite_and_adjust_position(DIRECTION_RIGHT)

	horizontal_movement *= WALKING_SPEED
	character_velocity.x = lerp(character_velocity.x, horizontal_movement, 0.1)

	# Jumping
	if Input.is_action_just_pressed("up") and (is_on_floor() or (Upgrades.BROOM and !has_double_jumped)):
		character_velocity.y = -JUMPING_SPEED
		$AudioStreamPlayer.stream = sound_jump
		$AudioStreamPlayer.play()
		has_double_jumped = !is_on_floor()
			
	# Transforming
	if Upgrades.CAT and Input.is_action_just_pressed("down"):
		transform_to_cat(!is_transformed_to_cat)
		
	# Blinking
	if Upgrades.TUNIC and Input.is_action_just_pressed("blink"):
		blink()
	
	if is_blinking:
		blink_duration += delta
	#if we blinked for longer than our BLINK_DURATION we stop and reset our accumulator
	if blink_duration >= BLINK_DURATION:    
		is_blinking = false
		character_velocity = Vector2(0, 0)
		blink_duration = 0
		gravity_vector = Vector2(0, GRAVITY)
			
	# Shooting
	if Upgrades.WAND and !is_transformed_to_cat and Input.is_action_just_pressed("fire"):
		shoot()

	### ANIMATION ###
	var new_anim = "Idle"
	if is_transformed_to_cat:
		new_anim = "Idle_cat"

	if is_on_floor:
		if character_velocity.x < -SIDE_CHANGE_SPEED:
			#witch_sprite.scale.x = -1
			new_anim = "Walking"
			if is_transformed_to_cat:
				new_anim = "Running_cat"

		if character_velocity.x > SIDE_CHANGE_SPEED:
			#witch_sprite.scale.x = 1
			new_anim = "Walking"
			if is_transformed_to_cat:
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
			if is_transformed_to_cat:
				new_anim = "Jumping_cat"
		else:
			new_anim = "Falling"
			if is_transformed_to_cat:
				new_anim = "Falling_cat"

	if new_anim != anim:
		anim = new_anim
		$Sprite.play(anim)
