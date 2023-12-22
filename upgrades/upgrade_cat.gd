extends Node2D

func _on_Node2D_body_entered(body):
	if "wbody" in body.name:
		Upgrades.CAT = true
	$AudioStreamPlayer.play()
	$Sprite.visible = false
	pass

func _on_AudioStreamPlayer_finished():
	queue_free()
	pass
