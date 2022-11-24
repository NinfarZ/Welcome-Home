extends Control

onready var sanityBar = $MarginContainer2/ProgressBar

var recoverValue = 0.09
var punishmentTime = false
var isMonsterDraining = false
onready var heartbeat = get_parent().get_parent().get_node("Audio/heartbeat")

func _physics_process(delta):
	var tween = create_tween()
	if sanityBar.value > 70:
		tween.tween_property(sanityBar, "self_modulate", Color(0.92, 0.41, 0.35), 5.0)
		if not heartbeat.playing:
			heartbeat.play()
		tween.tween_property(heartbeat, "volume_db", -5, 8.0)
		#$ProgressBar.self_modulate = Color(0.92, 0.41, 0.35)
	elif sanityBar.value <= 70:
		tween.tween_property(sanityBar, "self_modulate", Color(1.00, 0.91, 0.92), 5.0)
		
		if heartbeat.playing:
			if heartbeat.volume_db == -10:
				heartbeat.stop()
			tween.tween_property(heartbeat, "volume_db", -10, 8.0)
		
		
#	if sanityBar.value < 20:
#		get_tree().call_group("monsterController", "changeDifficulty", 1, 10)
#		get_tree().call_group("monsterController", "cooldown", 5, 10)
#		get_tree().call_group("door", "setMonsterDoorTimer", 5)
#	elif sanityBar.value >= 20 and sanityBar.value < 30:
#		get_tree().call_group("monsterController", "changeDifficulty", 1.5, 8)
#		get_tree().call_group("monsterController", "cooldown", 5, 8)
#		get_tree().call_group("door", "setMonsterDoorTimer", 4)
#	elif sanityBar.value >= 30 and sanityBar.value < 50:
#		get_tree().call_group("monsterController", "changeDifficulty", 2, 6)
#		get_tree().call_group("monsterController", "cooldown", 5, 6)
#		get_tree().call_group("door", "setMonsterDoorTimer", 3)
#
#		get_tree().call_group("audioController", "stop")
#	elif sanityBar.value >= 50 and sanityBar.value < 70:
#		get_tree().call_group("monsterController", "changeDifficulty", 3, 4)
#		get_tree().call_group("monsterController", "cooldown", 4, 5)
#		get_tree().call_group("door", "setMonsterDoorTimer", 2)
#
#		get_tree().call_group("audioController", "play", -10)
#
#	elif sanityBar.value >= 70:
#		get_tree().call_group("monsterController", "changeDifficulty", 4, 2)
#		#get_tree().call_group("monsterController", "cooldown", 2, 5)
#		get_tree().call_group("door", "setMonsterDoorTimer", 1)
#
#		get_tree().call_group("audioController", "play", -9)

func setRecoverValue(value):
	recoverValue = value

func drainSanity(drainValue):
	if not punishmentTime:
		if sanityBar.value < sanityBar.max_value:
			sanityBar.value += drainValue
			get_tree().call_group("monster", "setFaceAnimation", sanityBar.value)
#		else:
#			#pass
#			punishmentTime = true
#			print("punishment time")
#
#			get_tree().call_group("gameMaster", "setGameState", 5)
		

func recoverSanity(value):
	if not isMonsterDraining:
		var tween = create_tween()
		tween.tween_property(sanityBar, "value", sanityBar.value - value, 0.5)
		#sanityBar.value -= value

func setIsDraining(value):
	isMonsterDraining = value

func getSanityBarValue():
	return sanityBar.value

func isPlayerDead():
	if sanityBar.value >= sanityBar.max_value:
		get_tree().call_group("gameMaster", "setGameState", 4)
	return	

func resetSanity():
	sanityBar.value = 0
	punishmentTime = false

	
