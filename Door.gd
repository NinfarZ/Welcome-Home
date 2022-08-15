extends StaticBody

export var closed_angle = Vector3(0,0,0)
export var open_angle = Vector3(0,0,0)
onready var tween = $Tween

var in_animation = false
export var open = false

var monsterWantsToOpen = false
var monsterCollisionMask = true

func _physics_process(delta):
	pass
		
		
func interact():
	if in_animation:
		return
	else:
		open_and_close()

func open_and_close():
	#print("trying to open/close door")
	#NOT OPEN MEANS CLOSES
	if not open and not in_animation:
		$openCloseSound.play()
		in_animation = true
		$CollisionShape.disabled = true
		tween.interpolate_property(self, "rotation_degrees", closed_angle, open_angle, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		set_collision_layer_bit(7, false)
		
	
	#CASE IF OPEN
	elif open and not in_animation:
		in_animation = true
		$CollisionShape.disabled = true
		tween.interpolate_property(self, "rotation_degrees", open_angle, closed_angle, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		set_collision_layer_bit(7, true)
		
		
	tween.start()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_all_completed():
	open = !open
	in_animation = false
	$CollisionShape.disabled = false


	
	
		

func _on_monsterSensor_body_entered(body):
	if body.is_in_group("invisibleEnemy") and not open:
		monsterWantsToOpen = true
		print("invisibleMonster is trying to open " + self.name)
		$TimerMonsterOpenDoor.start()
		
		
		


func _on_monsterSensor_body_exited(body):
	if body.is_in_group("invisibleEnemy"):
		monsterWantsToOpen = false
		$TimerMonsterOpenDoor.stop()
		


func _on_TimerMonsterOpenDoor_timeout():
	if monsterWantsToOpen:
		interact()
