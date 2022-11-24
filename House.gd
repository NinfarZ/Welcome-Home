extends Spatial


onready var player = $Player
onready var monsters = $Monsters
onready var invisibleEnemy = $Navigation/invisibleEnemy
onready var candyManager = $Candy
onready var candyBasket = $BasketManager/candyBasket/basket
onready var basketManager = $BasketManager
onready var doorManager = $Doors
onready var keyManager = $keyManager
onready var spotlightManager = $spotlights
onready var furnitureManager = $Furniture
onready var bunnyManager = $BunnyManager

var isWardrobeDown = false
var state = START
var phase = PHASE0
var currentOnLight = "spotlight4"
var CandyRandomized = false
var monsterTriggered = false
var initialKeysRandomized = false
var bunnyActive = false
var bunnyCanSpawn = false
var currentBunny = null
var difficulty = 1
var lockedDoor = null
var currentKey = null


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

func _ready():
	spotlightManager.turnAllLightsOff()
	spotlightManager.turnOnLight("spotlight8")
	spotlightManager.turnOnLight("spotlight9")
	spotlightManager.turnOnLight("spotlight3")
	spotlightManager.turnOnLight("spotlight13")
	spotlightManager.turnOnLight("spotlight")
	spotlightManager.turnOnLight("spotlight12")
	spotlightManager.turnOnLight("spotlight11")
	spotlightManager.turnOnLight("spotlight7")
	doorManager.lockDoor($Doors/Door)
	keyManager.placeKey(keyManager.get_node("Key7"))
	
	
	basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionBedroom2"))

