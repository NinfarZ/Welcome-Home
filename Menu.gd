extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$TransitionScreen.visible = false
	$skipIntroMenu.visible = false
	$AnimationPlayer.play("lights")
	$music.play()
	

func _on_startButton_pressed():
	$skipIntroMenu.visible = true
	

func _on_quitButton_pressed():
	get_tree().quit()


func _on_TransitionScreen_transitioned():
	get_tree().change_scene("res://House.tscn")

#starts game without intro
func _on_Button_pressed():
	GameData.setSkipIntro(true)
	var tween = create_tween()
	tween.tween_property($music, "volume_db", -80.0, 3.0)
	$TransitionScreen.transition()
	$TransitionScreen.visible = true
	

func _unhandled_input(event):
	if $skipIntroMenu.visible == true:
		if event.is_action_pressed("pause"):
			$skipIntroMenu.visible = false

#starts game WITH intro
func _on_Button2_pressed():
	GameData.setSkipIntro(false)
	var tween = create_tween()
	tween.tween_property($music, "volume_db", -80.0, 3.0)
	$TransitionScreen.transition()
	$TransitionScreen.visible = true
