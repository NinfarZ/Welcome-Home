extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func addCandy():
	counter += 1
	$counter.text = "%s" % counter

func removeCandy():
	counter -= 1
	$counter.text = "%s" % counter
