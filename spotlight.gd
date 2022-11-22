extends Spatial

signal changeLight

var isPlayerInside = false
var isEnemyInside = false
var state = OFF
var timerOver = false

enum {
	ON,
	OFF,
}

func _ready():
	set_physics_process(false)


func _physics_process(delta):
	if isPlayerInside:
		get_tree().call_group("sanityBar", "recoverSanity", 0.5)
			#state = CHANGELIGHT
				
		

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		isPlayerInside = true
		get_tree().call_group("invisibleEnemy", "setMonsterSpawner", false)
		
	if body.is_in_group("invisibleEnemy"):
		if body.get_current_location() != null:
			if self.is_in_group(body.get_current_location()):
				isEnemyInside = true
	
		


func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		isPlayerInside = false
		get_tree().call_group("invisibleEnemy", "setMonsterSpawner", true)
		
	if body.is_in_group("invisibleEnemy"):
		isEnemyInside = false

func disableLight():
	set_physics_process(false)
	self.get_node("Area/CollisionShape").disabled = true
	$SpotLight.visible = false
	$lightSwitch.play()

func enableLight():
	set_physics_process(true)
	self.get_node("Area/CollisionShape").disabled = false
	$SpotLight.visible = true
	$changeTimer.start()
	$lightSwitch.play()

func setState(newState):
	$lightSwitch.play()
	state = newState

func getState():
	return state

func getIsPlayerInside():
	return isPlayerInside

func getIsEnemyInside():
	return isEnemyInside

func superflicker():
	$AnimationPlayer.play("superFlicker")


func _on_changeTimer_timeout():
	print("light timer time out")
	emit_signal("changeLight")
	#self.setState(1)
	#timerOver = true
	
	#state = CHANGELIGHT
	
