extends Spatial

enum {
	ACTIVE,
	INACTIVE
}


var state = INACTIVE
var currentCandyCount = 0
var totalCandy = 0
var isBasketFull = false

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

#plays music box
func playMusicBox():
	get_parent().get_node("AudioStreamPlayer3D").play()

func stopMusicBox():
	get_parent().get_node("AudioStreamPlayer3D").stop()


func addCandy(candyToAdd):
	if isBasketFull:
		return
	
	currentCandyCount += candyToAdd
	if currentCandyCount >= totalCandy:
		currentCandyCount = totalCandy
		isBasketFull = true
	
	get_parent().get_node("candyCountLabel").set_text(str(currentCandyCount) + " / " + str(totalCandy))
	
	
	

func displayText(candyAmount):
	totalCandy = candyAmount
	get_parent().get_node("candyCountLabel").set_text("0 / " + str(totalCandy))
	

func interact():
	#animate and add sound
	pass

func setState(newState):
	state = newState

func getTotalCandy():
	return totalCandy

func getIsBasketFull():
	return isBasketFull




func _on_AudioStreamPlayer3D_finished():
	state = INACTIVE
	get_tree().call_group("gameMaster", "setGameState", 4)
