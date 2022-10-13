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
	PUNISHMENT
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
			#if not $Audio/BackgroundAmbience.playing:
				#$Audio/BackgroundAmbience.play()
				
			match phase:
				PHASE0:
					#MONSTERS CAN NOT SPAWN
					
					difficultySet(1)
					if not CandyRandomized:
					
						
						randomizeCandy(10)
						get_tree().call_group("monsterController", "setStateIdle")
						CandyRandomized = true
						$candyBasket/basket.displayText(5)

					elif $candyBasket/basket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						$Audio/phaseTransition.play()
						
						
						
							
							
							
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
						phase = PHASE1
				PHASE1:
					#MONSTERS CAN SPAWN, EASY DIFFUCLTY
					
					difficultySet(2)
					if not CandyRandomized:
						
						randomizeCandy(25)
						get_tree().call_group("monsterController", "setStateSearching")
						CandyRandomized = true
						currentBunny = pickBunny()
						
						
						$candyBasket/basket.displayText(15)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif $candyBasket/basket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						
							
							
							
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
						phase = PHASE2
				PHASE2:
					#MEDIUM DIFFICULTY
					
					difficultySet(3)
					if not CandyRandomized:
						randomizeCandy(28)
						$bunnySpawnTimer.start()
						
						CandyRandomized = true
						$candyBasket/basket.displayText(20)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif $candyBasket/basket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						
						phase = PHASE3
						
				PHASE3:
					
					difficultySet(4)
					if not CandyRandomized:
						randomizeCandy(33)
						
						CandyRandomized = true
						$candyBasket/basket.displayText(25)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif $candyBasket/basket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						
						phase = PHASE4
				PHASE4:
					
					difficultySet(5)
					if not CandyRandomized:
						$Audio/phaseTransition.play()
						randomizeCandy(40)
						
						CandyRandomized = true
						$candyBasket/basket.displayText(30)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif $candyBasket/basket.getIsBasketFull():
						print("done")
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
		
		#PLAYER NEEDS TO RUN FOR THEIR LIVES
		PUNISHMENT:
			turnAllLightsOff()
			get_tree().call_group("player", "toggleFlashlight", false)
			$CanvasLayer/Sanity.visible = false
			if not $Audio/fearNoise.playing:
				$Audio/fearNoise.play()
			if $punishmentTimer.is_stopped():
				$punishmentTimer.start()
			get_tree().call_group("invisibleEnemy", "setStateChase")
			get_tree().call_group("door", "setMonsterDoorTimer", 1)
			
			
			
func shutDownLight(currentLight, isTimeOver):
	if isTimeOver:
		currentLight.setState(1)
		$lightCoolDown.wait_time = RNGTools.randi_range(10, 20)
		$lightCoolDown.start()
		#pickLight()
	elif $Navigation/invisibleEnemy.get_current_location() in currentLight.get_groups():
		#get_tree().call_group("LIGHT" + currentLocation, "setState", 1)
		currentLight.setState(1)
		$lightCoolDown.wait_time = RNGTools.randi_range(5, 10)
		$lightCoolDown.start()
		#pickLight()



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

func turnAllLightsOn():
	for light in $spotlights.get_children():
		light.setState(0)

func turnOnLight(lightName):
	for light in $spotlights.get_children():
		if light.name == lightName:
			light.setState(0)

func pickLight(): 
	RNGTools.pick($spotlights.get_children()).setState(0)

func setGameState(newState):
	state = newState
	
	
func startBunnyTimer():
	$bunnySpawnTimer.wait_time = RNGTools.randi_range(30, 60)
	$bunnySpawnTimer.start()


	
	

func pickBunny():
	var bunnyList = $Bunnies.get_children()
	var bunny = RNGTools.pick(bunnyList)
	#bunny.get_node("bunny").setState(0)
	#bunnyList.erase(bunny)
	return bunny

func spawnBunny(currentBunny):
	bunnyActive = true
	currentBunny.get_node("bunny").setState(0)
	#currentBunny.get_node("bunny").displayText(candyAmount)
	currentBunny.get_node("bunny").playMusicBox()

func despawnBunny(currentBunny):
	bunnyActive = false
	currentBunny.get_node("bunny").stopMusicBox()
	#yield(get_tree().create_timer(1),"timeout")
	currentBunny.get_node("bunny").setState(1)

func difficultySet(difficulty):
	match difficulty:
		1:
			
			get_tree().call_group("monsterController", "changeDifficulty", 2, 10)
			get_tree().call_group("monsterController", "cooldown", 5, 10)
			get_tree().call_group("door", "setMonsterDoorTimer", 5)
			
			
			
			
			get_tree().call_group("monster", "setMonsterPhase", 0)
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
				
		2:
			
			
			
			#if not bunnyActive:
				#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
			#elif bunnyActive:
				#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
			if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 2, 8)
				get_tree().call_group("monsterController", "cooldown", 7, 10)
				get_tree().call_group("door", "setMonsterDoorTimer", 4)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("monsterController", "changeDifficulty", 1.5, 10)
				get_tree().call_group("monsterController", "cooldown", 8, 10)
				get_tree().call_group("door", "setMonsterDoorTimer", 5)
				
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				
		3:
			
			
			
			
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 3, 6)
				get_tree().call_group("monsterController", "cooldown", 6, 10)
				get_tree().call_group("door", "setMonsterDoorTimer", 3)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 2, 8)
				get_tree().call_group("monsterController", "cooldown", 7, 10)
				get_tree().call_group("door", "setMonsterDoorTimer", 4)
		4:
			
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monster", "setMonsterPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 4, 4)
				get_tree().call_group("monsterController", "cooldown", 5, 8)
				get_tree().call_group("door", "setMonsterDoorTimer", 2)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("monster", "setMonsterPhase", 0)
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 3, 6)
				get_tree().call_group("monsterController", "cooldown", 6, 10)
				get_tree().call_group("door", "setMonsterDoorTimer", 3)
			
			
			#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
		5:
			#get_tree().call_group("monsterController", "changeDifficulty", 3, 4)
			#get_tree().call_group("monsterController", "cooldown", 4, 5)
			#get_tree().call_group("door", "setMonsterDoorTimer", 2)
			#get_tree().call_group("monster", "setMonsterPhase", 1)
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				get_tree().call_group("monster", "setMonsterPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 5, 5)
				get_tree().call_group("monsterController", "cooldown", 2, 8)
				get_tree().call_group("door", "setMonsterDoorTimer", 1)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("monster", "setMonsterPhase", 1)
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 4, 5)
				get_tree().call_group("monsterController", "cooldown", 5, 8)
				get_tree().call_group("door", "setMonsterDoorTimer", 2)


func _on_bunnySpawnTimer_timeout():
	var bunnyList = $Bunnies.get_children()
	currentBunny = RNGTools.pick(bunnyList)
	currentBunny.get_node("bunny").setState(0)
	currentBunny.get_node("bunny").playMusicBox()


func _on_lightCoolDown_timeout():
	pickLight()


func _on_punishmentTimer_timeout():
	state = GAME
	$CanvasLayer/Sanity.resetSanity()
	$CanvasLayer/Sanity.visible = true
	$Audio/fearNoise.stop()
	$Navigation/invisibleEnemy/monsterSpawner/CollisionShape.disabled = false
	get_tree().call_group("player", "toggleFlashlight", true)
	pickLight()
	get_tree().call_group("invisibleEnemy", "setStateFollow")
	

func setPunishmentTimer(time):
	$punishmentTimer.wait_time = time
