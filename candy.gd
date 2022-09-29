extends StaticBody

var state = DISABLED


enum {
	ENABLED,
	DISABLED
}

func _physics_process(delta):
	match state:
		ENABLED:
			
			get_parent().visible = true
			$CollisionShape.disabled = false
		DISABLED:
			get_parent().visible = false
			$CollisionShape.disabled = true
			
#get candy
func interact():
	state = DISABLED
	#get_tree().call_group("sanityBar", "recoverSanity", 2)

func getState():
	return state

func setState(newState):
	state = newState

		
