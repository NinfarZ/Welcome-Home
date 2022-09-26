extends StaticBody



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		get_tree().call_group("crouchMonster", "setCrouchMonsterSpawn", true)
	


func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		get_tree().call_group("crouchMonster", "setCrouchMonsterSpawn", false)
