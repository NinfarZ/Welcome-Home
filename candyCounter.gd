extends Control

var counter = 0
onready var counterLabel = $MarginContainer/VBoxContainer/counter
onready var radar = $MarginContainer2/radar


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
	radar.get_node("AnimationPlayer").play("radarBeep")

func stopBeep():
	radar.visible = false
	radar.get_node("AnimationPlayer").stop()

func showHandFull():
	$AnimationPlayer.play("handFull")
