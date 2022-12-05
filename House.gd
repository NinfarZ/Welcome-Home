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
onready var positions = $positions

var isWardrobeDown = false
var state = INTRO
var phase = PHASE0
var currentOnLight = "spotlight4"
var CandyRandomized = false
var monsterTriggered = false
var scaryHornSoundFinished = false
var initialKeysRandomized = false
var bunnyActive = false
var bunnyCanSpawn = false
var currentBunny = null
var difficulty = 1
var lockedDoor = null
var currentKey = null
var lightsToTurnOn = []


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
	$TransitionScreen.connect("transitioned", self, "playerTransition")
	$CanvasLayer/Sanity.connect("sanityThreshold", self, "controlDifficulty")
	if GameData.getSkipIntro() == true:
		skipIntro()
	else:
		state = INTRO
	

func _physics_process(delta):
	match state:
		INTRO:
			if not CandyRandomized:
				monsters.setStateIdle()
				invisibleEnemy.isMonsterActive(false)
				lightsToTurnOn = ["Entrance", "Livingroom", "Bathroom1", "Corridor2"]
				for light in lightsToTurnOn:
					spotlightManager.turnOnLight("spotlight" + light)
				#$CanvasLayer/Sanity.visible = false

				
				
					
				doorManager.lockDoor($Doors/Door5)
				#keyManager.placeKey(keyManager.get_node("Key7"))
				
				
				basketManager.moveBasketToPosition(basketManager.get_node("locations/livingroom"))
				monsters.spawnMonster(monsters.get_node("yellowgirl75"))
				candyManager.randomizeCandy(3, candyManager.get_node("livingroom"))
				candyManager.randomizeCandy(1, candyManager.get_node("bathroom1"))
				
				
				
				CandyRandomized = true
				candyBasket.displayText(5)
			
			elif basketManager.get_node("candyBasket/basket").getCurrentCandyCount() >= 3 and not monsterTriggered:
				yield(get_tree().create_timer(5),"timeout")
				bunnyManager.playBunnyMusicBox(bunnyManager.get_node("Bunnies/Bunny5"))
				monsterTriggered = true
			elif monsterTriggered and bunnyManager.get_node("Bunnies/Bunny5/bunny").getIsMusicBoxFinished():
				$Audio/darkScaryHorn.play()
				for label in $TutorialLabels.get_children():
					if label.name != "LabelRun":
						label.visible = false
					else:
						label.visible = true
				spotlightManager.turnAllLightsOff()
				CandyRandomized = false
				monsterTriggered = false
				monsters.get_node("yellowgirl75").shadeFace(false)
				candyManager.hideCandy()
				state = START
		START:
			if scaryHornSoundFinished:
				monsters.get_node("yellowgirl75").shadeFace(true)
				monsters.despawnMonster(monsters.get_node("yellowgirl75"))
				scaryHornSoundFinished = false
				$TransitionScreen.transition()
				
				
				
			#where the villain will introduce himself
			
				
		GAME:
			#if not $Audio/BackgroundAmbience.playing:
				#$Audio/BackgroundAmbience.play()
				
			match phase:
				PHASE0:
					#MONSTERS CAN NOT SPAWN
					
					#difficultySet(1)
					spotlightManager.get_node("lights/spotlightBedroom2/AnimationPlayer").play("superFlicker")
						
					if not CandyRandomized:
						for label in $TutorialLabels.get_children():
							label.visible = false
						$CanvasLayer/Sanity.visible = true
						doorManager.unlockLastDoor()
						doorManager.lockDoor($Doors/Door)
						keyManager.placeKey(keyManager.get_node("Key7"))
						
						lightsToTurnOn = ["MyBedroom", "Bedroom2", "Corridor3", "Corridor2", "Bathroom2"]
						for light in lightsToTurnOn:
							spotlightManager.turnOnLight("spotlight" + light)
	
	
						basketManager.moveBasketToPosition(basketManager.get_node("locations/bedRoom2"))
						basketManager.setCurrentCandyAmount(5)
					
						candyManager.randomizeCandy(2, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(2, candyManager.get_node("corridor"))
						candyManager.randomizeCandy(2, candyManager.get_node("bedRoom2"))
						#monsters.setStateIdle()
						#invisibleEnemy.setStateStop()
						CandyRandomized = true
						candyBasket.displayText(10)
					#if the basket is full, moves to phase1
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						candyManager.hideCandy()
						monsterTriggered = false
						phase = PHASE1
					
					
						
						
					#wakes up monster after grabbing the key and heading to corridor
					elif not monsterTriggered and doorManager.get_node("Door").isLocked():
						if player.get_current_location() == "corridor1" and keyManager.getHasKey():
							monsters.spawnMonster(monsters.get_node("yellowgirl143"))
							doorManager.get_node("Door").playMonsterLockedDoor()
							monsterTriggered = true
							yield(get_tree().create_timer(2),"timeout")
							#invisibleEnemy.playMonsterGrunt()
							yield(get_tree().create_timer(2),"timeout")
							$Audio/suspencePiano.play()
		
						
					elif monsterTriggered:
						if monsters.get_node("yellowgirl143").canSeePlayer():
							monsters.get_node("yellowgirl143").makeCreepySound(1)
						elif not doorManager.get_node("Door").isLocked():
							monsters.despawnMonster(monsters.get_node("yellowgirl143"))
							spotlightManager.turnAllLightsOff()
							spotlightManager.startTimer()
							monsters.setStateCooldown()
							invisibleEnemy.isMonsterActive(true)
							#invisibleEnemy.setStateFollow()
							monsterTriggered = false
					
							
						
							
						
					
					
					
					
						
						
						
							
							
							
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
						
				PHASE1:
					#MONSTERS CAN SPAWN BUT NOT DANGEROUS, JUST SCARY
					
					#difficultySet(2)
					if not CandyRandomized:
						for letter in $Letters.get_children():
							letter.visible = false
							letter.get_node("CollisionShape").disabled = true
							
						
						furnitureManager.setBarricade(furnitureManager.get_node("barricade3"), false)
						furnitureManager.setBarricade(furnitureManager.get_node("barricade4"), false)
						
						#spreads 12 candy across apartment
						spreadCandyAcrossMap(12)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						#currentBunny = pickBunny()
						
						
						candyBasket.displayText(19)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						candyManager.hideCandy()
					
							#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 0)
						phase = PHASE2
							
				PHASE2:
					#MEDIUM DIFFICULTY. MONSTER CAN KILL
					
					#difficultySet(3)
					if not CandyRandomized:
						furnitureManager.setBarricade(furnitureManager.get_node("barricade2"), false)
						#spreads 10 candy across apartment
						spreadCandyAcrossMap(10)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						
						monsters.setStateSearching()
						monsters.setMonsterManagerPhase(1)
						CandyRandomized = true
						bunnyManager.startTimer()
						
						
						candyBasket.displayText(29)
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						candyManager.hideCandy()
						
						phase = PHASE3
						
				PHASE3:
					
					#difficultySet(4)
					if not CandyRandomized:
						$mannequim.visible = false
						#spreads 10 candy across apartment
						spreadCandyAcrossMap(10)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						
						
						
						candyBasket.displayText(39)
						
						#currentBunny = pickBunny()
						#spawnBunny(currentBunny, 5)
						#bunnyActive = true
					
						
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						candyManager.hideCandy()
						
						phase = PHASE4
				PHASE4:
					
					#difficultySet(5)
					if not CandyRandomized:
						$Audio/lastPhase.play()
						#spreads 10 candy across apartment
						spreadCandyAcrossMap(10)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						
						
						candyBasket.displayText(49)
					
						
					elif candyBasket.getIsBasketFull():
						CandyRandomized = false
						candyManager.hideCandy()
						$TransitionScreen.transition()
						
						set_physics_process(false)
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
				$Audio/darkScaryHorn.play()
				spotlightManager.turnAllLightsOff()
			
				$CanvasLayer/Sanity.visible = false
				$punishmentTimer.start()
			
				get_tree().call_group("monsterController", "setStateHunting")
			
			elif candyBasket.getIsBasketFull():
				punishmentEnd()
				
			
func deathSequence():
	$punishmentTimer.stop()
	player.die()
	monsters.set_physics_process(false)
	$Audio/BackgroundAmbience.stop()
	$Audio/fearNoise.stop()
	$Audio/deathMusic.play()
	yield(get_tree().create_timer(2), "timeout")
	endGame()
	
	
func fade_out():
	$Audio/deathMusic/Tween.interpolate_property($Audio/deathMusic, "volume_db", 0, -40, 1)
	$Audio/deathMusic/Tween.start()



func endGame():
	get_tree().change_scene("res://Menu.tscn")

func setGameState(newState):
	state = newState

func skipIntro():
	for label in $TutorialLabels.get_children():
		label.visible = false
	state = GAME
	phase = PHASE1
	player.set_current_location("myBedroom")
	player.set_deferred("translation", positions.get_node("myBedroom").translation)
	spotlightManager.startTimer()
	$FlashlightItem.get_node("flashlight").interact()
	monsters.setStateCooldown()
	invisibleEnemy.isMonsterActive(true)
	basketManager.setCurrentCandyAmount(9)

func spreadCandyAcrossMap(amount):
	var locationList = candyManager.get_children()
	var candyToSpread = amount
	var candyAmount = 0
	while candyToSpread > 0 and not locationList == []:
		if not candyToSpread < 3:
			candyAmount = RNGTools.randi_range(1, 3)
		else:
			candyAmount = candyToSpread
		var location = RNGTools.pick(locationList)
		candyManager.randomizeCandy(candyAmount, location)
		locationList.erase(location)
		candyToSpread -= candyAmount
		

func controlDifficulty(fear):
	match phase:
		#PHASE0
		PHASE0:
			pass
		#PHASE1
		PHASE1:
			invisibleEnemy.setInvisibleEnemyPhase(1)
			invisibleEnemy.setSanityDrain(0.025)
			match fear:
				0:
					monsters.changeDifficulty(2,3)
					monsters.cooldown(10,30)
					invisibleEnemy.setMonsterDoorTimer(5)
					
				1:
					monsters.changeDifficulty(2,4)
					monsters.cooldown(10,25)
					invisibleEnemy.setMonsterDoorTimer(4.5)
				2:
					pass
		#PHASE2
		PHASE2:
			invisibleEnemy.setSanityDrain(0.03)
			match fear:
				0:
					
					invisibleEnemy.setInvisibleEnemyPhase(1)
					monsters.changeDifficulty(3.2,3)
					monsters.cooldown(10,15)
					invisibleEnemy.setMonsterDoorTimer(4.5)
				1:
					invisibleEnemy.setInvisibleEnemyPhase(2)
					monsters.changeDifficulty(4.2,6)
					monsters.cooldown(7,10)
					invisibleEnemy.setMonsterDoorTimer(4)
				2:
					invisibleEnemy.setInvisibleEnemyPhase(2)
					monsters.changeDifficulty(5.2,10)
					monsters.cooldown(1,7)
					invisibleEnemy.setMonsterDoorTimer(2.5)
		#PHASE3
		PHASE3:
			invisibleEnemy.setInvisibleEnemyPhase(2)
			invisibleEnemy.setSanityDrain(0.04)
			match fear:
				0:
					monsters.changeDifficulty(3.2,3)
					monsters.cooldown(8,10)
					invisibleEnemy.setMonsterDoorTimer(4)
				1:
					monsters.changeDifficulty(4.2,8)
					monsters.cooldown(5,8)
					invisibleEnemy.setMonsterDoorTimer(3.5)
				2:
					monsters.changeDifficulty(5.2,10)
					monsters.cooldown(1,5)
					invisibleEnemy.setMonsterDoorTimer(2)
		#PHASE4
		PHASE4:
			invisibleEnemy.setInvisibleEnemyPhase(2)
			invisibleEnemy.setSanityDrain(0.05)
			match fear:
				0:
					monsters.changeDifficulty(3.2,3)
					monsters.cooldown(6,8)
					invisibleEnemy.setMonsterDoorTimer(3)
				1:
					monsters.changeDifficulty(4.2,8)
					monsters.cooldown(3,6)
					invisibleEnemy.setMonsterDoorTimer(2)
				2:
					monsters.changeDifficulty(5.2,10)
					monsters.cooldown(1,3)
					invisibleEnemy.setMonsterDoorTimer(1)


func difficultySet(difficulty):
	match difficulty:
		1:
			invisibleEnemy.setSanityDrain(0.015)
			get_tree().call_group("monsterController", "changeDifficulty", 2, 3)
			get_tree().call_group("monsterController", "cooldown", 10, 30)
			get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 5)
			get_tree().call_group("monster", "setMonsterPhase", 0)
			get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)

		2:
			
			invisibleEnemy.setSanityDrain(0.02)
			
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
				get_tree().call_group("monsterController", "changeDifficulty", 3.2, 6)
				get_tree().call_group("monsterController", "cooldown", 5, 10)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 4)
			elif $CanvasLayer/Sanity.getSanityBarValue() >= 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 4.2, 10)
				get_tree().call_group("monsterController", "cooldown", 2, 5)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 3)
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 1)
				get_tree().call_group("monsterController", "changeDifficulty", 2, 3)
				get_tree().call_group("monsterController", "cooldown", 10, 15)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 4.5)
		4:
			pass
			
			
			#get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
		5:
			#get_tree().call_group("monsterController", "changeDifficulty", 3, 4)
			#get_tree().call_group("monsterController", "cooldown", 4, 5)
			#get_tree().call_group("door", "setMonsterDoorTimer", 2)
			#get_tree().call_group("monster", "setMonsterPhase", 1)
			invisibleEnemy.setSanityDrain(0.035)
			
			if $CanvasLayer/Sanity.getSanityBarValue() > 50 and $CanvasLayer/Sanity.getSanityBarValue() < 90:
				get_tree().call_group("monsterController", "changeDifficulty", 4.2, 8)
				get_tree().call_group("monsterController", "cooldown", 2, 4)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 2)
			elif $CanvasLayer/Sanity.getSanityBarValue() >= 90:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 5.2, 10)
				get_tree().call_group("monsterController", "cooldown", 1, 2)
				get_tree().call_group("invisibleEnemy", "setMonsterDoorTimer", 1)
			
				
				
			elif $CanvasLayer/Sanity.getSanityBarValue() <= 50:
				get_tree().call_group("invisibleEnemy", "setInvisibleEnemyPhase", 2)
				get_tree().call_group("monsterController", "changeDifficulty", 3.2, 3)
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
	bunnyManager.startTimer()
	#$Navigation/invisibleEnemy/monsterSpawner/CollisionShape.disabled = false
	#player.toggleFlashlight(true)
	#spotlightManager.pickLight()


func _on_punishmentTimer_timeout():
	state = GAME
	#get_tree().call_group("invisibleEnemy", "setStateFollow")
	get_tree().call_group("monsterController", "setStateCooldown")
	$CanvasLayer/Sanity.visible = true
	$Audio/fearNoise.stop()
	bunnyManager.startTimer()
	#$Navigation/invisibleEnemy/monsterSpawner/CollisionShape.disabled = false
	#get_tree().call_group("player", "toggleFlashlight", true)
	#spotlightManager.pickLight()

func playerTransition():
	if state == START:
		state = GAME
		player.set_deferred("translation", positions.get_node("myBedroom").translation)
#	elif phase == PHASE1:
#		player.set_deferred("translation", positions.get_node("PositionmyBedroom").translation)
	elif phase == PHASE4:
		get_tree().change_scene("res://gameOver.tscn")	
	

func setPunishmentTimer(time):
	$punishmentTimer.wait_time = time


func _on_darkScaryHorn_finished():
	if state == START:
		scaryHornSoundFinished = true
