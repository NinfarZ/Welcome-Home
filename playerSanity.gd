extends Control

onready var sanityBar = $MarginContainer2/ProgressBar

signal sanityThreshold(value)

enum {
	LOW,
	MEDIUM,
	HIGH
}

var fear = null
var isSignalEmited = false
var recoverValue = 0.09
var punishmentTime = false
var isMonsterDraining = false
onready var heartbeat = get_parent().get_parent().get_node("Audio/heartbeat")

func _physics_process(delta):
	var tween = create_tween()
	if sanityBar.value > 50:
		tween.tween_property(sanityBar, "self_modulate", Color(0.92, 0.41, 0.35), 5.0)

		#$ProgressBar.self_modulate = Color(0.92, 0.41, 0.35)
	elif sanityBar.value <= 50:
		tween.tween_property(sanityBar, "self_modulate", Color(1.00, 0.91, 0.92), 5.0)
		

func setRecoverValue(value):
	recoverValue = value

func drainSanity(drainValue):
	if not punishmentTime:
		if sanityBar.value < sanityBar.max_value:
			sanityBar.value += drainValue
			get_tree().call_group("monster", "setFaceAnimation", sanityBar.value)
#

func recoverSanity(value):
	if not isMonsterDraining:

		sanityBar.value -= value

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

	





func _on_ProgressBar_value_changed(value):
	if value == 0:
		if not fear == null:
			fear = null
	elif value < 50 and value > 0:
		if not fear == LOW:
			var tween = create_tween()
			fear = LOW
			emit_signal("sanityThreshold", fear)
			get_tree().call_group("monsterSpawner", "setSpawnAreaRadius", fear)
			get_tree().call_group("flashlight", "changeLightColor", Color(0.77,0,1.0))
			tween.tween_property(heartbeat, "volume_db", -80.0, 5.0)
			
	elif value >= 50 and value < 70:
		if not fear == MEDIUM:
			var tween = create_tween()
			fear = MEDIUM
			emit_signal("sanityThreshold", fear)
			get_tree().call_group("monsterSpawner", "setSpawnAreaRadius", fear)
			get_tree().call_group("flashlight", "changeLightColor", Color(0.8,0.19,0.19))
			heartbeat.play()
			tween.tween_property(heartbeat, "volume_db", -4.0, 3.0)
			
	elif value >= 70:
		if not fear == HIGH:
			fear = HIGH
			emit_signal("sanityThreshold", fear)
			
