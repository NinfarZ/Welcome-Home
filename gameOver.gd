extends CanvasLayer

func _ready():
	if GameData.getIsPlayerDead():
		$MarginContainer/VBoxContainer/CenterContainer/Label.text = "R.I.P"
	else:
		$MarginContainer/VBoxContainer/CenterContainer/Label.text = "You Win~"
		$AudioStreamPlayer.play()
		

func _on_AudioStreamPlayer_finished():
	get_tree().change_scene("res://Menu.tscn")



