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
	setState(0)
	displayText(5)

func _physics_process(delta):
	match state:
		ACTIVE:
			get_parent().visible = true
			$CollisionShape.disabled = false
		INACTIVE:
			get_parent().visible = false
			$CollisionShape.disabled = true

#plays music box
func playMusicBox():
	$AudioStreamPlayer3D.play()


func addCandy(candyToAdd):
	if isBasketFull:
		return
	
	currentCandyCount += candyToAdd
	if currentCandyCount >= totalCandy:
		currentCandyCount = totalCandy
		isBasketFull = true
	
	get_parent().get_node("candyCountLabel").set_text(str(currentCandyCount) + " / " + str(totalCandy))
	
	
	

func displayText(candyAmount):
	get_parent().get_node("candyCountLabel").set_text("0 / " + str(totalCandy))
	totalCandy = candyAmount

func interact():
	#addCandy(get_tree().call_group("candy", "getNumberOfCandy"))
	pass

func setState(newState):
	state = newState

func getTotalCandy():
	return totalCandy

