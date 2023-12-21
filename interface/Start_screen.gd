extends Node2D

var pressed = false

func _ready():
#	$AnimationPlayer.current_animation = "stop"
	pass
	
func _process(_delta):
	if pressed == false:
		if Input.is_action_pressed("blink") or Input.is_action_pressed("fire"):
			$Prompt.hide()
			$AnimationPlayer.play("Intro")
			pressed = true
			
func _on_AnimationPlayer_animation_finished(_anim_name):
	if get_tree().change_scene("res://world/main.tscn") != OK:
		print ("An unexpected error occured when trying to switch to the Main scene")