func _physics_process(delta):
	match state:
		INTRO:
			pass
		START:
			
			#monsters.spawnMonster($Monsters/yellowgirl25)
			
			
			
			#randomize candy on house
			
			state = GAME
		GAME:
			#if not $Audio/BackgroundAmbience.playing:
				#$Audio/BackgroundAmbience.play()
				
			match phase:
				PHASE0:
					#MONSTERS CAN NOT SPAWN
					
					difficultySet(1)
					spotlightManager.get_node("lights/spotlight7/AnimationPlayer").play("superFlicker")
						
					if not CandyRandomized:
					
						candyManager.randomizeCandy(2, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(2, candyManager.get_node("corridor"))
						candyManager.randomizeCandy(2, candyManager.get_node("bedRoom2"))
						monsters.setStateIdle()
						invisibleEnemy.setStateStop()
						CandyRandomized = true
						candyBasket.displayText(5)
					#if the basket is full, moves to phase1
					elif candyBasket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						candyManager.hideCandy()
						monsterTriggered = false
						phase = PHASE1
					
					
						
						
					#wakes up monster after grabbing the key and heading to corridor
					elif not monsterTriggered and doorManager.get_node("Door").isLocked():
						if player.get_current_location() == "corridor1":
							monsters.spawnMonster(monsters.get_node("yellowgirl85"))
							doorManager.get_node("Door").playMonsterLockedDoor()
							monsterTriggered = true
							yield(get_tree().create_timer(2),"timeout")
							#invisibleEnemy.playMonsterGrunt()
							yield(get_tree().create_timer(2),"timeout")
							$Audio/suspencePiano.play()
		
						
					elif monsterTriggered:
						if monsters.get_node("yellowgirl85").canSeePlayer():
							monsters.get_node("yellowgirl85").makeCreepySound(1)
						elif doorManager.get_node("Door").isOpen():
							monsters.despawnMonster(monsters.get_node("yellowgirl85"))
							spotlightManager.turnAllLightsOff()
							spotlightManager.startTimer()
							$Audio/darkScaryHorn.play()
							#invisibleEnemy.setStateFollow()
							monsterTriggered = false
					
							
						
							
						
					
					
					
					
						
						
						
							
							
							
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
						
				PHASE1:
					#MONSTERS CAN SPAWN, EASY DIFFUCLTY
					
					difficultySet(2)
					if not CandyRandomized:
						
						furnitureManager.setBarricade(furnitureManager.get_node("barricade3"), false)
						candyManager.randomizeCandy(3, candyManager.get_node("livingroom"))
						candyManager.randomizeCandy(2, candyManager.get_node("kitchen"))
						candyManager.randomizeCandy(1, candyManager.get_node("bathroom2"))
						candyManager.randomizeCandy(2, candyManager.get_node("bathroom1"))
						candyManager.randomizeCandy(2, candyManager.get_node("corridor"))
						
						doorManager.lockDoor($Doors/Door6)
						keyManager.placeKey(keyManager.get_node("Key"))
			
						basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionBathroom1"))
						
						CandyRandomized = true
						#currentBunny = pickBunny()
						
						
						candyBasket.displayText(9)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						candyManager.hideCandy()
					
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
						phase = PHASE2
						
					elif not monsterTriggered:
						if player.get_current_location() == "myBedroom" and not keyManager.hasKey:
							yield(get_tree().create_timer(5),"timeout")
							if not doorManager.get_node("Door2").isOpen() and player.get_current_location() == "myBedroom":
								doorManager.get_node("Door2").interact(2)
						elif keyManager.hasKey and not monsters.get_node("yellowgirl88").getIsActive():
							monsters.spawnMonster(monsters.get_node("yellowgirl88"))
							
						elif monsters.get_node("yellowgirl88").getIsActive():
							if monsters.get_node("yellowgirl88").canSeeMonsterFace and monsters.get_node("yellowgirl88").canSeeMonsterFace or monsters.get_node("yellowgirl88").getDistanceFromPlayer() < 8:
								monsters.despawnMonster(monsters.get_node("yellowgirl88"))
								monsterTriggered = true
							invisibleEnemy.moveToPosition($positions/PositionMyBedroom)
							monsters.setStateCooldown()
				PHASE2:
					#MEDIUM DIFFICULTY
					
					difficultySet(3)
					if not CandyRandomized:
						furnitureManager.setBarricade(furnitureManager.get_node("barricade4"), false)
						furnitureManager.setBarricade(furnitureManager.get_node("barricade2"), false)
						candyManager.randomizeCandy(2, candyManager.get_node("livingroom"))
						candyManager.randomizeCandy(1, candyManager.get_node("kitchen"))
						candyManager.randomizeCandy(3, candyManager.get_node("bathroom2"))
						candyManager.randomizeCandy(4, candyManager.get_node("bedRoom3"))
						candyManager.randomizeCandy(3, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(2, candyManager.get_node("bedRoom2"))
						
						doorManager.lockDoor($Doors/Door5)
						keyManager.placeKey(keyManager.get_node("Key2"))
			
						basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionKitchen"))
						
						
						monsters.setStateSearching()
						monsters.setMonsterManagerPhase(1)
						CandyRandomized = true
						bunnyManager.startTimer()
						
						
						candyBasket.displayText(13)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						candyManager.hideCandy()
						
						phase = PHASE3
						
				PHASE3:
					
					difficultySet(4)
					if not CandyRandomized:
						candyManager.randomizeCandy(4, candyManager.get_node("livingroom"))
						candyManager.randomizeCandy(1, candyManager.get_node("bathroom2"))
						candyManager.randomizeCandy(3, candyManager.get_node("bathroom1"))
						candyManager.randomizeCandy(1, candyManager.get_node("bedRoom3"))
						candyManager.randomizeCandy(1, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(5, candyManager.get_node("bedRoom2"))
						
						doorManager.lockDoor($Doors/Door3)
						keyManager.placeKey(keyManager.get_node("Key16"))
			
						basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionBathroom2"))
						
						CandyRandomized = true
						
						
						
						candyBasket.displayText(15)
						
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						candyManager.hideCandy()
						
						phase = PHASE4
				PHASE4:
					
					difficultySet(5)
					if not CandyRandomized:
						$Audio/phaseTransition.play()
						for location in candyManager:
							candyManager.randomizeCandy(2, location)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey()
						#keyManager.placeKey(keyManager.get_node("Key16"))
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						#currentBunny = pickBunny()
						
						
						candyBasket.displayText(16)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						print("done")
						CandyRandomized = false
						candyManager.hideCandy()
						
						phase = PHASE4
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
			get_tree().call_group("flashlight", "flicker")
			if not $Audio/fearNoise.playing:
				$Audio/fearNoise.play()
			if $punishmentTimer.is_stopped():
				spotlightManager.turnAllLightsOff()
				#spotlightManager.get_node("lightCoolDown").stop()
				#get_tree().call_group("player", "setState", 1)
				#get_tree().call_group("player", "toggleFlashlight", false)
				$CanvasLayer/Sanity.visible = false
				$punishmentTimer.start()
			#get_tree().call_group("invisibleEnemy", "setStateChase")
				get_tree().call_group("monsterController", "setStateHunting")
			#get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 1)
			elif spotlightManager.getCurrentLight() != null:
				if spotlightManager.getCurrentLight().getIsPlayerInside():
					punishmentEnd()
				
			
				#$CanvasLayer/Sanity.resetSanity()
				#$CanvasLayer/Sanity.visible = true
	#$Navigation/invisibleEnemy/monsterSpawner/CollisionShape.disabled = false
				#get_tree().call_group("player", "toggleFlashlight", true)
				#get_tree().call_group("player", "setState", 0)
				#pickLight()
			
			
			
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



#func randomizeCandy(amount):
#	var candiesPicked = 0
#	var candyList = $Candy.get_children()
#	var activeCandy = []
#	var possibleCandyFound = false
#
#	#for candy in $Candy.get_children():
#		#candy.get_node("candy").setState(0)
#	while candiesPicked < amount:
#		var newCandy = RNGTools.pick(candyList)
#		for candy in activeCandy:
#			while newCandy.transform.origin.distance_to(candy.transform.origin) < 9.0:
#				candyList.erase(newCandy)
#				print(newCandy.name + "was too close to " + candy.name)
#				newCandy = RNGTools.pick(candyList)
#		newCandy.get_node("candy").setState(0)
#		candiesPicked += 1
#		activeCandy.append(newCandy)
		
		


func deathSequence():
	$punishmentTimer.stop()
	#get_tree().call_group("invisibleEnemy", "setStateKillplayer")
	#get_tree().call_group("door","setMonsterDoorTimer", 0)
	#get_tree().call_group("invisibleEnemy", "playRunningAudio")
	player.die()
	monsters.set_physics_process(false)
	$Audio/BackgroundAmbience.stop()
	$Audio/fearNoise.stop()
	#yield(get_tree().create_timer(2), "timeout")
	$Audio/deathMusic.play()
	#yield(get_tree().create_timer(1),"timeout")
	yield(get_tree().create_timer(2), "timeout")
	endGame()
	
	
func fade_out():
	$Audio/deathMusic/Tween.interpolate_property($Audio/deathMusic, "volume_db", 0, -40, 1)
	$Audio/deathMusic/Tween.start()



func endGame():
	#yield(get_tree().create_timer(1),"timeout")
	get_tree().change_scene("res://House.tscn")

#func turnAllLightsOff():
#	for light in $spotlights.get_children():
#		light.setState(1)
#
#func turnAllLightsOn():
#	for light in $spotlights.get_children():
#		light.setState(0)
#
#func turnOnLight(lightName):
#	for light in $spotlights.get_children():
#		if light.name == lightName:
#			light.setState(0)
#
#func pickLight(): 
#	RNGTools.pick($spotlights.get_children()).setState(0)

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
			invisibleEnemy.setSanityDrain(0.015)
			get_tree().call_group("monsterController", "changeDifficulty", 2, 3)
			get_tree().call_group("monsterController", "cooldown", 10, 30)
			get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 5)
			
			
			
			
			
			get_tree().call_group("monster", "setMonsterPhase", 0)
			
			#if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				
			get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
			#elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
				
		2:
			
			invisibleEnemy.setSanityDrain(0.02)
			
			#if not bunnyActive:
				#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
			#elif bunnyActive:
				#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
			if $CanvasLayer/Sanity.getSanityBarValue() > 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 2, 4)
				get_tree().call_group("monsterController", "cooldown", 10, 25)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 4.5)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("monsterController", "changeDifficulty", 2, 3)
				get_tree().call_group("monsterController", "cooldown", 10, 30)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 5)
				
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				
		3:
			invisibleEnemy.setSanityDrain(0.025)
			
			
			
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50 and $CanvasLayer/Sanity.getSanityBarValue() < 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 2.5, 6)
				get_tree().call_group("monsterController", "cooldown", 5, 10)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 4)
			elif $CanvasLayer/Sanity.getSanityBarValue() >= 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 3.5, 10)
				get_tree().call_group("monsterController", "cooldown", 2, 5)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 3)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 2, 3)
				get_tree().call_group("monsterController", "cooldown", 10, 15)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 4.5)
		4:
			invisibleEnemy.setSanityDrain(0.03)
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50 and $CanvasLayer/Sanity.getSanityBarValue() < 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 3, 8)
				get_tree().call_group("monsterController", "cooldown", 3, 6)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 3.5)
			elif $CanvasLayer/Sanity.getSanityBarValue() >= 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 4, 10)
				get_tree().call_group("monsterController", "cooldown", 1, 5)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 2)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 2.5, 3)
				get_tree().call_group("monsterController", "cooldown", 5, 10)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 4)
			
			
			#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
		5:
			#get_tree().call_group("monsterController", "changeDifficulty", 3, 4)
			#get_tree().call_group("monsterController", "cooldown", 4, 5)
			#get_tree().call_group("door", "setMonsterDoorTimer", 2)
			#get_tree().call_group("monster", "setMonsterPhase", 1)
			invisibleEnemy.setSanityDrain(0.035)
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50 and $CanvasLayer/Sanity.getSanityBarValue() < 90:
				get_tree().call_group("monsterController", "changeDifficulty", 3.5, 8)
				get_tree().call_group("monsterController", "cooldown", 2, 4)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 2)
			elif $CanvasLayer/Sanity.getSanityBarValue() >= 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 5, 10)
				get_tree().call_group("monsterController", "cooldown", 1, 2)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 1)
			
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 3, 3)
				get_tree().call_group("monsterController", "cooldown", 3, 6)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 3)


