extends Spatial

var bunnyActive = false

func pickBunny():
	var bunnyList = get_children()
	var bunny = RNGTools.pick(bunnyList)
	#bunny.get_node("bunny").setState(0)
	#bunnyList.erase(bunny)
	return bunny

func spawnBunny(currentBunny):
	bunnyActive = true
	currentBunny.get_node("bunny").setState(0)
	#currentBunny.get_node("bunny").displayText(candyAmount)
	currentBunny.get_node("bunny").playMusicBox()

func despawnBunny(currentBunny):
	bunnyActive = false
	currentBunny.get_node("bunny").stopMusicBox()
	#yield(get_tree().create_timer(1),"timeout")
	currentBunny.get_node("bunny").setState(1)
