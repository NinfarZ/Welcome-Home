extends KinematicBody

export var speed = 2

enum {
	PATROL,
	STOP,
	FOLLOWPLAYER,
	KILLPLAYER
}

enum {
	PHASE1
	PHASE2
	PHASE3
}

var state = FOLLOWPLAYER
var phase = PHASE1

var path = []
var current_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var threshold = 0.1
var offset = Vector3(10,10,10)
var decreaseScale = Vector3(0.01, 0.01, 0.01)
var invisibleEnemyInview = false

var canPlaySound = true
var timesSoundPlayed = 1
var timeFootstepPlayed = 1

var currentLocation = null
var monstersToSpawn = null

onready var nav = get_parent()

func _ready():
	#randomize()
	yield(owner, "ready")
	target = owner.player

func _physics_process(delta):
	match state:
		FOLLOWPLAYER:
			if path.size() > 0:
				move_to_target()
			if RNGTools.pick([1,0]) == 1:
				if currentLocation != null and currentLocation == target.get_current_location():
					match phase:
						PHASE1:
							pass
						PHASE2:
							if not $RandomAudioStreamPlayer.playing and canPlaySound:
								$RandomAudioStreamPlayer.play()
								$RandomAudioStreamPlayer/TimerAudio.start()
								canPlaySound = false
						PHASE3:
							if not $RandomAudioStreamPlayer.playing and canPlaySound:
								$RandomAudioStreamPlayer.play()
								$RandomAudioStreamPlayer/TimerAudio.start()
								canPlaySound = false
						
						#timesSoundPlayed -= 1
				#elif currentLocation != target.get_current_location():
					#timesSoundPlayed = 1
			if currentLocation != target.get_current_location():
				
				match phase:
					PHASE1:
						pass
					PHASE2:
						playFootStep()
					PHASE3:
						playFootStep()
						if not $monsterBreath.playing:
							$monsterBreath.play()
					#else:
						#print("rng failed!")
						#yield(get_tree().create_timer(5.0),"timeout")
					
		STOP:
			pass
		KILLPLAYER:
			speed = 10
			if path.size() > 0:
				move_to_target()
			#if not $running3D.playing:
				#$running3D.play()
				
		
		

func move_to_target():
	
	if current_path_idx >= path.size():
		return
		
	if global_transform.origin.distance_to(path[current_path_idx]) < threshold:
		current_path_idx += 1
	
	else:
		var direction = path[current_path_idx] - global_transform.origin
		velocity = direction.normalized() * speed
		move_and_slide(velocity, Vector3.UP)

func get_target_path(target_pos):
	#get_simple_path()
	path = nav.get_simple_path(global_transform.origin, target_pos)
	current_path_idx = 0

func playFootStep():
	if not $steps3D.playing and timeFootstepPlayed > 0:
		var randomNumber = RNGTools.pick([1,0])
		#print("random number is " + str(randomNumber))
		if randomNumber == 1:
			#print("sound is playing!")
			$steps3D.play()
			timeFootstepPlayed -= 1
			yield(get_tree().create_timer(1.0),"timeout")
	
	

func _on_Timer_timeout():
	get_target_path(target.global_transform.origin)

func setStateStop():
	state = STOP

func setStateFollow():
	state = FOLLOWPLAYER

func setStateKillplayer():
	state = KILLPLAYER
	

func getSpeed():
	return speed

func setSpeedIncrease(newSpeed):
	speed = newSpeed
	#speed += increase -- old version
	






func _on_VisibilityNotifier_camera_entered(camera):
	invisibleEnemyInview = true


func _on_VisibilityNotifier_camera_exited(camera):
	invisibleEnemyInview = false




#audio just finished playing, so it's on cooldown
func _on_RandomAudioStreamPlayer_finished():
	#print("sound finished")
	$RandomAudioStreamPlayer/TimerAudio.start()

#audio cooldown over, can play sound again
func _on_TimerAudio_timeout():
	canPlaySound = true
	

func get_current_location():
	return currentLocation

func get_current_monstersToSpawn():
	return monstersToSpawn


#func _on_myBedroom_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "my_bedroom"
#		monstersToSpawn = "monsterMybedroom"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_bedRoom3_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "bedRoom3"
#		monstersToSpawn = "monsterBedroom3"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_bathroom2_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "bathroom2"
#		monstersToSpawn = "monsterBathroom2"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_corridor1_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "corridor1"
#		monstersToSpawn = "monsterCorridor1"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_corridor3_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "corridor3"
#		monstersToSpawn = "monsterCorridor3"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_corridor2_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "corridor2"
#		monstersToSpawn = "monsterCorridor2"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_livingroom_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "livingroom"
#		monstersToSpawn = "monsterLivingroom"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_entrance_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "entrance"
#		monstersToSpawn = "monsterEntrance"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_bathroom1_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "bathroom1"
#		monstersToSpawn = "monsterBathroom1"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_kitchen_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "kitchen"
#		monstersToSpawn = "monsterKitchen"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_bedRoom2_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "my_bedroom2"
#		monstersToSpawn = "monsterBedroom2"
#		print("enemy is in " + currentLocation)
#
#
#
#
#func _on_balcony_body_entered(body):
#	if body.is_in_group("invisibleEnemy"):
#		currentLocation = "balcony"
#		monstersToSpawn = "monsterBalcony"
#		print("enemy is in " + currentLocation)


func _on_steps3D_finished():
	yield(get_tree().create_timer(5.0), "timeout")
	timeFootstepPlayed = 1


func _on_running3D_finished():
	get_tree().call_group("gameMaster", "fade_out")
	get_tree().call_group("gameMaster", "endGame")
	


func _on_locationSensor_area_entered(area):
	monstersToSpawn = "monster" + area.name
	#print("MONSTERSTOSPAWN LOCATION IS monster" + area.name)
	currentLocation = area.name
	#print("ENEMY IS INSIDE " + area.name)
	#get_tree().call_group("gameMaster", "shutDownLight", currentLocation)


func setMonsterSpawner(setSpawner):
	$monsterSpawner.monitorable = setSpawner

func setInvisibleEnemyPhase(newPhase):
	phase = newPhase

func playRunningAudio():
	yield(get_tree().create_timer(2.0), "timeout")
	$running3D.play()
