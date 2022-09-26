extends Spatial


onready var player = $Player
onready var monsters = $Monsters

var isWardrobeDown = false
var state = START
var currentOnLight = "spotlight4"
var initialCandyRandomized = false
var initialKeysRandomized = false

enum {
	START,
	GAME,
	END,
	DEATH
}

func _physics_process(delta):
	match state:
		START:
			turnAllLightsOff()
			turnOnLight("spotlight")
			
			#randomize candy on house
			if not initialCandyRandomized:
				randomizeCandy()
				initialCandyRandomized = true
			
			state = GAME
		GAME:
			pass
		END:
			pass
		DEATH:
			pass
			
func shutDownLight(currentLight):
	if $Navigation/invisibleEnemy.get_current_location() in currentLight.get_groups():
		#get_tree().call_group("LIGHT" + currentLocation, "setState", 1)
		currentLight.setState(1)
		pickLight()

func randomizeCandy():
	var candiesPicked = 0
	var candyList = $Candy.get_children()
	
	#for candy in $Candy.get_children():
		#candy.get_node("candy").setState(0)
	while candiesPicked < 5:
		var candy = RNGTools.pick(candyList)
		candy.get_node("candy").setState(0)
		candyList.erase(candy)
		candiesPicked += 1
		


func deathSequence():
	get_tree().call_group("door","setMonsterDoorTimer", 0)
	player.die()
	monsters.set_physics_process(false)
	$AudioStreamPlayer.stop()
	yield(get_tree().create_timer(2), "timeout")
	$deathMusic.play()
	yield(get_tree().create_timer(1),"timeout")
	get_tree().call_group("invisibleEnemy", "setStateKillplayer")
	
func fade_out():
	$deathMusic/Tween.interpolate_property($deathMusic, "volume_db", 0, -40, 1)
	$deathMusic/Tween.start()



func endGame():
	#yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene("res://House.tscn")

func turnAllLightsOff():
	for light in $spotlights.get_children():
		light.disableLight()

func turnOnLight(lightName):
	for light in $spotlights.get_children():
		if light.name == lightName:
			light.setState(0)

func pickLight(): 
	RNGTools.pick($spotlights.get_children()).setState(0)
	
	
	 
