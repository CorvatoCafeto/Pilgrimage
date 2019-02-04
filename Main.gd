extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var vengance = preload("res://revenge.wav")


func _on_change_music_body_entered(body):
		if "wbody" in body.name:
			$AudioStreamPlayer.stream = vengance
			$AudioStreamPlayer.play()
