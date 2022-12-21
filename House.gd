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

				doorManager.lockDoor($Doors/Door5)

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
				state = START
		START:
			if scaryHornSoundFinished:
				monsters.get_node("yellowgirl75").shadeFace(true)
				monsters.despawnMonster(monsters.get_node("yellowgirl75"))
				scaryHornSoundFinished = false
				$TransitionScreen.transition()
				

		GAME:

				
			match phase:
				PHASE0:

					if not CandyRandomized:
						for label in $TutorialLabels.get_children():
							label.visible = false
						doorManager.unlockLastDoor()
						doorManager.lockDoor($Doors/Door)
						keyManager.placeKey(keyManager.get_node("Key7"))
						
						lightsToTurnOn = ["MyBedroom", "Corridor3", "Corridor2", "Bathroom2"]
						for light in lightsToTurnOn:
							spotlightManager.turnOnLight("spotlight" + light)
	
	
						basketManager.moveBasketToPosition(basketManager.get_node("locations/bedRoom2"))
						basketManager.setCurrentCandyAmount(5)
					
						candyManager.randomizeCandy(2, candyManager.get_node("myBedroom"))
						candyManager.randomizeCandy(2, candyManager.get_node("corridor"))
						candyManager.randomizeCandy(2, candyManager.get_node("bedRoom2"))
						CandyRandomized = true
						candyBasket.displayText(10)
					#if the basket is full, moves to phase1
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						monsterTriggered = false
						phase = PHASE1
					

					#wakes up monster after grabbing the key and heading to corridor
					elif not monsterTriggered and doorManager.get_node("Door").isLocked():
						if player.get_current_location() == "corridor1" and keyManager.getHasKey():
							monsters.spawnMonster(monsters.get_node("yellowgirl85"))
							doorManager.get_node("Door").playMonsterLockedDoor()
							monsterTriggered = true
							yield(get_tree().create_timer(4),"timeout")
							$Audio/suspencePiano.play()
		
					#after door is unlocked, monster can move around
					elif monsterTriggered:
						if not doorManager.get_node("Door").isLocked():
							monsters.despawnMonster(monsters.get_node("yellowgirl85"))
							spotlightManager.turnAllLightsOff()
							spotlightManager.startTimer()
							monsters.setStateSearching()
							invisibleEnemy.isMonsterActive(true)
							monsterTriggered = false
					

				PHASE1:
					#MONSTERS CAN SPAWN BUT NOT DANGEROUS, JUST SCARY
					
					if not CandyRandomized:
						for letter in $Letters.get_children():
							letter.visible = false
							letter.get_node("CollisionShape").disabled = true
							
						
						furnitureManager.setBarricade(furnitureManager.get_node("barricade3"), false)
						furnitureManager.setBarricade(furnitureManager.get_node("barricade4"), false)
						
						spreadCandyAcrossMap(13)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true

						candyBasket.displayText(18)

						
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
					
						
						phase = PHASE2
							
				PHASE2:
					
					if not CandyRandomized:
						furnitureManager.setBarricade(furnitureManager.get_node("barricade2"), false)
						spreadCandyAcrossMap(12)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						
						CandyRandomized = true
						bunnyManager.startTimer()
						
						
						candyBasket.displayText(26)
						
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						
						phase = PHASE3
						
				PHASE3:
					
					if not CandyRandomized:
						$mannequim.visible = false
						spreadCandyAcrossMap(8)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						
						
						
						candyBasket.displayText(34)
						
					
						
					elif candyBasket.getIsBasketFull():
						$Audio/basketTransition.play()
						CandyRandomized = false
						
						phase = PHASE4
				PHASE4:
					
					if not CandyRandomized:
						$Audio/lastPhase.play()
						spreadCandyAcrossMap(6)
						
						lockedDoor = doorManager.pickDoor()
						doorManager.lockDoor(lockedDoor)
						
						currentKey = keyManager.chooseKey()
						keyManager.placeKey(currentKey)
			
						basketManager.changeBasketLocation()
						
						CandyRandomized = true
						
						
						candyBasket.displayText(42)
					
						
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
				spotlightManager.startTimer()
			
				$punishmentTimer.start()
			
				get_tree().call_group("monsterController", "setStateHunting")
			
			elif phase == PHASE4 and candyBasket.getIsBasketFull():
				punishmentEnd()
			elif spotlightManager.getCurrentLight() != null:
				if spotlightManager.getIsPlayerInSpotlight():
					punishmentEnd()
				
			
func deathSequence():
	$punishmentTimer.stop()
	player.die()
	monsters.set_physics_process(false)
	$Audio/BackgroundAmbience.stop()
	$Audio/fearNoise.stop()
	GlobalNode.playDeathMusic()
	yield(get_tree().create_timer(2), "timeout")
	endGame()
	
	
