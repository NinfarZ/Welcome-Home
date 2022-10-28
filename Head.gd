extends Spatial





# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func playDeathAudio():
	pass

func headJumpscare():
	
	visible = true
	if not $deathAnimation.is_playing():
		for eye in $head/eyes.get_children():
			eye.frame = RNGTools.pick([0,1,2])
		$head/mouths/mouths.frame = RNGTools.pick([0,1,2])
		$deathAnimation.play("jumpscareDeath")




func _on_deathAnimation_animation_finished(anim_name):
	pass
