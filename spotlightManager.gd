extends Spatial

var currentOnLight = null

func _ready():
	for light in $lights.get_children():
		light.connect("changeLight", self, "startTimer")

func turnAllLightsOff():
	for light in $lights.get_children():
		light.setState(1)

func turnAllLightsOn():
	for light in $lights.get_children():
		light.setState(0)

func turnOnLight(lightName):
#	for light in $lights.get_children():
#		if light.name == lightName:
#			light.setState(0)
	currentOnLight = $lights.get_node(lightName)
	$lights.get_node(lightName).setState(0)

func startTimer():
	if $lightCoolDown.is_stopped():
		$lightCoolDown.wait_time = RNGTools.randi_range(5, 15)
		$lightCoolDown.start()

func stopTimer():
	if not $lightCoolDown.is_stopped():
		$lightCoolDown.stop()

func pickLight():
	var lightList = $lights.get_children()
	lightList.erase(currentOnLight)
	var newLight = RNGTools.pick(lightList)
	turnOnLight(newLight.name)

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
	currentOnLight.setState(1)
	pickLight()

