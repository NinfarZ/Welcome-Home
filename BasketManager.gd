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
	candyBasket.transform.origin = newLocation.transform.origin
	lastPosition = newLocation

func updateCandyCounter():
	candyCounter.removeCandy()

