extends Spatial

var currentCandyCount = 5

func _ready():
	pass

#plays music box
func playMusicBox():
	$AudioStreamPlayer3D.play()

func addCandy(candyToAdd):
	get_parent().get_node("candyCountLabel").set_text(str(candyToAdd) + " / 10" )

func interact():
	#addCandy(get_tree().call_group("candy", "getNumberOfCandy"))
	pass