func fade_out():
	$Audio/deathMusic/Tween.interpolate_property($Audio/deathMusic, "volume_db", 0, -40, 1)
	$Audio/deathMusic/Tween.start()



func endGame():
	GameData.setIsPlayerDead(true)
	get_tree().change_scene("res://gameOver.tscn")

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
	monsters.setStateSearching()
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
		var canBeRandomized = candyManager.randomizeCandy(candyAmount, location)
		if not canBeRandomized:
			return
		else:
			locationList.erase(location)
			candyToSpread -= candyAmount
		

func controlDifficulty(fear):
	match phase:
		PHASE0:
			invisibleEnemy.setInvisibleEnemyPhase(1)
			spotlightManager.setSanityDrain(0.013)
			monsters.changeDifficulty(2,3,-1)
		PHASE1:
			invisibleEnemy.setInvisibleEnemyPhase(1)
			spotlightManager.setSanityDrain(0.014)
			match fear:
				0:
					monsters.changeDifficulty(2,3,25)
					monsters.cooldown(10,30)
					invisibleEnemy.setMonsterDoorTimer(5)
					
				1:
					monsters.changeDifficulty(2,4,50)
					monsters.cooldown(10,25)
					invisibleEnemy.setMonsterDoorTimer(4.5)
				2:
					monsters.changeDifficulty(3.2,4,70)
		PHASE2:
			spotlightManager.setSanityDrain(0.015)
			match fear:
				0:
					
					invisibleEnemy.setInvisibleEnemyPhase(1)
					monsters.changeDifficulty(3.2,3,70)
					monsters.cooldown(10,15)
					invisibleEnemy.setMonsterDoorTimer(4.5)
				1:
					invisibleEnemy.setInvisibleEnemyPhase(2)
					monsters.changeDifficulty(3.5,6,80)
					monsters.cooldown(7,10)
					invisibleEnemy.setMonsterDoorTimer(4)
				2:
					invisibleEnemy.setInvisibleEnemyPhase(2)
					monsters.changeDifficulty(4.2,10,90)
					monsters.cooldown(1,7)
					invisibleEnemy.setMonsterDoorTimer(2.5)
		PHASE3:
			invisibleEnemy.setInvisibleEnemyPhase(2)
			spotlightManager.setSanityDrain(0.015)
			match fear:
				0:
					monsters.changeDifficulty(3.2,3,70)
					monsters.cooldown(8,10)
					invisibleEnemy.setMonsterDoorTimer(4)
				1:
					monsters.changeDifficulty(3.5,8,80)
					monsters.cooldown(5,8)
					invisibleEnemy.setMonsterDoorTimer(3.5)
				2:
					monsters.changeDifficulty(4.2,10,90)
					monsters.cooldown(1,5)
					invisibleEnemy.setMonsterDoorTimer(2)
		PHASE4:
			invisibleEnemy.setInvisibleEnemyPhase(2)
			spotlightManager.setSanityDrain(0.016)
			match fear:
				0:
					monsters.changeDifficulty(3.2,3,70)
					monsters.cooldown(6,8)
					invisibleEnemy.setMonsterDoorTimer(3)
				1:
					monsters.changeDifficulty(3.5,8,80)
					monsters.cooldown(3,6)
					invisibleEnemy.setMonsterDoorTimer(2.5)
				2:
					monsters.changeDifficulty(4.2,10,90)
					monsters.cooldown(1,3)
					invisibleEnemy.setMonsterDoorTimer(2)

func _on_bunnySpawnTimer_timeout():
	var bunnyList = $Bunnies.get_children()
	currentBunny = RNGTools.pick(bunnyList)
	currentBunny.get_node("bunny").setState(0)
	currentBunny.get_node("bunny").playMusicBox()

func punishmentEnd():
	state = GAME
	monsters.setStateCooldown()
	$Audio/fearNoise.stop()
	$punishmentTimer.stop()
	bunnyManager.startTimer()


func _on_punishmentTimer_timeout():
	state = GAME
	monsters.setStateCooldown()
	$Audio/fearNoise.stop()
	bunnyManager.startTimer()

func playerTransition():
	if state == START:
		state = GAME
		player.set_deferred("translation", positions.get_node("myBedroom").translation)
	elif phase == PHASE4:
		get_tree().change_scene("res://gameOver.tscn")	
	

func setPunishmentTimer(time):
	$punishmentTimer.wait_time = time


func _on_darkScaryHorn_finished():
	if state == START:
		scaryHornSoundFinished = true
