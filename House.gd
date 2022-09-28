extends Spatial


onready var player = $Player
onready var monsters = $Monsters

var isWardrobeDown = false
var state = START
var phase = PHASE0
var currentOnLight = "spotlight4"
var CandyRandomized = false
var initialKeysRandomized = false
var bunnyActive = false
var bunnyCanSpawn = false
var currentBunny = null
var difficulty = 1


enum {
	INTRO,
	START,
	GAME,
	END,
	DEATH
}

enum {
	PHASE0
	PHASE1,
	PHASE2
	PHASE3
	PHASE4
	PHASE5
}

func _physics_process(delta):
	match state:
		INTRO:
			pass
		START:
			turnAllLightsOff()
			turnOnLight("spotlight")
			
			#randomize candy on house
			
			state = GAME
		GAME:
			#PHASE1 -- under 50% fear
			
			match phase:
				PHASE0:
					#MONSTERS CAN NOT SPAWN
					
					if not CandyRandomized:
						randomizeCandy(15)
						get_tree().call_group("monsterController", "setStateIdle")
						difficultySet(1)
						CandyRandomized = true
						$bunnySpawnTimer.wait_time = 60
						$bunnySpawnTimer.start()
						
						
					elif bunnyCanSpawn and not bunnyActive:
						spawnBunny(currentBunny, 5)
						#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
						bunnyActive = true
					elif bunnyActive:
						if currentBunny.get_node("bunny").getIsBasketFull():
							despawnBunny(currentBunny)
							bunnyCanSpawn = false
							CandyRandomized = false
							
							
							
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
							phase = PHASE1
				PHASE1:
					#MONSTERS CAN SPAWN, EASY DIFFUCLTY
					
					if not CandyRandomized:
						randomizeCandy(25)
						get_tree().call_group("monsterController", "setStateSearching")
						difficultySet(2)
						CandyRandomized = true
						$bunnySpawnTimer.wait_time = 60
						$bunnySpawnTimer.start()
						
					elif bunnyCanSpawn and not bunnyActive:
						spawnBunny(currentBunny, 15)
						#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
						bunnyActive = true
					elif bunnyActive:
						if currentBunny.get_node("bunny").getIsBasketFull():
							despawnBunny(currentBunny)
							bunnyCanSpawn = false
							CandyRandomized = false
							
							phase = PHASE2
				PHASE2:
					#MEDIUM DIFFICULTY
					
					if not CandyRandomized:
						randomizeCandy(25)
						difficultySet(3)
						CandyRandomized = true
						$bunnySpawnTimer.wait_time = 70
						$bunnySpawnTimer.start()
						
					elif bunnyCanSpawn and not bunnyActive:
						spawnBunny(currentBunny, 15)
						#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
						bunnyActive = true
					elif bunnyActive:
						if currentBunny.get_node("bunny").getIsBasketFull():
							despawnBunny(currentBunny)
							bunnyCanSpawn = false
							CandyRandomized = false
							
							phase = PHASE3
				PHASE3:
					if not CandyRandomized:
						randomizeCandy(35)
						difficultySet(4)
						CandyRandomized = true
						$bunnySpawnTimer.wait_time = 80
						$bunnySpawnTimer.start()
						
					elif bunnyCanSpawn and not bunnyActive:
						spawnBunny(currentBunny, 20)
						#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
						bunnyActive = true
					elif bunnyActive:
						if currentBunny.get_node("bunny").getIsBasketFull():
							despawnBunny(currentBunny)
							bunnyCanSpawn = false
							CandyRandomized = false
							
							phase = PHASE4
				PHASE4:
					if not CandyRandomized:
						randomizeCandy(45)
						difficultySet(4)
						CandyRandomized = true
						$bunnySpawnTimer.wait_time = 90
						$bunnySpawnTimer.start()
						
					elif bunnyCanSpawn and not bunnyActive:
						spawnBunny(currentBunny, 25)
						#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
						bunnyActive = true
					elif bunnyActive:
						if currentBunny.get_node("bunny").getIsBasketFull():
							despawnBunny(currentBunny)
							bunnyCanSpawn = false
							CandyRandomized = false
							
							phase = PHASE5
				PHASE5:
					pass
					
			
			
				
		END:
			pass
		DEATH:
			get_tree().call_group("player", "setState", 1)
			$CanvasLayer/Sanity.queue_free()
			deathSequence()
			set_physics_process(false)
			
