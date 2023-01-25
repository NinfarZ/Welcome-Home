extends Spatial

signal changeLight

var isPlayerInside = false
var isEnemyInside = false
var state = OFF
var timerOver = false
var player = null
var enemy = null

signal playerInSpotlight(value)

enum {
	ON,
	OFF,
}

func _ready():
	set_physics_process(false)
	self.get_node("Area/CollisionShape").disabled = true
	$SpotLight.visible = false


func _physics_process(delta):
	if getIsPlayerInside():
		emit_signal("playerInSpotlight", true)
		get_tree().call_group("sanityBar", "recoverSanity", 0.13)
		get_tree().call_group("invisibleEnemy", "setMonsterSpawner", false)
			#state = CHANGELIGHT
	else:
		emit_signal("playerInSpotlight", false)
		get_tree().call_group("invisibleEnemy", "setMonsterSpawner", true)


func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		isPlayerInside = true
		
		
	if body.is_in_group("invisibleEnemy"):
		enemy = body
		isEnemyInside = true
	
		


func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		isPlayerInside = false
		
		
	if body.is_in_group("invisibleEnemy"):
		isEnemyInside = false

func disableLight():
	set_physics_process(false)
	self.get_node("Area/CollisionShape").disabled = true
	$SpotLight.visible = false
	$lightSwitch.play()
	$changeTimer.stop()

func enableLight():
	set_physics_process(true)
	self.get_node("Area/CollisionShape").disabled = false
	$SpotLight.visible = true
	#$changeTimer.start()
	$lightSwitch.play()

func changeTimerStart():
	$changeTimer.start()

func setState(newState):
	$lightSwitch.play()
	state = newState

func getState():
	return state

func getIsPlayerInside():
	if player == null:
		return false
	if isPlayerInside and self.is_in_group(player.get_current_location()):
		return true
	return false

func getIsEnemyInside():
	if enemy == null:
		return false
	if enemy.get_current_location() == null:
		return false
	if enemy.getState() == 1:
		return false
	if isEnemyInside and self.is_in_group(enemy.get_current_location()):
		return true
	return false

func superflicker():
	$AnimationPlayer.play("superFlicker")

func _on_changeTimer_timeout():
	print("light timer time out")
	emit_signal("changeLight")
	#self.setState(1)
	#timerOver = true
	
	#state = CHANGELIGHT
	
