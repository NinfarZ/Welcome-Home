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
	#NOT OPEN MEANS CLOSED
	if not open and not in_animation:
		$openCloseSound.play()
		if $slowKnock.playing or $fastKnock.playing:
			$slowKnock.stop()
			$fastKnock.stop()
		in_animation = true
		tween.interpolate_property(self, "rotation_degrees", closed_angle, open_angle, openingForce, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	#CASE IF OPEN
	elif open and not in_animation:
		in_animation = true
		tween.interpolate_property(self, "rotation_degrees", open_angle, closed_angle, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	tween.start()
	

func _on_Tween_tween_all_completed():
	open = !open
	in_animation = false
	if !open:
		$closeDoor.play()


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
	$AnimationPlayer.play("unlock")
	setLock(false)

func playMonsterLockedDoor():
	if not $monsterLockedDoorKnock.playing:
		$monsterLockedDoorKnock.play()

func monsterKnocking(speed):
	if speed <= 4.2:
		$slowKnock.play()
	elif speed > 4.2:
		$fastKnock.play()
	
