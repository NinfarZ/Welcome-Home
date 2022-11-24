extends Control

onready var mainScene = preload("res://House.tscn")


func _on_startButton_pressed():
	get_tree().change_scene_to(mainScene)


func _on_quitButton_pressed():
	get_tree().quit()
