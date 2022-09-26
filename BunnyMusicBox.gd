extends Spatial

var currentCandyCount = 5

func _ready():
	addCandy(5)

#plays music box
func playMusicBox():
	$AudioStreamPlayer3D.play()

func addCandy(candyToAdd):
	$candyCountLabel.set_text(str(candyToAdd) + " / 20" )
