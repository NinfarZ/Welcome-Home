extends CanvasLayer

signal transitioned

	
func transition():
	visible = true
	$AnimationPlayer.play("fadeToBlack")




func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeToBlack":
		emit_signal("transitioned")
		$AnimationPlayer.play("fadeToNormal")
	elif anim_name == "fadeToNormal":
		visible = false
