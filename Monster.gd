extends Spatial

enum {
	HIDING,
	ACTIVE
}

enum {
	PHASE1,
	PHASE2
}


var player = null
onready var head = $Head

#onready var player = get_node(nodePath)

var monsterPhase = PHASE1
var state = HIDING
var inView = false
var canSpawn = false
var doorOpen = false
var isActive = false

#special unique monster conditions
export var monsterNearDoor = false
export var needsDoor = false
export var isCrouchMonster = false

var collidingWithDoor = false
var canSeeMonsterFace = false
var timesSoundPlayed = 1
var canMakeSound = false
var animationValue = 0
var inSpotlight = false
var monsterInSight = false

export var backbreak = false


#fade out var
export var transition_duration = 1.00
export var transition_type = 1 # TRANS_SINE

func _ready():
	yield(owner, "ready")
	player = owner.player
	#set_state_hiding()
	set_physics_process(false)
	visible = false
	head.get_node("headArea").monitoring = false
	
	if backbreak:
		$AnimationPlayer.play("backbreak")
	else:
		$AnimationPlayer.play("upright")

func _physics_process(delta):
	lookAtPlayer()
#	match state:
#		HIDING:
#			visible = false
#			$headArea.monitoring = false
#			canMakeSound = true
#			#timesSoundPlayed = 1
#
#		ACTIVE:
#			visible = true
#			$headArea.monitoring = true
#			#yield(get_tree().create_timer(RNGTools.randi_range(1,5)),"timeout")
#			#makeCreepySound()
			
	if isActive:
			#disappear if colliding with door
			if collidingWithDoor:
				#state = HIDING
				if not needsDoor:
					get_parent().despawnMonster(self)
			elif not collidingWithDoor:
				if needsDoor:
					get_parent().despawnMonster(self)
	
func lookAtPlayer():
	head.look_at(player.get_node("Neck").global_transform.origin, Vector3.UP) #+ Vector3(0,1,0)
	head.rotate_object_local(Vector3(0,1,0), 3.14)
	head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(60))
	head.rotation.z = clamp(head.rotation.z, deg2rad(0), deg2rad(0))
	head.rotation.y = clamp(head.rotation.y, deg2rad(-60), deg2rad(60))
	

func isCanSpawn():
	#if not inView and canSpawn: #and canSeePlayer():
		#return true
	#else:
		#return false
	if  isCrouchMonster:
		if not canSeePlayer() or not player.getIsUnderFurniture():
			return false
		
	match monsterNearDoor:
		true:
			if collidingWithDoor:
				#monster needs door collision to spawn
				if needsDoor:
					#isMonsterPositionedToSpawn()
					if canSpawn: #and canSeePlayer():
						return true
#
				return false
			elif not collidingWithDoor:
				#monster doesn't want door collision to spawn
				if not needsDoor:
					#isMonsterPositionedToSpawn()
					if canSpawn: #and canSeePlayer():
						return true
#
				return false
		false:
			#isMonsterPositionedToSpawn()
			if canSpawn: #and canSeePlayer():
				return true
			else:
				return false
		

func isInView():
	if inView:
		return true
	else:
		return false

func isFaceInView():
	if canSeeMonsterFace:
		return true
	else:
		return false

func getDistanceFromPlayer():
	return transform.origin.distance_to(player.get_position())

func isMonsterPositionedToSpawn():
	if monsterInSight and canSeePlayer():
		
		return false
	return true
		
			
	

func get_monster_position():
	return global_transform.origin

func set_state_active():
	#state = ACTIVE
	isActive = true
	visible = true
	head.get_node("headArea").monitoring = true
	disableArea()
			
		#animate monster face
	for eye in $Head/head/eyes.get_children():
		eye.frame = RNGTools.pick([0,1,2])
	$Head/head/mouths/mouths.frame = RNGTools.pick([0,1,2,3])
	#for raycast in $Cube001.get_children():
		#raycast.enabled = true
	
func shadeFace(value):
	
	for eye in $Head/head/eyes.get_children():
		eye.shaded = value
	#$Head/head/mouths/mouths.shaded = value

func set_state_hiding():
	#state = HIDING
	isActive = false
	visible = false
	head.get_node("headArea").monitoring = false
	canMakeSound = true
	enableArea()
	#for raycast in $Cube001.get_children():
		#raycast.enabled = false

func getIsActive():
	return isActive

func canSeePlayer():
	for raycast in $Head/head/raycasts.get_children():
		if not raycast.is_in_group("eyes"):
			if raycast.get_collider() != null:
				if raycast.get_collider().is_in_group("player"): #== player.get_node("AreaPlayer"):
					return true
	return false

