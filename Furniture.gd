extends Spatial

var totalCandy = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#picks random furniture to place keys
func placeKeys():
	pass

#player (or monster???) takes the key
func takeKey(furniture):
	pass
#monster places key on some furniture??? Possible code for monster moving keys
func placeKey(furniture):
	pass

#func randomizeCandy():

	#for candy in $Items.get_children():
		#if RNGTools.pick([0,0,1]) == 1 and totalCandy < 3:
			#candy.get_node("candy").setState(0)
			#totalCandy += 1
	#if totalCandy < 1:
		#RNGTools.pick(get_node("Items").get_children()).get_node("candy").setState(0)
