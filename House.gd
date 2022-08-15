extends Spatial


onready var player = $Player
onready var monsters = $Monsters

var isWardrobeDown = false

func shutDownWardrobe():
	if not isWardrobeDown:
		$OmniLight2.visible = false
		$Sanity.setRecoverValue(0)
		isWardrobeDown = true


func deathSequence():
	$OmniLight.visible = false
	$OmniLight2.visible = false
	$OmniLight4.visible = false
	player.die()
	monsters.set_physics_process(false)
	$AudioStreamPlayer.stop()
	yield(get_tree().create_timer(2), "timeout")
	$deathMusic.play()
	yield(get_tree().create_timer(1),"timeout")
	$Navigation/invisibleEnemy.state = 3
	
func fade_out():
	$deathMusic/Tween.interpolate_property($deathMusic, "volume_db", 0, -40, 1)
	$deathMusic/Tween.start()



func endGame():
	yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene("res://House.tscn")
