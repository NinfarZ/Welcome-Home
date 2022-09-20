extends Spatial

#States for if the monster is active and staring at target, 
#or if a target is not yet picked

enum {
	SEARCHING
	STALKING
	CHANGING
	ANGER
	ROOMCHANGE
	KILL
	COOLDOWN
}

export(NodePath) var invisibleMonsterPath
onready var invisibleMonster = get_node(invisibleMonsterPath)

var state = SEARCHING
var currentMonster = null
var monsterCanDespawn = false
var lastMonster = null



#monsters that can currently see the player (possible to be spawned)
var monstersInRange = []

func _ready():
	randomize()

#TO DO: Make it so monster can disappear as soon as the timer is down. No need to move out of view of the monster
func _physics_process(delta):
	
	match state:
		SEARCHING:
			#print("monster is searching")
			#for monster in get_children():
				#for raycast in monster.get_node("Cube001").get_children():
					#if raycast.is_colliding():
			invisibleMonster.setStateFollow()
			for monster in get_children():
				if monster.isCanSpawn() and monster.isMonsterInPlayerLocation() and monster.is_in_group(invisibleMonster.get_current_monstersToSpawn()) and monster != lastMonster: #
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
					spawnMonster(currentMonster)
				else:
					monstersInRange = []
					state = COOLDOWN
					get_parent().get_node("TimerMonsterCooldown").wait_time = RNGTools.randi_range(5,10)
					get_parent().get_node("TimerMonsterCooldown").start()
		STALKING:
			print(currentMonster + " is staking hehe")
			#for raycast in get_node(currentMonster).get_node("Cube001").get_children():
				#if not raycast.is_colliding():
			get_parent().get_node("TimerMonsterSwitch").start()
			invisibleMonster.setStateStop()
			state = CHANGING
		CHANGING:
			#check if player still inside monsters room
			if not get_node(currentMonster).isMonsterInPlayerLocation():
				get_parent().get_node("TimerMonsterSwitch").stop()
				despawnMonster(currentMonster)
				state = ROOMCHANGE
			
			if get_node(currentMonster).canSeePlayer() and get_node(currentMonster).isFaceInView():
				get_node(currentMonster).playerLooksAtMonster()
					#print(get_node(currentMonster).name + " can see you")
					#invisibleMonster.setStateFollow()
				state = ANGER
				#else:
					#invisibleMonster.setStateStop()
			elif monsterCanDespawn:
				if not get_node(currentMonster).canSeePlayer() or not get_node(currentMonster).isInView():
					despawnMonster(currentMonster)
					monsterCanDespawn = false
					state = SEARCHING
		ANGER:
			incrementDifficulty()
			get_tree().call_group("sanityBar", "drainSanity", 1.17)
			get_tree().call_group("flashlight", "flicker")
			state = CHANGING
		ROOMCHANGE:
			#print("rommchange, monster disappeared")
			#if get_parent().get_node("TimerMonsterSwitch").get_time_left() == 0:
			#yield(get_tree().create_timer(5.0),"timeout")
			state = SEARCHING
		KILL:
			get_node(currentMonster).killPlayer()
			#print("player has been killed")
		
		COOLDOWN:
			#print("monster spawner is on cooldown!")
			pass
			
			
			
		
		

func add_monster_to_list(monster):
	if not monster.name in monstersInRange:
		monstersInRange.append(monster.name)

func remove_monster_from_list(monster):
	var i = 0
	while i < monstersInRange.size():
		if monstersInRange[i] == monster.name:
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
	
	chosenMonster = monstersInRange[randi() % monstersInRange.size()]
	print(chosenMonster)
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
	get_node(chosenMonster).set_state_active()
	get_node(chosenMonster).makeCreepySound()
	lastMonster = get_node(currentMonster)
	state = STALKING
	#else:
		#return

func despawnMonster(chosenMonster):
	get_node(chosenMonster).set_state_hiding()
	#invisibleMonster.setStateFollow()
	monstersInRange = []


	

func incrementDifficulty():
	get_parent().get_node("TimerMonsterSwitch").wait_time -=0.05
	get_parent().get_node("TimerMonsterSwitch").wait_time = clamp(get_parent().get_node("TimerMonsterSwitch").wait_time, 8, 10)
	#print(get_parent().get_node("TimerMonsterSwitch").wait_time)
	invisibleMonster.setSpeedIncrease(0.01)
	invisibleMonster.speed = clamp(invisibleMonster.speed, 1, 4)
	#print(invisibleMonster.speed)
	
	

func _on_monsterSpawner_area_entered(area):
	#print("there are monsters here")
	pass


func _on_monsterSpawner_area_exited(area):
	monstersInRange = []


func _on_TimerMonsterCooldown_timeout():
	state = SEARCHING
