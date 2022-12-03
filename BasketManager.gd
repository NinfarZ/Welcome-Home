extends Spatial

onready var candyBasket = $candyBasket
onready var candyCounter = get_parent().get_node("CanvasLayer/candyCounter")
var lastPosition = null


func _ready():
	$candyBasket/basket.connect("basketFull", self, "changeBasketLocation")
	$candyBasket/basket.connect("addedCandy", self, "updateCandyCounter")

func changeBasketLocation():
	var availableLocations = $locations.get_children()
	if lastPosition != null:
		availableLocations.erase(lastPosition)
	var newLocation = RNGTools.pick(availableLocations)
	moveBasketToPosition(newLocation)
	

func moveBasketToPosition(basketPosition):
	candyBasket.transform.origin = basketPosition.transform.origin
	lastPosition = basketPosition


func setCurrentCandyAmount(amount):
	candyBasket.get_node("basket").currentCandyCount = amount
	candyBasket.get_node("Sprite3D").transform.origin.y = amount * 0.02

func updateCandyCounter():
	candyCounter.removeCandy()

