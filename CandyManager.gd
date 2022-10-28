extends Spatial

var candiesUsed = []
var activeCandy = []
onready var candyList = get_children()

func _ready():
	for candy in candyList:
		candy.get_node("candy").connect("candyPicked", self, "activeCandyPicked")

	
#Randomizes candies 
func randomizeCandy(amount):
	
	var candiesPicked = 0
	#for candy in $Candy.get_children():
		#candy.get_node("candy").setState(0)
	while candiesPicked < amount:
		var newCandy = RNGTools.pick(candyList)
		for candy in activeCandy:
			while newCandy.transform.origin.distance_to(candy.transform.origin) < 9.0:
				#candyList.erase(newCandy)
				newCandy = RNGTools.pick(candyList)
		newCandy.get_node("candy").setState(0)
		candiesPicked += 1
		activeCandy.append(newCandy)
		candyList.erase(newCandy)

func activeCandyPicked(candy):
	activeCandy.erase(candy)

#Resets active candy list, hides all candies not picked and adds them back to the candy list
func hideCandy():
	
	activeCandy = []
	for candy in activeCandy:
		candy.get_node("candy").setState(1)
		candyList.append(candy)


