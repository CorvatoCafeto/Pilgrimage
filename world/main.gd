extends Node2D

var vengance = preload("res://music/revenge.wav")

func _on_change_music_body_entered(body):
	if "wbody" in body.name:
		$AudioStreamPlayer.stream = vengance
		$AudioStreamPlayer.play()
		$ChangeMusic/CollisionShape2D.free()
