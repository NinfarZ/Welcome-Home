extends Spatial


func tweenDownLight():
	$Tween.interpolate_property($OmniLight, "light_energy", 0.216, 0, 1)
	$Tween.start()
