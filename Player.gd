extends KinematicBody

enum {
	DEFAULT,
	SEEMONSTER
}
const MOUSE_SENSITIVITY: float = 0.08
const MOVE_SPEED: float = 5.0
const GRAVITY_ACCELERATION: float = 5.8



export(NodePath) var nodePath
export var moveSpeed = 5.0
export var sprintSpeed = 5.0

onready var neck: Spatial = $Neck

var invisibleEnemy = null

var input_move: Vector3 = Vector3()
var gravity_local: Vector3 = Vector3()
var currentLocation = null
var inSpotlight = false
var crouching = false
var flashlightOn = true
var drainSanityValue = 0.013
var state = DEFAULT
var isUnderFurniture = false
var playerCanRun = true
var stamina = 100
var isRunning = false

func _ready():
	yield(owner, "ready")
	invisibleEnemy = owner.invisibleEnemy
	
	#makes mouse cursor invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	invisibleEnemy.connect("killPlayer", self, "die")
	toggleFlashlight(false)
	
	#CONNECT INVISIBLE ENEMY KILL SIGNAL

func _input(event):
	#makes player look up/down and left/right
	if event is InputEventMouseMotion:
		rotate_y(deg2rad( -1 * event.relative.x * MOUSE_SENSITIVITY))
		neck.rotate_x(deg2rad(event.relative.y) * MOUSE_SENSITIVITY)
		
		#stop player from looking 360 degrees vertically. Max is 90 degrees
		neck.rotation.x = clamp(neck.rotation.x, deg2rad(-90), deg2rad(90))
		

func _physics_process(delta):
	input_move = get_input_direction() * moveSpeed
	
	if not input_move == Vector3(0,0,0) and not crouching:
		if moveSpeed == 3.2:
			if not $Audio/walk.playing:
				$Audio/running.stop()
				$Audio/walk.play()
		elif moveSpeed == sprintSpeed:
			if not $Audio/running.playing:
				$Audio/walk.stop()
				$Audio/running.play()
			isRunning = false
			
				
	else:
		isRunning = false
		$Audio/walk.stop()
		$Audio/running.stop()
		
	if not is_on_floor():
		gravity_local += GRAVITY_ACCELERATION * Vector3.DOWN * delta
	
	
	#for raycast in $Neck/Camera.get_children():
		#if raycast.is_colliding():
			#print(raycast.get_collider())
	
	#crouching
	if Input.is_action_just_pressed("crouch") and not crouching:
		$AnimationPlayer.play("crouch")
		moveSpeed = 1.5
		crouching = true
	elif Input.is_action_just_pressed("crouch") and crouching:
		if not $RayCast.is_colliding():
			$AnimationPlayer.play_backwards("crouch")
			moveSpeed = 3.2
			crouching = false
	
	#running
	
	if Input.is_action_pressed("run") and not crouching:
		if playerCanRun:
			isRunning = true
			moveSpeed = sprintSpeed
				
			stamina -= 0.4 
			stamina = clamp(stamina, 0, 100)
			if stamina == 0:
				playerCanRun = false
				isRunning = false
				moveSpeed = 3.2
	elif Input.is_action_just_released("run") and not crouching:
		moveSpeed = 3.2
		
	elif not playerCanRun:
		if stamina == 100:
			playerCanRun = true
	
	if not isRunning or not playerCanRun:
		stamina += 0.3 
		stamina = clamp(stamina, 0, 100)
	
	move_and_slide(input_move + gravity_local, Vector3.UP)
	

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

func toggleFlashlight(power):
	if not power:
		$Neck/flashlight/SpotLight.visible = false
		flashlightOn = false
		$AnimationPlayer.play("flashlightOFF")
	elif power:
		$Neck/flashlight/SpotLight.visible = true
		flashlightOn = true
		$AnimationPlayer.play("flashlightON")

func getFlashlightPower():
	return flashlightOn
	
func die():
	$Neck/flashlight/SpotLight.visible = false
	$Neck/flashlight.tweenDownLight()
	$Neck/viewCone/CollisionShape.disabled = true
	
	$Neck/Camera/Head.headJumpscare()
	#state = DEAD

func setDrainSanity(drainValue):
	drainSanityValue = drainValue


func get_current_location():
	return currentLocation
	
func setState(newState):
	state = newState


func _on_AreaPlayer_area_entered(area):
	currentLocation = area.name


func _on_AreaPlayer_area_exited(area):
		pass

func setIsUnderFurniture(value):
	isUnderFurniture = value

func getDoorOpeningForce():
	var doorForce
	if input_move == Vector3(0,0,0):
		doorForce = 2
	elif moveSpeed == 3.2:
		doorForce = 1
	elif moveSpeed == sprintSpeed:
		doorForce = 0.5
	elif moveSpeed == 1.5:
		doorForce = 1.5
	
		
	return doorForce

func getIsUnderFurniture():
	return isUnderFurniture
