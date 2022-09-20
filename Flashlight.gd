extends Spatial


func tweenDownLight():
	$Tween.interpolate_property($OmniLight, "light_energy", 0.216, 0, 1)
	$Tween.start()

func flicker():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("flicker")

func stopFlicker():
	$AnimationPlayer.stop()


