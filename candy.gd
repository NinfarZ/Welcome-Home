extends StaticBody

var state = DISABLED
var canSpawn = true
var listOfCandyNearby = []

signal candyPicked


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
	set_physics_process(false)
			
#get candy
func interact():
	setState(DISABLED)
	#get_tree().call_group("sanityBar", "recoverSanity", 4)
	get_parent().get_node("candyPicked").play()
	emit_signal("candyPicked", self)

func getState():
	return state

func setState(newState):
	state = newState
	set_physics_process(true)

func canSpawn():
	print(listOfCandyNearby)
	if listOfCandyNearby == []:
		return true
	else:
		return false

		


#func _on_Area_body_entered(body):
#	if body.is_in_group("candy") and not self.get_parent():
#		listOfCandyNearby.append(body)
#
#
#
#
#func _on_Area_body_exited(body):
#	if body.is_in_group("candy"):
#		#listOfCandyNearby.erase(body)
#		pass
