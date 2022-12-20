extends Control

var isPaused = false setget setIsPaused
onready var canvasLayer = get_parent()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.isPaused = !isPaused

func setIsPaused(value):
	isPaused = value
	get_tree().paused = isPaused
	visible = isPaused
	
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$AnimationPlayer.play("writeText")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
	for ui in canvasLayer.get_children():
		if ui != self:
			ui.visible = !isPaused
	

func _on_resumeButton_pressed():
	self.isPaused = false


func _on_quitButton_pressed():
	get_tree().quit()

