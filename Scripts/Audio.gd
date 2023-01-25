extends Spatial

func play(volume):
	if not $fearNoise.playing:
		$fearNoise.play()
	$fearNoise.volume_db = volume

func stop():
	if $fearNoise.playing:
		$fearNoise.stop()
