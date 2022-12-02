extends Spatial

var lastKey = null
var currentKey = null
var hasKey = false
onready var doorManager = get_parent().get_node("Doors")
onready var player = get_parent().get_node("Player")


func _ready():
	for key in get_children():
		key.connect("gotKey", self, "handleKey")

#called when player gets key. Updates UI and Haskey
func handleKey(value):
	hasKey = value
	get_tree().call_group("keyUI", "setKey", value)

#spawns a new key
func placeKey(key):
	if key != null:
		key.setStateActive()
		lastKey = key
		print("spawned ", key)

func chooseKey():
	var listOfKeys = get_children()
	if lastKey != null:
		lastKey.setStateInactive()
		listOfKeys.erase(lastKey)
	listOfKeys = removeImpossibleKeys(listOfKeys)
	currentKey = RNGTools.pick(listOfKeys)
	
	return currentKey

#erases keys where they player can't reach
func removeImpossibleKeys(listOfKeys):
	var currentLockedDoor = doorManager.getCurrentDoor()
	for key in listOfKeys:
		var keyDistance = distanceToPlayer(key)
		if currentLockedDoor.is_in_group(key.get_groups()[0]) or keyDistance < 15:
			listOfKeys.erase(key)
			print(key, " can't be placed")
	return listOfKeys
		

func distanceToPlayer(key):
	return key.global_transform.origin.distance_to(player.get_position())

func getHasKey():
	return hasKey
	
	



