extends StaticBody

export var closed_angle = Vector3(0,0,0)
export var open_angle = Vector3(0,0,0)
onready var tween = $Tween

var in_animation = false
export var open = false
export var locked = false

var monsterWantsToOpen = false
var monsterCollisionMask = true

func _physics_process(delta):
	if in_animation:
		set_collision_mask_bit(0, false)
		set_collision_mask_bit(5, false)
	else:
		if !open:
			set_collision_mask_bit(5, true)
		set_collision_mask_bit(0, true)
		
		
func interact(openingForce):
	if not $monsterLockedDoorKnock.playing:
		if not locked:
			if in_animation:
				return
			else:
				open_and_close(openingForce)
		else:
			$AnimationPlayer.play("locked")
		
		
		
		

func open_and_close(openingForce):
	#print("trying to open/close door")
	#NOT OPEN MEANS CLOSES
	if not open and not in_animation:
		#$monsterSensor/CollisionShape.disabled = true
		$openCloseSound.play()
		in_animation = true
		#$CollisionShape.disabled = true
		
		tween.interpolate_property(self, "rotation_degrees", closed_angle, open_angle, openingForce, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
		
	
	#CASE IF OPEN
	elif open and not in_animation:
		#$monsterSensor/CollisionShape.disabled = true
		in_animation = true
		#$CollisionShape.disabled = false
		tween.interpolate_property(self, "rotation_degrees", open_angle, closed_angle, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
		
		
	tween.start()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_all_completed():
	open = !open
	in_animation = false
	if !open:
		$closeDoor.play()
	#$CollisionShape.disabled = false
	#$monsterSensor/CollisionShape.disabled = false
	


	
	
		

#func _on_monsterSensor_body_entered(body):
#	if body.is_in_group("invisibleEnemy") and not open:
#
#		#print("invisibleMonster is trying to open " + self.name)
#		$TimerMonsterOpenDoor.start()
#
#
#
#
#
#func _on_monsterSensor_body_exited(body):
#	if body.is_in_group("invisibleEnemy"):
#		#monsterWantsToOpen = false
#		$TimerMonsterOpenDoor.stop()
#
#
#
#func _on_TimerMonsterOpenDoor_timeout():
#	#if monsterWantsToOpen:
#	interact()

func setMonsterDoorTimer(newTime):
	$TimerMonsterOpenDoor.wait_time = newTime

func setLock(islocked):
	if not islocked:
		get_tree().call_group("keyManager", "handleKey", false)
	locked = islocked

func isLocked():
	return locked

func isOpen():
	return open

func unlock():
	#animate
	$AnimationPlayer.play("unlock")
	setLock(false)

func playMonsterLockedDoor():
	if not $monsterLockedDoorKnock.playing:
		$monsterLockedDoorKnock.play()

func monsterKnocking(speed):
	if speed <= 3:
		$slowKnock.play()
	elif speed > 3:
		$fastKnock.play()
	
