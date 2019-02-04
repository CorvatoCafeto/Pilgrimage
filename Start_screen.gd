extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.current_animation = "stop"
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("blink") or Input.is_action_just_pressed("fire"):
		$Prompt.hide()
		$Timer.start()
		$AnimationPlayer.play("Intro")

func _on_Timer_timeout():
		get_tree().change_scene("res://Main.tscn")
