extends Spatial

enum {
	IDLE
	SEARCHING
	STALKING
	CHANGING
	ANGER
	KILL
	COOLDOWN
	HUNTING
}

export(NodePath) var invisibleMonsterPath
export(NodePath) var playerPath
onready var invisibleMonster = get_node(invisibleMonsterPath)
onready var player = get_node(playerPath)
onready var monsterSoundTimer = get_parent().get_node("monsterSoundTimer")

var state = IDLE
var currentMonster = null
var monsterCanDespawn = false
var lastMonster = null
var monsterActive = false
var rngCreepyBehavior = null
var monsterCanMakeSound = true
var spawnChance = 25

var cooldownValues = [5, 10]



#monsters that can currently see the player (possible to be spawned)
var validMonsters = []
var monstersInRange = []

func _ready():
	for monster in get_children():
		monster.connect("monsterInRange", self, "_addMonsterInRange")
		monster.connect("monsterOutOfRange", self, "_removeMonsterOutOfRange")
		monster.connect("monsterShouldDespawn", self, "_stopMonsterStalking")
	invisibleMonster.setBodyVisible(false)

	randomize()


func _physics_process(delta):
	
	match state:
		IDLE:
			pass
			
		SEARCHING:
			invisibleMonster.setStateFollow()
			if monstersInRange != []:
				for monster in monstersInRange:
					createSpawnableMonsterList(monster, 2)
			
			if validMonsters != []:
				if RNGTools.randi_range(0, 100) <= spawnChance:
					currentMonster = RNGTools.pick(validMonsters)
	
					spawnMonster(currentMonster)
					state = STALKING
				else:
					validMonsters = []
					setStateCooldown()
					
		STALKING:
			print(currentMonster.name + " is staking hehe")

			get_parent().get_node("TimerMonsterSwitch").start()
			invisibleMonster.setStateStop()
			state = CHANGING
		CHANGING:

			if currentMonster.canSeePlayer() and currentMonster.isFaceInView():
				currentMonster.playerLooksAtMonster()
				state = ANGER
			
					
			elif monsterCanDespawn:
				if not currentMonster.isInView():
					print("monster cooldown over so can despawn")
					despawnMonster(currentMonster)
					monsterCanDespawn = false

					setStateCooldown()
			
		ANGER:
			currentMonster.flickerFace(RNGTools.pick([1,2]))
			currentMonster.makeCreepySound(RNGTools.pick([1,2]))
			get_tree().call_group("sanityBar", "drainSanity", 2.2)
			if player.getFlashlightPower():
				get_tree().call_group("flashlight", "flicker")
			else:
				get_tree().call_group("flashlight", "flicker2")
			
			get_tree().call_group("sanityBar", "isPlayerDead")
			
			state = CHANGING
		KILL:
			currentMonster.killPlayer()
		
		COOLDOWN:
			if get_parent().get_node("TimerMonsterCooldown").is_stopped():
				get_parent().get_node("TimerMonsterCooldown").wait_time = RNGTools.randi_range(cooldownValues[0], cooldownValues[1])
				get_parent().get_node("TimerMonsterCooldown").start()
				rngCreepyBehavior = RNGTools.pick([1,0])
			#monster creeps around. Not dangerous but creepy
			elif rngCreepyBehavior == 1:
				#monster can peek for a split second 
				if not monsterActive:
					if monstersInRange != []:
						for monster in monstersInRange:
							createSpawnableMonsterList(monster, 13)
							
					if validMonsters != []:
						currentMonster = RNGTools.pick(validMonsters)
						
						spawnMonster(currentMonster)
						monsterActive = true
				elif currentMonster.isInView() or currentMonster.getDistanceFromPlayer() <= 13:
					if get_parent().get_node("monsterCreepTimer").is_stopped():
						get_parent().get_node("monsterCreepTimer").wait_time = 0.3
						get_parent().get_node("monsterCreepTimer").start()
			#monster can appear walking behind the player
			elif rngCreepyBehavior == 0:
				if not monsterActive:
					if not invisibleMonster.getIsInView() and invisibleMonster.getDistanceToPlayer() > 13:
						print("monster is behind you!!")
						invisibleMonster.setBodyVisible(true)
						monsterActive = true
					
				elif invisibleMonster.getIsInView() or invisibleMonster.getDistanceToPlayer() <= 13:
					if get_parent().get_node("monsterCreepTimer").is_stopped():
						get_parent().get_node("monsterCreepTimer").wait_time = 0.4
						get_parent().get_node("monsterCreepTimer").start()
		

		HUNTING:
			invisibleMonster.setStateChase()
			despawnMonster(currentMonster)
			monsterActive = false
			get_parent().get_node("TimerMonsterCooldown").stop()
			get_parent().get_node("TimerMonsterSwitch").stop()
			


