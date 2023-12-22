extends KinematicBody2D

var GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 64 # pixels/sec
const JUMP_SPEED = 200
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1
const SHOOT_TIME_SHOW_WEAPON = 0.2

const FIREBALL = preload("res://fireball/Fireball.tscn")

var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var has_double_jumped = false
var shoot_time=99999 #time since last shot

var anim=""

var cat_form = preload("res://witch/cat.png")
var is_cat = false
var human_form = preload("res://witch/witch1616.png")


#cache the sprite here for fast access (we will set scale to flip it often)
onready var witch_sprite = $witch_sprite

#dash variables
var dashing = false
const DASH_TIME = 1 #dash for one second
var dash_acc = 0 #here we count up the time while dashing until we reach DASH_TIME


func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta

	### MOVEMENT ###

	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0
		has_double_jumped = false
		#$witch_sprite.animation = "Idle"

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("left"):
		target_speed += -1
		$Sprite.flip_h = true
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	if Input.is_action_pressed("right"):
		target_speed +=  1
		$Sprite.flip_h = false
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1
		
		
	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("up"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()
	elif Upgrades.BROOM and !has_double_jumped and Input.is_action_just_pressed("up"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()
		has_double_jumped = true
		
	# Transforming
	if Upgrades.CAT:
		if !is_cat and Input.is_action_just_pressed("down"):
			is_cat = true
			$CollisionShape2D.scale.y = 0.5
			$CollisionShape2D.scale.x = 0.5
			$sound_cat.play()
		elif is_cat and Input.is_action_just_pressed("down"):
			$CollisionShape2D.scale.y = 1
			$CollisionShape2D.scale.x = 1
			is_cat = false
			$sound_cat.play()
		
	# Blinking
	if Upgrades.TUNIC:
		if Input.is_action_just_pressed("blink"):
			if !$Sprite.flip_h:
				linear_vel = Vector2(500, 0)
				dashing = true
				#GRAVITY_VEC = Vector2(0, 450)
				$sound_blink.play()
			elif $Sprite.flip_h:
				linear_vel = Vector2(-500, 0)
				dashing = true
				#GRAVITY_VEC = Vector2(0, 450)
				$sound_blink.play()
		
			if dashing:
				dash_acc += delta
			#if we dashed for longer than our DASH_TIME we stop and reset our accumulator
			if dash_acc >= DASH_TIME:    
				dashing = false
				linear_vel = Vector2(0, 0)
				dash_acc = 0
				GRAVITY_VEC = Vector2(0, 900)
			
	# Shooting
	if Upgrades.WAND:
		if !is_cat and Input.is_action_just_pressed("fire"):
			
			var fireball = FIREBALL.instance()
			if sign($Position2D.position.x) == 1:
				fireball.set_fireball_direction(1)
			else:
				fireball.set_fireball_direction(-1)	
			get_parent().add_child(fireball)
			fireball.global_position = $Position2D.global_position #use node for shoot position
			$sound_shoot.play()
		
	### ANIMATION ###
	var new_anim = "Idle"
	if is_cat:
		new_anim = "Idle_cat"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			#witch_sprite.scale.x = -1
			new_anim = "Walking"
			if is_cat:
				new_anim = "Running_cat"

		if linear_vel.x > SIDING_CHANGE_SPEED:
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

		if linear_vel.y < 0:
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
