extends Control

onready var sanityBar = $ProgressBar

func drainSanity():
	if sanityBar.value < sanityBar.max_value:
		sanityBar.value += 1.17
	else:
		get_tree().call_group("gameMaster", "deathSequence")

func recoverSanity():
	sanityBar.value -= 0.05
	
