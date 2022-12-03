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
	$counter.text = "%s" % counter if counter < 5 else "%s\n (full)" % counter

func removeCandy():
	counter -= 1
	$counter.text = "%s" % counter

func resetCounter():
	counter = 0
	$counter.text = "%s" % counter

func playBeep():
	$radar.visible = true
	#$radar/AnimationPlayer.playback_speed = speed
	$radar/AnimationPlayer.play("radarBeep")

func stopBeep():
	$radar.visible = false
	$radar/AnimationPlayer.stop()
