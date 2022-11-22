extends Spatial

var currentOnLight = null
var availableLightsList = []
var invisibleEnemy = null
var player = null

func _ready():
	for light in $lights.get_children():
		light.connect("changeLight", self, "startTimer")
	
	yield(owner, "ready")
	invisibleEnemy = owner.invisibleEnemy
	player = owner.player

func _physics_process(delta):
	if currentOnLight != null and invisibleEnemy.get_current_location() != null:
		if currentOnLight.is_in_group(invisibleEnemy.get_current_location()) and not invisibleEnemy.getState() == 1:
			turnOffLight(currentOnLight.name)
			startTimer()
		elif currentOnLight.getIsPlayerInside():
			get_tree().call_group("sanityBar", "recoverSanity", 0.5)

func turnAllLightsOff():
	for light in $lights.get_children():
		light.disableLight()

func turnAllLightsOn():
	for light in $lights.get_children():
		light.enableLight()

func turnOnLight(lightName):
#	for light in $lights.get_children():
#		if light.name == lightName:
#			light.setState(0)
	currentOnLight = $lights.get_node(lightName)
	$lights.get_node(lightName).enableLight()

func turnOffLight(lightName):
	$lights.get_node(lightName).disableLight()
	currentOnLight = null

func startTimer():
	if $lightCoolDown.is_stopped():
		if currentOnLight != null:
			turnOffLight(currentOnLight.name)
		$lightCoolDown.wait_time = RNGTools.randi_range(5, 15)
		$lightCoolDown.start()

func stopTimer():
	if not $lightCoolDown.is_stopped():
		$lightCoolDown.stop()

func getCurrentLight():
	return currentOnLight

func pickLight():
	var lightList = $lights.get_children()
	lightList.erase(currentOnLight)
	var newLight = RNGTools.pick(lightList)
	while not canLightSpawn(newLight):
		lightList.erase(newLight)
		newLight = RNGTools.pick(lightList)
	turnOnLight(newLight.name)

func canLightSpawn(light):
	if not light.is_in_group(player.get_current_location()) and not light.is_in_group(invisibleEnemy.get_current_location()):
		return true
	return false

#Not every area of the house can be reached sometimes. This removes the unreachable lights by changing the light list
func eraseOutOfReachLights(lightArray):
	if lightArray == []:
		availableLightsList = $lights.get_children()
	elif lightArray != []:
		for light in lightArray:
			availableLightsList.erase(light)

#func shutDownLight(currentLight, isTimeOver):
#	if isTimeOver:
#		currentLight.setState(1)
#		$lightCoolDown.wait_time = RNGTools.randi_range(10, 20)
#		$lightCoolDown.start()
#		#pickLight()
#	elif $Navigation/invisibleEnemy.get_current_location() in currentLight.get_groups():
#		#get_tree().call_group("LIGHT" + currentLocation, "setState", 1)
#		currentLight.setState(1)
#		$lightCoolDown.wait_time = RNGTools.randi_range(5, 10)
#		$lightCoolDown.start()
#		#pickLight()


func _on_lightCoolDown_timeout():
	#eraseOutOfReachLights([])
	#currentOnLight.setState(1)
	pickLight()

