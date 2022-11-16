extends Spatial

signal changeLight

var isPlayerInside = false
var isEnemyInside = false
var state = OFF
var timerOver = false

enum {
	ON,
	OFF,
	CHANGELIGHT
}



func _physics_process(delta):
	match state:
		ON:
			enableLight()
			if isEnemyInside:
				emit_signal("changeLight")
				self.setState(1)
			elif isPlayerInside:
				get_tree().call_group("sanityBar", "recoverSanity", 0.5)
			#state = CHANGELIGHT
		OFF:
			disableLight()
			#timerOver = false
			isPlayerInside = false
		CHANGELIGHT:
			get_tree().call_group("gameMaster", "shutDownLight", self, timerOver)
			#state = OFF
				
		

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
	self.get_node("Area/CollisionShape").disabled = true
	$SpotLight.visible = false

func enableLight():
	self.get_node("Area/CollisionShape").disabled = false
	$SpotLight.visible = true
	$changeTimer.start()

func setState(newState):
	$lightSwitch.play()
	state = newState

func getState():
	return state


func _on_changeTimer_timeout():
	print("light timer time out")
	emit_signal("changeLight")
	self.setState(1)
	#timerOver = true
	
	#state = CHANGELIGHT
	
