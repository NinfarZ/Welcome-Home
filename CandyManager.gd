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
			candy.get_node("candy").connect("handFull", self, "playHandFull")
			

func _process(delta):
	if activeCandy != []:
		getDistanceFromPlayerToCandy()

	
#Randomizes candies 
func randomizeCandy(amount, location):
	
	var candiesPicked = 0
	var locationCandyList = location.get_children()

	#erases candy that has been placed so it doesn't get placed again
	var i = 0
	if candiesUsed != []:
		while i < len(locationCandyList):
			if locationCandyList[i] in candiesUsed and locationCandyList[i] in activeCandy:
				locationCandyList.erase(locationCandyList[i])
			else:
				i += 1
		#if the amount of available candy is less than required, assume that value
		if len(locationCandyList) < amount:
			amount = len(locationCandyList)
			if amount == 0: 
				return false #unable to place candy in location, they're still active
	while candiesPicked < amount:
		var newCandy = RNGTools.pick(locationCandyList)
		newCandy.get_node("candy").setState(0)
		candiesPicked += 1
		activeCandy.append(newCandy)
		if not newCandy in candiesUsed:
			candiesUsed.append(newCandy)
		locationCandyList.erase(newCandy)
	return true

func activeCandyPicked(candy):
	activeCandy.erase(candy)
	candyCounter.addCandy()
	currentCandyAmount += 1

func getCurrentCandyAmount():
	return currentCandyAmount

func setCurrentCandyAmount(amount):
	currentCandyAmount = amount

func playHandFull():
	candyCounter.showHandFull()

func resetCandyPicked():
	candyCounter.resetCounter()
	currentCandyAmount = 0

#makes the radar beep when close to candy
func getDistanceFromPlayerToCandy():
	for candy in activeCandy:
		if not candy.get_node("candy").getState() == 1:
			if candy.transform.origin.distance_to(player.get_position()) < 7:
				candyCounter.playBeep()
				return
	candyCounter.stopBeep()

#makes a given amount of candy cursed
func pickCursedCandy(amount):
	while amount > 0:
		var cursedCandy = RNGTools.pick(activeCandy)
		cursedCandy.get_node("candy").setIsCursed(true)
		amount -= 1
	
	
		


#Resets active candy list, hides all candies not picked and adds them back to the candy list
func hideCandy():
	for candy in activeCandy:
		candy.get_node("candy").setState(1)
	activeCandy = []


