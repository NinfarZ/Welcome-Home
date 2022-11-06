extends Spatial

var candiesUsed = []
var activeCandy = []
onready var candyList = get_children()
onready var candyCounter = get_parent().get_node("CanvasLayer/candyCounter")

func _ready():
	for location in candyList:
		for candy in location.get_children():
			candy.get_node("candy").connect("candyPicked", self, "activeCandyPicked")

	
#Randomizes candies 
func randomizeCandy(amount, location):
	
	var candiesPicked = 0
	#for candy in $Candy.get_children():
		#candy.get_node("candy").setState(0)
	while candiesPicked < amount:
		var newCandy = RNGTools.pick(location.get_children())
		if activeCandy != []:
			for candy in activeCandy:
				while newCandy.transform.origin.distance_to(candy.transform.origin) < 1.0:
					#candyList.erase(newCandy)
					newCandy = RNGTools.pick(location.get_children())
		newCandy.get_node("candy").setState(0)
		candiesPicked += 1
		activeCandy.append(newCandy)
		#candyList.erase(newCandy)

func activeCandyPicked(candy):
	activeCandy.erase(candy)
	candyCounter.addCandy()

#Resets active candy list, hides all candies not picked and adds them back to the candy list
func hideCandy():
	
	activeCandy = []
	for candy in activeCandy:
		candy.get_node("candy").setState(1)
		candyList.append(candy)