func add_monster_to_list(monster):
	if not monster in validMonsters:
		validMonsters.append(monster)

func remove_monster_from_list(monster):
	if monster in validMonsters:
		validMonsters.erase(monster)


func createSpawnableMonsterList(monster, distance):
	if not monster.isCanSpawn():
		return
	if monster == lastMonster:
		return
	if monster.getDistanceFromPlayer() <= distance:
		return
	if not monster.is_in_group(invisibleMonster.get_current_monstersToSpawn()):
		return
	if monster.isMonsterPositionedToSpawn(): 
		add_monster_to_list(monster)
	else:
		remove_monster_from_list(monster)


func _on_TimerMonsterSwitch_timeout():
	monsterCanDespawn = true


func spawnMonster(chosenMonster):
	chosenMonster.set_state_active()
	lastMonster = currentMonster
	if RNGTools.pick([1,0]) == 1 and monsterCanMakeSound:
		chosenMonster.makeCreepySound(1)
		monsterCanMakeSound = false
		monsterSoundTimer.start()



func despawnMonster(chosenMonster):
	if chosenMonster != null:
		chosenMonster.set_state_hiding()
		validMonsters = []



func changeDifficulty(newSpeed, newTime, newSpawnChance):
	get_parent().get_node("TimerMonsterSwitch").wait_time = newTime
	spawnChance = newSpawnChance
	invisibleMonster.setSpeedIncrease(newSpeed)


func cooldown(minValue, maxValue):
	cooldownValues = [minValue, maxValue]
	

func _on_TimerMonsterCooldown_timeout():
	despawnMonster(currentMonster)
	invisibleMonster.setBodyVisible(false)
	monsterActive = false
	state = SEARCHING

func _addMonsterInRange(monster):
	if not monster in monstersInRange:
		monstersInRange.append(monster)
		monster.enableMonster(true)

func _removeMonsterOutOfRange(monster):
	if monster in monstersInRange:
		monstersInRange.erase(monster)
		monster.enableMonster(false)
		if monster.getIsActive() and not state == IDLE:
			despawnMonster(monster)
			get_parent().get_node("TimerMonsterSwitch").stop()
			setStateCooldown()

func _stopMonsterStalking(monster):
	if not state == COOLDOWN and not state == IDLE:
		despawnMonster(monster)
		get_parent().get_node("TimerMonsterSwitch").stop()
		setStateCooldown()
	

func setStateIdle():
	state = IDLE
	
func setStateSearching():
	if not get_parent().get_node("TimerMonsterCooldown").is_stopped():
		monsterActive = false
		despawnMonster(currentMonster)
		invisibleMonster.setBodyVisible(false)
		get_parent().get_node("TimerMonsterCooldown").stop()
	state = SEARCHING
	
func setStateCooldown():
	state = COOLDOWN
	invisibleMonster.setStateFollow()
	
func setStateHunting():
	state = HUNTING

func setMonsterActive(value):
	monsterActive = value

func _on_monsterCreepTimer_timeout():
	if rngCreepyBehavior == 1:
		despawnMonster(currentMonster)
		monsterActive = false
		rngCreepyBehavior = 0
	if rngCreepyBehavior == 0:
		invisibleMonster.setBodyVisible(false)
		monsterActive = false


func _on_monsterSoundTimer_timeout():
	monsterCanMakeSound = true
