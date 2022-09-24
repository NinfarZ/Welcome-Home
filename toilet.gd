extends Spatial

var isOpen = false

func interact():
	if not isOpen:
		get_parent().get_node("AnimationPlayer").play("openSeat")
		isOpen = true
	elif isOpen:
		get_parent().get_node("AnimationPlayer").play_backwards("openSeat")
		isOpen = false
