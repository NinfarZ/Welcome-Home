extends Spatial


func tweenDownLight():
	var tween = create_tween()
	tween.tween_property($OmniLight, "light_energy", 0, 1.0)

func flicker():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("flicker")

func stopFlicker():
	$AnimationPlayer.stop()


