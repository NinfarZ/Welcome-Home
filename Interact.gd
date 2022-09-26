extends Spatial

var interactables = []

var items = []
var hasKey = false
var numberOfCandy = 0

func _physics_process(delta):
	#OPENING DOORS
	if not interactables.empty() and interactables.front().has_method("unlock") and hasKey:
		if Input.is_action_just_pressed("interact"):
			if interactables.front().isLocked():
				interactables.front().unlock()
				hasKey = false
			elif not interactables.front().isLocked():
				interactables.front().interact()
	
	#INTERACT WITH ANYTHING ELSE
	elif not interactables.empty() and interactables.front().has_method("interact"):
		if Input.is_action_just_pressed("interact"):
			interactables.front().interact()
			if interactables.front().is_in_group("candy"):
				numberOfCandy += 1
			elif interactables.front().is_in_group("bunny"):
				interactables.front().addCandy(numberOfCandy)
	
func _on_Area_body_entered(body):
	print("FOUND " + body.name)
	if body.has_method("interact"):
		interactables.append(body)
	


func _on_Area_body_exited(body):
	if body in interactables:
		var index = 0
		for i in interactables:
			if i == body:
				interactables.pop_at(index)
			index += 1

func addItem(newItem):
	items.append(newItem)

func addKey():
	hasKey = true

func getNumberOfCandy():
	return numberOfCandy
