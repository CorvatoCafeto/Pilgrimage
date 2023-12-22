extends Area2D

func _on_Upgrade_wand_body_entered(body):
	if "wbody" in body.name:
		Upgrades.WAND = true
	$AudioStreamPlayer.play()
	$Sprite.visible = false
	pass

func _on_AudioStreamPlayer_finished():
	queue_free()
	pass
