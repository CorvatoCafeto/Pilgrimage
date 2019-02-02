extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 64 # pixels/sec
const JUMP_SPEED = 200
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1
const SHOOT_TIME_SHOW_WEAPON = 0.2

var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var has_double_jumped = false
var shoot_time=99999 #time since last shot

var anim=""

var cat_form = preload("res://cat.png")
var is_cat = false
var human_form = preload("res://witch1616.png")


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

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("left"):
		target_speed += -1
		$witch_sprite.flip_h = true
	if Input.is_action_pressed("right"):
		target_speed +=  1
		$witch_sprite.flip_h = false
		
		
	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("up"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()
	elif !has_double_jumped and Input.is_action_just_pressed("up"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()
		has_double_jumped = true
		
	# Transforming
	if !is_cat and Input.is_action_just_pressed("down"):
		$witch_sprite.texture = cat_form
		is_cat = true
		$CollisionShape2D.scale.y = 0.5
		$sound_cat.play()
	elif is_cat and Input.is_action_just_pressed("down"):
		$witch_sprite.texture = human_form
		$CollisionShape2D.scale.y = 1
		is_cat = false
		$sound_cat.play()
		
	# Blinking
	if Input.is_action_just_pressed("blink"):
		if !$witch_sprite.flip_h:
			linear_vel = Vector2(500, 0)
			dashing = true
			$sound_blink.play()
		else:
			linear_vel = Vector2(-500, 0)
			dashing = true
			$sound_blink.play()
	
	if dashing:
		dash_acc += delta
	#if we dashed for longer than our DASH_TIME we stop and reset our accumulator
	if dash_acc >= DASH_TIME:    
		dashing = false
		linear_vel = Vector2(0, 0)
		dash_acc = 0
			
	# Shooting
	if Input.is_action_just_pressed("fire"):
		var bullet = preload("res://Fireball.tscn").instance()
		bullet.position = $witch_sprite/firewand.global_position #use node for shoot position
		bullet.linear_velocity = Vector2(witch_sprite.scale.x * BULLET_VELOCITY, 0)
		bullet.add_collision_exception_with(self) # don't want player to collide with bullet
		$witch_sprite/firewand.add_child(bullet) #don't want bullet to move with me, so add it as child of parent
		$sound_shoot.play()
		shoot_time = 0
		
	### ANIMATION ###