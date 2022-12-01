extends StaticBody

export(Texture) var texture 

func interact():
	$Letter/TextureRect.texture = texture
	$Letter.visible = true
	$CollisionShape.disabled = true
	

func _unhandled_input(event):
	if $Letter.visible:
		if event.is_action_pressed("interact"):
			$Letter.visible = false
			$CollisionShape.disabled = false
			
		
