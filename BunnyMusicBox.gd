extends Spatial

#enum {
#	ACTIVE,
#	INACTIVE
#}


#var state = INACTIVE
var isActive = false
var isDeadly = false
var isMusicBoxFinished = false

func _ready():
	get_parent().visible = false
	$CollisionShape.disabled = true

#func _physics_process(delta):
#	match state:
#		ACTIVE:
#			get_parent().visible = true
#			$CollisionShape.disabled = false
#		INACTIVE:
#			get_parent().visible = false
#			$CollisionShape.disabled = true

#plays music box
func playMusicBox():
	get_parent().get_node("AudioStreamPlayer3D").play()

func stopMusicBox():
	get_parent().get_node("AudioStreamPlayer3D").stop()

func interact():
	#animate and add sound
	stopMusicBox()
	setActive(false)
#	get_tree().call_group("gameMaster", "startBunnyTimer")

func setActive(active):
	if active:
		get_parent().visible = true
		$CollisionShape.disabled = false
		isDeadly = true
		isMusicBoxFinished = false
	else:
		get_parent().visible = false
		$CollisionShape.disabled = true
		isDeadly = false

func getIsMusicBoxFinished():
	return isMusicBoxFinished
		

func getIsActive():
	return isActive

func _on_AudioStreamPlayer3D_finished():
	if isDeadly:
		setActive(false)
		get_tree().call_group("gameMaster", "setPunishmentTimer", RNGTools.randi_range(15, 30))
		get_tree().call_group("gameMaster", "setGameState", 5)
		get_tree().call_group("invisibleEnemy", "setStateChase")
	isMusicBoxFinished = true
	
