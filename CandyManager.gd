extends Spatial

var candiesUsed = []
var activeCandy = []
var currentCandyAmount = 0
onready var candyList = get_children()
onready var candyCounter = get_parent().get_node("CanvasLayer/candyCounter")
onready var player = get_parent().get_node("Player")

func _ready():
	for location in candyList:
		for candy in location.get_children():
			candy.get_node("candy").connect("candyPicked", self, "activeCandyPicked")

func _process(delta):
	if activeCandy != []:
		getDistanceFromPlayerToCandy()

	
#Randomizes candies 
func randomizeCandy(amount, location):
	
	var candiesPicked = 0
	var locationCandyList = location.get_children()
	#for candy in $Candy.get_children():
		#candy.get_node("candy").setState(0)
	while candiesPicked < amount:
		var newCandy = RNGTools.pick(locationCandyList)
		if activeCandy != []:
			for candy in activeCandy:
				while newCandy.transform.origin.distance_to(candy.global_transform.origin) < 1.0:
					#candyList.erase(newCandy)
					locationCandyList.erase(newCandy)
					newCandy = RNGTools.pick(locationCandyList)
		newCandy.get_node("candy").setState(0)
		candiesPicked += 1
		activeCandy.append(newCandy)
		locationCandyList.erase(newCandy)
		#candyList.erase(newCandy)

func activeCandyPicked(candy):
	activeCandy.erase(candy)
	candyCounter.addCandy()
	currentCandyAmount += 1

func getCurrentCandyAmount():
	return currentCandyAmount

func resetCandyPicked():
	candyCounter.resetCounter()
	currentCandyAmount = 0

#makes the radar beep when close to candy
func getDistanceFromPlayerToCandy():
	for candy in activeCandy:
		if candy.get_node("candy").getState() == 0: 
			if candy.transform.origin.distance_to(player.get_position()) < 7:
				candyCounter.playBeep()
				return
	candyCounter.stopBeep()
		


#Resets active candy list, hides all candies not picked and adds them back to the candy list
func hideCandy():
	for candy in activeCandy:
		candy.get_node("candy").setState(1)
	activeCandy = []


