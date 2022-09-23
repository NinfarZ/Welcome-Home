extends Spatial

var interactables = []

var items = []
var hasKey = false

func _physics_process(delta):
	if not interactables.empty() and interactables.front().has_method("unlock") and hasKey:
		if Input.is_action_just_pressed("interact"):
			interactables.front().unlock()
			hasKey = false
	elif not interactables.empty() and interactables.front().has_method("interact"):
		if Input.is_action_just_pressed("interact"):
			interactables.front().interact()
	
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
	
