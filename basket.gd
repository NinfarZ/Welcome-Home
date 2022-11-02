extends StaticBody

enum {
	ACTIVE,
	INACTIVE
}


var state = ACTIVE
var currentCandyCount = 0
var totalCandy = 0
var isBasketFull = false

signal basketFull
signal addedCandy

func _ready():
	pass

func _physics_process(delta):
	match state:
		ACTIVE:
			get_parent().visible = true
			$CollisionShape.disabled = false
		INACTIVE:
			get_parent().visible = false
			$CollisionShape.disabled = true
			currentCandyCount = 0
			totalCandy = 0
			isBasketFull = false

func addCandy(candyToAdd):
	get_tree().call_group("sanityBar", "recoverSanity", 3.5)
	if isBasketFull:
		return
	
#	currentCandyCount += candyToAdd
#
#	if currentCandyCount >= totalCandy:
#		isBasketFull = true
#		currentCandyCount = totalCandy
	currentCandyCount += 1
	emit_signal("addedCandy")
	if currentCandyCount >= totalCandy:
		isBasketFull = true
		emit_signal("basketFull")
	
	get_parent().get_node("candyCountLabel").set_text(str(currentCandyCount) + " / " + str(totalCandy))
	
	
	

func displayText(candyAmount):
	totalCandy = candyAmount
	get_parent().get_node("candyCountLabel").set_text("0 / " + str(totalCandy))
	isBasketFull = false
	currentCandyCount = 0
	

func interact():
	#animate and add sound
	pass

func setState(newState):
	state = newState

func getTotalCandy():
	return totalCandy

func getIsBasketFull():
	return isBasketFull

#possible code to fade out basket when full
func dissolveBasket():
	var tween = create_tween()
	pass




