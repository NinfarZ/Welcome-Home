extends Spatial

#States for if the monster is active and staring at target, 
#or if a target is not yet picked

enum {
	IDLE
	SEARCHING
	STALKING
	CHANGING
	ANGER
	ROOMCHANGE
	KILL
	COOLDOWN
	HUNTING
}

export(NodePath) var invisibleMonsterPath
onready var invisibleMonster = get_node(invisibleMonsterPath)

var state = IDLE
var currentMonster = null
var monsterCanDespawn = false
var lastMonster = null
var monsterActive = false
var rngCreepyBehavior = null

var playerStaringAtMonster = false

var cooldownValues = [5, 10]



#monsters that can currently see the player (possible to be spawned)
var monstersInRange = []

func _ready():
	randomize()

#TO DO: Make it so monster can disappear as soon as the timer is down. No need to move out of view of the monster
func _physics_process(delta):
	
	match state:
		IDLE:
			invisibleMonster.setStateFollow()
			
		SEARCHING:
			monsterActive = false
			#print("monster is searching")
			#for monster in get_children():
				#for raycast in monster.get_node("Cube001").get_children():
					#if raycast.is_colliding():
			invisibleMonster.setStateFollow()
			for monster in get_children():
				if monster.isCanSpawn() and monster.isPlayerInViewcone() and monster.isMonsterInPlayerLocation() and monster.is_in_group(invisibleMonster.get_current_monstersToSpawn()) and monster != lastMonster: #and monster.isMonsterInPlayerLocation()
					#monster.enableArea()
					#print("monster can spawn")
					add_monster_to_list(monster)
				else:
					#monster.set_state_hiding()
					#monster.disableArea()
					remove_monster_from_list(monster)
			
			if monstersInRange != []:
				if RNGTools.pick([1,0,0]) == 1:
					currentMonster = RNGTools.pick(monstersInRange)
					#get_node(currentMonster).makeCreepySound()
					spawnMonster(currentMonster)
					state = STALKING
				else:
					monstersInRange = []
					state = COOLDOWN
					
		STALKING:
			print(currentMonster.name + " is staking hehe")
			#for raycast in get_node(currentMonster).get_node("Cube001").get_children():
				#if not raycast.is_colliding():
			get_parent().get_node("TimerMonsterSwitch").start()
			invisibleMonster.setStateStop()
			state = CHANGING
		CHANGING:
			#check if player has left the crouch monster's area so they can despawn
#			if get_node(currentMonster).is_in_group("crouchMonster") and not get_node(currentMonster).canCrouchMonsterAttack:
#				get_parent().get_node("TimerMonsterSwitch").stop()
#				despawnMonster(currentMonster)
#				state = ROOMCHANGE

			#print(rad2deg(get_node(currentMonster).get_node("Head").rotation.x))
			
			if currentMonster.canSeePlayer() and currentMonster.isFaceInView():
				currentMonster.playerLooksAtMonster()	
				state = ANGER
				
				
			elif not currentMonster.isMonsterInPlayerLocation():
				get_parent().get_node("TimerMonsterSwitch").stop()
				despawnMonster(currentMonster)
				#get_parent().get_node("TimerMonsterCooldown").start()
				state = COOLDOWN
			
			#if the player is away from the monster's view cone, it despawns
			elif not currentMonster.isPlayerInViewcone():
				despawnMonster(currentMonster)
					#print("monster can't see play so was removed")
				get_parent().get_node("TimerMonsterSwitch").stop()
				#monsterCanDespawn = false
				#get_parent().get_node("TimerMonsterCooldown").start()
				state = COOLDOWN
					
			elif monsterCanDespawn:
				if not currentMonster.isInView():
					print("monster cooldown over so can despawn")
					despawnMonster(currentMonster)
					monsterCanDespawn = false
					#get_parent().get_node("TimerMonsterCooldown").start()
					state = COOLDOWN
		ANGER:
			#incrementDifficulty()
			get_tree().call_group("sanityBar", "drainSanity", 1.17)
			get_tree().call_group("flashlight", "flicker")
			state = CHANGING
		ROOMCHANGE:
			#print("rommchange, monster disappeared")
			#if get_parent().get_node("TimerMonsterSwitch").get_time_left() == 0:
			#yield(get_tree().create_timer(5.0),"timeout")
			#state = SEARCHING
			get_parent().get_node("TimerMonsterSwitch").start()
			if monsterCanDespawn:
				state = SEARCHING
		KILL:
			currentMonster.killPlayer()
			#print("player has been killed")
		
		COOLDOWN:
			invisibleMonster.setStateFollow()
			if get_parent().get_node("TimerMonsterCooldown").is_stopped():
				get_parent().get_node("TimerMonsterCooldown").wait_time = RNGTools.randi_range(cooldownValues[0], cooldownValues[1])
				#print(get_parent().get_node("TimerMonsterCooldown").wait_time)
				get_parent().get_node("TimerMonsterCooldown").start()
				rngCreepyBehavior = RNGTools.pick([1,0])
			#monster creeps around. Not dangerous but creepy
			elif rngCreepyBehavior == 1:
				#monster can either peek for a split second or appear in the form of invisible enemy
				if not monsterActive:
					for monster in get_children():
						if monster.isCanSpawn() and monster.isPlayerInViewcone() and monster.isMonsterInPlayerLocation() and monster.is_in_group(invisibleMonster.get_current_monstersToSpawn()) and monster != lastMonster and monster.getDistanceFromPlayer() > 10:
							add_monster_to_list(monster)
						else:
							remove_monster_from_list(monster)
							
					if monstersInRange != []:
						currentMonster = RNGTools.pick(monstersInRange)
						
						spawnMonster(currentMonster)
						monsterActive = true
				elif currentMonster.isInView():
					if get_parent().get_node("monsterCreepTimer").is_stopped():
						get_parent().get_node("monsterCreepTimer").start()
			else:
				if not monsterActive:
					if not invisibleMonster.getIsInView() and invisibleMonster.getDistanceToPlayer() > 20:
						invisibleMonster.setBodyVisible(true)
						monsterActive = true
				elif invisibleMonster.getIsInView() or invisibleMonster.getDistanceToPlayer() <= 15:
					if get_parent().get_node("monsterCreepTimer").is_stopped():
						get_parent().get_node("monsterCreepTimer").start()
					
				#invisibleMonster.monsterIsVisibleForMoment()
					#monsterActive = true
					
			
				#yield(get_tree().create_timer(0.1),"timeout")
				
			
		HUNTING:
			despawnMonster(currentMonster)
			monsterActive = false
			get_parent().get_node("TimerMonsterCooldown").stop()
			get_parent().get_node("TimerMonsterSwitch").stop()
			
			
			
		
		

