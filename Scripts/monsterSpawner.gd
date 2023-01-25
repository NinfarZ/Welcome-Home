extends Area


func setSpawnAreaRadius(fear):
	print($AnimationPlayer.current_animation)
	match fear:
		0:
			$AnimationPlayer.play("lowFear")
		1:
			$AnimationPlayer.play("highFear")
	
