extends Spatial

var lastLockedDoor = null
var doorPicked = null
var player = null
var invisibleEnemy = null

func _ready():
	yield(owner, "ready")
	player = owner.player
	invisibleEnemy = owner.invisibleEnemy

#pick door to lock
func pickDoor():
	unlockLastDoor()
	var availableDoors = get_children()
	availableDoors.erase(lastLockedDoor)
	
	removeImpossibleDoors(availableDoors)
	doorPicked = RNGTools.pick(availableDoors)
	return doorPicked
		

#lock door
func lockDoor(door):
	if door.isOpen():
		door.interact()
	door.setLock(true)
	print(door, " is locked")
	lastLockedDoor = door

func unlockLastDoor():
	if lastLockedDoor != null:
		lastLockedDoor.setLock(false)

#return the current locked door 
func getCurrentDoor():
	return doorPicked

#erase doors where the player or the monster currently is
func removeImpossibleDoors(availableDoors):
	#wardrobe doors
	availableDoors.erase($Door8)
	availableDoors.erase($Door7)
	
	for door in availableDoors:
		if door.is_in_group(player.get_current_location()) or door.is_in_group(invisibleEnemy.get_current_location()):
			availableDoors.erase(door)
			print("removed door", door, " bacause player is in ", player.get_current_location(), " and enemy in ", invisibleEnemy.get_current_location())
	
	
	