func shutDownLight(currentLight, isTimeOver):
	if isTimeOver:
		currentLight.setState(1)
		pickLight()
	elif $Navigation/invisibleEnemy.get_current_location() in currentLight.get_groups():
		#get_tree().call_group("LIGHT" + currentLocation, "setState", 1)
		currentLight.setState(1)
		pickLight()



func randomizeCandy(amount):
	var candiesPicked = 0
	var candyList = $Candy.get_children()
	
	#for candy in $Candy.get_children():
		#candy.get_node("candy").setState(0)
	while candiesPicked < amount:
		var candy = RNGTools.pick(candyList)
		candy.get_node("candy").setState(0)
		candyList.erase(candy)
		candiesPicked += 1
		


func deathSequence():
	get_tree().call_group("invisibleEnemy", "setStateKillplayer")
	get_tree().call_group("door","setMonsterDoorTimer", 0)
	get_tree().call_group("invisibleEnemy", "playRunningAudio")
	player.die()
	monsters.set_physics_process(false)
	$Audio/BackgroundAmbience.stop()
	$Audio/fearNoise.stop()
	yield(get_tree().create_timer(2), "timeout")
	$Audio/deathMusic.play()
	yield(get_tree().create_timer(1),"timeout")
	
	
func fade_out():
	$Audio/deathMusic/Tween.interpolate_property($Audio/deathMusic, "volume_db", 0, -40, 1)
	$Audio/deathMusic/Tween.start()



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

func setGameState(newState):
	state = newState
	
	
	 


func _on_bunnySpawnTimer_timeout():
	bunnyCanSpawn = true
	currentBunny = pickBunny()

func pickBunny():
	var bunnyList = $Bunnies.get_children()
	var bunny = RNGTools.pick(bunnyList)
	#bunny.get_node("bunny").setState(0)
	#bunnyList.erase(bunny)
	return bunny

func spawnBunny(currentBunny, candyAmount):
	bunnyActive = true
	currentBunny.get_node("bunny").setState(0)
	currentBunny.get_node("bunny").displayText(candyAmount)
	currentBunny.get_node("bunny").playMusicBox()

func despawnBunny(currentBunny):
	bunnyActive = false
	currentBunny.get_node("bunny").stopMusicBox()
	#yield(get_tree().create_timer(1),"timeout")
	currentBunny.get_node("bunny").setState(1)

func difficultySet(difficulty):
	match difficulty:
		1:
			get_tree().call_group("monsterController", "changeDifficulty", 1, 10)
			get_tree().call_group("monsterController", "cooldown", 5, 10)
			get_tree().call_group("door", "setMonsterDoorTimer", 5)
			
			
			get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
			get_tree().call_group("monster", "setMonsterPhase", 0)
		2:
			#get_tree().call_group("monsterController", "changeDifficulty", 1, 10)
			#get_tree().call_group("monsterController", "cooldown", 5, 10)
			#get_tree().call_group("door", "setMonsterDoorTimer", 5)
			
			
			if not bunnyActive:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
			elif bunnyActive:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
		3:
			get_tree().call_group("monsterController", "changeDifficulty", 1.5, 8)
			get_tree().call_group("monsterController", "cooldown", 5, 8)
			get_tree().call_group("door", "setMonsterDoorTimer", 4)
			
			get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
		4:
			get_tree().call_group("monsterController", "changeDifficulty", 2, 6)
			get_tree().call_group("monsterController", "cooldown", 5, 6)
			get_tree().call_group("door", "setMonsterDoorTimer", 3)
			
			get_tree().call_group("audioController", "play", -10)
			
			#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
		5:
			get_tree().call_group("monsterController", "changeDifficulty", 3, 4)
			get_tree().call_group("monsterController", "cooldown", 4, 5)
			get_tree().call_group("door", "setMonsterDoorTimer", 2)
			get_tree().call_group("monster", "setMonsterPhase", 1)
