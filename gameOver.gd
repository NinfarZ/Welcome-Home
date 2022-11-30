extends CanvasLayer


func _on_AudioStreamPlayer_finished():
	get_tree().change_scene("res://Menu.tscn")
