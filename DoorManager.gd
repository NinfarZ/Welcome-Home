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
	print(availableDoors)
	doorPicked = RNGTools.pick(availableDoors)
	return doorPicked
		

#lock door
func lockDoor(door):
	if door.isOpen():
		door.interact(0.5)
	door.setLock(true)
	lastLockedDoor = door
	get_tree().call_group("invisibleEnemy", "isMonsterLockedInside", lastLockedDoor)

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
	var i = 0
	
	while i < len(availableDoors):
		if availableDoors[i].is_in_group(player.get_current_location() if player.get_current_location() != null else "myBedroom"):
			print("removed door", availableDoors[i], " bacause player is in ", player.get_current_location())
			availableDoors.erase(availableDoors[i])
		elif availableDoors[i].is_in_group(invisibleEnemy.get_current_location() if invisibleEnemy.get_current_location() != null else "bedRoom2"):
			print("removed door", availableDoors[i], " because enemy is in ", invisibleEnemy.get_current_location())
			availableDoors.erase(availableDoors[i])
		else:
			#index only goes forward if no element is erased
			i += 1
			
	
	
	

