extends Spatial

onready var candyBasket = $candyBasket
var lastPosition = null


func _ready():
	$candyBasket/basket.connect("basketFull", self, "changeBasketLocation")

func changeBasketLocation():
	var availableLocations = $locations.get_children()
	if lastPosition != null:
		availableLocations.erase(lastPosition)
	var newLocation = RNGTools.pick(availableLocations)
	candyBasket.transform.origin = newLocation.transform.origin
	lastPosition = newLocation

