extends Spatial

var totalCandy = 0

func setBarricade(barricade, isActive):
	for furniture in barricade.get_children():
		print(furniture.name)
		for object in furniture.get_children():
			print(object.name)
			if object.get_class() == "StaticBody":
				for collision in object.get_children():
					collision.disabled = !isActive
		furniture.visible = isActive


