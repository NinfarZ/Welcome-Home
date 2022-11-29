extends Control

const mainScene = preload("res://House.tscn")

func _process(delta):
	if not $music.playing:
		$music.play()
	

func _on_startButton_pressed():
	$TransitionScreen.transition()
	$TransitionScreen.visible = true
	var tween = create_tween()
	tween.tween_property($music, "volume_db", -80.0, 3.0)
	
	


func _on_quitButton_pressed():
	get_tree().quit()


func _on_TransitionScreen_transitioned():
	get_tree().change_scene_to(mainScene)
