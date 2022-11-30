extends StaticBody



func interact():
	$Letter.visible = true
	$CollisionShape.disabled = true
	

func _unhandled_input(event):
	if $Letter.visible:
		if event.is_action_pressed("interact"):
			$Letter.visible = false
			$CollisionShape.disabled = false
			
		
