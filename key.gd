extends StaticBody

var state = INACTIVE
signal gotKey

enum {
	ACTIVE,
	INACTIVE
}

#func _physics_process(delta):
#
#	match state:
#		ACTIVE:
#			$CollisionShape.disabled = false
#			visible = true
#		INACTIVE:
#			$CollisionShape.disabled = true
#			visible = false

#get key
func interact():
	get_tree().call_group("interact", "addKey")
	$getKey.play()
	setStateInactive()
	emit_signal("gotKey", true)

func setStateActive():
	#state = ACTIVE
	$CollisionShape.disabled = false
	visible = true

func setStateInactive():
	#state = INACTIVE
	$CollisionShape.disabled = true
	visible = false