func _on_bunnySpawnTimer_timeout():
	var bunnyList = $Bunnies.get_children()
	currentBunny = RNGTools.pick(bunnyList)
	currentBunny.get_node("bunny").setState(0)
	currentBunny.get_node("bunny").playMusicBox()

func punishmentEnd():
	state = GAME
	#get_tree().call_group("invisibleEnemy", "setStateFollow")
	monsters.setStateCooldown()
	$CanvasLayer/Sanity.visible = true
	$Audio/fearNoise.stop()
	$punishmentTimer.stop()
	#$Navigation/invisibleEnemy/monsterSpawner/CollisionShape.disabled = false
	#player.toggleFlashlight(true)
	#spotlightManager.pickLight()


func _on_punishmentTimer_timeout():
	state = GAME
	#get_tree().call_group("invisibleEnemy", "setStateFollow")
	get_tree().call_group("monsterController", "setStateCooldown")
	$CanvasLayer/Sanity.visible = true
	$Audio/fearNoise.stop()
	#$Navigation/invisibleEnemy/monsterSpawner/CollisionShape.disabled = false
	#get_tree().call_group("player", "toggleFlashlight", true)
	#spotlightManager.pickLight()
	
	

func setPunishmentTimer(time):
	$punishmentTimer.wait_time = time