func makeCreepySound(type):
	
	match type:
		1:
			if canMakeSound and not $monsterNoise3D.playing:
				$monsterNoise3D.play()
				canMakeSound = false
		2:
			if canMakeSound and not $monsterNoise3D_2.playing:
				$monsterNoise3D_2.play()
				canMakeSound = false

func get_state():
	return state

func _on_Visible_camera_exited(camera):
	inView = false


func _on_Visible_camera_entered(camera):
	inView = true
	


func _on_MonsterArea_area_entered(area):
	if area.is_in_group("spotlight"):
		inSpotlight = true
		canSpawn = false
	elif area.get_parent().is_in_group("invisibleEnemy") and not inSpotlight:
		canSpawn = true
		#set_physics_process(true)
	


func _on_MonsterArea_area_exited(area):
	if area.is_in_group("spotlight"):
		inSpotlight = false
	elif area.get_parent().is_in_group("invisibleEnemy"):
		canSpawn = false
#		if state == ACTIVE:
#			state == HIDING
#		set_physics_process(false)

func isMonsterInPlayerLocation():
	if is_in_group(player.get_current_location()):
		return true
	return false

func canMonsterSpawnNextToDoor():
	if "Door" in self.get_groups():
		if "Door" in get_parent().invisibleMonster.get_current_location():
			return true
		else:
			return false
	return true

func isPlayerInViewcone():
	if head.rotation.x >= deg2rad(60) or head.rotation.x <= deg2rad(-60):
		return false
	elif head.rotation.y >= deg2rad(60) or head.rotation.y <= deg2rad(-60):
		return false
	else:
		return true
	

func killPlayer():
	if not $RandomAudioStreamPlayer.playing:
		$RandomAudioStreamPlayer.play()
		get_tree().call_group("player", "die")

func playerKeepsStaring():
	$stareDrainSound.play()

func flickerFace(faceType):
	match faceType:
		1:
			shadeFace(false)
			for eye in $Head/head/eyes.get_children():
				eye.frame = RNGTools.pick([0,1,2])
		2:
			shadeFace(false)
			$Head/head/mouths/mouths.frame = RNGTools.pick([0,1,2,3])
		3:
			shadeFace(false)
			for eye in $Head/head/eyes.get_children():
				eye.frame = RNGTools.pick([0,1,2])
			$Head/head/mouths/mouths.frame = RNGTools.pick([0,1,2,3])
			

func playerLooksAtMonster():
	if isActive and not $stareDrainSound.playing and timesSoundPlayed > 0:
		$RandomAudioStreamPlayer.play()
		$stareDrainSound.play()
		timesSoundPlayed -= 1
		
func enableArea():
	$MonsterArea.monitorable = true

func disableArea():
	$MonsterArea.monitorable = false

func backBreak():
	$AnimationPlayer.play("backbreak")

func isBackBreak():
	return backbreak



#func _on_headVisibility_camera_entered(camera):
	#canSeeMonsterFace = true


#func _on_headVisibility_camera_exited(camera):
	#canSeeMonsterFace = false
	#timesSoundPlayed = 1


func _on_headArea_area_entered(area):
	if area.is_in_group("playerViewCone"):
		$faceStareDelay.start()
		
		#print("monster head are entered")
			
		
func fadeDrainSound():
	$stareDrainSound/Tween.interpolate_property($stareDrainSound, "volume_db", 0, -40, transition_duration, transition_type, Tween.EASE_IN, 0)
	$stareDrainSound/Tween.start()


func _on_headArea_area_exited(area):
	if area.is_in_group("playerViewCone"):
		canSeeMonsterFace = false
		shadeFace(true)
		$faceStareDelay.stop()
		if $stareDrainSound.playing:
			fadeDrainSound()
		#print("monster head are exited")


func _on_Tween_tween_all_completed():
	$stareDrainSound.stop()
	$stareDrainSound.volume_db = 0
	#$stareDrainSound.pitch_scale = 1
	timesSoundPlayed = 1


func _on_MonsterArea_body_entered(body):
	if body.is_in_group("door") and monsterNearDoor:
		#print("there's a door in the way, monster can't spawn")
		collidingWithDoor = true


func _on_MonsterArea_body_exited(body):
	if body.is_in_group("door") and monsterNearDoor:
		#print("the door is out of the way, monster can now spawn")
		collidingWithDoor = false

func setFaceAnimation(value):
	animationValue = value

func setMonsterPhase(newPhase):
	monsterPhase = newPhase


func _on_faceStareDelay_timeout():
	canSeeMonsterFace = true


func _on_bodyVisibleArea_area_entered(area):
	if area.is_in_group("playerViewCone"):
		monsterInSight = true
		#print("monster can not spawn")


func _on_bodyVisibleArea_area_exited(area):
	if area.is_in_group("playerViewCone"):
		monsterInSight = false
		#print("monster can spawn")
