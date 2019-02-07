extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.current_animation = "stop"
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pressed == false:
		if Input.is_action_pressed("blink") or Input.is_action_pressed("fire"):
			$Prompt.hide()
			$AnimationPlayer.play("Intro")
			pressed = true

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Main.tscn")

