extends Spatial

var lastLockedDoor = null
var doorPicked = null

func _ready():
	pass # Replace with function body.

#pick door to lock
func pickDoor():
	unlockLastDoor()
	var availableDoors = get_children()
	availableDoors.erase(lastLockedDoor)
	doorPicked = RNGTools.pick(availableDoors)
	return doorPicked
		

#lock door
func lockDoor(door):
	if door.isOpen():
		door.interact()
	door.setLock(true)
	lastLockedDoor = door

func unlockLastDoor():
	if lastLockedDoor != null:
		lastLockedDoor.setLock(false)

