extends KinematicBody

export var speed = 2
var maxSpeed = speed + 1.5
var minSpeed = speed

enum {
	PATROL,
	STOP,
	FOLLOWPLAYER,
	KILLPLAYER,
	CHASE
}

enum {
	PHASE1
	PHASE2
	PHASE3
}

var state = FOLLOWPLAYER
var phase = PHASE1

signal killPlayer

var path = []
var current_path_idx = 0
var target = null
var velocity = Vector3.ZERO
var threshold = 0.1
var offset = Vector3(10,10,10)
var decreaseScale = Vector3(0.01, 0.01, 0.01)
var invisibleEnemyInview = false
var gracePeriodOver = false
var monsterChaseVisible = false
var monsterWantsToOpenDoor = false
var door = null

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
	lookAtPlayer()
	
	#open doors code
	if monsterWantsToOpenDoor:
		door.interact()
	
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
				elif transform.origin.distance_to(target.transform.origin) > 15:
					
					match phase:
						PHASE1:
							pass
						PHASE2:
							playFootStep()
						PHASE3:
							playFootStep()
						#else:
							#print("rng failed!")
							#yield(get_tree().create_timer(5.0),"timeout")
					
		STOP:
			pass
		KILLPLAYER:
			emit_signal("killPlayer")
			$body.visible = false
			#if not $running3D.playing:
				#$running3D.play()
		CHASE:
			#$monsterSpawner/CollisionShape.disabled = true
			if gracePeriodOver:
				if path.size() > 0:
					if not $steps3D.playing:
						match phase:
							PHASE1, PHASE2:
								$steps3D.play()
							PHASE3:
								$steps3D.play()
								$monsterBreath.play()
					if transform.origin.distance_to(target.transform.origin) <= 15:
						$body.visible = true
						flickerLightIfClose()
					elif transform.origin.distance_to(target.transform.origin) > 15:
						$body.visible = false
					
					monsterSpeedUp()
					move_to_target()
			
				
		
		

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
	#$body.visible = false
	monsterChaseVisible = false
	gracePeriodOver = false

func setStateKillplayer():
	state = KILLPLAYER

func setStateChase():
	state = CHASE
	$body/head/mouths/mouths.frame = RNGTools.pick([0,1,2,3])
	#$body.visible = true
	if not gracePeriodOver and $chaseGracePeriod.is_stopped():
		$chaseGracePeriod.start()
	print("timer start chase")

func monsterIsVisibleForMoment():
	if not invisibleEnemyInview and transform.origin.distance_to(target.transform.origin) > 20:
		$body.visible = true
	else:
		yield(get_tree().create_timer(0.1),"timeout")
		$body.visible = false

func getDistanceToPlayer():
	return transform.origin.distance_to(target.transform.origin)

func flickerLightIfClose():
	if transform.origin.distance_to(target.transform.origin) <= 5:
		get_tree().call_group("flashlight", "flicker")

func setBodyVisible(value):
	print("setting body visibility to ", value)
	$body.visible = value

func getIsInView():
	return invisibleEnemyInview

func monsterSpeedUp():
	if invisibleEnemyInview:
		speed += 0.01
		
	else:
		speed -= 0.01
	speed = clamp(speed, minSpeed, maxSpeed)
	

func getSpeed():
	return speed

func setSpeedIncrease(newSpeed):
	speed = newSpeed
	#speed += increase -- old version

func setMonsterDoorTimer(newTime):
	$openDoorTimer.wait_time = newTime
	






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

func lookAtPlayer():
	$body.look_at(target.get_position(), Vector3.UP) #+ Vector3(0,1,0)
	$body.rotate_object_local(Vector3(0,1,0), 3.14)
	#head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(60))
	#head.rotation.z = clamp(head.rotation.z, deg2rad(-10), deg2rad(10))
	$body.rotation.x = clamp($body.rotation.x, deg2rad(0), deg2rad(0))
	
	for eye in $body/head/eyes.get_children():
		eye.frame = RNGTools.pick([0,1,2,3])
	


func _on_steps3D_finished():
	yield(get_tree().create_timer(5.0), "timeout")
	timeFootstepPlayed = 1


func _on_running3D_finished():
	get_tree().call_group("gameMaster", "fade_out")
	get_tree().call_group("gameMaster", "endGame")
	


func _on_locationSensor_area_entered(area):
	if not area.is_in_group("player"):
		monstersToSpawn = "monster" + area.name
	#print("MONSTERSTOSPAWN LOCATION IS monster" + area.name)
		currentLocation = area.name
	#print("ENEMY IS INSIDE " + area.name)
	#get_tree().call_group("gameMaster", "shutDownLight", currentLocation)
	
	
	


func setMonsterSpawner(setSpawner):
	$monsterSpawner.monitorable = setSpawner

func setInvisibleEnemyPhase(newPhase):
	phase = newPhase

func setWantsToOpenDoor(value):
	monsterWantsToOpenDoor = value

func playRunningAudio():
	yield(get_tree().create_timer(2.0), "timeout")
	$running3D.play()


func _on_locationSensor_body_entered(body):
	if body.is_in_group("player") and gracePeriodOver:
		if state == CHASE:
			state = KILLPLAYER
			get_tree().call_group("gameMaster", "setGameState", 4)
			#_physics_process(false)
	elif body.is_in_group("door"):
		if not body.isOpen():
			door = body
			if $openDoorTimer.is_stopped():
				$openDoorTimer.start()
			


func _on_locationSensor_body_exited(body):
	$openDoorTimer.stop()
	door = null
	monsterWantsToOpenDoor = false


func _on_chaseGracePeriod_timeout():
	gracePeriodOver = true
	monsterChaseVisible = true
	print("grace period over")


func _on_openDoorTimer_timeout():
	monsterWantsToOpenDoor = true


func _on_bodyVisibility_area_entered(area):
	if area.is_in_group("playerViewCone"):
		setBodyVisible(false)
		
