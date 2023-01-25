extends Control


func setKey(value):
	if value:
		$Sprite.visible = true
	else:
		$Sprite.visible = false
