extends Control

onready var sanityBar = $ProgressBar

var recoverValue = 0.05
var playerIsDead = false
var isMonsterDraining = false

func setRecoverValue(value):
	recoverValue = value

func drainSanity(drainValue):
	if sanityBar.value < sanityBar.max_value and not playerIsDead:
		sanityBar.value += drainValue
		get_tree().call_group("monster", "setFaceAnimation", sanityBar.value)
	else:
		playerIsDead = true
		get_tree().call_group("player", "setState", 1)
		get_tree().call_group("gameMaster", "deathSequence")
		queue_free()

func recoverSanity():
	if not isMonsterDraining:
		sanityBar.value -= recoverValue

func setIsDraining(value):
	isMonsterDraining = value

func getSanityBarValue():
	return sanityBar.value
	
