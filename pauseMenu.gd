extends Control

var isPaused = false setget setIsPaused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.isPaused = !isPaused 

func setIsPaused(value):
	isPaused = value
	get_tree().paused = isPaused
	visible = isPaused

func _on_resumeButton_pressed():
	self.isPaused = false


func _on_quitButton_pressed():
	get_tree().quit()
