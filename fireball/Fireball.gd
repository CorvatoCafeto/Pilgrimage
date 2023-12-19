extends Area2D

const SPEED = 100
var velocity = Vector2()
var direction = 1

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
	$Sprite.play("flying")
	
func set_fireball_direction(dir):
	direction = dir
	if dir ==-1:
		$Sprite.flip_h = true
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Fireball_body_entered(body):
	if "Villager" in body.name:
		body.dead()
	if "firewall" in body.name:
		body.free()
	queue_free()
