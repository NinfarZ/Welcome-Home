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
	if not value:
		get_tree().call_group("interact", "removeKey")
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
	removeImpossibleKeys(listOfKeys)
	currentKey = RNGTools.pick(listOfKeys)
	
	return currentKey

#erases keys where they player can't reach
func removeImpossibleKeys(listOfKeys):
	var currentLockedDoor = doorManager.getCurrentDoor()
	var i = 0
	while i < len(listOfKeys):
		if currentLockedDoor.is_in_group(listOfKeys[i].get_groups()[0]):
			listOfKeys.erase(listOfKeys[i])
		elif player.get_current_location() != null:
			if listOfKeys[i].is_in_group(player.get_current_location()):
				listOfKeys.erase(listOfKeys[i])
				
			else:
				#the index only goes forward if no element is removed
				i += 1
			

func distanceToPlayer(key):
	return key.global_transform.origin.distance_to(player.get_position())

func getHasKey():
	return hasKey
	
	



