extends Spatial

onready var candyBasket = $candyBasket
onready var candyCounter = get_parent().get_node("CanvasLayer/candyCounter")
onready var doorManager = get_parent().get_node("Doors")
var lastPosition = null
onready var availableLocations = $locations.get_children()

func _ready():
	$candyBasket/basket.connect("addedCandy", self, "updateCandyCounter")

func changeBasketLocation():
	var newLocation = null
	var i = 0
	if lastPosition != null:
		availableLocations.erase(lastPosition)
	if availableLocations == []:
			availableLocations = $locations.get_children()
	RNGTools.shuffle(availableLocations)
	while i < len(availableLocations):
		if doorManager.getCurrentDoor().is_in_group(availableLocations[i].name) and availableLocations[i] != lastPosition:
			newLocation = availableLocations[i]
			moveBasketToPosition(newLocation)
			return
		i += 1
		
	newLocation = RNGTools.pick(availableLocations)
	moveBasketToPosition(newLocation)
	return
	
	

func moveBasketToPosition(basketPosition):
	candyBasket.transform.origin = basketPosition.transform.origin
	lastPosition = basketPosition
	availableLocations.erase(basketPosition)


func setCurrentCandyAmount(amount):
	candyBasket.get_node("basket").currentCandyCount = amount
	candyBasket.get_node("Sprite3D").transform.origin.y = amount * 0.015
	candyBasket.get_node("Sprite3D").visible = true

func updateCandyCounter():
	candyCounter.removeCandy()