func add_monster_to_list(monster):
	if not monster in monstersInRange:
		monstersInRange.append(monster)

func remove_monster_from_list(monster):
	var i = 0
	while i < monstersInRange.size():
		if monstersInRange[i] == monster:
				monstersInRange.pop_at(i)
		i += 1

#checks if player is in range
func player_in_range(raycast):
	if raycast != null:
		if raycast.get_collider().name == "AreaPlayer":
			return true
		return false

#picks a random monster from those that are currently in range
func pickRandomMonster():
	var chosenMonster
	
	#chosenMonster = monstersInRange[randi() % monstersInRange.size()]
	chosenMonster = RNGTools.pick(monstersInRange)
	#print(chosenMonster)
	#get_node(chosenMonster).set_state_active()
	#state = STALKING
	return chosenMonster
	


func _on_TimerMonsterSwitch_timeout():
	#print("timer ran out!")
	monsterCanDespawn = true
	
	#else:
		#state = SEARCHING
	#if get_node(currentMonster).canSeePlayer() == false or get_node(currentMonster).isInView() == false:
		#despawnMonster(currentMonster)
		#state = SEARCHING

func spawnMonster(chosenMonster):
	#if RNGTools.randi_range(-10,10) < 0:
	chosenMonster.set_state_active()
	#get_node(chosenMonster).makeCreepySound()
	lastMonster = currentMonster
	#state = STALKING
	#else:
		#return

func despawnMonster(chosenMonster):
	if chosenMonster != null:
		chosenMonster.set_state_hiding()
	#invisibleMonster.setStateFollow()
		monstersInRange = []


	

func changeDifficulty(newSpeed, newTime):
	get_parent().get_node("TimerMonsterSwitch").wait_time = newTime
	#get_parent().get_node("TimerMonsterSwitch").wait_time = clamp(get_parent().get_node("TimerMonsterSwitch").wait_time, 8, 10)
	#print(get_parent().get_node("TimerMonsterSwitch").wait_time)
	invisibleMonster.setSpeedIncrease(newSpeed)
	#invisibleMonster.speed = clamp(invisibleMonster.speed, 1, 4)
	#print(invisibleMonster.speed)

func cooldown(minValue, maxValue):
	#get_parent().get_node("TimerMonsterCooldown").wait_time = RNGTools.randi_range(minValue, maxValue)
	cooldownValues = [minValue, maxValue]
	


func _on_monsterSpawner_area_entered(area):
	#print("there are monsters here")
	pass


func _on_monsterSpawner_area_exited(area):
	monstersInRange = []
	despawnMonster(currentMonster)


func _on_TimerMonsterCooldown_timeout():
	if monsterActive:
		despawnMonster(currentMonster)
		monsterActive = false
	state = SEARCHING

func setStateIdle():
	state = IDLE
func setStateSearching():
	state = SEARCHING
func setStateCooldown():
	state = COOLDOWN
func setStateHunting():
	state = HUNTING


func _on_monsterCreepTimer_timeout():
	if rngCreepyBehavior == 1:
		despawnMonster(currentMonster)
	else:
		invisibleMonster.setBodyVisible(false)
	monsterActive = false
