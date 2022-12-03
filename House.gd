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
				
				
				basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionLivingroom"))
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
					
					difficultySet(1)
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
	
	
						basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionBedroom2"))
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
					#MONSTERS CAN SPAWN, EASY DIFFUCLTY
					
					difficultySet(2)
					if not CandyRandomized:
						for letter in $Letters.get_children():
							letter.visible = false
							letter.get_node("CollisionShape").disabled = true
							
						
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
					#MEDIUM DIFFICULTY
					
					difficultySet(3)
					if not CandyRandomized:
						furnitureManager.setBarricade(furnitureManager.get_node("barricade4"), false)
						furnitureManager.setBarricade(furnitureManager.get_node("barricade2"), false)
						candyManager.randomizeCandy(2, candyManager.get_node("livingroom"))
						candyManager.randomizeCandy(1, candyManager.get_node("kitchen"))
						candyManager.randomizeCandy(1, candyManager.get_node("bathroom2"))
						candyManager.randomizeCandy(3, candyManager.get_node("bedRoom3"))
						candyManager.randomizeCandy(1, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(2, candyManager.get_node("bedRoom2"))
						
						doorManager.lockDoor($Doors/Door5)
						keyManager.placeKey(keyManager.get_node("Key2"))
			
						basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionKitchen"))
						
						
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
					
					difficultySet(4)
					if not CandyRandomized:
						$mannequim.visible = false
						candyManager.randomizeCandy(1, candyManager.get_node("livingroom"))
						candyManager.randomizeCandy(1, candyManager.get_node("kitchen"))
						candyManager.randomizeCandy(3, candyManager.get_node("bathroom1"))
						candyManager.randomizeCandy(1, candyManager.get_node("bedRoom3"))
						candyManager.randomizeCandy(2, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(1, candyManager.get_node("bedRoom2"))
						
						doorManager.lockDoor($Doors/Door3)
						keyManager.placeKey(keyManager.get_node("Key16"))
			
						basketManager.moveBasketToPosition(basketManager.get_node("locations/PositionBathroom2"))
						
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
					
					difficultySet(5)
					if not CandyRandomized:
						$Audio/lastPhase.play()
						for location in candyManager.get_children():
							candyManager.randomizeCandy(1, location)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						
						
						candyBasket.displayText(47)
					
						
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
	player.set_deferred("translation", positions.get_node("PositionmyBedroom").translation)
	spotlightManager.startTimer()
	$FlashlightItem.get_node("flashlight").interact()
	monsters.setStateCooldown()
	invisibleEnemy.isMonsterActive(true)
	basketManager.setCurrentCandyAmount(9)
	

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
