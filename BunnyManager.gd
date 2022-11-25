extends Spatial

var bunnyActive = false
var currentBunny = null

var player = null

func _ready():
	yield(owner, "ready")
	player = owner.player

func getDistanceFromPlayer(bunny):
	return bunny.transform.origin.distance_to(player.transform.origin)

func pickBunny():
	var bunnyList = $Bunnies.get_children()
	var bunny = RNGTools.pick(bunnyList)
	while getDistanceFromPlayer(bunny) < 30:
		bunnyList.erase(bunny)
		bunny = RNGTools.pick(bunnyList)
	#bunny.get_node("bunny").setState(0)
	#bunnyList.erase(bunny)
	return bunny

func startTimer():
	$bunnySpawnTimer.start()

func stopTimer():
	$bunnySpawnTimer.stop()

func spawnBunny(currentBunny):
	bunnyActive = true
	currentBunny.get_node("bunny").setActive(true)
	#currentBunny.get_node("bunny").displayText(candyAmount)
	currentBunny.get_node("bunny").playMusicBox()

func playBunnyMusicBox(bunny):
	bunny.get_node("bunny").playMusicBox()

func despawnBunny(currentBunny):
	bunnyActive = false
	currentBunny.get_node("bunny").stopMusicBox()
	#yield(get_tree().create_timer(1),"timeout")
	startTimer()
	currentBunny.get_node("bunny").setActive(false)


func _on_bunnySpawnTimer_timeout():
	var bunnyList = $Bunnies.get_children()
	currentBunny = RNGTools.pick(bunnyList)
	spawnBunny(currentBunny)
	currentBunny.get_node("bunny").playMusicBox()
