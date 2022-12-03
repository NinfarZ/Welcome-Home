extends Spatial

var interactables = []

var items = []
var hasKey = false
var numberOfCandy = 0
onready var player = get_parent().get_parent()
var openingForce = null
export var candyLimit = 5

var interactLabel = preload("res://interactLabel.tscn")


func _physics_process(delta):
	#OPENING DOORS
	if not interactables.empty() and interactables.front().is_in_group("door"):
		if Input.is_action_just_pressed("interact"):
			openingForce = player.getDoorOpeningForce()
			if interactables.front().isLocked():
				interactables.front().interact(openingForce)
				if hasKey:
					interactables.front().unlock()
					hasKey = false
			elif not interactables.front().isLocked():
				interactables.front().interact(openingForce)
	
	#INTERACT WITH ANYTHING ELSE
	elif not interactables.empty() and interactables.front().has_method("interact"):
		if Input.is_action_just_pressed("interact"):
			if interactables.front().is_in_group("candy"):
				if numberOfCandy < candyLimit:
					interactables.front().interact()
					numberOfCandy += 1
				else:
					interactables.front().emitHandFull()
			elif interactables.front().is_in_group("basket"):
				if numberOfCandy != 0:
					interactables.front().addCandy(numberOfCandy)
					numberOfCandy -= 1
#					if numberOfCandy > interactables.front().getTotalCandy():
#						numberOfCandy -= interactables.front().getTotalCandy()
#					else:
#						numberOfCandy = 0
			else:
				interactables.front().interact()
			
				
	
func _on_Area_body_entered(body):
	
	if body.has_method("interact"):
		interactables.append(body)
		print("can interact")
		if not has_node("interactLabel"):
			add_child(interactLabel.instance())
	


func _on_Area_body_exited(body):
	if body in interactables:
		var index = 0
		for i in interactables:
			if i == body:
				interactables.pop_at(index)
			index += 1
		if has_node("interactLabel"):
			get_node("interactLabel").queue_free()

func addItem(newItem):
	items.append(newItem)

func addKey():
	hasKey = true

func getHaskey():
	return hasKey

func getNumberOfCandy():
	return numberOfCandy
