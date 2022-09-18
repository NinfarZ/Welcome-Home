extends Spatial

var isPlayerInside = false
var isEnemyInside = false

func _physics_process(delta):
	if isPlayerInside and isEnemyInside:
		$Area.monitoring != false
		$SpotLight.visible = false
	elif isPlayerInside:
		get_tree().call_group("sanityBar", "recoverSanity")
	
	

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		isPlayerInside = true
	if body.is_in_group("invisibleEnemy"):
		isEnemyInside = true
	
		


func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		isPlayerInside = false
	if body.is_in_group("invisibleEnemy"):
		isEnemyInside = false
