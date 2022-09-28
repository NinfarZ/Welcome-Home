extends KinematicBody

enum {
	DEFAULT,
	SEEMONSTER
}
const MOUSE_SENSITIVITY: float = 0.08
const MOVE_SPEED: float = 5.0
const GRAVITY_ACCELERATION: float = 9.8

export(NodePath) var nodePath
export var moveSpeed = 5.0

onready var neck: Spatial = $Neck

var input_move: Vector3 = Vector3()
var gravity_local: Vector3 = Vector3()
var currentLocation = null
var inSpotlight = false
var crouching = false
var flashlightOn = true
var state = DEFAULT

func _ready():
	
	#makes mouse cursor invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#makes player look up/down and left/right
	if event is InputEventMouseMotion:
		rotate_y(deg2rad( -1 * event.relative.x * MOUSE_SENSITIVITY))
		neck.rotate_x(deg2rad(event.relative.y) * MOUSE_SENSITIVITY)
		
		#stop player from looking 360 degrees vertically. Max is 90 degrees
		neck.rotation.x = clamp(neck.rotation.x, deg2rad(-90), deg2rad(90))
		

func _physics_process(delta):
	input_move = get_input_direction() * moveSpeed
	if not is_on_floor():
		gravity_local += GRAVITY_ACCELERATION * Vector3.DOWN * delta
	move_and_slide(input_move + gravity_local, Vector3.UP)
	
	#for raycast in $Neck/Camera.get_children():
		#if raycast.is_colliding():
			#print(raycast.get_collider())
	
	#crouching
	if Input.is_action_just_pressed("crouch") and not crouching:
		$AnimationPlayer.play("crouch")
		moveSpeed = 2.0
		crouching = true
	elif Input.is_action_just_pressed("crouch") and crouching:
		if not $Neck/RayCast.is_colliding():
			$AnimationPlayer.play_backwards("crouch")
			moveSpeed = 5.0
			crouching = false
	
	#flashlightToggle
	if Input.is_action_just_pressed("flashlightToggle") and flashlightOn:
		$Neck/flashlight/SpotLight.visible = false
		flashlightOn = false
		$AnimationPlayer.play("flashlightOFF")
	elif Input.is_action_just_pressed("flashlightToggle") and not flashlightOn:
		$Neck/flashlight/SpotLight.visible = true
		flashlightOn = true
		$AnimationPlayer.play("flashlightON")
		
	
	#recovering sanity
	match state:
		DEFAULT:
			if not inSpotlight:
				get_tree().call_group("sanityBar", "drainSanity", 0.02)
			else:
				get_tree().call_group("sanityBar", "recoverSanity")
		SEEMONSTER:
			pass

func get_input_direction() -> Vector3:
	#
	var z: float = (
		Input.get_action_strength("forward") - Input.get_action_strength("backwards")
	)
	var x: float = (
		Input.get_action_strength("left") - Input.get_action_strength("right")
	)
	
	return transform.basis.xform(Vector3(x, 0, z)).normalized()

func get_position():
	return global_transform.origin


func die():
	$Neck/flashlight/SpotLight.visible = false
	$Neck/flashlight.tweenDownLight()
	$Neck/viewCone/CollisionShape.disabled = true
	#state = DEAD


func get_current_location():
	return currentLocation
	
#func _on_myBedroom_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "my_bedroom"
#		print(currentLocation)
#
#
#func _on_bedRoom2_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "my_bedroom2"
#		print(currentLocation)
#
#
#func _on_balcony_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "balcony"
#		print(currentLocation)
#
#
#func _on_corridor1_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "corridor1"
#		print(currentLocation)
#
#
#func _on_corridor2_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "corridor2"
#		print(currentLocation)
#
#
#
#func _on_livingroom_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "livingroom"
#		print(currentLocation)
#
#
#func _on_entrance_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "entrance"
#		print(currentLocation)
#
#
#func _on_bathroom1_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "bathroom1"
#		print(currentLocation)
#
#
#func _on_kitchen_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "kitchen"
#		print(currentLocation)


#func _on_bedRoom3_body_entered(body):
#	if body.is_in_group("player"):
#		currentLocation = "bedRoom3"
		#print(currentLocation)
	


#func _on_bathroom2_body_entered(body):
	#if body.is_in_group("player"):
		#currentLocation = "bathroom2"
		#print(currentLocation)


#func _on_corridor3_body_entered(body):
	#if body.is_in_group("player"):
		#currentLocation = "corridor3"
		#print(currentLocation)
func setState(newState):
	state = newState

func _on_viewCone_area_entered(area):
	if area.is_in_group("monsterHead"):
		print("player can see monster!")


func _on_viewCone_area_exited(area):
	if area.is_in_group("monsterHead"):
		print("player can NOT see monster!")


#func _on_wardrobe_body_entered(body):
	#currentLocation = "wardrobe"
	#print(currentLocation)


func _on_AreaPlayer_area_entered(area):
	currentLocation = area.name
	#print("PLAYER IS INSIDE " + area.name)
	if area.is_in_group("spotlight"):
		inSpotlight = true


func _on_AreaPlayer_area_exited(area):
	if area.is_in_group("spotlight"):
		inSpotlight = false
