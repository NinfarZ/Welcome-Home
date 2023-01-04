extends Spatial

enum {
	HIDING,
	ACTIVE
}

enum {
	PHASE1,
	PHASE2
}

signal monsterInRange(monster)
signal monsterOutOfRange(monster)
signal monsterShouldDespawn(monster)

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
	enableMonster(false)
	visible = false
	head.get_node("headArea").monitoring = false
	
	if backbreak:
		$AnimationPlayer.play("backbreak")
	else:
		$AnimationPlayer.play("upright")

func _physics_process(delta):
	lookAtPlayer()

	if not isActive:
		return
	#handle monster collision with door
	if monsterNearDoor:
		if needsDoor:
			if not collidingWithDoor:
				emit_signal("monsterShouldDespawn", self)
		else:
			if collidingWithDoor:
				emit_signal("monsterShouldDespawn", self)
	if isCrouchMonster:
		if not player.getIsUnderFurniture():
			emit_signal("monsterShouldDespawn", self)
			
#	if not isMonsterInPlayerLocation():
#		emit_signal("monsterShouldDespawn", self)
	if not isPlayerInViewcone():
		if isInView():
			emit_signal("monsterShouldDespawn", self)
	if inSpotlight:
		emit_signal("monsterShouldDespawn", self)
	if getDistanceFromPlayer() > 15:
		emit_signal("monsterShouldDespawn", self)
		
func lookAtPlayer():
	head.look_at(player.get_node("Neck").global_transform.origin, Vector3.UP) 
	head.rotate_object_local(Vector3(0,1,0), 3.14)
	head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(60))
	head.rotation.z = clamp(head.rotation.z, deg2rad(0), deg2rad(0))
	head.rotation.y = clamp(head.rotation.y, deg2rad(-60), deg2rad(60))
	

func isCanSpawn():
	
	if not canSpawn:
		return false

	if isCrouchMonster:
		if not player.getIsUnderFurniture():
			return false
	#monster needs to either want door collision or not to spawn
	if monsterNearDoor:
		#monster needs door collision to spawn
		if needsDoor:
			if not collidingWithDoor:
				return false

			return true
		#monster doesn't want door collision to spawn
		elif not needsDoor:
			if collidingWithDoor:
				return false

			return true
			
	return true
func enableMonster(enable):
	if enable:
		set_physics_process(true)
		#$bodyVisibleArea/CollisionShape.disabled = false
		$Head/headArea/CollisionShape.disabled = false
		for raycast in $Head/head/raycasts.get_children():
			raycast.enabled = true
		
	elif not enable:
		set_physics_process(false)
		#$bodyVisibleArea/CollisionShape.disabled = true
		$Head/headArea/CollisionShape.disabled = true
		for raycast in $Head/head/raycasts.get_children():
			raycast.enabled = false
	
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
	if getDistanceFromPlayer() > 10:
		if not monsterInSight:
			if canSeePlayer() and isPlayerInViewcone():
				return true
	else:
		if not isInView():
			if canSeePlayer() and isPlayerInViewcone():
		
				return true
	return false
		
			
	

func get_monster_position():
	return global_transform.origin

func set_state_active():
	isActive = true
	visible = true
	head.get_node("headArea").monitoring = true
	disableArea()
			
	#animate monster face
	for eye in $Head/head/eyes.get_children():
		if getDistanceFromPlayer() < 7:
			eye.frame = RNGTools.pick([0,1,2,3,4])
		else:
			eye.frame = RNGTools.pick([0,1,2])
	$Head/head/mouths/mouths.frame = RNGTools.pick([0,1,2,3,4])

func shadeFace(value):
	
	for eye in $Head/head/eyes.get_children():
		eye.shaded = value

func set_state_hiding():
	isActive = false
	visible = false
	head.get_node("headArea").monitoring = false
	canMakeSound = true
	enableArea()
	if canSeeMonsterFace:
		get_tree().call_group("flashlight", "blink")

func getIsActive():
	return isActive

#check if monster can see player. At least two raycasts must return true
func canSeePlayer():
	var raycastsColliding = 0
	for raycast in $Head/head/raycasts.get_children():
		if not raycast.is_in_group("eyes"):
			if raycast.get_collider() != null:
				if raycast.get_collider().is_in_group("player"):
					raycastsColliding += 1 
	if raycastsColliding >= 2:
		return true
	return false

func makeCreepySound(type):
	
	match type:
		1:
			if not $monsterNoise3D.playing:
				$monsterNoise3D.play()
				#canMakeSound = false
		2:
			if not $monsterNoise3D_2.playing:
				$monsterNoise3D_2.play()
				#canMakeSound = false

func get_state():
	return state

func _on_Visible_camera_exited(camera):
	inView = false


func _on_Visible_camera_entered(camera):
	inView = true
	


func _on_MonsterArea_area_entered(area):
	if canSpawn:
		if area.is_in_group("spotlight"):
			inSpotlight = true
			canSpawn = false
	elif area.get_parent().is_in_group("invisibleEnemy"):
		if not inSpotlight:
			canSpawn = true
			emit_signal("monsterInRange", self)
	


func _on_MonsterArea_area_exited(area):
	if area.is_in_group("spotlight"):
		inSpotlight = false
	elif area.get_parent().is_in_group("invisibleEnemy"):
		canSpawn = false
		emit_signal("monsterOutOfRange", self)


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
	elif head.rotation.y >= deg2rad(50) or head.rotation.y <= deg2rad(-50):
		return false
	
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
			for eye in $Head/head/eyes.get_children():
				eye.frame = RNGTools.pick([0,1,2,3,4])
		2:
			$Head/head/mouths/mouths.frame = RNGTools.pick([0,1,2,3])

func playerLooksAtMonster():
	if isActive and not $stareDrainSound.playing and timesSoundPlayed > 0:
		$RandomAudioStreamPlayer.play()
		$stareDrainSound.play()
		timesSoundPlayed -= 1
		
func enableArea():
	$MonsterArea.set_deferred("monitorable", true)

func disableArea():
	$MonsterArea.set_deferred("monitorable", false)

func backBreak():
	$AnimationPlayer.play("backbreak")

func isBackBreak():
	return backbreak


func _on_headArea_area_entered(area):
	if area.is_in_group("playerViewCone"):
		shadeFace(false)
		$faceStareDelay.start()
		
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
