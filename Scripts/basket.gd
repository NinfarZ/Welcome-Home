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
	get_parent().get_node("candyDrop").play()
	fillBasketSprite()
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
		get_tree().call_group("sanityBar", "resetSanity")
		emit_signal("basketFull")
	
	get_parent().get_node("candyCountLabel").set_text(str(currentCandyCount) + " / " + str(totalCandy))
	
	
	

func displayText(candyAmount):
	totalCandy = candyAmount
	get_parent().get_node("candyCountLabel").set_text(str(currentCandyCount) + " / " + str(totalCandy))
	isBasketFull = false
	#currentCandyCount = 0

func fillBasketSprite():
	if not get_parent().get_node("Sprite3D").visible:
		get_parent().get_node("Sprite3D").visible = true
	get_parent().get_node("Sprite3D").transform.origin.y += 0.02


func interact():
	#animate and add sound
	pass

func setState(newState):
	state = newState

func getTotalCandy():
	return totalCandy

func getCurrentCandyCount():
	return currentCandyCount

func getIsBasketFull():
	return isBasketFull

#possible code to fade out basket when full
func dissolveBasket():
	var tween = create_tween()
	pass




