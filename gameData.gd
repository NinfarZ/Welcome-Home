extends Node


var skipIntro = false setget setSkipIntro, getSkipIntro
var canPauseGame = true setget setCanPauseGame, getCanPauseGame

func setSkipIntro(value):
	skipIntro = value

func getSkipIntro():
	return skipIntro

func setCanPauseGame(value):
	canPauseGame = value

func getCanPauseGame():
	return canPauseGame
