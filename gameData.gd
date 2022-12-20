extends Node

var deathMusic = load("res://audio/deathJumpscare.wav")
var skipIntro = false setget setSkipIntro, getSkipIntro
var canPauseGame = true setget setCanPauseGame, getCanPauseGame
var isPlayerDead = false setget setIsPlayerDead, getIsPlayerDead

func setSkipIntro(value):
	skipIntro = value

func getSkipIntro():
	return skipIntro

func setCanPauseGame(value):
	canPauseGame = value

func getCanPauseGame():
	return canPauseGame

func setIsPlayerDead(isDead):
	isPlayerDead = isDead

func getIsPlayerDead():
	return isPlayerDead

func playDeathMusic():
	$deathMusic.stream = deathMusic
	$deathMusic.play()
	var tween = create_tween()
	tween.tween_property($deathMusic, "volume_db", -20, 5.0)


func _on_deathMusic_finished():
	setIsPlayerDead(false)
	get_tree().change_scene("res://Menu.tscn")
