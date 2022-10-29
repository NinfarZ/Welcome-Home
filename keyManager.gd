extends Spatial

var lastKey = null
var currentKey = null
onready var doorManager = get_parent().get_node("Doors")
onready var player = get_parent().get_node("Player")


func _ready():
	for key in get_children():
		key.connect("gotKey", self, "handleKey")

#called when player gets key. Updates UI and Haskey
func handleKey():
	pass

#spawns a new key
func placeKey(key):
	if key != null:
		key.setStateActive()
		lastKey = key

func chooseKey():
	var listOfKeys = get_children()
	if lastKey != null:
		listOfKeys.erase(lastKey)
	removeImpossibleKeys(listOfKeys)
	currentKey = RNGTools.pick(listOfKeys)
	
	return currentKey

#erases keys where they player can't reach
func removeImpossibleKeys(listOfKeys):
	var currentLockedDoor = doorManager.getCurrentDoor()
	for key in listOfKeys:
		var keyDistance = distanceToPlayer(key)
		if currentLockedDoor.is_in_group(key.get_groups()[0]):
			listOfKeys.erase(key)
			print(key, " can't be place because its room is locked")
		elif keyDistance < 20:
			listOfKeys.erase(key)
			print(key, " was too close to player")
		

func distanceToPlayer(key):
	return key.transform.origin.distance_to(player.transform.origin)
	
	



