extends Control

onready var sanityBar = $ProgressBar

var recoverValue = 0.05
var playerIsDead = false
var isMonsterDraining = false

func _physics_process(delta):
	
	if sanityBar.value < 20:
		get_tree().call_group("monsterController", "changeDifficulty", 1, 10)
		get_tree().call_group("monsterController", "cooldown", 5, 10)
		get_tree().call_group("door", "setMonsterDoorTimer", 5)
	elif sanityBar.value >= 20 and sanityBar.value < 30:
		get_tree().call_group("monsterController", "changeDifficulty", 1.5, 8)
		get_tree().call_group("monsterController", "cooldown", 5, 8)
		get_tree().call_group("door", "setMonsterDoorTimer", 4)
	elif sanityBar.value >= 30 and sanityBar.value < 50:
		get_tree().call_group("monsterController", "changeDifficulty", 2, 6)
		get_tree().call_group("monsterController", "cooldown", 5, 6)
		get_tree().call_group("door", "setMonsterDoorTimer", 3)
	elif sanityBar.value >= 50 and sanityBar.value < 70:
		get_tree().call_group("monsterController", "changeDifficulty", 3, 4)
		get_tree().call_group("monsterController", "cooldown", 4, 5)
		get_tree().call_group("door", "setMonsterDoorTimer", 2)
	elif sanityBar.value >= 70:
		get_tree().call_group("monsterController", "changeDifficulty", 4, 2)
		#get_tree().call_group("monsterController", "cooldown", 2, 5)
		get_tree().call_group("door", "setMonsterDoorTimer", 1)

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
	
