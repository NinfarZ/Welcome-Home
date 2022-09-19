extends Control

onready var sanityBar = $ProgressBar

var recoverValue = 0.05
var playerIsDead = false

func setRecoverValue(value):
	recoverValue = value

func drainSanity(drainValue):
	if sanityBar.value < sanityBar.max_value and not playerIsDead:
		sanityBar.value += drainValue
	else:
		playerIsDead = true
		get_tree().call_group("gameMaster", "deathSequence")
		queue_free()

func recoverSanity():
	if not playerIsDead:
		sanityBar.value -= recoverValue
	
