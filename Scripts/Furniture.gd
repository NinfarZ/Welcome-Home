extends Spatial

#enables or disables a barricade
func setBarricade(barricade, isActive):
	for furniture in barricade.get_children():
		for object in furniture.get_children():
			if object.get_class() == "StaticBody":
				for collision in object.get_children():
					collision.disabled = !isActive
		furniture.visible = isActive


