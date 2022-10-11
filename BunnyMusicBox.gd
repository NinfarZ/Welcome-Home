extends Spatial

enum {
	ACTIVE,
	INACTIVE
}


var state = INACTIVE

func _ready():
	pass

func _physics_process(delta):
	match state:
		ACTIVE:
			get_parent().visible = true
			$CollisionShape.disabled = false
		INACTIVE:
			get_parent().visible = false
			$CollisionShape.disabled = true

#plays music box
func playMusicBox():
	get_parent().get_node("AudioStreamPlayer3D").play()

func stopMusicBox():
	get_parent().get_node("AudioStreamPlayer3D").stop()

func interact():
	#animate and add sound
	stopMusicBox()
	state = INACTIVE
	get_tree().call_group("gameMaster", "startBunnyTimer")

func setState(newState):
	state = newState

func getState():
	return state

func _on_AudioStreamPlayer3D_finished():
	state = INACTIVE
	get_tree().call_group("gameMaster", "setPunishmentTimer", RNGTools.randi_range(15, 30))
	get_tree().call_group("gameMaster", "setGameState", 5)
