extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var counter = 0
onready var counterLabel = $MarginContainer/VBoxContainer/counter
onready var radar = $MarginContainer2/radar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func addCandy():
	counter += 1
	counterLabel.text = "%s" % counter 

func removeCandy():
	counter -= 1
	counterLabel.text = "%s" % counter

func resetCounter():
	counter = 0
	counterLabel.text = "%s" % counter

func playBeep():
	radar.visible = true
	#$radar/AnimationPlayer.playback_speed = speed
	radar.get_node("AnimationPlayer").play("radarBeep")

func stopBeep():
	radar.visible = false
	radar.get_node("AnimationPlayer").stop()

func showHandFull():
	$AnimationPlayer.play("handFull")
