extends Area2D

func _on_Upgrade_tunic_body_entered(body):
	if "wbody" in body.name:
		Upgrades.TUNIC = true
	$AudioStreamPlayer.play()
	$Sprite.visible = false
	pass

func _on_AudioStreamPlayer_finished():
	queue_free()
	pass
