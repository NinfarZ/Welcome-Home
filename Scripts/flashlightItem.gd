extends StaticBody

var state = ENABLED

signal flashlightPicked

enum {
	ENABLED,
	DISABLED
}

			
#get candy
func interact():
	setState(DISABLED)
	#get_tree().call_group("sanityBar", "recoverSanity", 4)
	get_tree().call_group("player", "toggleFlashlight", true)

func getState():
	return state

func setState(newState):
	state = newState
	if state == ENABLED:
		get_parent().visible = true
		$CollisionShape.disabled = false
	elif state == DISABLED:
		get_parent().visible = false
		$CollisionShape.disabled = true
